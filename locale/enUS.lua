local ADDON_NAME, addon = ...

addon.locales = addon.locales or {}
local L = {}
addon.locales["enUS"] = L

L.SlashBG = "bg"
L.SlashBGOn = "xanDurability: Background is now [|cFF99CC33SHOWN|r]"
L.SlashBGOff = "xanDurability: Background is now [|cFF99CC33HIDDEN|r]"
L.SlashBGInfo = "Show the window background."

L.SlashReset = "reset"
L.SlashResetInfo = "Reset frame position."
L.SlashResetAlert = "xanDurability: Frame position has been reset!"

L.SlashScale = "scale"
L.SlashScaleSet = "xanDurability: scale has been set to [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "Scale invalid! Number must be from [0.5 - 5].  (0.5, 1, 3, 4.6, etc..)"
L.SlashScaleInfo = "Set the scale of the LootRollMover loot frames (0.5 - 5)."
L.SlashScaleText = "xanDurability Frame Scale"

L.SlashAutoRepair = "autorepair"
L.SlashAutoRepairOn = "xanDurability: Auto repair at merchant is [|cFF99CC33ON|r]"
L.SlashAutoRepairOff = "xanDurability: Auto repair at merchant is [|cFF99CC33OFF|r]"
L.SlashAutoRepairInfo = "Enable auto repair when visiting a merchant."

L.SlashAutoRepairGuild = "guildrepair"
L.SlashAutoRepairGuildOn = "xanDurability: Auto repair using Guild is [|cFF99CC33ON|r]"
L.SlashAutoRepairGuildOff = "xanDurability: Auto repair using Guild is [|cFF99CC33OFF|r]"
L.SlashAutoRepairGuildInfo = "Allow auto repair to use guild funds |cFF99CC33(Auto Repair must be enabled)|r."

L.ShowMoreDetails = "Show repair cost breakdown per item and location."
L.ShowMoreDetailsOn = "xanDurability: Show item breakdown info is [|cFF99CC33ON|r]"
L.ShowMoreDetailsOff = "xanDurability: Show item breakdown info is [|cFF99CC33OFF|r]"

L.RepairedFromGuild = "Repaired from Guild."
L.NoGuildFunds = "Insufficient guild funds to make repairs."
L.RepairedAll = "Repaired all items."
L.NoFunds = "Insufficient funds to make repairs."

L.TooltipDragInfo = "[Hold Shift and Drag to move window.]"

L.Equipped = "Equipped"
L.Bags = "Bags"
L.Total = "Total"
