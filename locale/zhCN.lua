local ADDON_NAME, addon = ...

addon.locales = addon.locales or {}
local L = {}
addon.locales["zhCN"] = L

L.SlashBG = "背景"
L.SlashBGOn = "xanDurability: 背景 [|cFF99CC33显示|r]"
L.SlashBGOff = "xanDurability: 背景 [|cFF99CC33隐藏|r]"
L.SlashBGInfo = "显示窗口背景。"

L.SlashReset = "重置"
L.SlashResetInfo = "重置位置"
L.SlashResetAlert = "xanDurability: 位置已重置！"

L.SlashScale = "比例"
L.SlashScaleSet = "xanDurability: 比例设置为 [|cFF20ff20%s|r]"
-- L.SlashScaleSetInvalid = "数值无效！数字必须是 [0.5 - 5]。(0.5, 1, 3, 4.6, 等..)"
-- L.SlashScaleInfo = "设置 XanDurability 耐久度窗口的比例 (0.5 - 5)."
L.SlashScaleText = "耐久度窗口比例"

L.SlashAutoRepair = "自动修理"
L.SlashAutoRepairOn = "xanDurability: 自动修理 [|cFF99CC33开|r]"
L.SlashAutoRepairOff = "xanDurability: 自动修理 [|cFF99CC33关|r]"
L.SlashAutoRepairInfo = "访问商人时自动修理。"

L.SlashAutoRepairGuild = "公会修理"
L.SlashAutoRepairGuildOn = "xanDurability: 优先使用公会修理 [|cFF99CC33开|r]"
L.SlashAutoRepairGuildOff = "xanDurability: 优先使用公会修理 [|cFF99CC33关|r]"
L.SlashAutoRepairGuildInfo = "自动修理优先使用公会修理 |cFF99CC33（必须启用自动修理）|r。"

L.ShowMoreDetails = "显示每件装备和位置的修理成本明细。"
L.ShowMoreDetailsOn = "xanDurability: 显示装备详细信息 [|cFF99CC33开|r]"
L.ShowMoreDetailsOff = "xanDurability: 显示装备详细信息 [|cFF99CC33关|r]"

L.RepairedFromGuild = "用公会资金修理。"
L.NoGuildFunds = "公会银行资金不足，无法进行修理。"
L.RepairedAll = "已修理所有装备。"
L.NoFunds = "没有足够的资金来修理所有装备。"

L.TooltipDragInfo = "[按住Shift-点击来移动窗口。]"

L.Equipped = "已装备"
L.Bags = "背包"
L.Total = "总计"
