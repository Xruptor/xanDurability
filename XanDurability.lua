--I'm the original author of DurabilityStatus.  Yes I changed my name from Derkyle to Xruptor.  Anyways, although
--I liked what they have done with my old mod.  I liked the original simplistic minimalistic appeal my original mod had.
--So I decided to do it again :)

--This mod creates a very simple movable box with the current players durability.  The box can be moved :)
--use /xdu to access the slash commands

local ADDON_NAME, private = ...
if not _G[ADDON_NAME] then
	_G[ADDON_NAME] = CreateFrame("Frame", ADDON_NAME, UIParent, BackdropTemplateMixin and "BackdropTemplate")
end
local addon = _G[ADDON_NAME]

-- Locale files load with the addon's private table (2nd return from "...").
addon.private = private
addon.L = (private and private.L) or addon.L or {}
local L = addon.L

local PAD4 = "    "

local wipeTable = _G.wipe or function(t)
	for k in pairs(t) do t[k] = nil end
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
local equipCost = 0
local bagCost = 0
local totalCost = 0

--percent variables
local pEquipDura = { min=0, max=0 }
local pBagDura = { min=0, max=0 }

local xanDurabilityTooltip = CreateFrame("GameTooltip", "xanDurabilityTooltip", UIParent, "GameTooltipTemplate")
local tmpTip

local function GetNumBagSlots()
	return (_G.NUM_BAG_SLOTS ~= nil and _G.NUM_BAG_SLOTS) or 4
end

local function ForEachBagIndex(callback)
	for bag = 0, GetNumBagSlots() do
		callback(bag)
	end

	-- Retail reagent bag (avoid hard-failing on Classic)
	if Enum and Enum.BagIndex and Enum.BagIndex.ReagentBag ~= nil then
		callback(Enum.BagIndex.ReagentBag)
	end
end

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
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:RegisterEvent("BAG_UPDATE_DELAYED")
	self:RegisterEvent("MERCHANT_SHOW")

	SLASH_XANDURABILITY1 = "/xdu";
	SlashCmdList["XANDURABILITY"] = function()
		if Settings then
			Settings.OpenToCategory("xanDurability")
		elseif InterfaceOptionsFrame_OpenToCategory then

			if not addon.IsRetail and InterfaceOptionsFrame then
				--only do this for Expansions less than Retail
				InterfaceOptionsFrame:Show() --has to be here to load the about frame onLoad
			else
				if InCombatLockdown() or GameMenuFrame:IsShown() or InterfaceOptionsFrame then
					return false
				end
			end

			InterfaceOptionsFrame_OpenToCategory(addon.aboutPanel)
		end
	end

	if addon.configFrame then addon.configFrame:EnableConfig() end

	local ver
	if C_AddOns and C_AddOns.GetAddOnMetadata then
		ver = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version")
	elseif GetAddOnMetadata then
		ver = GetAddOnMetadata(ADDON_NAME, "Version")
	end
	ver = ver or "1.0"
	DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF99CC33%s|r [v|cFF20ff20%s|r] loaded:   /xdu", ADDON_NAME, ver or "1.0"))

	self._durabilityDirty = true
	self._repairDirty = true
	self:RequestUpdate()

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
	addon.text = g

	addon:SetScript("OnMouseDown",function(self)
		if (IsShiftKeyDown()) then
			self.isMoving = true
			self:StartMoving();
	 	end
	end)
	addon:SetScript("OnMouseUp",function(self)
		if( self.isMoving ) then

			self.isMoving = nil
			self:StopMovingOrSizing()

			addon:SaveLayout(self:GetName());

		end
	end)
	addon:SetScript("OnLeave",function(self)
		xanDurabilityTooltip:Hide()
	end)


	addon:SetScript("OnEnter",function(self)
		-- Ensure durability is current for displayed percentages.
		if addon._durabilityDirty then
			addon:ScanDurabilityLight()
		end

		-- Only build repair info when the tooltip is actually shown.
		-- Always compute totals; compute per-item rows only when enabled.
		if addon._repairDirty or (XanDUR_Opt.ShowMoreDetails and not addon._repairDetailsMode) then
			addon:ScanRepairDetails(XanDUR_Opt.ShowMoreDetails)
		end

		xanDurabilityTooltip:SetOwner(self, "ANCHOR_NONE")
		addon:SetSmartTipAnchor(self, xanDurabilityTooltip)
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

		if XanDUR_Opt.ShowMoreDetails and self.moreDurInfo and #self.moreDurInfo > 0 then
			xanDurabilityTooltip:AddLine(" ")
			for _, v in ipairs(self.moreDurInfo) do
				if v.slotRepairCost and v.slotRepairCost < 0 then
					xanDurabilityTooltip:AddLine(" ")
				else
					local left = v.slotName or ""
					local item = v.slotItem or ""
					if left ~= "" then
						left = "|cFFFFFFFF" .. left .. "|r"
					end
					if item ~= "" then
						left = (left ~= "" and (left .. ": " .. item)) or item
					end

					local moneyString = (v.slotRepairCost and GetMoneyString(v.slotRepairCost, true)) or ""
					local right = (v.slotDurability or "") .. "  " .. moneyString
					xanDurabilityTooltip:AddDoubleLine(left, right)
				end
			end
		end

		xanDurabilityTooltip:Show()

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

function addon:ScanDurabilityLight()
	pEquipDura.min, pEquipDura.max = 0, 0
	pBagDura.min, pBagDura.max = 0, 0

	-- Equipped items: use real inventory slot IDs (more correct and faster than Enum.InventoryType).
	local firstSlot = _G.INVSLOT_FIRST_EQUIPPED or 1
	local lastSlot = _G.INVSLOT_LAST_EQUIPPED or 19
	for slotID = firstSlot, lastSlot do
		local Minimum, Maximum = GetInventoryItemDurability(slotID)
		if Minimum and Maximum then
			pEquipDura.min = pEquipDura.min + Minimum
			pEquipDura.max = pEquipDura.max + Maximum
		end
	end

	-- Bags
	local xGetNumSlots = (C_Container and C_Container.GetContainerNumSlots) or GetContainerNumSlots
	local xGetContainerItemDurability = (C_Container and C_Container.GetContainerItemDurability) or GetContainerItemDurability

	ForEachBagIndex(function(bag)
		local numSlots = xGetNumSlots and xGetNumSlots(bag)
		if not numSlots or numSlots <= 0 then return end
		for slot = 1, numSlots do
			local Minimum, Maximum = xGetContainerItemDurability(bag, slot)
			if Minimum and Maximum then
				pBagDura.min = pBagDura.min + Minimum
				pBagDura.max = pBagDura.max + Maximum
			end
		end
	end)

	self._durabilityDirty = false
end

function addon:ScanRepairDetails(includeDetails)
	if not tmpTip then tmpTip = CreateFrame("GameTooltip", "XDTT", UIParent, "GameTooltipTemplate") end

	equipCost, bagCost, totalCost = 0, 0, 0

	self.moreDurInfo = self.moreDurInfo or {}
	if includeDetails then
		wipeTable(self.moreDurInfo)
		self.addSpace = false
	end

	local xGetNumSlots = (C_Container and C_Container.GetContainerNumSlots) or GetContainerNumSlots
	local xGetContainerInfo = (C_Container and C_Container.GetContainerItemInfo) or GetContainerItemInfo
	local xGetContainerItemDurability = (C_Container and C_Container.GetContainerItemDurability) or GetContainerItemDurability
	local xGetContainerItemID = (C_Container and C_Container.GetContainerItemID) or GetContainerItemID

	local function AddRow(slotName, slotItem, slotDurability, slotRepairCost)
		if not includeDetails then return end
		local idx = #self.moreDurInfo + 1
		local row = self.moreDurInfo[idx]
		if not row then
			row = {}
			self.moreDurInfo[idx] = row
		end
		row.slotName = slotName
		row.slotItem = slotItem
		row.slotDurability = slotDurability
		row.slotRepairCost = slotRepairCost
	end

	-- Equipped items (repair costs can be expensive to compute on Retail, so only do it on-demand)
	local firstSlot = _G.INVSLOT_FIRST_EQUIPPED or 1
	local lastSlot = _G.INVSLOT_LAST_EQUIPPED or 19
	for slotID = firstSlot, lastSlot do
		local hasItem, repairCost

		-- Retail: tooltip data API (returns a table).
		if C_TooltipInfo and C_TooltipInfo.GetInventoryItem then
			hasItem = C_TooltipInfo.GetInventoryItem("player", slotID)
			repairCost = hasItem and hasItem.repairCost
		else
			-- Legacy: use a hidden tooltip.
			hasItem, _, repairCost = tmpTip:SetInventoryItem("player", slotID)
		end

		local Minimum, Maximum = GetInventoryItemDurability(slotID)
		if hasItem and repairCost and repairCost > 0 and Minimum and Maximum then
			equipCost = equipCost + repairCost

			if includeDetails then
				local itemLink = GetInventoryItemLink("player", slotID)
				local equipLoc = ""

				if itemLink then
					equipLoc = select(9, GetItemInfo(itemLink)) or ""
					equipLoc = (equipLoc ~= "" and _G[equipLoc]) or equipLoc
					AddRow(equipLoc, itemLink, Minimum .. "/" .. Maximum, repairCost)
				else
					local itemID = GetInventoryItemID("player", slotID) or "Unknown"
					AddRow(equipLoc, "itemID:" .. itemID, Minimum .. "/" .. Maximum, repairCost)
				end
			end
		end
	end

	-- Bag items
	ForEachBagIndex(function(bag)
		local numSlots = xGetNumSlots and xGetNumSlots(bag)
		if not numSlots or numSlots <= 0 then return end

		for slot = 1, numSlots do
			local repairCost

			-- Retail: avoid SetBagItem issues (battle pets etc.)
			if C_TooltipInfo and C_TooltipInfo.GetBagItem then
				local data = C_TooltipInfo.GetBagItem(bag, slot)
				repairCost = data and data.repairCost
			else
				_, repairCost = tmpTip:SetBagItem(bag, slot)
			end

			if repairCost and repairCost > 0 then
				local Minimum, Maximum = xGetContainerItemDurability(bag, slot)
				if Minimum and Maximum then
					bagCost = bagCost + repairCost

					if includeDetails then
						local itemLink
						if C_Container and C_Container.GetContainerItemInfo then
							local containerInfo = xGetContainerInfo(bag, slot)
							itemLink = containerInfo and containerInfo.hyperlink
						else
							itemLink = select(7, xGetContainerInfo(bag, slot))
						end

						if not self.addSpace then
							AddRow(PAD4, PAD4, PAD4, -1)
							self.addSpace = true
						end

						if itemLink then
							AddRow(BACKPACK_TOOLTIP, itemLink, Minimum .. "/" .. Maximum, repairCost)
						else
							local itemID = (xGetContainerItemID and xGetContainerItemID(bag, slot)) or "Unknown"
							AddRow(BACKPACK_TOOLTIP, "itemID:" .. itemID, Minimum .. "/" .. Maximum, repairCost)
						end
					end
				end
			end
		end
	end)

	if bagCost < 0 then bagCost = 0 end
	totalCost = equipCost + bagCost
	self._repairDirty = false
	self._repairDetailsMode = includeDetails and true or false
end

-- Backwards-compatible entrypoint (historically did both durability + repair cost).
function addon:GetDurabilityInfo()
	self:ScanDurabilityLight()
	self:ScanRepairDetails(true)
end

function addon:UpdatePercent()
	--only show current equipped durability not total
	if self._durabilityDirty then
		self:ScanDurabilityLight()
	end

	local tPer = 100
	if pEquipDura.max and pEquipDura.max > 0 then
		tPer = floor(pEquipDura.min / pEquipDura.max * 100)
	end

	if self.text then
		self.text:SetText(addon:DurColor(tPer) .. tPer .. "%|r")
	else
		getglobal(ADDON_NAME.."Text"):SetText(addon:DurColor(tPer) .. tPer .. "%|r")
	end
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
	self._durabilityDirty = true
	self._repairDirty = true
	self:RequestUpdate()
end


function addon:UPDATE_INVENTORY_DURABILITY()
	self._durabilityDirty = true
	self._repairDirty = true
	self:RequestUpdate()
end

function addon:PLAYER_EQUIPMENT_CHANGED()
	self._durabilityDirty = true
	self._repairDirty = true
	self:RequestUpdate()
end

function addon:BAG_UPDATE_DELAYED()
	self._durabilityDirty = true
	self._repairDirty = true
	self:RequestUpdate()
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
--      Updates       --
------------------------

function addon:RequestUpdate(delaySeconds)
	delaySeconds = delaySeconds or 0.35

	if not self._updateFrame then
		self._updateFrame = CreateFrame("Frame")
		self._updateFrame:Hide()
		self._updateFrame:SetScript("OnUpdate", function(_, _)
			if not addon._pendingUpdate then return end
			if GetTime() < (addon._nextUpdateAt or 0) then return end

			addon._pendingUpdate = false
			addon._updateFrame:Hide()

			if addon._durabilityDirty then
				addon:ScanDurabilityLight()
			end
			addon:UpdatePercent()
		end)
	end

	self._pendingUpdate = true
	self._nextUpdateAt = (GetTime() + delaySeconds)
	self._updateFrame:Show()
end

------------------------
--      Tooltip!      --
------------------------

function addon:SetSmartTipAnchor(frame, tooltipFrame)
    local x, y = frame:GetCenter()

	tooltipFrame:ClearAllPoints()
	tooltipFrame:SetClampedToScreen(true)

    if not x or not y then
        tooltipFrame:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT")
		return
    end

    local hhalf = (x > UIParent:GetWidth() * 2 / 3) and "RIGHT" or (x < UIParent:GetWidth() / 3) and "LEFT" or ""
    local vhalf = (y > UIParent:GetHeight() / 2) and "TOP" or "BOTTOM"

	tooltipFrame:SetPoint(vhalf .. hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP") .. hhalf)
end
