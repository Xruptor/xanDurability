--I'm the original author of DurabilityStatus.  Yes I changed my name from Derkyle to Xruptor.  Anyways, although
--I liked what they have done with my old mod.  I liked the original simplistic minimalistic appeal my original mod had.
--So I decided to do it again :)

--This mod creates a very simple movable box with the current players durability.  The box can be moved :)
--use /xdu to access the slash commands

local ADDON_NAME, addon = ...
if not _G[ADDON_NAME] then
	_G[ADDON_NAME] = CreateFrame("Frame", ADDON_NAME, UIParent, BackdropTemplateMixin and "BackdropTemplate")
end
addon = _G[ADDON_NAME]

local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

local debugf = tekDebug and tekDebug:GetFrame(ADDON_NAME)
local function Debug(...)
    if debugf then debugf:AddMessage(string.join(", ", tostringall(...))) end
end

addon:RegisterEvent("ADDON_LOADED")
addon:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" or event == "PLAYER_LOGIN" then
		if event == "ADDON_LOADED" then
			local arg1 = ...
			if arg1 and arg1 == ADDON_NAME then
				self:UnregisterEvent("ADDON_LOADED")
				self:RegisterEvent("PLAYER_LOGIN")
			end
			return
		end
		if IsLoggedIn() then
			self:EnableAddon(event, ...)
			self:UnregisterEvent("PLAYER_LOGIN")
		end
		return
	end
	if self[event] then
		return self[event](self, event, ...)
	end
end)

--repair variables
local equipCost = 0;
local bagCost = 0;
local totalCost = 0;

--percent variables
local pEquipDura = { min=0, max=0};
local pBagDura = { min=0, max=0};

local Slots = { "HeadSlot", "ShoulderSlot", "ChestSlot", "WaistSlot", "WristSlot", "HandsSlot", "LegsSlot", "FeetSlot", "MainHandSlot", "SecondaryHandSlot", "RangedSlot" }

local IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

----------------------
--      Enable      --
----------------------

function addon:EnableAddon()

	if not XanDUR_DB then XanDUR_DB = {} end
	if not XanDUR_Opt then XanDUR_Opt = {} end
	if XanDUR_DB.bgShown == nil then XanDUR_DB.bgShown = true end
	if XanDUR_DB.scale == nil then XanDUR_DB.scale = 1 end
	if XanDUR_Opt.autoRepair == nil then XanDUR_Opt.autoRepair = true end
	if XanDUR_Opt.autoRepairUseGuild == nil then XanDUR_Opt.autoRepairUseGuild = false end

	self:CreateDURFrame()
	self:RestoreLayout(ADDON_NAME)

	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	self:RegisterEvent("MERCHANT_SHOW")
	
	SLASH_XANDURABILITY1 = "/xdu";
	SlashCmdList["XANDURABILITY"] = function()
		InterfaceOptionsFrame:Show() --has to be here to load the about frame onLoad
		InterfaceOptionsFrame_OpenToCategory(addon.aboutPanel) --force the panel to show
	end
	
	if addon.configFrame then addon.configFrame:EnableConfig() end
	
	local ver = GetAddOnMetadata(ADDON_NAME,"Version") or '1.0'
	DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF99CC33%s|r [v|cFF20ff20%s|r] loaded:   /xdu", ADDON_NAME, ver or "1.0"))

	addon:GetDurabilityInfo()
	addon:UpdatePercent()
	
end

function addon:CreateDURFrame()

	addon:SetWidth(61)
	addon:SetHeight(27)
	addon:SetMovable(true)
	addon:SetClampedToScreen(true)
	
	addon:SetScale(XanDUR_DB.scale)
	
	if XanDUR_DB.bgShown then
		addon:SetBackdrop( {
			bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground";
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border";
			tile = true; tileSize = 32; edgeSize = 16;
			insets = { left = 5; right = 5; top = 5; bottom = 5; };
		} );
		addon:SetBackdropBorderColor(0.5, 0.5, 0.5);
		addon:SetBackdropColor(0.5, 0.5, 0.5, 0.6)
	else
		addon:SetBackdrop(nil)
	end
	
	addon:EnableMouse(true);
	
	local t = addon:CreateTexture("$parentIcon", "ARTWORK")
	t:SetTexture("Interface\\Icons\\Trade_Blacksmithing")
	t:SetWidth(16)
	t:SetHeight(16)
	t:SetPoint("TOPLEFT",5,-6)

	local g = addon:CreateFontString("$parentText", "ARTWORK", "GameFontNormalSmall")
	g:SetJustifyH("LEFT")
	g:SetPoint("CENTER",8,0)
	g:SetText("")

	addon:SetScript("OnMouseDown",function()
		if (IsShiftKeyDown()) then
			self.isMoving = true
			self:StartMoving();
	 	end
	end)
	addon:SetScript("OnMouseUp",function()
		if( self.isMoving ) then

			self.isMoving = nil
			self:StopMovingOrSizing()

			addon:SaveLayout(self:GetName());

		end
	end)
	addon:SetScript("OnLeave",function()
		GameTooltip:Hide()
	end)

	addon:SetScript("OnEnter",function()
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint(self:GetTipAnchor(self))
		GameTooltip:ClearLines()

		local cP = (pEquipDura.max > 0 and floor(pEquipDura.min / pEquipDura.max * 100)) or 100
		local bP = (pBagDura.max > 0 and floor(pBagDura.min / pBagDura.max * 100)) or 100
		local tP = ((pEquipDura.max + pBagDura.max) > 0 and floor( (pEquipDura.min + pBagDura.min) / (pEquipDura.max + pBagDura.max) * 100)) or 100
		
		if cP > 100 then cP = 100 end
		if bP > 100 then bP = 100 end
		if tP > 100 then tP = 100 end

		GameTooltip:AddLine(ADDON_NAME)
		GameTooltip:AddLine(L.TooltipDragInfo, 64/255, 224/255, 208/255)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine("|cFFFFFFFF"..L.Equipped.."|r  ("..self:DurColor(cP)..cP.."%|r".."):", GetMoneyString(equipCost, true), nil,nil,nil, 1,1,1)
		GameTooltip:AddDoubleLine("|cFFFFFFFF"..L.Bags.."|r  ("..self:DurColor(bP)..bP.."%|r".."):", GetMoneyString(bagCost, true), nil,nil,nil, 1,1,1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine("|cFFFFFFFF"..L.Total.."|r  ("..self:DurColor(tP)..tP.."%|r".."):", GetMoneyString(totalCost, true), nil,nil,nil, 1,1,1)
		GameTooltip:Show()
	end)
	
	addon:Show();
end

function addon:GetDurabilityInfo()
	
	pEquipDura = { min=0, max=0};
	pBagDura = { min=0, max=0};
	
	if not tmpTip then tmpTip = CreateFrame("GameTooltip", "XDTT", UIParent, BackdropTemplateMixin and "BackdropTemplate") end
	
	equipCost = 0
	for _, slotName in ipairs(Slots) do
		local item = _G["Character" .. slotName]
		if item then
			local hasItem, _, repairCost = tmpTip:SetInventoryItem("player", item:GetID())
			local Minimum, Maximum = GetInventoryItemDurability(item:GetID())

			if hasItem and repairCost and repairCost > 0 then
				equipCost = equipCost + repairCost
			end
			if Minimum and Maximum then
				pEquipDura.min = pEquipDura.min + Minimum
				pEquipDura.max = pEquipDura.max + Maximum
			end
		end
	end

	bagCost = 0
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local hasCooldown, repairCost = tmpTip:SetBagItem(bag, slot)
			local Minimum, Maximum = GetContainerItemDurability(bag, slot)

			if repairCost and repairCost > 0 then
				bagCost = bagCost + repairCost
			end
			if Minimum and Maximum then
				pBagDura.min = pBagDura.min + Minimum
				pBagDura.max = pBagDura.max + Maximum
			end
		end
	end
	if bagCost < 0 then bagCost = 0 end
	
	totalCost = equipCost + bagCost
end

function addon:UpdatePercent()
	--only show current equipped durability not total
	local tPer = floor(pEquipDura.min / pEquipDura.max * 100)
	getglobal(ADDON_NAME.."Text"):SetText(addon:DurColor(tPer)..tPer.."%|r");
end

function addon:SaveLayout(frame)
	if type(frame) ~= "string" then return end
	if not _G[frame] then return end
	if not XanDUR_DB then XanDUR_DB = {} end
	
	local opt = XanDUR_DB[frame] or nil

	if not opt then
		XanDUR_DB[frame] = {
			["point"] = "CENTER",
			["relativePoint"] = "CENTER",
			["xOfs"] = 0,
			["yOfs"] = 0,
		}
		opt = XanDUR_DB[frame]
		return
	end

	local point, relativeTo, relativePoint, xOfs, yOfs = _G[frame]:GetPoint()
	opt.point = point
	opt.relativePoint = relativePoint
	opt.xOfs = xOfs
	opt.yOfs = yOfs
end

function addon:RestoreLayout(frame)
	if type(frame) ~= "string" then return end
	if not _G[frame] then return end
	if not XanDUR_DB then XanDUR_DB = {} end

	local opt = XanDUR_DB[frame] or nil

	if not opt then
		XanDUR_DB[frame] = {
			["point"] = "CENTER",
			["relativePoint"] = "CENTER",
			["xOfs"] = 0,
			["yOfs"] = 0,
		}
		opt = XanDUR_DB[frame]
	end

	_G[frame]:ClearAllPoints()
	_G[frame]:SetPoint(opt.point, UIParent, opt.relativePoint, opt.xOfs, opt.yOfs)
end

function addon:BackgroundToggle()
	if XanDUR_DB.bgShown then
		addon:SetBackdrop( {
			bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground";
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border";
			tile = true; tileSize = 32; edgeSize = 16;
			insets = { left = 5; right = 5; top = 5; bottom = 5; };
		} );
		addon:SetBackdropBorderColor(0.5, 0.5, 0.5);
		addon:SetBackdropColor(0.5, 0.5, 0.5, 0.6)
	else
		addon:SetBackdrop(nil)
	end
end

function addon:DurColor(percent)

	local tmpString = ""
	
	if percent >= 80 then
		tmpString = "|cff00FF00"
	elseif percent >= 60 then
		tmpString = "|cff99FF00"
	elseif percent >= 40 then
		tmpString = "|cffFFFF00"
	elseif percent >= 20 then
		tmpString = "|cffFF9900"
	elseif percent >= 0 then
		tmpString = "|cffFF2000"
	end
	
	return tmpString;
end

------------------------------
--      Event Handlers      --
------------------------------

function addon:PLAYER_REGEN_ENABLED()
	addon:GetDurabilityInfo()
	addon:UpdatePercent()
end


function addon:UPDATE_INVENTORY_DURABILITY()
	addon:GetDurabilityInfo()
	addon:UpdatePercent()
end

------------------------
--      Auto Repair!      --
------------------------

function addon:MERCHANT_SHOW()

	if XanDUR_Opt.autoRepair then
		--do repairs
		if CanMerchantRepair() then
			local repairCost, canRepair = GetRepairAllCost()
			if canRepair and repairCost > 0 then
				if IsRetail and XanDUR_Opt.autoRepairUseGuild and CanGuildBankRepair() then
					local amount = GetGuildBankWithdrawMoney()
					local guildMoney = GetGuildBankMoney()
					if amount == -1 then
						amount = guildMoney
					else
						amount = min(amount, guildMoney)
					end
					if amount > repairCost then
						RepairAllItems(1)
						DEFAULT_CHAT_FRAME:AddMessage("xanDurability: "..L.RepairedFromGuild.." ["..GetCoinTextureString(repairCost).."]")
						return
					else
						DEFAULT_CHAT_FRAME:AddMessage("xanDurability: "..L.NoGuildFunds.." ["..GetCoinTextureString(repairCost).."]")
					end
				elseif GetMoney() > repairCost then
					RepairAllItems()
					DEFAULT_CHAT_FRAME:AddMessage("xanDurability: "..L.RepairedAll.." ["..GetCoinTextureString(repairCost).."]")
					return
				else
					DEFAULT_CHAT_FRAME:AddMessage("xanDurability: "..L.NoFunds.." ["..GetCoinTextureString(repairCost).."]")
				end
			end
		end
		
	end
	
end

------------------------
--      Tooltip!      --
------------------------

function addon:GetTipAnchor(frame)
	local x,y = frame:GetCenter()
	if not x or not y then return "TOPLEFT", "BOTTOMLEFT" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end
