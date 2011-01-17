--I'm the original author of DurabilityStatus.  Yes I changed my name from Derkyle to Xruptor.  Anyways, although
--I liked what they have done with my old mod.  I liked the original simplistic minimalistic appeal my original mod had.
--So I decided to do it again :)

--This mod creates a very simple movable box with the current players durability.  The box can be moved :)
--use /xdu to access the slash commands

local f = CreateFrame("frame","xanDurability",UIParent)
f:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)

--repair variables
local equipCost = 0;
local bagCost = 0;
local totalCost = 0;

--percent variables
local pEquipDura = { min=0, max=0};
local pBagDura = { min=0, max=0};

local Slots = { "HeadSlot", "ShoulderSlot", "ChestSlot", "WaistSlot", "WristSlot", "HandsSlot", "LegsSlot", "FeetSlot", "MainHandSlot", "SecondaryHandSlot", "RangedSlot" }

----------------------
--      Enable      --
----------------------

function f:PLAYER_LOGIN()

	if not XanDUR_DB then XanDUR_DB = {} end
	if XanDUR_DB.bgShown == nil then XanDUR_DB.bgShown = 1 end
	if XanDUR_DB.scale == nil then XanDUR_DB.scale = 1 end
	
	self:CreateDURFrame()
	self:RestoreLayout("xanDurability")

	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("UPDATE_INVENTORY_DURABILITY")

	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
	
	SLASH_XANDURABILITY1 = "/xdu";
	SlashCmdList["XANDURABILITY"] = xanDurability_SlashCommand;
	
	local ver = GetAddOnMetadata("xanDurability","Version") or '1.0'
	DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF99CC33%s|r [v|cFFDF2B2B%s|r] Loaded", "xanDurability", ver or "1.0"))
end

function xanDurability_SlashCommand(cmd)

	local a,b,c=strfind(cmd, "(%S+)"); --contiguous string of non-space characters
	
	if a then
		if c and c:lower() == "bg" then
			xanDurability:BackgroundToggle()
			return true
		elseif c and c:lower() == "reset" then
			DEFAULT_CHAT_FRAME:AddMessage("xanDurability: Frame position has been reset!");
			xanDurability:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
			return true
		elseif c and c:lower() == "scale" then
			if b then
				local scalenum = strsub(cmd, b+2)
				if scalenum and scalenum ~= "" and tonumber(scalenum) then
					XanDUR_DB.scale = tonumber(scalenum)
					xanDurability:SetScale(tonumber(scalenum))
					DEFAULT_CHAT_FRAME:AddMessage("xanDurability: scale has been set to ["..tonumber(scalenum).."]")
					return true
				end
			end
		end
	end

	DEFAULT_CHAT_FRAME:AddMessage("xanDurability");
	DEFAULT_CHAT_FRAME:AddMessage("/xdu reset - resets the frame position");
	DEFAULT_CHAT_FRAME:AddMessage("/xdu bg - toggles the background on/off");
	DEFAULT_CHAT_FRAME:AddMessage("/xdu scale # - Set the scale of the xanDurability frame")
end

function f:CreateDURFrame()

	f:SetWidth(61)
	f:SetHeight(27)
	f:SetMovable(true)
	f:SetClampedToScreen(true)
	
	f:SetScale(XanDUR_DB.scale)
	
	if XanDUR_DB.bgShown == 1 then
		f:SetBackdrop( {
			bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground";
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border";
			tile = true; tileSize = 32; edgeSize = 16;
			insets = { left = 5; right = 5; top = 5; bottom = 5; };
		} );
		f:SetBackdropBorderColor(0.5, 0.5, 0.5);
		f:SetBackdropColor(0.5, 0.5, 0.5, 0.6)
	else
		f:SetBackdrop(nil)
	end
	
	f:EnableMouse(true);
	
	local t = f:CreateTexture("$parentIcon", "ARTWORK")
	t:SetTexture("Interface\\Icons\\Trade_Blacksmithing")
	t:SetWidth(16)
	t:SetHeight(16)
	t:SetPoint("TOPLEFT",5,-6)

	local g = f:CreateFontString("$parentText", "ARTWORK", "GameFontNormalSmall")
	g:SetJustifyH("LEFT")
	g:SetPoint("CENTER",8,0)
	g:SetText("")

	f:SetScript("OnMouseDown",function()
		if (IsShiftKeyDown()) then
			self.isMoving = true
			self:StartMoving();
	 	end
	end)
	f:SetScript("OnMouseUp",function()
		if( self.isMoving ) then

			self.isMoving = nil
			self:StopMovingOrSizing()

			f:SaveLayout(self:GetName());

		end
	end)
	f:SetScript("OnLeave",function()
		GameTooltip:Hide()
	end)

	f:SetScript("OnEnter",function()
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint(self:GetTipAnchor(self))
		GameTooltip:ClearLines()

		local cP = (pEquipDura.max > 0 and floor(pEquipDura.min / pEquipDura.max * 100)) or 100
		local bP = (pBagDura.max > 0 and floor(pBagDura.min / pBagDura.max * 100)) or 100
		local tP = ((pEquipDura.max + pBagDura.max) > 0 and floor( (pEquipDura.min + pBagDura.min) / (pEquipDura.max + pBagDura.max) * 100)) or 100
		
		if cP > 100 then cP = 100 end
		if bP > 100 then bP = 100 end
		if tP > 100 then tP = 100 end

		GameTooltip:AddLine("xanDurability")
		GameTooltip:AddDoubleLine("|cFFFFFFFFEquipped|r  ("..self:DurColor(cP)..cP.."%|r".."):", self:GetMoneyText(equipCost), nil,nil,nil, 1,1,1)
		GameTooltip:AddDoubleLine("|cFFFFFFFFBags|r  ("..self:DurColor(bP)..bP.."%|r".."):", self:GetMoneyText(bagCost), nil,nil,nil, 1,1,1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine("|cFFFFFFFFTotal|r  ("..self:DurColor(tP)..tP.."%|r".."):", self:GetMoneyText(totalCost), nil,nil,nil, 1,1,1)
		GameTooltip:Show()
	end)
	
	f:Show();
end

function f:GetDurabilityInfo()
	
	pEquipDura = { min=0, max=0};
	pBagDura = { min=0, max=0};
	
	if not tmpTip then tmpTip = CreateFrame("GameTooltip", "XDTT") end
	
	equipCost = 0
	for _, slotName in ipairs(Slots) do
		local item = _G["Character" .. slotName]
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

function f:UpdatePercent()
	--only show current equipped durability not total
	local tPer = floor(pEquipDura.min / pEquipDura.max * 100)
	getglobal("xanDurabilityText"):SetText(f:DurColor(tPer)..tPer.."%|r");
end

function f:SaveLayout(frame)

	if not XanDUR_DB then XanDUR_DB = {} end

	local opt = XanDUR_DB[frame] or nil;

	if opt == nil then
		XanDUR_DB[frame] = {
			["point"] = "CENTER",
			["relativePoint"] = "CENTER",
			["PosX"] = 0,
			["PosY"] = 0,
		}
		opt = XanDUR_DB[frame];
	end

	local f = getglobal(frame);
	local scale = f:GetEffectiveScale();
	opt.PosX = f:GetLeft() * scale;
	opt.PosY = f:GetTop() * scale;
	
end

function f:RestoreLayout(frame)

	if not XanDUR_DB then XanDUR_DB = {} end	

	local f = getglobal(frame);
	local opt = XanDUR_DB[frame] or nil;

	if opt == nil then
		XanDUR_DB[frame] = {
			["point"] = "CENTER",
			["relativePoint"] = "CENTER",
			["PosX"] = 0,
			["PosY"] = 0,
		}
		opt = XanDUR_DB[frame];
	end

	local x = opt.PosX;
	local y = opt.PosY;
	local s = f:GetEffectiveScale();

	if (not x or not y) or (x==0 and y==0) then
		f:ClearAllPoints();
		f:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
		return 
	end

	--calculate the scale
	x,y = x/s,y/s;

	--set the location
	f:ClearAllPoints();
	f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y);

end

function f:BackgroundToggle()
	if not XanDUR_DB then XanDUR_DB = {} end
	if XanDUR_DB.bgShown == nil then XanDUR_DB.bgShown = 1 end
	
	if XanDUR_DB.bgShown == 0 then
		XanDUR_DB.bgShown = 1;
		DEFAULT_CHAT_FRAME:AddMessage("xanDurability: Background Shown");
	elseif XanDUR_DB.bgShown == 1 then
		XanDUR_DB.bgShown = 0;
		DEFAULT_CHAT_FRAME:AddMessage("xanDurability: Background Hidden");
	else
		XanDUR_DB.bgShown = 1
		DEFAULT_CHAT_FRAME:AddMessage("xanDurability: Background Shown");
	end

	--now change background
	if XanDUR_DB.bgShown == 1 then
		f:SetBackdrop( {
			bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground";
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border";
			tile = true; tileSize = 32; edgeSize = 16;
			insets = { left = 5; right = 5; top = 5; bottom = 5; };
		} );
		f:SetBackdropBorderColor(0.5, 0.5, 0.5);
		f:SetBackdropColor(0.5, 0.5, 0.5, 0.6)
	else
		f:SetBackdrop(nil)
	end
	
end

function f:GetMoneyText(money)
	local COLOR_COPPER = "eda55f"
	local COLOR_SILVER = "c7c7cf"
	local COLOR_GOLD = "ffd700"

	local gold = floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD));
	local silver = floor((money - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER);
	local copper = mod(money, COPPER_PER_SILVER);
	
	if gold < 0 then gold = 0 end
	if silver < 0 then silver = 0 end
	if copper < 0 then copper = 0 end
	
	if money >= 10000 then
		return format("%d|cff%sg|r %d|cff%ss|r %d|cff%sc|r", gold, COLOR_GOLD, silver, COLOR_SILVER, copper, COLOR_COPPER)
	elseif money >= 100 then
		return format("%d|cff%ss|r %d|cff%sc|r", silver, COLOR_SILVER, copper, COLOR_COPPER)
	else
		return format("%d|cff%sc|r", copper, COLOR_COPPER)
	end
end

function f:DurColor(percent)

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

function f:PLAYER_REGEN_ENABLED()
	f:GetDurabilityInfo()
	f:UpdatePercent()
end


function f:UPDATE_INVENTORY_DURABILITY()
	f:GetDurabilityInfo()
	f:UpdatePercent()
end

------------------------
--      Tooltip!      --
------------------------

function f:GetTipAnchor(frame)
	local x,y = frame:GetCenter()
	if not x or not y then return "TOPLEFT", "BOTTOMLEFT" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end

if IsLoggedIn() then f:PLAYER_LOGIN() else f:RegisterEvent("PLAYER_LOGIN") end
