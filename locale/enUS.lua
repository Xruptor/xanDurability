local ADDON_NAME, addon = ...

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "enUS", true)
if not L then return end

--for non-english fonts
--https://github.com/tomrus88/BlizzardInterfaceCode/blob/master/Interface/FrameXML/Fonts.xml

--Get the best possible font for the localization langugage.
--Some fonts are better than others to display special character sets.
L.GetFontType = "Fonts\\FRIZQT__.TTF"

L.SlashBG = "bg"
L.SlashBGOn = "xanDurability: Background is now [|cFF99CC33SHOWN|r]"
L.SlashBGOff = "xanDurability: Background is now [|cFF99CC33HIDDEN|r]"
L.SlashBGInfo = "Show the window background."

L.SlashReset = "reset"
L.SlashResetInfo = "Reset frame position."
L.SlashResetAlert = "xanDurability: Frame position has been reset!"

L.SlashScale = "scale"
L.SlashScaleSet = "xanDurability: scale has been set to [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "xanDurability: scale invalid or number cannot be greater than 2"
L.SlashScaleInfo = "Set the scale of the xanDurability frame (0-200)"
L.SlashScaleText = "xanDurability Frame Scale"

L.TooltipDragInfo = "[Hold Shift and Drag to move window.]"

L.Equipped = "Equipped"
L.Bags = "Bags"
L.Total = "Total"
