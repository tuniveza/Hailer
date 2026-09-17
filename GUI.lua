local ADDON_NAME, ns = ...

local AGAVE_BOLD = "Interface\\AddOns\\Hailer\\Fonts\\Agave-Bold.ttf"
local AGAVE_REGULAR = "Interface\\AddOns\\Hailer\\Fonts\\Agave-Regular.ttf"

--------------------------------------------------------------------
-- Tab list (icons are stock WoW icons, tinted by nothing -- kept as-is
-- so they stay recognizable)
--------------------------------------------------------------------

local TABS = {
	{ key = "general", label = "General", icon = "Interface\\Icons\\INV_Misc_Compass_01" },
	{ key = "party", label = "Party / Raid", icon = "Interface\\Icons\\INV_Misc_GroupLooking" },
	{ key = "instance", label = "Instance Group", icon = "Interface\\Icons\\INV_Misc_Map_02" },
	{ key = "guild", label = "Guild", icon = "Interface\\Icons\\Achievement_GuildPerk_EverybodysFriend" },
	{ key = "community", label = "Communities", icon = "Interface\\Icons\\INV_Letter_15" },
	{ key = "custom", label = "Custom Channels", icon = "Interface\\Icons\\INV_Misc_Note_01" },
	{ key = "friends", label = "Friends", icon = "Interface\\FriendsFrame\\StatusIcon-Online" },
	{ key = "ignore", label = "Ignore List", icon = "Interface\\Icons\\Ability_Rogue_FeignDeath" },
}

local ON_COLOR = { 0.35, 0.9, 0.45, 1 }
local OFF_COLOR = { 0.55, 0.55, 0.6, 0.85 }
local function StatusWord(on)
	return on and "|cff55e0ffON|r" or "|cff888888off|r"
end

--------------------------------------------------------------------
-- Basic themed widget helpers
--------------------------------------------------------------------

local function CreateLabel(parent, text, dim)
	local fs = parent:CreateFontString(nil, "ARTWORK", dim and "GameFontDisableSmall" or "GameFontHighlightSmall")
	fs:SetText(text)
	if not dim then
		fs:SetTextColor(0.78, 0.92, 1)
	end
	return fs
end

local function CreateCheckbox(parent, labelText)
	local cb = CreateFrame("CheckButton", nil, parent)
	cb:SetSize(22, 22)
	cb:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
	cb:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
	cb:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight", "ADD")
	cb:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
	cb:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
	cb:GetCheckedTexture():SetVertexColor(0.5, 0.85, 1)

	local label = cb:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	label:SetPoint("LEFT", cb, "RIGHT", 6, 0)
	label:SetText(labelText)
	label:SetTextColor(0.8, 0.92, 1)
	cb.Text = label

	return cb
end

local function CreateEditBox(parent, width)
	local eb = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
	eb:SetSize(width, 20)
	eb:SetAutoFocus(false)
	eb:SetScript("OnEscapePressed", eb.ClearFocus)
	return eb
end

local function CreateNumberEditBox(parent, width)
	local eb = CreateEditBox(parent, width)
	eb:SetNumeric(true)
	return eb
end

-- A genuinely cyan button, drawn from a flat white texture + our own color,
-- rather than tinting Blizzard's gold button art (which never fully lets go
-- of its own warm base color under a vertex tint).
local function CreateButton(parent, text, width, height)
	local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
	btn:SetSize(width or 90, height or 22)
	btn:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 10,
	})
	btn:SetBackdropColor(0.07, 0.26, 0.40, 0.92)
	btn:SetBackdropBorderColor(0.35, 0.75, 0.95, 1)

	local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetAllPoints()
	highlight:SetColorTexture(0.55, 0.88, 1, 0.3)
	btn:SetHighlightTexture(highlight)

	local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	fs:SetPoint("CENTER")
	fs:SetText(text)
	fs:SetTextColor(0.85, 0.95, 1)
	btn:SetFontString(fs)

	btn:SetScript("OnMouseDown", function(self)
		self:SetBackdropColor(0.03, 0.14, 0.22, 0.96)
	end)
	btn:SetScript("OnMouseUp", function(self)
		self:SetBackdropColor(0.07, 0.26, 0.40, 0.92)
	end)

	return btn
end

local function CreateTabButton(parent, text, onClick, width, iconPath)
	local btn = CreateButton(parent, text, width or 168, 28)
	btn:SetScript("OnClick", onClick)
	if iconPath then
		local icon = btn:CreateTexture(nil, "ARTWORK")
		icon:SetSize(18, 18)
		icon:SetPoint("LEFT", 10, 0)
		icon:SetTexture(iconPath)
		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		local fs = btn:GetFontString()
		if fs then
			fs:ClearAllPoints()
			fs:SetPoint("LEFT", icon, "RIGHT", 6, 0)
			fs:SetPoint("RIGHT", -20, 0)
			fs:SetJustifyH("LEFT")
		end
	end

	local dot = btn:CreateTexture(nil, "OVERLAY")
	dot:SetTexture("Interface\\Buttons\\WHITE8x8")
	dot:SetSize(9, 9)
	dot:SetPoint("TOPRIGHT", -5, -5)
	dot:Hide()
	btn.statusDot = dot

	return btn
end

local function SortedKeys(t)
	local out = {}
	for k in pairs(t) do
		table.insert(out, k)
	end
	table.sort(out)
	return out
end

local function CreateNameList(parent, width, height)
	local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
	scrollFrame:SetSize(width, height)
	local scrollChild = CreateFrame("Frame", nil, scrollFrame)
	scrollChild:SetSize(width - 20, height)
	scrollFrame:SetScrollChild(scrollChild)
	return scrollFrame, scrollChild
end

local function RefreshNameRows(scrollChild, names, onRemove)
	scrollChild.rows = scrollChild.rows or {}
	for _, row in ipairs(scrollChild.rows) do
		row:Hide()
	end
	local count = 0
	for _, name in ipairs(names) do
		count = count + 1
		local row = scrollChild.rows[count]
		if not row then
			row = CreateFrame("Frame", nil, scrollChild)
			row:SetSize(scrollChild:GetWidth(), 22)
			row.text = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
			row.text:SetPoint("LEFT", 4, 0)
			row.text:SetPoint("RIGHT", -26, 0)
			row.text:SetJustifyH("LEFT")
			row.text:SetTextColor(0.8, 0.92, 1)
			row.removeBtn = CreateButton(row, "x", 20, 20)
			row.removeBtn:SetPoint("RIGHT", -2, 0)
			scrollChild.rows[count] = row
		end
		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", 0, -(count - 1) * 22)
		row.text:SetText(name)
		row.removeBtn:SetScript("OnClick", function()
			onRemove(name)
		end)
		row:Show()
	end
	scrollChild:SetHeight(math.max(1, count) * 22)
end

--------------------------------------------------------------------
-- Message pool editor (input + Add + Presets menu + removable list)
--------------------------------------------------------------------

local presetMenu

local function GetPresetMenu()
	if presetMenu then
		return presetMenu
	end
	local menu = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
	menu:SetFrameStrata("TOOLTIP")
	menu:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 12,
	})
	menu:SetBackdropColor(0.02, 0.08, 0.14, 0.97)
	menu:SetBackdropBorderColor(0.3, 0.75, 0.95, 1)
	menu:SetSize(300, #ns.PRESET_MESSAGES * 20 + 16)
	menu:Hide()
	menu:SetFrameLevel(100)

	menu.rows = {}
	for i, text in ipairs(ns.PRESET_MESSAGES) do
		local row = CreateFrame("Button", nil, menu)
		row:SetSize(280, 20)
		row:SetPoint("TOP", 0, -8 - (i - 1) * 20)
		local fs = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		fs:SetPoint("LEFT", 4, 0)
		fs:SetText(text)
		fs:SetTextColor(0.8, 0.92, 1)
		row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
		row.text = text
		menu.rows[i] = row
	end

	presetMenu = menu
	return menu
end

local function BuildMessagePool(parent, y, pool, width)
	width = width or 460

	local input = CreateEditBox(parent, width - 140)
	input:SetPoint("TOPLEFT", 20, y)
	local addBtn = CreateButton(parent, "Add", 50, 22)
	addBtn:SetPoint("LEFT", input, "RIGHT", 6, 0)
	local presetBtn = CreateButton(parent, "Presets", 66, 22)
	presetBtn:SetPoint("LEFT", addBtn, "RIGHT", 6, 0)
	y = y - 26

	local scrollFrame, scrollChild = CreateNameList(parent, width, 90)
	scrollFrame:SetPoint("TOPLEFT", 20, y)
	y = y - 96

	local function DoRefresh()
		RefreshNameRows(scrollChild, pool, function(msg)
			for i, v in ipairs(pool) do
				if v == msg then
					table.remove(pool, i)
					break
				end
			end
			DoRefresh()
		end)
	end

	local function AddMessage(text)
		text = text and text:gsub("^%s+", ""):gsub("%s+$", "")
		if text and text ~= "" then
			table.insert(pool, text)
			DoRefresh()
		end
	end

	addBtn:SetScript("OnClick", function()
		AddMessage(input:GetText())
		input:SetText("")
	end)
	input:SetScript("OnEnterPressed", function(self)
		AddMessage(self:GetText())
		self:SetText("")
		self:ClearFocus()
	end)

	presetBtn:SetScript("OnClick", function()
		local menu = GetPresetMenu()
		if menu:IsShown() and menu.owner == presetBtn then
			menu:Hide()
			return
		end
		for _, row in ipairs(menu.rows) do
			row:SetScript("OnClick", function()
				AddMessage(row.text)
				menu:Hide()
			end)
		end
		menu.owner = presetBtn
		menu:ClearAllPoints()
		menu:SetPoint("TOPLEFT", presetBtn, "BOTTOMLEFT", 0, -2)
		menu:Show()
	end)

	return y, DoRefresh
end

--------------------------------------------------------------------
-- Rain + ripple + caustics background animation
--------------------------------------------------------------------

local function SpawnDropInto(container)
	local drop = container:CreateTexture(nil, "ARTWORK")
	drop:SetColorTexture(0.55, 0.85, 1, 1)
	drop:SetSize(2, 24)

	local ag = drop:CreateAnimationGroup()
	local move = ag:CreateAnimation("Translation")
	move:SetSmoothing("IN")

	local function Reset()
		local w = container:GetWidth()
		local h = container:GetHeight()
		local x = math.random(0, math.max(1, math.floor(w)))
		drop:ClearAllPoints()
		drop:SetPoint("TOP", container, "TOPLEFT", x, math.random(0, 80))
		drop:SetAlpha(math.random(30, 65) / 100)
		move:SetOffset(0, -(h + 100))
		move:SetDuration(math.random(140, 260) / 100)
	end

	ag:SetScript("OnFinished", function()
		Reset()
		ag:Play()
	end)

	Reset()
	container.hailerAnims = container.hailerAnims or {}
	table.insert(container.hailerAnims, ag)
end

local function StartRain(container, count)
	if not container.hailerAnims then
		for _ = 1, count do
			SpawnDropInto(container)
		end
	end
	for _, ag in ipairs(container.hailerAnims) do
		if not ag:IsPlaying() then
			ag:Play()
		end
	end
end

local function StopRain(container)
	if container.hailerAnims then
		for _, ag in ipairs(container.hailerAnims) do
			ag:Stop()
		end
	end
end

local function BuildCaustics(frame, width, height)
	for _ = 1, 26 do
		local blob = frame:CreateTexture(nil, "BORDER")
		blob:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-SoftEdge-Circle")
		local size = math.random(60, 170)
		blob:SetSize(size, size)
		blob:SetPoint("CENTER", frame, "TOPLEFT", math.random(0, width), -math.random(0, height))
		local shade = math.random(60, 100) / 100
		blob:SetVertexColor(0.12 * shade, 0.4 * shade, 0.55 * shade, math.random(6, 15) / 100)
	end
end

local function PlayRipple(parent, x, y)
	local tex = parent:CreateTexture(nil, "OVERLAY")
	tex:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-SoftEdge-Circle")
	tex:SetVertexColor(0.4, 0.85, 1, 0.85)
	tex:SetSize(10, 10)
	tex:SetPoint("CENTER", parent, "CENTER", x or 0, y or 0)

	local ag = tex:CreateAnimationGroup()
	local scale = ag:CreateAnimation("Scale")
	scale:SetOrigin("CENTER", 0, 0)
	scale:SetScale(6, 6)
	scale:SetDuration(0.6)
	scale:SetSmoothing("OUT")
	local alpha = ag:CreateAnimation("Alpha")
	alpha:SetFromAlpha(0.85)
	alpha:SetToAlpha(0)
	alpha:SetDuration(0.6)
	ag:SetScript("OnFinished", function()
		tex:Hide()
		tex:SetParent(nil)
	end)
	ag:Play()
end
ns.PlayRipple = PlayRipple

function ns:PlayGreetSplash()
	local btn = _G.HailerMinimapButton
	if btn and btn:IsShown() then
		PlayRipple(btn, 0, 0)
	end
	if ns.frame and ns.frame:IsShown() then
		PlayRipple(ns.frame, 0, 40)
	end
end

--------------------------------------------------------------------
-- Shared cooldown + chance row
--------------------------------------------------------------------

local function BuildCooldownChanceRow(page, y, getCooldown, setCooldown, getChance, setChance)
	local cooldownLabel = CreateLabel(page, "Cooldown (sec):")
	cooldownLabel:SetPoint("TOPLEFT", 4, y)
	local cooldownBox = CreateNumberEditBox(page, 55)
	cooldownBox:SetPoint("LEFT", cooldownLabel, "RIGHT", 6, 0)
	cooldownBox:SetScript("OnEnterPressed", function(self)
		local v = tonumber(self:GetText())
		if v and v >= 0 then
			setCooldown(math.floor(v))
		end
		self:ClearFocus()
	end)

	local chanceBox, chanceLabel
	if getChance then
		chanceLabel = CreateLabel(page, "Chance (%):")
		chanceLabel:SetPoint("LEFT", cooldownBox, "RIGHT", 20, 0)
		chanceBox = CreateNumberEditBox(page, 50)
		chanceBox:SetPoint("LEFT", chanceLabel, "RIGHT", 6, 0)
		chanceBox:SetScript("OnEnterPressed", function(self)
			local v = tonumber(self:GetText())
			if v then
				setChance(math.max(0, math.min(100, math.floor(v))))
			end
			self:ClearFocus()
		end)
	end

	local function Refresh()
		cooldownBox:SetText(tostring(getCooldown()))
		if chanceBox then
			chanceBox:SetText(tostring(getChance()))
		end
	end

	return y - 32, Refresh
end

--------------------------------------------------------------------
-- Page builders
--------------------------------------------------------------------

local function BuildWatchListSection(page, y)
	local label = CreateLabel(page, "Channels to watch (exact name, e.g. \"General\" or \"Trade\"):")
	label:SetPoint("TOPLEFT", 0, y)
	y = y - 22

	local input = CreateEditBox(page, 190)
	input:SetPoint("TOPLEFT", 0, y)
	local addBtn = CreateButton(page, "Add", 70, 22)
	addBtn:SetPoint("LEFT", input, "RIGHT", 8, 0)
	y = y - 28

	local scrollFrame, scrollChild = CreateNameList(page, 400, 90)
	scrollFrame:SetPoint("TOPLEFT", 0, y)

	local function DoRefresh()
		local watchList = HailerDB.scopes.custom.watchList
		local display = {}
		for _, original in pairs(watchList) do
			table.insert(display, original)
		end
		table.sort(display)
		RefreshNameRows(scrollChild, display, function(name)
			watchList[ns.NormalizeWatchName(name)] = nil
			DoRefresh()
		end)
	end

	local function AddChannel()
		local name = input:GetText()
		name = name and name:gsub("^%s+", ""):gsub("%s+$", "")
		if name and name ~= "" then
			HailerDB.scopes.custom.watchList[ns.NormalizeWatchName(name)] = name
			input:SetText("")
			DoRefresh()
		end
	end
	addBtn:SetScript("OnClick", AddChannel)
	input:SetScript("OnEnterPressed", function(self)
		AddChannel()
		self:ClearFocus()
	end)

	page.RefreshWatchList = DoRefresh
end

local function BuildScopePage(page, scopeKey)
	local y = -4
	local isWhisperOnly = ns.WHISPER_ONLY_SCOPES[scopeKey]

	if scopeKey == "custom" then
		local warn = CreateLabel(page, "Best-effort: WoW has no \"channel join\" event, so this greets the first message seen from each name per session.", true)
		warn:SetPoint("TOPLEFT", 0, y)
		warn:SetJustifyH("LEFT")
		warn:SetWidth(480)
		y = y - 26
	elseif scopeKey == "community" then
		local warn = CreateLabel(page, "Blizzard blocks addons from posting into Community chat automatically, so only the whisper below can be sent here.", true)
		warn:SetPoint("TOPLEFT", 0, y)
		warn:SetJustifyH("LEFT")
		warn:SetWidth(480)
		y = y - 26
	elseif scopeKey == "friends" then
		local warn = CreateLabel(page, "There is no chat channel for a friends list, so this scope can only whisper the friend who came online.", true)
		warn:SetPoint("TOPLEFT", 0, y)
		warn:SetJustifyH("LEFT")
		warn:SetWidth(480)
		y = y - 26
	end

	local enableCB = CreateCheckbox(page, "Enable greetings for this scope")
	enableCB:SetPoint("TOPLEFT", 0, y)
	enableCB:SetScript("OnClick", function(self)
		HailerDB.scopes[scopeKey].enabled = self:GetChecked() and true or false
		ns:UpdateNavIndicators()
	end)
	y = y - 30

	local newY, refreshCooldownChance = BuildCooldownChanceRow(page, y,
		function() return HailerDB.scopes[scopeKey].cooldown end,
		function(v) HailerDB.scopes[scopeKey].cooldown = v end,
		function() return HailerDB.scopes[scopeKey].chance end,
		function(v) HailerDB.scopes[scopeKey].chance = v end)
	y = newY

	local announceCB, refreshAnnouncePool
	if not isWhisperOnly then
		announceCB = CreateCheckbox(page, "Announce publicly in chat")
		announceCB:SetPoint("TOPLEFT", 0, y)
		announceCB:SetScript("OnClick", function(self)
			HailerDB.scopes[scopeKey].announce.enabled = self:GetChecked() and true or false
		end)
		y = y - 24
		y, refreshAnnouncePool = BuildMessagePool(page, y, HailerDB.scopes[scopeKey].announce.messages, 460)
	end

	local whisperCB = CreateCheckbox(page, "Whisper the person directly")
	whisperCB:SetPoint("TOPLEFT", 0, y)
	whisperCB:SetScript("OnClick", function(self)
		HailerDB.scopes[scopeKey].whisper.enabled = self:GetChecked() and true or false
	end)
	y = y - 24
	local y2, refreshWhisperPool = BuildMessagePool(page, y, HailerDB.scopes[scopeKey].whisper.messages, 460)
	y = y2

	local hint = CreateLabel(page, "Placeholders: {name}   {class}   {level}", true)
	hint:SetPoint("TOPLEFT", 20, y)
	y = y - 22

	if scopeKey == "custom" then
		BuildWatchListSection(page, y)
	end

	page.Refresh = function()
		local scope = HailerDB.scopes[scopeKey]
		enableCB:SetChecked(scope.enabled)
		refreshCooldownChance()
		if announceCB then
			announceCB:SetChecked(scope.announce.enabled)
			refreshAnnouncePool()
		end
		whisperCB:SetChecked(scope.whisper.enabled)
		refreshWhisperPool()
		if page.RefreshWatchList then
			page.RefreshWatchList()
		end
	end
end

local function BuildGuildTriggerSection(parent, subKey, onEnabledChanged)
	local y = -4
	local function Trigger()
		return HailerDB.scopes.guild.triggers[subKey]
	end

	local enableCB = CreateCheckbox(parent, "Enable this greeting")
	enableCB:SetPoint("TOPLEFT", 0, y)
	enableCB:SetScript("OnClick", function(self)
		Trigger().enabled = self:GetChecked() and true or false
		if onEnabledChanged then
			onEnabledChanged()
		end
	end)
	y = y - 30

	local newY, refreshChance = BuildCooldownChanceRow(parent, y,
		function() return HailerDB.scopes.guild.cooldown end,
		function(v) HailerDB.scopes.guild.cooldown = v end,
		function() return Trigger().chance end,
		function(v) Trigger().chance = v end)
	y = newY

	local coordinateCB
	if subKey == "online" then
		coordinateCB = CreateCheckbox(parent, "Coordinate with other Hailer users (only one guildmate greets)")
		coordinateCB:SetPoint("TOPLEFT", 0, y)
		coordinateCB:SetScript("OnClick", function(self)
			Trigger().coordinate = self:GetChecked() and true or false
		end)
		y = y - 26
	end

	local announceCB = CreateCheckbox(parent, "Announce publicly in guild chat")
	announceCB:SetPoint("TOPLEFT", 0, y)
	announceCB:SetScript("OnClick", function(self)
		Trigger().announce.enabled = self:GetChecked() and true or false
	end)
	y = y - 24
	local y1, refreshAnnouncePool = BuildMessagePool(parent, y, Trigger().announce.messages, 460)
	y = y1

	local whisperCB = CreateCheckbox(parent, "Also whisper the person directly")
	whisperCB:SetPoint("TOPLEFT", 0, y)
	whisperCB:SetScript("OnClick", function(self)
		Trigger().whisper.enabled = self:GetChecked() and true or false
	end)
	y = y - 24
	local y2, refreshWhisperPool = BuildMessagePool(parent, y, Trigger().whisper.messages, 460)
	y = y2

	local hint = CreateLabel(parent, "Placeholders: {name}   {class}   {level}", true)
	hint:SetPoint("TOPLEFT", 20, y)

	parent.Refresh = function()
		local trigger = Trigger()
		enableCB:SetChecked(trigger.enabled)
		refreshChance()
		if coordinateCB then
			coordinateCB:SetChecked(trigger.coordinate)
		end
		announceCB:SetChecked(trigger.announce.enabled)
		refreshAnnouncePool()
		whisperCB:SetChecked(trigger.whisper.enabled)
		refreshWhisperPool()
	end
end

local function BuildGuildPage(page)
	local sections = {}
	local subTabs = { { key = "newMember", label = "New Member" }, { key = "online", label = "Came Online" } }

	local subNav = CreateFrame("Frame", nil, page)
	subNav:SetPoint("TOPLEFT", 0, 0)
	subNav:SetSize(400, 26)

	local subContent = CreateFrame("Frame", nil, page)
	subContent:SetPoint("TOPLEFT", 0, -34)
	subContent:SetPoint("BOTTOMRIGHT", 0, 0)

	local buttons = {}
	local activeSub = "newMember"

	local function UpdateSubIndicators()
		for key, btn in pairs(buttons) do
			local trigger = HailerDB.scopes.guild.triggers[key]
			if btn.statusDot and trigger then
				local c = trigger.enabled and ON_COLOR or OFF_COLOR
				btn.statusDot:SetVertexColor(c[1], c[2], c[3], c[4])
				btn.statusDot:Show()
			end
		end
	end

	local function SelectSub(key)
		activeSub = key
		for k, sec in pairs(sections) do
			sec:SetShown(k == key)
			if k == key and sec.Refresh then
				sec.Refresh()
			end
		end
		for k, btn in pairs(buttons) do
			if k == key then
				btn:LockHighlight()
			else
				btn:UnlockHighlight()
			end
		end
		UpdateSubIndicators()
	end

	for i, tab in ipairs(subTabs) do
		local btn = CreateTabButton(subNav, tab.label, function()
			SelectSub(tab.key)
		end, 150)
		btn:SetPoint("TOPLEFT", (i - 1) * 158, 0)
		buttons[tab.key] = btn

		local section = CreateFrame("Frame", nil, subContent)
		section:SetAllPoints()
		section:Hide()
		sections[tab.key] = section
		BuildGuildTriggerSection(section, tab.key, UpdateSubIndicators)
	end

	page.Refresh = function()
		SelectSub(activeSub)
	end
end

local function BuildGeneralPage(page)
	local intro = CreateLabel(page, "Hailer watches your guild, group, communities, and friends list, and greets people when they join or come online.", true)
	intro:SetPoint("TOPLEFT", 0, -4)
	intro:SetJustifyH("LEFT")
	intro:SetWidth(480)

	local minimapCB = CreateCheckbox(page, "Show minimap icon")
	minimapCB:SetPoint("TOPLEFT", 0, -56)
	minimapCB:SetScript("OnClick", function(self)
		local shown = self:GetChecked() and true or false
		if ns.SetMinimapShown then
			ns:SetMinimapShown(shown)
		end
	end)

	local allBtn = CreateButton(page, "Enable / Disable Optional Scopes", 230, 24)
	allBtn:SetPoint("TOPLEFT", 0, -92)
	allBtn:SetScript("OnClick", function()
		local anyEnabled = false
		for _, key in ipairs(ns.optionalScopeOrder) do
			if HailerDB.scopes[key].enabled then
				anyEnabled = true
				break
			end
		end
		for _, key in ipairs(ns.optionalScopeOrder) do
			HailerDB.scopes[key].enabled = not anyEnabled
		end
		ns:RefreshGUI()
	end)

	local allHint = CreateLabel(page, "(Party/Instance/Community/Custom/Friends only -- Guild's toggles live on the Guild tab and are never touched here.)", true)
	allHint:SetPoint("TOPLEFT", 0, -118)
	allHint:SetJustifyH("LEFT")
	allHint:SetWidth(480)

	local statusHeader = CreateLabel(page, "Current status (also shown as a dot on each tab):")
	statusHeader:SetPoint("TOPLEFT", 0, -134)

	local statusLabel = CreateLabel(page, "", true)
	statusLabel:SetPoint("TOPLEFT", 4, -156)
	statusLabel:SetJustifyH("LEFT")
	statusLabel:SetWidth(460)

	page.Refresh = function()
		minimapCB:SetChecked(not HailerDB.minimap.hide)

		local guild = HailerDB.scopes.guild
		local lines = {
			"Guild - New Member (invites): " .. StatusWord(guild.enabled and guild.triggers.newMember.enabled),
			"Guild - Came Online: " .. StatusWord(guild.enabled and guild.triggers.online.enabled),
		}
		for _, key in ipairs(ns.optionalScopeOrder) do
			local scope = HailerDB.scopes[key]
			table.insert(lines, scope.label .. ": " .. StatusWord(scope.enabled))
		end
		statusLabel:SetText(table.concat(lines, "\n"))
	end
end

local function BuildIgnorePage(page)
	local label = CreateLabel(page, "Never greet these characters (name or Name-Realm):")
	label:SetPoint("TOPLEFT", 0, -4)

	local input = CreateEditBox(page, 220)
	input:SetPoint("TOPLEFT", 0, -28)
	local addBtn = CreateButton(page, "Add", 70, 22)
	addBtn:SetPoint("LEFT", input, "RIGHT", 8, 0)

	local scrollFrame, scrollChild = CreateNameList(page, 440, 420)
	scrollFrame:SetPoint("TOPLEFT", 0, -64)

	local function DoRefresh()
		RefreshNameRows(scrollChild, SortedKeys(HailerDB.ignoreList), function(name)
			HailerDB.ignoreList[name] = nil
			DoRefresh()
		end)
	end

	local function AddName()
		local name = input:GetText()
		name = name and name:gsub("^%s+", ""):gsub("%s+$", "")
		if name and name ~= "" then
			HailerDB.ignoreList[name] = true
			input:SetText("")
			DoRefresh()
		end
	end
	addBtn:SetScript("OnClick", AddName)
	input:SetScript("OnEnterPressed", function(self)
		AddName()
		self:ClearFocus()
	end)

	page.Refresh = DoRefresh
end

--------------------------------------------------------------------
-- Main frame
--------------------------------------------------------------------

function ns:UpdateNavIndicators()
	if not ns.navButtons then
		return
	end
	for _, tab in ipairs(TABS) do
		local btn = ns.navButtons[tab.key]
		local scope = btn and HailerDB and HailerDB.scopes[tab.key]
		if btn and btn.statusDot then
			if scope then
				local c = scope.enabled and ON_COLOR or OFF_COLOR
				btn.statusDot:SetVertexColor(c[1], c[2], c[3], c[4])
				btn.statusDot:Show()
			else
				btn.statusDot:Hide()
			end
		end
	end
end

function ns:SelectTab(key)
	ns.activeTab = key
	for _, page in pairs(ns.pages) do
		page:Hide()
	end
	local page = ns.pages[key]
	if page then
		page:Show()
		if page.Refresh then
			page.Refresh()
		end
	end
	for k, btn in pairs(ns.navButtons) do
		if k == key then
			btn:LockHighlight()
		else
			btn:UnlockHighlight()
		end
	end
	ns:UpdateNavIndicators()
end

function ns:RefreshGUI()
	if ns.frame and ns.activeTab then
		ns:SelectTab(ns.activeTab)
	end
end

function ns:BuildGUI()
	local WIDTH, HEIGHT = 780, 680

	local frame = CreateFrame("Frame", "HailerFrame", UIParent, "BackdropTemplate")
	frame:SetSize(WIDTH, HEIGHT)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("HIGH")
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:SetClipsChildren(true)
	frame:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16 })
	frame:SetBackdropBorderColor(0.3, 0.75, 0.95, 1)
	frame:Hide()
	tinsert(UISpecialFrames, "HailerFrame")
	ns.frame = frame

	local bg = frame:CreateTexture(nil, "BACKGROUND")
	bg:SetPoint("TOPLEFT", 4, -4)
	bg:SetPoint("BOTTOMRIGHT", -4, 4)
	bg:SetGradient("VERTICAL", CreateColor(0.02, 0.10, 0.18, 0.97), CreateColor(0.05, 0.22, 0.30, 0.97))

	BuildCaustics(frame, WIDTH, HEIGHT)

	local titleBanner = frame:CreateTexture(nil, "BORDER")
	titleBanner:SetPoint("TOPLEFT", 4, -4)
	titleBanner:SetPoint("TOPRIGHT", -4, -4)
	titleBanner:SetHeight(54)
	titleBanner:SetColorTexture(0.02, 0.06, 0.12, 0.5)

	local rainLayer = CreateFrame("Frame", nil, frame)
	rainLayer:SetPoint("TOPLEFT", 4, -4)
	rainLayer:SetPoint("BOTTOMRIGHT", -4, 4)
	rainLayer:SetFrameLevel(frame:GetFrameLevel() + 1)

	local titleIcon = frame:CreateTexture(nil, "ARTWORK")
	titleIcon:SetSize(32, 32)
	titleIcon:SetTexture("Interface\\Icons\\INV_Elemental_Mote_Water01")
	titleIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	local title = frame:CreateFontString(nil, "OVERLAY")
	title:SetFont(AGAVE_BOLD, 30, "")
	title:SetTextColor(0.4, 0.85, 1)
	title:SetText("Hailer")
	title:SetPoint("TOP", 0, -14)

	titleIcon:SetPoint("RIGHT", title, "LEFT", -8, 0)

	local subtitle = frame:CreateFontString(nil, "OVERLAY")
	subtitle:SetFont(AGAVE_REGULAR, 12, "")
	subtitle:SetTextColor(0.6, 0.78, 0.88)
	subtitle:SetText("Ahoy! Automatic greetings for your crew.")
	subtitle:SetPoint("TOP", title, "BOTTOM", 0, -4)

	local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	closeBtn:SetPoint("TOPRIGHT", -2, -2)
	closeBtn:SetScript("OnClick", function()
		frame:Hide()
	end)

	frame:SetScript("OnShow", function()
		StartRain(rainLayer, 20)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
	end)
	frame:SetScript("OnHide", function()
		StopRain(rainLayer)
		PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
		if presetMenu then
			presetMenu:Hide()
		end
	end)

	local nav = CreateFrame("Frame", nil, frame)
	nav:SetPoint("TOPLEFT", 16, -70)
	nav:SetSize(170, 570)

	local navPanel = frame:CreateTexture(nil, "BORDER")
	navPanel:SetPoint("TOPLEFT", nav, "TOPLEFT", -8, 8)
	navPanel:SetPoint("BOTTOMRIGHT", nav, "BOTTOMRIGHT", 8, -8)
	navPanel:SetColorTexture(0.01, 0.05, 0.10, 0.42)

	local navButtons = {}
	ns.navButtons = navButtons
	for i, tab in ipairs(TABS) do
		local btn = CreateTabButton(nav, tab.label, function()
			ns:SelectTab(tab.key)
		end, 168, tab.icon)
		btn:SetPoint("TOPLEFT", 0, -(i - 1) * 32)
		navButtons[tab.key] = btn
	end

	local content = CreateFrame("Frame", nil, frame)
	content:SetPoint("TOPLEFT", nav, "TOPRIGHT", 16, 0)
	content:SetPoint("BOTTOMRIGHT", -16, 16)

	local contentPanel = frame:CreateTexture(nil, "BORDER")
	contentPanel:SetPoint("TOPLEFT", content, "TOPLEFT", -8, 8)
	contentPanel:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", 8, -8)
	contentPanel:SetColorTexture(0.01, 0.05, 0.10, 0.3)

	local pages = {}
	ns.pages = pages
	for _, tab in ipairs(TABS) do
		local page = CreateFrame("Frame", nil, content)
		page:SetAllPoints()
		page:Hide()
		pages[tab.key] = page
		if tab.key == "general" then
			BuildGeneralPage(page)
		elseif tab.key == "ignore" then
			BuildIgnorePage(page)
		elseif tab.key == "guild" then
			BuildGuildPage(page)
		else
			BuildScopePage(page, tab.key)
		end
	end

	ns:SelectTab("general")
end

function ns:ToggleGUI()
	if not ns.frame then
		ns:BuildGUI()
	end
	if ns.frame:IsShown() then
		ns.frame:Hide()
	else
		ns.frame:Show()
	end
end
