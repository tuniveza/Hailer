local ADDON_NAME, ns = ...

local button

local function UpdatePosition()
	local angle = math.rad(HailerDB.minimap.pos or 220)
	local radius = (Minimap:GetWidth() / 2) + 5
	local x, y = math.cos(angle) * radius, math.sin(angle) * radius
	button:ClearAllPoints()
	button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function OnUpdate(self)
	local mx, my = Minimap:GetCenter()
	local px, py = GetCursorPosition()
	local scale = UIParent:GetEffectiveScale()
	px, py = px / scale, py / scale
	local angle = math.deg(math.atan2(py - my, px - mx))
	HailerDB.minimap.pos = angle
	UpdatePosition()
end

local function CreateButton()
	button = CreateFrame("Button", "HailerMinimapButton", Minimap)
	button:SetSize(31, 31)
	button:SetFrameStrata("MEDIUM")
	button:SetFrameLevel(8)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:RegisterForDrag("LeftButton")
	button:SetMovable(true)

	local overlay = button:CreateTexture(nil, "OVERLAY")
	overlay:SetSize(53, 53)
	overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	overlay:SetPoint("TOPLEFT")

	local background = button:CreateTexture(nil, "BACKGROUND")
	background:SetSize(20, 20)
	background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
	background:SetPoint("CENTER", 0, 0)

	local glow = button:CreateTexture(nil, "ARTWORK", nil, -1)
	glow:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-SoftEdge-Circle")
	glow:SetSize(30, 30)
	glow:SetPoint("CENTER", 0, 1)
	glow:SetVertexColor(0.4, 0.85, 1, 0.55)
	local glowAG = glow:CreateAnimationGroup()
	glowAG:SetLooping("BOUNCE")
	local glowAlpha = glowAG:CreateAnimation("Alpha")
	glowAlpha:SetFromAlpha(0.25)
	glowAlpha:SetToAlpha(0.6)
	glowAlpha:SetDuration(1.6)
	glowAlpha:SetSmoothing("IN_OUT")
	glowAG:Play()

	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetSize(19, 19)
	icon:SetTexture("Interface\\Icons\\Spell_Nature_WaterBolt")
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	icon:SetPoint("CENTER", 0, 1)
	icon:SetVertexColor(0.75, 0.95, 1)

	local highlight = button:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetSize(31, 31)
	highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
	highlight:SetPoint("CENTER", 0, 0)
	button:SetHighlightTexture(highlight)

	button:SetScript("OnDragStart", function(self)
		self:SetScript("OnUpdate", OnUpdate)
	end)
	button:SetScript("OnDragStop", function(self)
		self:SetScript("OnUpdate", nil)
	end)

	button:SetScript("OnClick", function(_, mouseButton)
		if mouseButton == "LeftButton" then
			if ns.ToggleGUI then
				ns:ToggleGUI()
			end
		elseif mouseButton == "RightButton" then
			local db = HailerDB
			local anyEnabled = false
			for _, key in ipairs(ns.optionalScopeOrder) do
				if db.scopes[key].enabled then
					anyEnabled = true
					break
				end
			end
			for _, key in ipairs(ns.optionalScopeOrder) do
				db.scopes[key].enabled = not anyEnabled
			end
			if ns.RefreshGUI then
				ns:RefreshGUI()
			end
			local state = (not anyEnabled) and "|cff40e0ffenabled|r" or "|cffff6060disabled|r"
			print("Hailer: optional greetings (Party/Instance/Community/Custom/Friends) " .. state .. ". Guild toggles are untouched -- use the Guild tab.")
		end
	end)

	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetText("Hailer", 0.4, 0.9, 1)
		GameTooltip:AddLine("Left-click: open settings", 1, 1, 1)
		GameTooltip:AddLine("Right-click: toggle optional greetings (not Guild)", 1, 1, 1)
		GameTooltip:AddLine("Drag: move this button", 1, 1, 1)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	UpdatePosition()

	if HailerDB.minimap.hide then
		button:Hide()
	end
end

function ns:InitMinimap()
	if not button then
		CreateButton()
	end
end

function ns:SetMinimapShown(shown)
	HailerDB.minimap.hide = not shown
	if button then
		if shown then
			button:Show()
		else
			button:Hide()
		end
	end
end
