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
local LibQTip = LibStub('LibQTip-1.0')

local debugf = tekDebug and tekDebug:GetFrame(ADDON_NAME)
local function Debug(...)
    if debugf then debugf:AddMessage(string.join(", ", tostringall(...))) end
end

local WOW_PROJECT_ID = _G.WOW_PROJECT_ID
local WOW_PROJECT_MAINLINE = _G.WOW_PROJECT_MAINLINE
local WOW_PROJECT_CLASSIC = _G.WOW_PROJECT_CLASSIC
--local WOW_PROJECT_BURNING_CRUSADE_CLASSIC = _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC
local WOW_PROJECT_WRATH_CLASSIC = _G.WOW_PROJECT_WRATH_CLASSIC

addon.IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
addon.IsClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
--BSYC.IsTBC_C = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
addon.IsWLK_C = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC


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

local xanDurabilityTooltip = CreateFrame("GameTooltip", "xanDurabilityTooltip", UIParent, "GameTooltipTemplate")

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
	if XanDUR_Opt.ShowMoreDetails == nil then XanDUR_Opt.ShowMoreDetails = true end

	self:CreateDURFrame()
	self:RestoreLayout(ADDON_NAME)

	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	self:RegisterEvent("MERCHANT_SHOW")

	SLASH_XANDURABILITY1 = "/xdu";
	SlashCmdList["XANDURABILITY"] = function()
		if not addon.IsRetail then
			InterfaceOptionsFrame:Show() --has to be here to load the about frame onLoad
		end
		InterfaceOptionsFrame_OpenToCategory(addon.aboutPanel) --force the panel to show
	end

	if addon.configFrame then addon.configFrame:EnableConfig() end

	local ver = C_AddOns.GetAddOnMetadata(ADDON_NAME,"Version") or '1.0'
	DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF99CC33%s|r [v|cFF20ff20%s|r] loaded:   /xdu", ADDON_NAME, ver or "1.0"))

	addon:GetDurabilityInfo()
	addon:UpdatePercent()

end

function addon:SetTipAnchor(frame, qTip)
    local x, y = frame:GetCenter()

	qTip:ClearAllPoints()
	qTip:SetClampedToScreen(true)

    if not x or not y then
        qTip:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT")
		return
    end

    local hhalf = (x > UIParent:GetWidth() * 2 / 3) and "RIGHT" or (x < UIParent:GetWidth() / 3) and "LEFT" or ""
    local vhalf = (y > UIParent:GetHeight() / 2) and "TOP" or "BOTTOM"

	qTip:SetPoint(vhalf .. hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP") .. hhalf)
end

function addon:CreateDURFrame()

	addon:SetWidth(61)
	addon:SetHeight(27)
	addon:SetMovable(true)
	addon:SetClampedToScreen(true)

	addon:SetAddonScale(XanDUR_DB.scale, true)

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
		xanDurabilityTooltip:Hide()
	end)


	addon:SetScript("OnEnter",function()
		if XanDUR_Opt.ShowMoreDetails then
			if not xanDurabilityTooltip.qTipDur or not LibQTip:IsAcquired("xanDurabilityQTip") then
				xanDurabilityTooltip.qTipDur = LibQTip:Acquire("xanDurabilityQTip", 4, "LEFT", "CENTER", "LEFT", "RIGHT")
			end
			self:SetSmartTipAnchor(xanDurabilityTooltip, xanDurabilityTooltip.qTipDur)
			xanDurabilityTooltip.qTipDur:Clear()

		elseif not XanDUR_Opt.ShowMoreDetails and xanDurabilityTooltip.qTipDur then
			LibQTip:Release(xanDurabilityTooltip.qTipDur)
			xanDurabilityTooltip.qTipDur = nil
		end

		xanDurabilityTooltip:SetOwner(self, "ANCHOR_TOP")
		xanDurabilityTooltip:SetPoint(self:GetTipAnchor(addon))
		xanDurabilityTooltip:ClearLines()

		local cP = (pEquipDura.max > 0 and floor(pEquipDura.min / pEquipDura.max * 100)) or 100
		local bP = (pBagDura.max > 0 and floor(pBagDura.min / pBagDura.max * 100)) or 100
		local tP = ((pEquipDura.max + pBagDura.max) > 0 and floor( (pEquipDura.min + pBagDura.min) / (pEquipDura.max + pBagDura.max) * 100)) or 100

		if cP > 100 then cP = 100 end
		if bP > 100 then bP = 100 end
		if tP > 100 then tP = 100 end

		xanDurabilityTooltip:AddLine(ADDON_NAME)
		xanDurabilityTooltip:AddLine(L.TooltipDragInfo, 64/255, 224/255, 208/255)
		xanDurabilityTooltip:AddLine(" ")
		xanDurabilityTooltip:AddDoubleLine("|cFFFFFFFF"..L.Equipped.."|r  ("..self:DurColor(cP)..cP.."%|r".."):", GetMoneyString(equipCost, true), nil,nil,nil, 1,1,1)
		xanDurabilityTooltip:AddDoubleLine("|cFFFFFFFF"..L.Bags.."|r  ("..self:DurColor(bP)..bP.."%|r".."):", GetMoneyString(bagCost, true), nil,nil,nil, 1,1,1)
		xanDurabilityTooltip:AddLine(" ")
		xanDurabilityTooltip:AddDoubleLine("|cFFFFFFFF"..L.Total.."|r  ("..self:DurColor(tP)..tP.."%|r".."):", GetMoneyString(totalCost, true), nil,nil,nil, 1,1,1)
		xanDurabilityTooltip:Show()

		if xanDurabilityTooltip.qTipDur and self.moreDurInfo and #self.moreDurInfo > 0 then
			for k, v in ipairs(self.moreDurInfo) do
				local moneyString = v.slotRepairCost
				if v.slotRepairCost >= 0 then
					moneyString = GetMoneyString(v.slotRepairCost, true)
				else
					moneyString = string.rep(" ", 4)
				end
				local lineNum = xanDurabilityTooltip.qTipDur:AddLine("|cFFFFFFFF"..v.slotName, v.slotItem, v.slotDurability, moneyString)
				--xanDurabilityTooltip.qTipDur:SetLineTextColor(lineNum, color.r, color.g, color.b, 1)

			end
			if xanDurabilityTooltip.qTipDur then
				xanDurabilityTooltip.qTipDur:Show()
			end
		end

	end)

	xanDurabilityTooltip:HookScript("OnHide", function(self)
		if self.qTipDur then
			LibQTip:Release(self.qTipDur)
			self.qTipDur = nil
		end
	end)

	addon:Show()
end

function addon:SetAddonScale(value, bypass)
	--fix this in case it's ever smaller than   
	if value < 0.5 then value = 0.5 end --anything smaller and it would vanish  
	if value > 5 then value = 5 end --WAY too big  

	XanDUR_DB.scale = value

	if not bypass then
		DEFAULT_CHAT_FRAME:AddMessage(string.format(L.SlashScaleSet, value))
	end
	addon:SetScale(XanDUR_DB.scale)
end

function addon:GetDurabilityInfo()
	--https://wowpedia.fandom.com/wiki/Enum.InventoryType

	pEquipDura = { min=0, max=0};
	pBagDura = { min=0, max=0};

	if not tmpTip then tmpTip = CreateFrame("GameTooltip", "XDTT", UIParent, "GameTooltipTemplate") end

	equipCost = 0

	self.moreDurInfo = {}
	self.addSpace = false

	local xGetNumSlots = (C_Container and C_Container.GetContainerNumSlots) or GetContainerNumSlots
	local xGetContainerInfo = (C_Container and C_Container.GetContainerItemInfo) or GetContainerItemInfo
	local xGetContainerItemDurability = (C_Container and C_Container.GetContainerItemDurability) or GetContainerItemDurability

	for slotName, slotID in pairs(Enum.InventoryType) do
		local hasItem, repairCost

		--we can't use SetInventoryItem on retail to get the repair costs as it will return nil, you have to use the C_TooltipInfo namespace for everything 
		if C_TooltipInfo and C_TooltipInfo.GetInventoryItem then
			hasItem = C_TooltipInfo.GetInventoryItem("player", slotID)
			if hasItem then
				repairCost = hasItem.repairCost
			end
		else
			--the old way
			hasItem, _, repairCost = tmpTip:SetInventoryItem("player", slotID)
		end

		local Minimum, Maximum = GetInventoryItemDurability(slotID)
		local equipLoc = slotName

		if hasItem and repairCost and repairCost > 0 then
			local itemLink = GetInventoryItemLink("player", slotID)

			if itemLink then
				equipLoc = select(9, GetItemInfo(itemLink))
				if equipLoc then equipLoc = _G[equipLoc] end
				table.insert(self.moreDurInfo,  {slotName=equipLoc, slotItem=itemLink, slotDurability=Minimum.."/"..Maximum, slotRepairCost=repairCost})
			else
				local itemID = GetInventoryItemID("player", slotID) or "Unknown"
				table.insert(self.moreDurInfo,  {slotName=equipLoc, slotItem="itemID:"..itemID, slotDurability=Minimum.."/"..Maximum, slotRepairCost=repairCost})
			end

			equipCost = equipCost + repairCost
		end

		if Minimum and Maximum then
			pEquipDura.min = pEquipDura.min + Minimum
			pEquipDura.max = pEquipDura.max + Maximum
		end
	end

	bagCost = 0
	for bag = 0, 4 do
		for slot = 1, xGetNumSlots(bag) do
			local repairCost

			--we can't use SetBagItem on retail as it generates errors and causes problems with BattlePet Tooltip, since they don't have durability
			if C_TooltipInfo and C_TooltipInfo.GetBagItem then
				local data = C_TooltipInfo.GetBagItem(bag, slot)
				if data then
					repairCost = data.repairCost
				end
			else
				--the old way
				_, repairCost = tmpTip:SetBagItem(bag, slot)
			end

			local Minimum, Maximum = xGetContainerItemDurability(bag, slot)

			if repairCost and repairCost > 0 then

				local itemLink

				if C_Container and C_Container.GetContainerItemInfo then
					local containerInfo = xGetContainerInfo(bag, slot)
					itemLink = containerInfo and containerInfo.hyperlink
				else
					itemLink = select(7, xGetContainerInfo(bag, slot))
				end

				if itemLink then
					if not self.addSpace then
						table.insert(self.moreDurInfo,  {slotName=string.rep(" ", 4),  slotItem=string.rep(" ", 4), slotDurability=string.rep(" ", 4), slotRepairCost=-1})
						self.addSpace = true
					end
					table.insert(self.moreDurInfo,  {slotName=BACKPACK_TOOLTIP, slotItem=itemLink, slotDurability=Minimum.."/"..Maximum, slotRepairCost=repairCost})
				else
					if not self.addSpace then
						table.insert(self.moreDurInfo,  {slotName=string.rep(" ", 4),  slotItem=string.rep(" ", 4), slotDurability=string.rep(" ", 4), slotRepairCost=-1})
						self.addSpace = true
					end
					local itemID = GetContainerItemID(bag, slot) or "Unknown"
					table.insert(self.moreDurInfo,  {slotName=BACKPACK_TOOLTIP, slotItem="itemID:"..itemID, slotDurability=Minimum.."/"..Maximum, slotRepairCost=repairCost})
				end

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
				if not self.IsClassic and XanDUR_Opt.autoRepairUseGuild and CanGuildBankRepair() then
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

function addon:SetSmartTipAnchor(frame, qTip)
    local x, y = frame:GetCenter()

	qTip:ClearAllPoints()
	qTip:SetClampedToScreen(true)

    if not x or not y then
        qTip:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT")
		return
    end

    local hhalf = (x > UIParent:GetWidth() * 2 / 3) and "RIGHT" or (x < UIParent:GetWidth() / 3) and "LEFT" or ""
    local vhalf = (y > UIParent:GetHeight() / 2) and "TOP" or "BOTTOM"

	qTip:SetPoint(vhalf .. hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP") .. hhalf)
end
