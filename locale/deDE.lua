local ADDON_NAME, private = ...
local L = private:NewLocale("deDE")
if not L then return end

L.SlashBG = "hintergrund"
L.SlashBGOn = "xanDurability: Hintergrund ist jetzt [|cFF99CC33ANGEZEIGT|r]"
L.SlashBGOff = "xanDurability: Hintergrund ist jetzt [|cFF99CC33VERSTECKT|r]"
L.SlashBGInfo = "Fensterhintergrund anzeigen."

L.SlashReset = "zurücksetzen"
L.SlashResetInfo = "Rahmenposition zurücksetzen."
L.SlashResetAlert = "xanDurability: Rahmenposition wurde zurückgesetzt!"

L.SlashScale = "skalierung"
L.SlashScaleSet = "xanDurability: Skalierung wurde auf [|cFF20ff20%s|r] gesetzt"
L.SlashScaleSetInvalid = "Skalierung ungültig! Zahl muss zwischen [0.5 - 5] liegen. (0.5, 1, 3, 4.6, usw.)"
L.SlashScaleInfo = "Skaliert den xanDurability-Rahmen (0.5 - 5)."
L.SlashScaleText = "xanDurability-Rahmenskalierung"

L.SlashAutoRepair = "autoreparatur"
L.SlashAutoRepairOn = "xanDurability: Automatische Reparatur beim Händler ist [|cFF99CC33AN|r]"
L.SlashAutoRepairOff = "xanDurability: Automatische Reparatur beim Händler ist [|cFF99CC33AUS|r]"
L.SlashAutoRepairInfo = "Automatische Reparatur beim Händler aktivieren."

L.SlashAutoRepairGuild = "gildenreparatur"
L.SlashAutoRepairGuildOn = "xanDurability: Automatische Reparatur mit Gildenmitteln ist [|cFF99CC33AN|r]"
L.SlashAutoRepairGuildOff = "xanDurability: Automatische Reparatur mit Gildenmitteln ist [|cFF99CC33AUS|r]"
L.SlashAutoRepairGuildInfo = "Erlaubt Reparaturen aus der Gildenbank |cFF99CC33(Automatische Reparatur muss aktiviert sein)|r."

L.ShowMoreDetails = "Reparaturkosten je Gegenstand und Platz anzeigen."
L.ShowMoreDetailsOn = "xanDurability: Gegenstandsdetails sind [|cFF99CC33AN|r]"
L.ShowMoreDetailsOff = "xanDurability: Gegenstandsdetails sind [|cFF99CC33AUS|r]"

L.RepairedFromGuild = "Mit Gildenmitteln repariert."
L.NoGuildFunds = "Nicht genug Gildengelder für Reparaturen."
L.RepairedAll = "Alle Gegenstände repariert."
L.NoFunds = "Nicht genug Geld für Reparaturen."

L.TooltipDragInfo = "[Shift gedrückt halten und ziehen, um das Fenster zu bewegen.]"

L.Equipped = "Angelegt"
L.Bags = "Taschen"
L.Total = "Gesamt"
