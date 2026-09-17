local ADDON_NAME, ns = ...

--------------------------------------------------------------------
-- Cross-client "only one guildmate greets" election.
--
-- When several guildmates are all running Hailer, each of their clients
-- independently notices the same person coming online. Without talking to
-- each other they'd all send a greeting at once. Instead, when a client
-- decides it WOULD greet, it broadcasts a random "claim" number for that
-- member over the addon-message channel (guild-only, invisible to players
-- without Hailer) and waits a couple of seconds. Whoever holds the highest
-- claim once the window closes is the one who actually sends the greeting;
-- everyone else stays quiet.
--------------------------------------------------------------------

local PREFIX = "HAILERSYNC1"
local ELECTION_WINDOW = 2.5

ns.GuildSync = {}
local GuildSync = ns.GuildSync

local pending = {} -- guid -> { bestRoll, bestSender, args = {scopeKey, targetFullName, displayName, extra, subKey} }
local registered = false

function GuildSync:Init()
	-- Prefix registration does not survive /reload, so this re-registers
	-- every login.
	if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
		C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
		registered = true
	end
end

function GuildSync:StartElection(scopeKey, targetFullName, displayName, extra, subKey)
	local guid = extra and extra.guid
	if not registered or not guid or not IsInGuild() then
		ns:DispatchGreeting(scopeKey, targetFullName, displayName, extra, subKey)
		return
	end

	if pending[guid] then
		-- Already running an election for this person; let it finish.
		return
	end

	local myRoll = math.random(1, 1000000000)
	local myName = Ambiguate and Ambiguate(UnitName("player"), "short") or UnitName("player")

	pending[guid] = {
		bestRoll = myRoll,
		bestSender = myName,
		args = { scopeKey, targetFullName, displayName, extra, subKey },
	}

	C_ChatInfo.SendAddonMessage(PREFIX, "CLAIM:" .. guid .. ":" .. myRoll, "GUILD")

	C_Timer.After(ELECTION_WINDOW, function()
		local entry = pending[guid]
		pending[guid] = nil
		if entry and entry.bestSender == myName then
			ns:DispatchGreeting(unpack(entry.args))
		end
	end)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:SetScript("OnEvent", function(_, event, prefix, text, channel, sender)
	if prefix ~= PREFIX then
		return
	end
	local guid, rollStr = text:match("^CLAIM:([^:]+):(%d+)$")
	if not guid then
		return
	end
	local entry = pending[guid]
	if not entry then
		return
	end

	local roll = tonumber(rollStr)
	local shortSender = Ambiguate and Ambiguate(sender, "short") or sender
	if roll > entry.bestRoll or (roll == entry.bestRoll and shortSender < entry.bestSender) then
		entry.bestRoll = roll
		entry.bestSender = shortSender
	end
end)
