local ADDON_NAME, private = ...
local L = private:NewLocale("zhTW")
if not L then return end

L.SlashBG = "背景"
L.SlashBGOn = "xanDurability: 背景 [|cFF99CC33顯示|r]"
L.SlashBGOff = "xanDurability: 背景 [|cFF99CC33隱藏|r]"
L.SlashBGInfo = "顯示視窗背景。"

L.SlashReset = "重置"
L.SlashResetInfo = "重置框架位置。"
L.SlashResetAlert = "xanDurability: 框架位置已重置！"

L.SlashScale = "比例"
L.SlashScaleSet = "xanDurability: 比例設定為 [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "數值無效！數字必須是 [0.5 - 5]。(0.5, 1, 3, 4.6, 等..)"
L.SlashScaleInfo = "設定 xanDurability 框架的比例 (0.5 - 5)."
L.SlashScaleText = "xanDurability 框架比例"

L.SlashAutoRepair = "自動修理"
L.SlashAutoRepairOn = "xanDurability: 自動修理 [|cFF99CC33開|r]"
L.SlashAutoRepairOff = "xanDurability: 自動修理 [|cFF99CC33關|r]"
L.SlashAutoRepairInfo = "造訪商人時自動修理。"

L.SlashAutoRepairGuild = "公會修理"
L.SlashAutoRepairGuildOn = "xanDurability: 優先使用公會修理 [|cFF99CC33開|r]"
L.SlashAutoRepairGuildOff = "xanDurability: 優先使用公會修理 [|cFF99CC33關|r]"
L.SlashAutoRepairGuildInfo = "自動修理優先使用公會資金 |cFF99CC33（必須啟用自動修理）|r。"

L.ShowMoreDetails = "顯示每件裝備和位置的修理成本明細。"
L.ShowMoreDetailsOn = "xanDurability: 顯示裝備詳細資訊 [|cFF99CC33開|r]"
L.ShowMoreDetailsOff = "xanDurability: 顯示裝備詳細資訊 [|cFF99CC33關|r]"

L.RepairedFromGuild = "使用公會資金修理。"
L.NoGuildFunds = "公會資金不足，無法修理。"
L.RepairedAll = "已修理所有裝備。"
L.NoFunds = "資金不足，無法修理。"

L.TooltipDragInfo = "[按住 Shift 並拖曳以移動視窗。]"

L.Equipped = "已裝備"
L.Bags = "背包"
L.Total = "總計"
