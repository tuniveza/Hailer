local ADDON_NAME, ns = ...

--------------------------------------------------------------------
-- Best-effort custom chat channel watcher
--
-- WoW does not fire an event when another player joins a public or
-- custom chat channel (only when *you* join/leave one), so there is
-- no reliable way to detect a "join" here. Instead this watches
-- configured channels and greets the first message it sees from a
-- given name each session -- an approximation, not a true join
-- detector. It intentionally resets every login/reload.
--------------------------------------------------------------------

local seenInChannel = {} -- channelBaseName -> { [senderName] = true }

local function NormalizeWatchName(name)
	if not name then
		return nil
	end
	return name:lower():gsub("^%s+", ""):gsub("%s+$", "")
end
ns.NormalizeWatchName = NormalizeWatchName

local function IsWatched(channelBaseName)
	local scope = HailerDB and HailerDB.scopes.custom
	if not scope or not scope.watchList then
		return false
	end
	local norm = NormalizeWatchName(channelBaseName)
	return norm ~= nil and scope.watchList[norm] ~= nil
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_CHANNEL")
frame:SetScript("OnEvent", function(_, event, text, senderName, languageName, channelName, _, _, _, channelIndex, channelBaseName)
	if not HailerDB then
		return
	end
	local scope = HailerDB.scopes.custom
	if not scope or not scope.enabled then
		return
	end
	if not IsWatched(channelBaseName) then
		return
	end

	local shortName = (Ambiguate and Ambiguate(senderName, "short")) or senderName
	if shortName == UnitName("player") then
		return
	end

	local seen = seenInChannel[channelBaseName]
	if not seen then
		seen = {}
		seenInChannel[channelBaseName] = seen
	end
	if seen[senderName] then
		return
	end
	seen[senderName] = true

	ns:SendGreeting("custom", senderName, shortName, { channelIndex = channelIndex })
end)

function ns:ResetChannelScan()
	wipe(seenInChannel)
end
