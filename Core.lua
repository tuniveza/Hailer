local ADDON_NAME, ns = ...

ns.ADDON_NAME = ADDON_NAME
ns.VERSION = "1.1.0"

--------------------------------------------------------------------
-- Defaults
--------------------------------------------------------------------

ns.scopeOrder = { "party", "instance", "guild", "community", "custom", "friends" }

-- Scopes that have no real chat channel to post into (protected API, or no
-- channel exists at all) -- these can only ever whisper.
ns.WHISPER_ONLY_SCOPES = { community = true, friends = true }

ns.PRESET_MESSAGES = {
	"Ahoy, {name}! Welcome aboard!",
	"Welcome to the crew, {name}!",
	"Land ho! Great to have you here, {name}!",
	"Batten down the hatches, {name} just joined!",
	"Welcome, {name}! Make yourself at home.",
	"A warm welcome to {name}!",
	"Everyone say hi to {name}!",
	"Welcome back, {name}! Good to see you.",
	"{name} has sailed back into port. Welcome back!",
	"Ahoy {name}, glad you're here!",
	"Welcome, {name} the {class}!",
	"Fair winds, {name}! Welcome.",
	"Smooth sailing, {name}! Glad to have you.",
	"Dock the ship, {name} is here!",
}

local function NewTriggerConfig(enabled, chance, announceOn, announceMsgs, whisperOn, whisperMsgs)
	return {
		enabled = enabled,
		chance = chance,
		announce = { enabled = announceOn, messages = announceMsgs },
		whisper = { enabled = whisperOn, messages = whisperMsgs },
	}
end

-- Quiet by default: out of the box, Hailer only welcomes brand new guild
-- members ("guild invites"). Every other scope -- and the guild "came back
-- online" trigger -- is off until explicitly switched on in the GUI.
local DEFAULTS = {
	minimap = {
		hide = false,
		pos = 220,
	},
	ignoreList = {},
	knownGuildGUIDs = {},
	scopes = {
		party = {
			label = "Party / Raid",
			enabled = false,
			cooldown = 300,
			chance = 100,
			announce = { enabled = true, messages = { "Welcome to the group, {name}! o/" } },
			whisper = { enabled = false, messages = { "Hey {name}, welcome to the group!" } },
		},
		instance = {
			label = "Instance Group (Dungeon/Raid/M+)",
			enabled = false,
			cooldown = 300,
			chance = 100,
			announce = { enabled = false, messages = { "Welcome aboard, {name}! Good luck out there." } },
			whisper = { enabled = false, messages = { "Welcome aboard, {name}! Good luck out there." } },
		},
		guild = {
			label = "Guild",
			enabled = true,
			cooldown = 1800,
			triggers = {
				newMember = NewTriggerConfig(
					true, 100,
					true, { "Everyone welcome {name} to the guild!" },
					true, { "Welcome to the guild, {name}! Let us know if you have any questions." }
				),
				online = NewTriggerConfig(
					false, 60,
					false, { "Ahoy, {name} has sailed back into port!" },
					false, { "Welcome back, {name}!" }
				),
			},
		},
		community = {
			label = "Communities",
			enabled = false,
			cooldown = 900,
			chance = 70,
			announce = { enabled = false, messages = { "Welcome, {name}! Glad to have you here." } },
			whisper = { enabled = false, messages = { "Welcome to the community, {name}!" } },
		},
		custom = {
			label = "Custom Channels",
			enabled = false,
			cooldown = 900,
			chance = 50,
			watchList = {},
			announce = { enabled = true, messages = { "Ahoy {name}, welcome!" } },
			whisper = { enabled = false, messages = { "Ahoy {name}, welcome!" } },
		},
		friends = {
			label = "Friends",
			enabled = false,
			cooldown = 1200,
			chance = 70,
			announce = { enabled = false, messages = { "Ahoy {name}, good to see you online!" } },
			whisper = { enabled = false, messages = { "Ahoy {name}, good to see you online!" } },
		},
	},
}
ns.DEFAULTS = DEFAULTS
DEFAULTS.scopes.guild.triggers.online.coordinate = true

local function IsArray(t)
	return t[1] ~= nil
end

-- Array-shaped defaults (message pools) are only copied in wholesale when
-- the key is entirely missing (a fresh install, or an upgrade adding a new
-- field) -- they are never merged index-by-index. Otherwise emptying out a
-- message pool in the GUI would have the default message quietly reappear
-- on the next login.
local function ApplyDefaults(dst, src)
	for k, v in pairs(src) do
		if type(v) == "table" then
			if IsArray(v) then
				if dst[k] == nil then
					local copy = {}
					for i, item in ipairs(v) do
						copy[i] = item
					end
					dst[k] = copy
				end
			else
				if type(dst[k]) ~= "table" then
					dst[k] = {}
				end
				ApplyDefaults(dst[k], v)
			end
		elseif dst[k] == nil then
			dst[k] = v
		end
	end
end
ns.ApplyDefaults = ApplyDefaults

--------------------------------------------------------------------
-- Message formatting
--------------------------------------------------------------------

local function PickMessage(pool)
	if not pool or #pool == 0 then
		return nil
	end
	return pool[math.random(#pool)]
end
ns.PickMessage = PickMessage

local function FormatMsg(msg, name, extra)
	extra = extra or {}
	msg = msg:gsub("{name}", name)
	msg = msg:gsub("%%s", name)
	if extra.classFile then
		local color = C_ClassColor and C_ClassColor.GetClassColor(extra.classFile)
		local classText = extra.className or extra.classFile
		if color then
			classText = color:WrapTextInColorCode(classText)
		end
		msg = msg:gsub("{class}", classText)
	else
		msg = msg:gsub("{class}", "")
	end
	msg = msg:gsub("{level}", extra.level and tostring(extra.level) or "")
	return msg
end
ns.FormatMsg = FormatMsg

--------------------------------------------------------------------
-- Outgoing chat queue (avoids chat spam-throttle when many join at once)
--------------------------------------------------------------------

local chatQueue = {}
local queueTicker

local function ProcessQueue()
	local item = table.remove(chatQueue, 1)
	if not item then
		queueTicker:Cancel()
		queueTicker = nil
		return
	end
	if item.chatType == "CHANNEL" then
		SendChatMessage(item.msg, "CHANNEL", nil, item.channelIndex)
	else
		SendChatMessage(item.msg, item.chatType, nil, item.target)
	end
end

local function QueueChatMessage(msg, chatType, target, channelIndex)
	table.insert(chatQueue, {
		msg = msg,
		chatType = chatType,
		target = target,
		channelIndex = channelIndex,
	})
	if not queueTicker then
		ProcessQueue()
		queueTicker = C_Timer.NewTicker(1.1, ProcessQueue)
	end
end
ns.QueueChatMessage = QueueChatMessage

--------------------------------------------------------------------
-- Ignore list
--------------------------------------------------------------------

local function IsIgnored(targetFullName, displayName)
	local list = HailerDB.ignoreList
	if not list then
		return false
	end
	local a, b = targetFullName and targetFullName:lower(), displayName and displayName:lower()
	for name in pairs(list) do
		local n = name:lower()
		if n == a or n == b then
			return true
		end
	end
	return false
end

--------------------------------------------------------------------
-- Greeting dispatch
--
-- scopeKey routes which chat channel a public announcement goes to.
-- subKey (only used by "guild" right now) selects which trigger inside
-- a scope fired -- e.g. a brand new guild member vs. one just coming
-- back online -- each with its own enable/messages/chance.
--------------------------------------------------------------------

local lastGreeted = {}

function ns:SendGreeting(scopeKey, targetFullName, displayName, extra, subKey)
	local scopeCfg = HailerDB.scopes[scopeKey]
	if not scopeCfg or not scopeCfg.enabled then
		return
	end

	local trigger = (subKey and scopeCfg.triggers and scopeCfg.triggers[subKey]) or scopeCfg
	if not trigger or not trigger.enabled then
		return
	end

	if IsIgnored(targetFullName, displayName) then
		return
	end

	local cooldownKey = scopeKey .. (subKey and (":" .. subKey) or "") .. ":" .. (targetFullName or displayName or "")
	local baseCooldown = scopeCfg.cooldown or 300
	-- Jittered so greets don't land on a perfectly predictable timer.
	local effectiveCooldown = baseCooldown * (0.85 + math.random() * 0.3)
	local last = lastGreeted[cooldownKey]
	if last and (GetTime() - last) < effectiveCooldown then
		return
	end

	local chance = trigger.chance or 100
	if chance < 100 and math.random(1, 100) > chance then
		return
	end

	-- This client has decided it WOULD greet -- consume the cooldown now so
	-- a suppressed (lost election) attempt doesn't retry immediately.
	lastGreeted[cooldownKey] = GetTime()
	extra = extra or {}

	if trigger.coordinate and extra.guid and IsInGuild() and ns.GuildSync then
		ns.GuildSync:StartElection(scopeKey, targetFullName, displayName, extra, subKey)
	else
		ns:DispatchGreeting(scopeKey, targetFullName, displayName, extra, subKey)
	end
end

-- The actual chat send. Only call this once a greet has already been
-- decided (cooldown/chance/ignore-list already checked by SendGreeting, and
-- -- for coordinated triggers -- the cross-client election already won).
function ns:DispatchGreeting(scopeKey, targetFullName, displayName, extra, subKey)
	local scopeCfg = HailerDB.scopes[scopeKey]
	local trigger = (subKey and scopeCfg.triggers and scopeCfg.triggers[subKey]) or scopeCfg
	extra = extra or {}

	-- Community/Friends chat cannot be posted to from an addon (no public
	-- channel exists, or the send API is protected and only works in direct
	-- response to a hardware event) -- those scopes only ever whisper.
	if not ns.WHISPER_ONLY_SCOPES[scopeKey] and trigger.announce.enabled then
		local msg = PickMessage(trigger.announce.messages)
		if msg then
			local text = FormatMsg(msg, displayName, extra)
			if scopeKey == "guild" then
				QueueChatMessage(text, "GUILD")
			elseif scopeKey == "custom" then
				if extra.channelIndex then
					QueueChatMessage(text, "CHANNEL", nil, extra.channelIndex)
				end
			else
				QueueChatMessage(text, IsInRaid() and "RAID" or "PARTY")
			end
		end
	end

	if trigger.whisper.enabled then
		local msg = PickMessage(trigger.whisper.messages)
		if msg then
			QueueChatMessage(FormatMsg(msg, displayName, extra), "WHISPER", targetFullName)
		end
	end

	if ns.PlayGreetSplash then
		ns:PlayGreetSplash()
	end
end

--------------------------------------------------------------------
-- Party / Raid / Instance-group roster watcher
--------------------------------------------------------------------

local knownRosterGUIDs = {}
local rosterInitialized = false

local function GetGroupUnits()
	local units = {}
	if IsInRaid() then
		for i = 1, GetNumGroupMembers() do
			units[#units + 1] = "raid" .. i
		end
	elseif IsInGroup() then
		units[#units + 1] = "player"
		for i = 1, GetNumGroupMembers() - 1 do
			units[#units + 1] = "party" .. i
		end
	end
	return units
end

local function UpdateRoster()
	if not IsInGroup() then
		wipe(knownRosterGUIDs)
		rosterInitialized = false
		return
	end

	local units = GetGroupUnits()
	local currentGUIDs = {}
	local newUnits = {}

	for _, unit in ipairs(units) do
		local guid = UnitGUID(unit)
		if guid then
			currentGUIDs[guid] = true
			if rosterInitialized and not knownRosterGUIDs[guid] and not UnitIsUnit(unit, "player") then
				newUnits[#newUnits + 1] = unit
			end
		end
	end

	if not rosterInitialized then
		-- First observation of this group: record the baseline, don't greet anyone yet.
		rosterInitialized = true
	else
		for _, unit in ipairs(newUnits) do
			local name, realm = UnitName(unit)
			if name then
				local fullName = (realm and realm ~= "") and (name .. "-" .. realm) or name
				local inInstance = IsInInstance()
				local scopeKey = inInstance and "instance" or "party"
				local className, classFile = UnitClass(unit)
				local level = UnitLevel(unit)
				ns:SendGreeting(scopeKey, fullName, name, {
					classFile = classFile,
					className = className,
					level = level,
				})
			end
		end
	end

	knownRosterGUIDs = currentGUIDs
end

local rosterPending = false
local function OnRosterEvent()
	if rosterPending then
		return
	end
	rosterPending = true
	C_Timer.After(0.6, function()
		rosterPending = false
		UpdateRoster()
	end)
end

--------------------------------------------------------------------
-- Guild watcher: distinguishes a brand new guild member from an
-- existing member simply coming back online, as two separate triggers.
--------------------------------------------------------------------

local knownGuildOnline = {}
local guildInitialized = false

local function UpdateGuildRoster()
	if not IsInGuild() then
		wipe(knownGuildOnline)
		guildInitialized = false
		return
	end

	local numMembers = GetNumGuildMembers and GetNumGuildMembers() or 0
	if numMembers == 0 then
		return
	end

	local newlyOnline = {}

	for i = 1, numMembers do
		local name, _, _, level, className, _, _, _, online, _, classFile, _, _, _, _, _, guid = GetGuildRosterInfo(i)
		if guid then
			if online then
				if guildInitialized and not knownGuildOnline[guid] then
					newlyOnline[#newlyOnline + 1] = {
						name = name,
						level = level,
						className = className,
						classFile = classFile,
						guid = guid,
						isNewMember = not HailerDB.knownGuildGUIDs[guid],
					}
				end
				knownGuildOnline[guid] = true
				HailerDB.knownGuildGUIDs[guid] = true
			else
				knownGuildOnline[guid] = false
			end
		end
	end

	if not guildInitialized then
		guildInitialized = true
	else
		for _, member in ipairs(newlyOnline) do
			local shortName = Ambiguate and Ambiguate(member.name, "short") or member.name
			local extra = {
				classFile = member.classFile,
				className = member.className,
				level = member.level,
				guid = member.guid,
			}
			ns:SendGreeting("guild", member.name, shortName, extra, member.isNewMember and "newMember" or "online")
		end
	end
end

local guildPending = false
local function OnGuildEvent()
	if guildPending then
		return
	end
	guildPending = true
	C_Timer.After(0.8, function()
		guildPending = false
		UpdateGuildRoster()
	end)
end

--------------------------------------------------------------------
-- Init
--------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
eventFrame:RegisterEvent("GUILD_ROSTER_UPDATE")

eventFrame:SetScript("OnEvent", function(_, event, ...)
	if event == "PLAYER_LOGIN" then
		if type(HailerDB) ~= "table" then
			HailerDB = {}
		end
		ApplyDefaults(HailerDB, DEFAULTS)
		ns.db = HailerDB

		if IsInGuild() then
			C_GuildInfo.GuildRoster()
		end
		if IsInGroup() then
			UpdateRoster()
		end

		if ns.InitCommunities then
			ns:InitCommunities()
		end

		if ns.InitFriends then
			ns:InitFriends()
		end

		if ns.GuildSync then
			ns.GuildSync:Init()
		end

		if ns.InitMinimap then
			ns:InitMinimap()
		end
	elseif event == "GROUP_ROSTER_UPDATE" then
		OnRosterEvent()
	elseif event == "GUILD_ROSTER_UPDATE" then
		OnGuildEvent()
	end
end)

--------------------------------------------------------------------
-- Slash command
--------------------------------------------------------------------

SLASH_HAILER1 = "/hailer"
SLASH_HAILER2 = "/hl"
SlashCmdList["HAILER"] = function()
	if ns.ToggleGUI then
		ns:ToggleGUI()
	end
end

--------------------------------------------------------------------
-- Addon Compartment (top-of-minimap dropdown) integration
--------------------------------------------------------------------

function Hailer_OnAddonCompartmentClick()
	if ns.ToggleGUI then
		ns:ToggleGUI()
	end
end

function Hailer_OnAddonCompartmentEnter(_, button)
	GameTooltip:SetOwner(button, "ANCHOR_LEFT")
	GameTooltip:SetText("Hailer", 0.4, 0.9, 1)
	GameTooltip:AddLine("Click to open the greeting settings.", 1, 1, 1, true)
	GameTooltip:Show()
end

function Hailer_OnAddonCompartmentLeave()
	GameTooltip:Hide()
end
