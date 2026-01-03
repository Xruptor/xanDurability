local ADDON_NAME, addon = ...

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "ruRU")
if not L then return end
-- Translator ZamestoTV
L.SlashBG = "bg"
L.SlashBGOn = "xanDurability: Фон теперь [|cFF99CC33ПОКАЗАН|r]"
L.SlashBGOff = "xanDurability: Фон теперь [|cFF99CC33СКРЫТ|r]"
L.SlashBGInfo = "Показывать фон окна."

L.SlashReset = "reset"
L.SlashResetInfo = "Сбросить позицию фрейма."
L.SlashResetAlert = "xanDurability: Позиция фрейма сброшена!"

L.SlashScale = "scale"
L.SlashScaleSet = "xanDurability: масштаб установлен на [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "Масштаб недействителен! Число должно быть от [0.5 - 5]. (0.5, 1, 3, 4.6 и т.д.)"
L.SlashScaleInfo = "Установить масштаб фрейма xanDurability (0.5 - 5)."
L.SlashScaleText = "Масштаб фрейма xanDurability"

L.SlashAutoRepair = "autorepair"
L.SlashAutoRepairOn = "xanDurability: Авторемонт у торговца [|cFF99CC33ВКЛ|r]"
L.SlashAutoRepairOff = "xanDurability: Авторемонт у торговца [|cFF99CC33ВЫКЛ|r]"
L.SlashAutoRepairInfo = "Включить авторемонт при посещении торговца."

L.SlashAutoRepairGuild = "guildrepair"
L.SlashAutoRepairGuildOn = "xanDurability: Авторемонт за счёт гильдии [|cFF99CC33ВКЛ|r]"
L.SlashAutoRepairGuildOff = "xanDurability: Авторемонт за счёт гильдии [|cFF99CC33ВЫКЛ|r]"
L.SlashAutoRepairGuildInfo = "Разрешить авторемонту использовать средства гильдии |cFF99CC33(Авторемонт должен быть включён)|r."

L.ShowMoreDetails = "Показывать разбивку стоимости ремонта по предметам и слотам."
L.ShowMoreDetailsOn = "xanDurability: Разбивка по предметам [|cFF99CC33ВКЛ|r]"
L.ShowMoreDetailsOff = "xanDurability: Разбивка по предметам [|cFF99CC33ВЫКЛ|r]"

L.RepairedFromGuild = "Отремонтировано за счёт гильдии."
L.NoGuildFunds = "Недостаточно средств гильдии для ремонта."
L.RepairedAll = "Все предметы отремонтированы."
L.NoFunds = "Недостаточно средств для ремонта."

L.TooltipDragInfo = "[Зажмите Shift и перетащите для перемещения окна.]"

L.Equipped = "Надето"
L.Bags = "Сумки"
L.Total = "Всего"
