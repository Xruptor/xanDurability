local ADDON_NAME, addon = ...
if not _G[ADDON_NAME] then
	_G[ADDON_NAME] = CreateFrame("Frame", ADDON_NAME, UIParent, BackdropTemplateMixin and "BackdropTemplate")
end
addon = _G[ADDON_NAME]

addon.configFrame = CreateFrame("frame", ADDON_NAME.."_config_eventFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
local configFrame = addon.configFrame

local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

local lastObject
local function addConfigEntry(objEntry, adjustX, adjustY)
	
	objEntry:ClearAllPoints()
	
	if not lastObject then
		objEntry:SetPoint("TOPLEFT", 20, -150)
	else
		objEntry:SetPoint("LEFT", lastObject, "BOTTOMLEFT", adjustX or 0, adjustY or -30)
	end
	
	lastObject = objEntry
end

local chkBoxIndex = 0
local function createCheckbutton(parentFrame, displayText)
	chkBoxIndex = chkBoxIndex + 1
	
	local checkbutton = CreateFrame("CheckButton", ADDON_NAME.."_config_chkbtn_" .. chkBoxIndex, parentFrame, "ChatConfigCheckButtonTemplate")
	getglobal(checkbutton:GetName() .. 'Text'):SetText(" "..displayText)
	
	return checkbutton
end

local buttonIndex = 0
local function createButton(parentFrame, displayText)
	buttonIndex = buttonIndex + 1
	
	local button = CreateFrame("Button", ADDON_NAME.."_config_button_" .. buttonIndex, parentFrame, "UIPanelButtonTemplate")
	button:SetText(displayText)
	button:SetHeight(30)
	button:SetWidth(button:GetTextWidth() + 30)

	return button
end

local sliderIndex = 0
local function createSlider(parentFrame, displayText, minVal, maxVal, setStep)
	sliderIndex = sliderIndex + 1

	local SliderBackdrop  = {
		bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
		edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
		tile = true, tileSize = 8, edgeSize = 8,
		insets = { left = 3, right = 3, top = 6, bottom = 6 }
	}

	local slider = CreateFrame("Slider", ADDON_NAME.."_config_slider_" .. sliderIndex, parentFrame, BackdropTemplateMixin and "BackdropTemplate")
	slider:SetOrientation("HORIZONTAL")
	slider:SetHeight(15)
	slider:SetWidth(300)
	slider:SetHitRectInsets(0, 0, -10, 0)
	slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
	slider:SetMinMaxValues(minVal or 0.5, maxVal or 5)
	slider:SetValue(0.5)
	slider:SetBackdrop(SliderBackdrop)
	slider:SetValueStep(setStep or 1)

	local label = slider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	label:SetPoint("CENTER", slider, "CENTER", 0, 16)
	label:SetJustifyH("CENTER")
	label:SetHeight(15)
	label:SetText(displayText)

	local lowtext = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	lowtext:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 2, 3)
	lowtext:SetText(minVal)

	local hightext = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	hightext:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", -2, 3)
	hightext:SetText(maxVal)

	local currVal = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	currVal:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", 45, 12)
	currVal:SetText('(?)')
	slider.currVal = currVal

	return slider
end

local function LoadAboutFrame()

	--Code inspired from tekKonfigAboutPanel
	local about = CreateFrame("Frame", ADDON_NAME.."AboutPanel", InterfaceOptionsFramePanelContainer, BackdropTemplateMixin and "BackdropTemplate")
	about.name = ADDON_NAME
	about:Hide()
	
    local fields = {"Version", "Author"}
	local notes = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Notes")

    local title = about:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")

	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText(ADDON_NAME)

	local subtitle = about:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtitle:SetHeight(32)
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtitle:SetPoint("RIGHT", about, -32, 0)
	subtitle:SetNonSpaceWrap(true)
	subtitle:SetJustifyH("LEFT")
	subtitle:SetJustifyV("TOP")
	subtitle:SetText(notes)

	local anchor
	for _,field in pairs(fields) do
		local val = C_AddOns.GetAddOnMetadata(ADDON_NAME, field)
		if val then
			local title = about:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
			title:SetWidth(75)
			if not anchor then title:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", -2, -8)
			else title:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -6) end
			title:SetJustifyH("RIGHT")
			title:SetText(field:gsub("X%-", ""))

			local detail = about:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
			detail:SetPoint("LEFT", title, "RIGHT", 4, 0)
			detail:SetPoint("RIGHT", -16, 0)
			detail:SetJustifyH("LEFT")
			detail:SetText(val)

			anchor = title
		end
	end
	
	if InterfaceOptions_AddCategory then
		InterfaceOptions_AddCategory(about)
	else
		local category, layout = _G.Settings.RegisterCanvasLayoutCategory(about, about.name);
		_G.Settings.RegisterAddOnCategory(category);
		addon.settingsCategory = category
	end

	return about
end

function configFrame:EnableConfig()
	
	addon.aboutPanel = LoadAboutFrame()
	
	--bg shown
	local btnBG = createCheckbutton(addon.aboutPanel, L.SlashBGInfo)
	btnBG:SetScript("OnShow", function() btnBG:SetChecked(XanDUR_DB.bgShown) end)
	btnBG.func = function(slashSwitch)
		local value = XanDUR_DB.bgShown
		if not slashSwitch then value = XanDUR_DB.bgShown end

		if value then
			XanDUR_DB.bgShown = false
			DEFAULT_CHAT_FRAME:AddMessage(L.SlashBGOff)
		else
			XanDUR_DB.bgShown = true
			DEFAULT_CHAT_FRAME:AddMessage(L.SlashBGOn)
		end
		
		addon:BackgroundToggle()
	end
	btnBG:SetScript("OnClick", btnBG.func)
	
	addConfigEntry(btnBG, 0, -20)
	addon.aboutPanel.btnBG = btnBG
	
	--reset
	local btnReset = createButton(addon.aboutPanel, L.SlashResetInfo)
	btnReset.func = function()
		DEFAULT_CHAT_FRAME:AddMessage(L.SlashResetAlert)
		addon:ClearAllPoints()
		addon:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	end
	btnReset:SetScript("OnClick", btnReset.func)
	
	addConfigEntry(btnReset, 0, -30)
	addon.aboutPanel.btnReset = btnReset
	
	--scale
	local sliderScale = createSlider(addon.aboutPanel, L.SlashScaleText, 0.5, 5, 0.1)
	sliderScale:SetScript("OnShow", function()
		sliderScale:SetValue(XanDUR_DB.scale)
		sliderScale.currVal:SetText("("..XanDUR_DB.scale..")")
	end)
	sliderScale.sliderFunc = function(self, value)
		value = math.floor(value * 10) / 10
		if value < 0.5 then value = 0.5 end --always make sure we are 0.5 as the highest zero.  Anything lower will make the frame dissapear
		if value > 5 then value = 5 end --nothing bigger than this
		sliderScale.currVal:SetText("("..value..")")
		sliderScale:SetValue(value)
	end
	sliderScale.sliderMouseUp = function(self, button)
		local value = math.floor(self:GetValue() * 10) / 10
		addon:SetAddonScale(value)
	end
	sliderScale:SetScript("OnValueChanged", sliderScale.sliderFunc)
	sliderScale:SetScript("OnMouseUp", sliderScale.sliderMouseUp)

	addConfigEntry(sliderScale, 0, -40)
	addon.aboutPanel.sliderScale = sliderScale

	local btnAutoRepair = createCheckbutton(addon.aboutPanel, L.SlashAutoRepairInfo)
	btnAutoRepair:SetScript("OnShow", function() btnAutoRepair:SetChecked(XanDUR_Opt.autoRepair) end)
	btnAutoRepair.func = function(slashSwitch)
		local value = XanDUR_Opt.autoRepair
		if not slashSwitch then value = XanDUR_Opt.autoRepair end

		if value then
			XanDUR_Opt.autoRepair = false
			DEFAULT_CHAT_FRAME:AddMessage(L.SlashAutoRepairOff)
		else
			XanDUR_Opt.autoRepair = true
			DEFAULT_CHAT_FRAME:AddMessage(L.SlashAutoRepairOn)
		end
	end
	btnAutoRepair:SetScript("OnClick", btnAutoRepair.func)
	
	addConfigEntry(btnAutoRepair, 0, -40)
	addon.aboutPanel.btnAutoRepair = btnAutoRepair
	
	if not self.IsClassic then
		local btnAutoRepairGuild = createCheckbutton(addon.aboutPanel, L.SlashAutoRepairGuildInfo)
		btnAutoRepairGuild:SetScript("OnShow", function() btnAutoRepairGuild:SetChecked(XanDUR_Opt.autoRepairUseGuild) end)
		btnAutoRepairGuild.func = function(slashSwitch)
			local value = XanDUR_Opt.autoRepairUseGuild
			if not slashSwitch then value = XanDUR_Opt.autoRepairUseGuild end

			if value then
				XanDUR_Opt.autoRepairUseGuild = false
				DEFAULT_CHAT_FRAME:AddMessage(L.SlashAutoRepairGuildOff)
			else
				XanDUR_Opt.autoRepairUseGuild = true
				DEFAULT_CHAT_FRAME:AddMessage(L.SlashAutoRepairGuildOn)
			end
		end
		btnAutoRepairGuild:SetScript("OnClick", btnAutoRepairGuild.func)
		
		addConfigEntry(btnAutoRepairGuild, 0, -20)
		addon.aboutPanel.btnAutoRepairGuild = btnAutoRepairGuild
	end
	
	local btnShowMoreDetails = createCheckbutton(addon.aboutPanel, L.ShowMoreDetails)
	btnShowMoreDetails:SetScript("OnShow", function() btnShowMoreDetails:SetChecked(XanDUR_Opt.ShowMoreDetails) end)
	btnShowMoreDetails.func = function(slashSwitch)
		local value = XanDUR_Opt.ShowMoreDetails
		if not slashSwitch then value = XanDUR_Opt.ShowMoreDetails end

		if value then
			XanDUR_Opt.ShowMoreDetails = false
			DEFAULT_CHAT_FRAME:AddMessage(L.ShowMoreDetailsOff)
		else
			XanDUR_Opt.ShowMoreDetails = true
			DEFAULT_CHAT_FRAME:AddMessage(L.ShowMoreDetailsOn)
		end
	end
	btnShowMoreDetails:SetScript("OnClick", btnShowMoreDetails.func)
	
	addConfigEntry(btnShowMoreDetails, 0, -20)
	addon.aboutPanel.btnShowMoreDetails = btnShowMoreDetails
	

end
