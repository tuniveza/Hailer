local ADDON_NAME, ns = ...

--------------------------------------------------------------------
-- Blizzard Community ("Club") online/join watcher
--
-- Guild chat is itself backed by a Club under the hood, so any club
-- whose clubType is Guild is skipped here -- that case is already
-- handled by the dedicated guild-roster watcher in Core.lua.
--------------------------------------------------------------------

local presenceCache = {} -- "clubId:memberId" -> isOnline (bool)
local initializedClubs = {} -- clubId -> true once a baseline snapshot has been taken

local function IsCommunityClub(clubInfo)
	return clubInfo ~= nil and clubInfo.clubType ~= Enum.ClubType.Guild
end

local function InitClubBaseline(clubId)
	local members = C_Club.GetClubMembers(clubId)
	if members then
		for _, memberId in ipairs(members) do
			local info = C_Club.GetMemberInfo(clubId, memberId)
			if info then
				presenceCache[clubId .. ":" .. memberId] = info.isOnline and true or false
			end
		end
	end
	initializedClubs[clubId] = true
end

local function ForEachCommunityClub(callback)
	if not C_Club then
		return
	end
	local clubs = C_Club.GetSubscribedClubs()
	if not clubs then
		return
	end
	for _, club in ipairs(clubs) do
		if IsCommunityClub(club) then
			callback(club.clubId)
		end
	end
end

function ns:InitCommunities()
	ForEachCommunityClub(InitClubBaseline)
end

local function IsSelf(clubId, info)
	local selfInfo = C_Club.GetMemberInfoForSelf and C_Club.GetMemberInfoForSelf(clubId)
	return selfInfo and info.memberId == selfInfo.memberId
end

local function HandleMemberAdded(clubId, memberId)
	local scope = HailerDB and HailerDB.scopes.community
	if not scope or not scope.enabled then
		return
	end
	local clubInfo = C_Club.GetClubInfo(clubId)
	if not IsCommunityClub(clubInfo) then
		return
	end
	local info = C_Club.GetMemberInfo(clubId, memberId)
	if not info or IsSelf(clubId, info) then
		return
	end

	presenceCache[clubId .. ":" .. memberId] = info.isOnline and true or false
	local name = info.name or "Someone"
	ns:SendGreeting("community", name, name)
end

local function HandlePresenceUpdate(clubId, memberId)
	local scope = HailerDB and HailerDB.scopes.community
	if not scope or not scope.enabled then
		return
	end
	local clubInfo = C_Club.GetClubInfo(clubId)
	if not IsCommunityClub(clubInfo) then
		return
	end

	if not initializedClubs[clubId] then
		InitClubBaseline(clubId)
		return
	end

	local info = C_Club.GetMemberInfo(clubId, memberId)
	if not info or IsSelf(clubId, info) then
		return
	end

	local key = clubId .. ":" .. memberId
	local wasOnline = presenceCache[key]
	local isOnline = info.isOnline and true or false
	presenceCache[key] = isOnline

	if isOnline and not wasOnline then
		local name = info.name or "Someone"
		ns:SendGreeting("community", name, name)
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("CLUB_MEMBER_ADDED")
frame:RegisterEvent("CLUB_MEMBER_PRESENCE_UPDATED")
frame:SetScript("OnEvent", function(_, event, clubId, memberId)
	if not C_Club or not HailerDB then
		return
	end
	if event == "CLUB_MEMBER_ADDED" then
		HandleMemberAdded(clubId, memberId)
	elseif event == "CLUB_MEMBER_PRESENCE_UPDATED" then
		HandlePresenceUpdate(clubId, memberId)
	end
end)
