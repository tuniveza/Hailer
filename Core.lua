local ADDON_NAME, ns = ...

ns.ADDON_NAME = ADDON_NAME
ns.VERSION = "1.1.0"

--------------------------------------------------------------------
-- Defaults
--------------------------------------------------------------------

ns.scopeOrder = { "party", "instance", "guild", "community", "custom", "friends" }

-- Used by the "Enable/Disable All" toggles (GUI + minimap right-click).
-- Deliberately excludes "guild" -- guild has its own dedicated New
-- Member / Came Online toggles, and a blunt "disable everything" click
-- should never be able to silently turn off guild invites.
ns.optionalScopeOrder = { "party", "instance", "community", "custom", "friends" }

-- Scopes that have no real chat channel to post into (protected API, or no
-- channel exists at all) -- these can only ever whisper.
ns.WHISPER_ONLY_SCOPES = { community = true, friends = true }

-- 160 WoW-flavored welcome presets. Available placeholders: {name} {class}
-- {level} {guild} -- see the "Tags" button next to each message box.
ns.PRESET_MESSAGES = {
	-- Nautical / Hailer brand
	"Ahoy, {name}! Welcome aboard the guild!",
	"Land ho! Welcome to {guild}, {name}!",
	"Batten down the hatches, {name} just joined {guild}!",
	"Welcome to the crew, {name}! Fair winds ahead.",
	"Dock the ship, {name} has arrived!",
	"Smooth sailing, {name}! Glad to have you with {guild}.",
	"All hands on deck to welcome {name}!",
	"{name} has sailed into port. Welcome to {guild}!",
	"Raise the sails, {name} is here!",
	"Anchors aweigh, {name}! Welcome to the guild.",
	"Full steam ahead now that {name} is with us!",
	"Welcome aboard, {name}! May your voyage with {guild} be a long one.",
	-- WoW general / hero flavor
	"Welcome to {guild}, {name}! Another hero answers the call.",
	"Azeroth just got a little safer -- welcome, {name}!",
	"Welcome, {name}! Adventure awaits with {guild}.",
	"A new champion joins {guild} -- welcome, {name}!",
	"Welcome, {name}! Glory and loot await.",
	"The realms tremble -- {name} has joined {guild}!",
	"Welcome, {name}! Your legend starts here.",
	"Hail, {name}! {guild} welcomes a new hero.",
	"Welcome, {name}! May your journey be legendary.",
	"A hero rises -- welcome to {guild}, {name}!",
	"Welcome, {name}! The Alliance and the Horde both watch and wonder who you'll become.",
	"Welcome, {name}! Every great story needs a hero, and today it's you.",
	"Welcome to {guild}, {name}! Grab your gear, adventure calls.",
	"A wandering soul finds a home -- welcome, {name}!",
	"Welcome, {name}! May the road rise to meet you.",
	"Welcome, {name}! Azeroth needs heroes like you.",
	"Welcome aboard, {name}! Let's write some history together.",
	"Welcome, {name}! {guild} just got a whole lot stronger.",
	-- Faction-flavored
	"For the Horde! Welcome, {name}!",
	"For the Alliance! Welcome, {name}!",
	"Lok'tar ogar, {name}! Welcome to {guild}!",
	"Light and honor, {name}! Welcome to {guild}.",
	"The Horde grows stronger -- welcome, {name}!",
	"The Alliance stands united -- welcome, {name}!",
	"Welcome, {name}! Together we are unstoppable.",
	"Blood and thunder, {name}! Welcome to the guild.",
	"Welcome, {name}! May the Light guide you.",
	"Welcome, {name}! Victory or death -- glad you're with us.",
	-- Race flavor (kept general enough for any race)
	"Whether Human, Orc, or something stranger -- welcome, {name}!",
	"Welcome, {name}! Every race, one guild.",
	"From the deepest mine to the tallest tree, welcome home, {name}!",
	"Welcome, {name}! {guild} is home now, wherever you're from.",
	"Welcome, {name}! Ancestors smile upon your arrival.",
	"Welcome, {name}! May your totems always find good ground.",
	"Welcome, {name}! The forests of Ashenvale welcome a new friend.",
	"Welcome, {name}! Even the Forsaken need good company.",
	"Welcome, {name}! Sunwell's light shines on your arrival.",
	"Welcome, {name}! Thunder Bluff nods in respect.",
	"Welcome, {name}! Stormwind's gates are always open to you.",
	"Welcome, {name}! Ironforge raises a mug in your honor.",
	"Welcome, {name}! Darnassus welcomes another wanderer.",
	"Welcome, {name}! The Exodar hums with your arrival.",
	-- Class flavor
	"Welcome, {name} the {class}! {guild} needed one of those.",
	"A {class} joins the fray -- welcome, {name}!",
	"Welcome, {name}! Every {class} makes {guild} stronger.",
	"Welcome, {name}! Another {class} to carry the raid... or the jokes.",
	"Welcome, {name}, {class} of renown!",
	"Welcome, {name}! Show us what a {class} can really do.",
	"Welcome aboard, {name} the {class}!",
	"Welcome, {name}! A skilled {class} is always welcome here.",
	"Hail, {name} the {class}! Glad to have you.",
	"Welcome, {name}! {guild} has been needing a good {class}.",
	"Welcome, {name}! May your {class} skills serve you well here.",
	"Welcome, {name}! {guild} welcomes another {class} to the roster.",
	"Welcome, {name}! Respect to a fellow {class}.",
	"Welcome, {name}! A {class} of your caliber doesn't come along often.",
	"Welcome, {name}! Let's see what a level {level} {class} can do.",
	"Welcome, {name}! At level {level}, you're just getting started with {guild}.",
	-- Guild life: raids, keys, roster
	"Welcome to {guild}, {name}! The guild bank thanks you in advance.",
	"Welcome, {name}! Grab a guild tabard, you're one of us now.",
	"Welcome, {name}! Raid night just got more interesting.",
	"Welcome, {name}! Hope you're ready for some Mythic+ keys.",
	"Welcome, {name}! {guild}'s roster grows stronger.",
	"Welcome, {name}! First round of world bosses is on us.",
	"Welcome to {guild}, {name}! Don't forget to set your guild tag.",
	"Welcome, {name}! We could use another hand on progression.",
	"Welcome, {name}! Guild chat just got a new voice.",
	"Welcome, {name}! Someone show them where the guild vault is.",
	"Welcome, {name}! May your loot rolls always land in your favor.",
	"Welcome, {name}! {guild} welcomes a new raider.",
	"Welcome, {name}! Time to update the roster.",
	"Welcome, {name}! We've got a guild house full of stories -- come hear them.",
	"Welcome, {name}! Hope you brought your own repair bill.",
	"Welcome, {name}! {guild} is one adventurer stronger today.",
	"Welcome, {name}! We don't bite... much.",
	"Welcome, {name}! Guild achievements just got a little closer.",
	"Welcome, {name}! Someone get this recruit a mount.",
	"Welcome, {name}! First one to the guild bank buys the repairs.",
	"Welcome, {name}! Hope you like guild groups and bad puns.",
	"Welcome, {name}! {guild} welcomes fresh blood -- er, talent.",
	"Welcome, {name}! Consider this your official guild initiation.",
	"Welcome, {name}! Now the fun really begins.",
	-- Lore / cosmic forces
	"Welcome, {name}! May Life find you always.",
	"Welcome, {name}! May the Light shine upon your path.",
	"Welcome, {name}! Even the Void couldn't keep you away.",
	"Welcome, {name}! Order guides your steps to {guild}.",
	"Welcome, {name}! The Elements themselves seem pleased.",
	"Welcome, {name}! Death is not the end -- your story with {guild} is just beginning.",
	"Welcome, {name}! The cosmic forces smile on your arrival.",
	"Welcome, {name}! Titans forge, but guilds are built by people like you.",
	"Welcome, {name}! The Old Gods whisper... but {guild} welcomes you all the same.",
	"Welcome, {name}! A spark of Life joins {guild}.",
	"Welcome, {name}! Balance favors your arrival.",
	"Welcome, {name}! Arcane, holy, or shadow -- {guild} welcomes it all.",
	-- Humorous / light-hearted
	"Welcome, {name}! Please don't pull the boss before the tank is ready.",
	"Welcome, {name}! We promise the wipes are character-building.",
	"Welcome, {name}! Loot rules: need before greed, jokes before everything.",
	"Welcome, {name}! Warning: guild chat may contain excessive memes.",
	"Welcome, {name}! Please mute Discord before you sneeze into your mic.",
	"Welcome, {name}! No hunters were harmed in the making of this welcome.",
	"Welcome, {name}! We die a lot, but we do it with style.",
	"Welcome, {name}! Standing in the fire is strongly discouraged.",
	"Welcome, {name}! Free advice: always repair before the raid.",
	"Welcome, {name}! Disclaimer: our jokes are worse than our DPS.",
	"Welcome, {name}! Rule one of {guild}: have fun. Rule two: see rule one.",
	"Welcome, {name}! We accept bribes in the form of baked goods... or gold.",
	"Welcome, {name}! Please silence your hearthstone before raid.",
	"Welcome, {name}! Fair warning: our healers gossip during boss fights.",
	"Welcome, {name}! You'll fit right in -- we're all a little chaotic.",
	"Welcome, {name}! Ninja-looting a mount will result in mockery, not banishment. Probably.",
	"Welcome, {name}! May your latency be low and your crits be high.",
	"Welcome, {name}! We heard you like adventure, so we brought you a guild.",
	-- Sincere / warm
	"Welcome, {name}! We're glad you're here.",
	"Welcome, {name}! {guild} just got a little brighter.",
	"Welcome, {name}! You've found a home.",
	"Welcome, {name}! Here's to new friendships and good times.",
	"Welcome, {name}! We hope you stay a while.",
	"Welcome, {name}! Glad to call you one of us.",
	"Welcome, {name}! May {guild} feel like home.",
	"Welcome, {name}! Every new face makes this place better.",
	"Welcome, {name}! We've been waiting for someone like you.",
	"Welcome, {name}! Here's to the adventures ahead.",
	"Welcome, {name}! You made the right choice joining {guild}.",
	"Welcome, {name}! We're happy to have you with us.",
	"Welcome, {name}! Thanks for choosing {guild}.",
	"Welcome, {name}! Here's to many good memories together.",
	"Welcome, {name}! We hope {guild} lives up to the hype.",
	"Welcome, {name}! Glad you found your way to us.",
	-- Zones and misc
	"Welcome, {name}! Even the Dark Portal couldn't keep you from {guild}.",
	"Welcome, {name}! Shattrath sends its regards.",
	"Welcome, {name}! Dalaran's still floating, and now you're here too.",
	"Welcome, {name}! Boralus raises a toast in your honor.",
	"Welcome, {name}! Oribos welcomes a new soul to {guild}.",
	"Welcome, {name}! Even the Maw couldn't hold you back.",
	"Welcome, {name}! Pandaria's brew is on us tonight.",
	"Welcome, {name}! The Broken Isles whisper your name.",
	"Welcome, {name}! Northrend's cold, but {guild}'s welcome is warm.",
	"Welcome, {name}! Outland's a wild place -- glad you found us instead.",
	"Welcome, {name}! Zandalar remembers those who arrive with purpose.",
	"Welcome, {name}! The Dragon Isles soar a little higher today.",
	"Welcome, {name}! Even the Emerald Dream stirs for a welcome like this.",
	"Welcome, {name}! Silvermoon's spires gleam a bit brighter.",
	"Welcome, {name}! Undercity's shadows part to let you through.",
	"Welcome, {name}! Everyone in {guild} raises a horn to you.",
	"Welcome, {name}! You've earned your place among us.",
	"Welcome, {name}! From humble beginnings to guild legend -- welcome.",
	"Welcome, {name}! {guild} salutes its newest member.",
	"Welcome, {name}! Here's to your first of many adventures with us.",
}

local function NewTriggerConfig(enabled, chance, announceOn, announceMsgs, whisperOn, whisperMsgs, announceRotating, whisperRotating)
	return {
		enabled = enabled,
		chance = chance,
		announce = { enabled = announceOn, messages = announceMsgs, rotating = announceRotating or false },
		whisper = { enabled = whisperOn, messages = whisperMsgs, rotating = whisperRotating or false },
	}
end

-- Quiet by default: out of the box, Hailer only welcomes brand new guild
-- members ("guild invites"). Every other scope -- and the guild "came back
-- online" trigger -- is off until explicitly switched on in the GUI.
-- How many random presets stay "in rotation" at once. This batch of 16 is
-- redrawn from the full PRESET_MESSAGES library on every /reload, and again
-- mid-session once every message in the current batch has been sent at
-- least once (see RollRotatingPresetBatch/NextRotatingPreset below).
ns.ROTATING_POOL_SIZE = 16

local DEFAULTS = {
	minimap = {
		hide = false,
		pos = 220,
	},
	ignoreList = {},
	knownGuildGUIDs = {},
	rotatingPresets = {
		pool = {},
		queue = {},
	},
	-- When several people trigger the same greeting within a short window
	-- (e.g. a whole raid group zoning in together), combine their names into
	-- one announcement instead of posting one line per person.
	batching = {
		enabled = true,
		window = 4,
	},
	scopes = {
		party = {
			label = "Party / Raid",
			enabled = false,
			cooldown = 300,
			chance = 100,
			announce = { enabled = true, messages = { "Welcome to the group, {name}! o/" }, rotating = false },
			whisper = { enabled = false, messages = { "Hey {name}, welcome to the group!" }, rotating = false },
		},
		instance = {
			label = "Instance Group (Dungeon/Raid/M+)",
			enabled = false,
			cooldown = 300,
			chance = 100,
			announce = { enabled = false, messages = { "Welcome aboard, {name}! Good luck out there." }, rotating = false },
			whisper = { enabled = false, messages = { "Welcome aboard, {name}! Good luck out there." }, rotating = false },
		},
		guild = {
			label = "Guild",
			enabled = true,
			cooldown = 1800,
			triggers = {
				-- On by default, and seeded with the rotating-preset engine so a
				-- fresh install immediately shows off the 16-random-preset feature.
				newMember = NewTriggerConfig(
					true, 100,
					true, { "Everyone welcome {name} to the guild!" },
					true, { "Welcome to the guild, {name}! Let us know if you have any questions." },
					true, true
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
			announce = { enabled = false, messages = { "Welcome, {name}! Glad to have you here." }, rotating = false },
			whisper = { enabled = false, messages = { "Welcome to the community, {name}!" }, rotating = false },
		},
		custom = {
			label = "Custom Channels",
			enabled = false,
			cooldown = 900,
			chance = 50,
			watchList = {},
			announce = { enabled = true, messages = { "Ahoy {name}, welcome!" }, rotating = false },
			whisper = { enabled = false, messages = { "Ahoy {name}, welcome!" }, rotating = false },
		},
		friends = {
			label = "Friends",
			enabled = false,
			cooldown = 1200,
			chance = 70,
			announce = { enabled = false, messages = { "Ahoy {name}, good to see you online!" }, rotating = false },
			whisper = { enabled = false, messages = { "Ahoy {name}, good to see you online!" }, rotating = false },
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

--------------------------------------------------------------------
-- Rotating preset engine: keeps a shared batch of 16 random messages
-- drawn from the 160-strong PRESET_MESSAGES library. Any message pool can
-- opt into it (per-pool "rotating" toggle in the GUI) instead of using its
-- own manually curated list. The batch is redrawn from scratch -- a fresh
-- random 16, not just a reshuffle of the old 16 -- on every /reload, and
-- again the moment every message in the current batch has gone out at
-- least once, so the rotation never gets predictable or stale.
--------------------------------------------------------------------

local function ShuffledIndices(n)
	local t = {}
	for i = 1, n do
		t[i] = i
	end
	for i = n, 2, -1 do
		local j = math.random(i)
		t[i], t[j] = t[j], t[i]
	end
	return t
end

function ns:RollRotatingPresetBatch()
	local total = #ns.PRESET_MESSAGES
	local count = math.min(ns.ROTATING_POOL_SIZE, total)
	local order = ShuffledIndices(total)
	local pool = {}
	for i = 1, count do
		pool[i] = ns.PRESET_MESSAGES[order[i]]
	end
	HailerDB.rotatingPresets.pool = pool
	HailerDB.rotatingPresets.queue = ShuffledIndices(count)
end

-- Pops the next not-yet-used message out of the current batch, rolling a
-- brand new batch first if there isn't one yet or the current one has been
-- fully used.
function ns:NextRotatingPreset()
	local rp = HailerDB.rotatingPresets
	if not rp.pool or #rp.pool == 0 or not rp.queue or #rp.queue == 0 then
		ns:RollRotatingPresetBatch()
		rp = HailerDB.rotatingPresets
	end
	local idx = table.remove(rp.queue)
	return rp.pool[idx]
end

-- Picks a message for one announce/whisper pool, honoring its "rotating"
-- toggle (drawn from the shared rotating batch) vs. its own message list.
local function PickPoolMessage(poolCfg)
	if not poolCfg then
		return nil
	end
	if poolCfg.rotating then
		return ns:NextRotatingPreset()
	end
	return PickMessage(poolCfg.messages)
end
ns.PickPoolMessage = PickPoolMessage

local function FormatMsg(msg, name, extra)
	extra = extra or {}
	msg = msg:gsub("{name}", name)
	msg = msg:gsub("%%s", name)
	local guildName = GetGuildInfo and GetGuildInfo("player") or ""
	msg = msg:gsub("{guild}", guildName or "")
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
		-- Coordinated (cross-client) greets already go through an async
		-- election on GuildSync; batching that too would mean waiting on
		-- multiple in-flight elections to land together, so those still
		-- dispatch one at a time as soon as each election is won.
		ns.GuildSync:StartElection(scopeKey, targetFullName, displayName, extra, subKey)
	elseif HailerDB.batching and HailerDB.batching.enabled then
		ns:QueueGreetForBatch(scopeKey, subKey, targetFullName, displayName, extra)
	else
		ns:DispatchGreeting(scopeKey, targetFullName, displayName, extra, subKey)
	end
end

--------------------------------------------------------------------
-- Quick-succession batching: several people joining within a short window
-- (a raid zoning in, a batch of guild invites) get folded into a single
-- combined announcement instead of one chat line per person. Whispers stay
-- one-per-person (they're private, so there's no "spam" to combine), but
-- still wait for the window to close so a lone joiner isn't whispered
-- ahead of a combined announce that ends up including them.
--------------------------------------------------------------------

local pendingBatches = {}

local function JoinNames(names)
	local n = #names
	if n == 1 then
		return names[1]
	elseif n == 2 then
		return names[1] .. " and " .. names[2]
	end
	return table.concat(names, ", ", 1, n - 1) .. ", and " .. names[n]
end
ns.JoinNames = JoinNames

-- Combined form of DispatchGreeting for 2+ people batched together. Since a
-- single {name} placeholder can't represent a group, the announce message
-- gets the joined name list in place of {name} and blank {class}/{level}
-- (those are only meaningful for one person). Whispers are still sent
-- individually, each with its own name/class/level intact.
function ns:DispatchCombinedGreeting(scopeKey, subKey, entries)
	local scopeCfg = HailerDB.scopes[scopeKey]
	local trigger = (subKey and scopeCfg.triggers and scopeCfg.triggers[subKey]) or scopeCfg

	if not ns.WHISPER_ONLY_SCOPES[scopeKey] and trigger.announce.enabled then
		local msg = PickPoolMessage(trigger.announce)
		if msg then
			local names = {}
			for _, entry in ipairs(entries) do
				table.insert(names, entry.displayName)
			end
			local text = FormatMsg(msg, JoinNames(names), {})
			if scopeKey == "guild" then
				QueueChatMessage(text, "GUILD")
			elseif scopeKey == "custom" then
				for _, entry in ipairs(entries) do
					if entry.extra.channelIndex then
						QueueChatMessage(text, "CHANNEL", nil, entry.extra.channelIndex)
						break
					end
				end
			else
				QueueChatMessage(text, IsInRaid() and "RAID" or "PARTY")
			end
		end
	end

	if trigger.whisper.enabled then
		for _, entry in ipairs(entries) do
			local msg = PickPoolMessage(trigger.whisper)
			if msg then
				QueueChatMessage(FormatMsg(msg, entry.displayName, entry.extra), "WHISPER", entry.targetFullName)
			end
		end
	end

	if ns.PlayGreetSplash then
		ns:PlayGreetSplash()
	end
end

local function FlushGreetBatch(scopeKey, subKey, entries)
	if #entries == 1 then
		local e = entries[1]
		ns:DispatchGreeting(scopeKey, e.targetFullName, e.displayName, e.extra, subKey)
	else
		ns:DispatchCombinedGreeting(scopeKey, subKey, entries)
	end
end

-- Custom-channel batches are further split by channelIndex so two
-- different watched channels never get merged into one announcement.
function ns:QueueGreetForBatch(scopeKey, subKey, targetFullName, displayName, extra)
	local batchKey = scopeKey .. ":" .. (subKey or "") .. ":" .. (extra.channelIndex or "")
	local batch = pendingBatches[batchKey]
	if not batch then
		batch = { entries = {} }
		pendingBatches[batchKey] = batch
	end
	table.insert(batch.entries, {
		targetFullName = targetFullName,
		displayName = displayName,
		extra = extra,
	})

	if not batch.timer then
		local window = (HailerDB.batching and HailerDB.batching.window) or 4
		batch.timer = C_Timer.NewTimer(window, function()
			pendingBatches[batchKey] = nil
			FlushGreetBatch(scopeKey, subKey, batch.entries)
		end)
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
		local msg = PickPoolMessage(trigger.announce)
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
		local msg = PickPoolMessage(trigger.whisper)
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
			-- Mark every roster member "known" as soon as they're visible at
			-- all -- online or offline -- not just once they happen to log in.
			-- Otherwise a long-time member who simply hasn't been online
			-- since Hailer was installed gets mistaken for a brand new
			-- member ("guild invite") the first time they do log in.
			local wasKnown = HailerDB.knownGuildGUIDs[guid]
			HailerDB.knownGuildGUIDs[guid] = true

			if online then
				if guildInitialized and not knownGuildOnline[guid] then
					newlyOnline[#newlyOnline + 1] = {
						name = name,
						level = level,
						className = className,
						classFile = classFile,
						guid = guid,
						isNewMember = not wasKnown,
					}
				end
				knownGuildOnline[guid] = true
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

-- GUILD_ROSTER_UPDATE can fire many times in quick succession during a
-- burst of guild activity (several people coming online, joining, etc. in
-- the same few seconds) as Blizzard's client catches up on roster data. A
-- naive "wait 0.8s after the first event, then scan once" debounce can fire
-- that one scan before a given change (e.g. a brand new member) has fully
-- landed, silently missing them for the rest of the session. This instead
-- resets the settle timer on every event (a true debounce), so the scan
-- only runs once things go quiet -- capped at GUILD_EVENT_MAX_WAIT so a
-- guild with nonstop traffic doesn't starve it forever -- and follows up
-- with one more scan a couple seconds later as a safety net.
local GUILD_EVENT_SETTLE = 0.8
local GUILD_EVENT_MAX_WAIT = 3
local GUILD_EVENT_CATCHUP = 2.5

local guildEventTimer
local guildBurstStart
local guildCatchupTimer

local function FlushGuildEvent()
	guildEventTimer = nil
	guildBurstStart = nil
	UpdateGuildRoster()
	if not guildCatchupTimer then
		guildCatchupTimer = C_Timer.NewTimer(GUILD_EVENT_CATCHUP, function()
			guildCatchupTimer = nil
			UpdateGuildRoster()
		end)
	end
end

local function OnGuildEvent()
	local now = GetTime()
	guildBurstStart = guildBurstStart or now

	if guildEventTimer then
		guildEventTimer:Cancel()
	end

	local elapsed = now - guildBurstStart
	local wait = math.min(GUILD_EVENT_SETTLE, math.max(0.1, GUILD_EVENT_MAX_WAIT - elapsed))
	guildEventTimer = C_Timer.NewTimer(wait, FlushGuildEvent)
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

		-- Fresh random 16-message batch every /reload (PLAYER_LOGIN fires on
		-- every UI reload, not just the first login of a session).
		ns:RollRotatingPresetBatch()

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
