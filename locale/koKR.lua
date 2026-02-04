local ADDON_NAME, private = ...
local L = private:NewLocale("koKR")
if not L then return end

L.SlashBG = "배경"
L.SlashBGOn = "xanDurability: 배경이 [|cFF99CC33표시됨|r]"
L.SlashBGOff = "xanDurability: 배경이 [|cFF99CC33숨김|r]"
L.SlashBGInfo = "창 배경을 표시합니다."

L.SlashReset = "초기화"
L.SlashResetInfo = "프레임 위치를 초기화합니다."
L.SlashResetAlert = "xanDurability: 프레임 위치가 초기화되었습니다!"

L.SlashScale = "크기"
L.SlashScaleSet = "xanDurability: 크기가 [|cFF20ff20%s|r]로 설정되었습니다"
L.SlashScaleSetInvalid = "크기가 올바르지 않습니다! 숫자는 [0.5 - 5] 사이여야 합니다. (0.5, 1, 3, 4.6 등)"
L.SlashScaleInfo = "xanDurability 프레임의 크기를 설정합니다 (0.5 - 5)."
L.SlashScaleText = "xanDurability 프레임 크기"

L.SlashAutoRepair = "자동수리"
L.SlashAutoRepairOn = "xanDurability: 상인 방문 시 자동 수리가 [|cFF99CC33켜짐|r]"
L.SlashAutoRepairOff = "xanDurability: 상인 방문 시 자동 수리가 [|cFF99CC33꺼짐|r]"
L.SlashAutoRepairInfo = "상인 방문 시 자동 수리를 사용합니다."

L.SlashAutoRepairGuild = "길드수리"
L.SlashAutoRepairGuildOn = "xanDurability: 길드 자금 자동 수리가 [|cFF99CC33켜짐|r]"
L.SlashAutoRepairGuildOff = "xanDurability: 길드 자금 자동 수리가 [|cFF99CC33꺼짐|r]"
L.SlashAutoRepairGuildInfo = "길드 자금을 자동 수리에 사용합니다 |cFF99CC33(자동 수리가 켜져 있어야 합니다)|r."

L.ShowMoreDetails = "아이템과 위치별 수리 비용 내역을 표시합니다."
L.ShowMoreDetailsOn = "xanDurability: 아이템 상세 정보가 [|cFF99CC33켜짐|r]"
L.ShowMoreDetailsOff = "xanDurability: 아이템 상세 정보가 [|cFF99CC33꺼짐|r]"

L.RepairedFromGuild = "길드 자금으로 수리했습니다."
L.NoGuildFunds = "길드 자금이 부족하여 수리할 수 없습니다."
L.RepairedAll = "모든 아이템을 수리했습니다."
L.NoFunds = "수리할 자금이 부족합니다."

L.TooltipDragInfo = "[Shift를 누른 채 드래그하여 창을 이동합니다.]"

L.Equipped = "착용"
L.Bags = "가방"
L.Total = "합계"
