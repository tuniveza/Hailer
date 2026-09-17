local ADDON_NAME, ns = ...

--------------------------------------------------------------------
-- In-game Friends + Battle.net Friends "comes online" watcher.
--
-- There is no chat channel for a friends list, so this scope only
-- ever whispers (see ns.WHISPER_ONLY_SCOPES in Core.lua).
--------------------------------------------------------------------

local knownOnline = {}
local initialized = false

local function Snapshot()
	local newlyOnline = {}

	local numBNet = BNGetNumFriends and BNGetNumFriends() or 0
	for i = 1, numBNet do
		local accountInfo = C_BattleNet.GetFriendAccountInfo(i)
		if accountInfo and accountInfo.bnetAccountID then
			local key = "bnet:" .. accountInfo.bnetAccountID
			local online = accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.isOnline
			if online then
				if initialized and not knownOnline[key] then
					table.insert(newlyOnline, accountInfo.accountName or "Someone")
				end
				knownOnline[key] = true
			else
				knownOnline[key] = false
			end
		end
	end

	local numFriends = C_FriendList and C_FriendList.GetNumFriends and C_FriendList.GetNumFriends() or 0
	for i = 1, numFriends do
		local info = C_FriendList.GetFriendInfoByIndex(i)
		if info and info.name then
			local key = "friend:" .. info.name
			if info.connected then
				if initialized and not knownOnline[key] then
					table.insert(newlyOnline, info.name)
				end
				knownOnline[key] = true
			else
				knownOnline[key] = false
			end
		end
	end

	if not initialized then
		initialized = true
	else
		for _, name in ipairs(newlyOnline) do
			ns:SendGreeting("friends", name, name)
		end
	end
end

function ns:InitFriends()
	Snapshot()
end

local pending = false
local function OnFriendsEvent()
	if pending then
		return
	end
	pending = true
	C_Timer.After(1.0, function()
		pending = false
		Snapshot()
	end)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("FRIENDLIST_UPDATE")
frame:RegisterEvent("BN_FRIEND_INFO_CHANGED")
frame:SetScript("OnEvent", function()
	if not HailerDB then
		return
	end
	OnFriendsEvent()
end)
