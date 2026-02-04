local ADDON_NAME, private = ...
local L = private:NewLocale("itIT")
if not L then return end

L.SlashBG = "sfondo"
L.SlashBGOn = "xanDurability: Lo sfondo ora è [|cFF99CC33VISIBILE|r]"
L.SlashBGOff = "xanDurability: Lo sfondo ora è [|cFF99CC33NASCOSTO|r]"
L.SlashBGInfo = "Mostra lo sfondo della finestra."

L.SlashReset = "ripristina"
L.SlashResetInfo = "Reimposta la posizione del frame."
L.SlashResetAlert = "xanDurability: La posizione del frame è stata reimpostata!"

L.SlashScale = "scala"
L.SlashScaleSet = "xanDurability: la scala è stata impostata a [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "Scala non valida! Il numero deve essere tra [0.5 - 5]. (0.5, 1, 3, 4.6, ecc.)"
L.SlashScaleInfo = "Imposta la scala del frame xanDurability (0.5 - 5)."
L.SlashScaleText = "Scala del frame xanDurability"

L.SlashAutoRepair = "autorepara"
L.SlashAutoRepairOn = "xanDurability: La riparazione automatica dal mercante è [|cFF99CC33ATTIVA|r]"
L.SlashAutoRepairOff = "xanDurability: La riparazione automatica dal mercante è [|cFF99CC33DISATTIVA|r]"
L.SlashAutoRepairInfo = "Abilita la riparazione automatica quando visiti un mercante."

L.SlashAutoRepairGuild = "riparagilda"
L.SlashAutoRepairGuildOn = "xanDurability: Riparazione automatica con fondi di gilda [|cFF99CC33ATTIVA|r]"
L.SlashAutoRepairGuildOff = "xanDurability: Riparazione automatica con fondi di gilda [|cFF99CC33DISATTIVA|r]"
L.SlashAutoRepairGuildInfo = "Consente di usare i fondi di gilda per la riparazione automatica |cFF99CC33(La riparazione automatica deve essere attiva)|r."

L.ShowMoreDetails = "Mostra il dettaglio dei costi di riparazione per oggetto e posizione."
L.ShowMoreDetailsOn = "xanDurability: Dettaglio oggetti [|cFF99CC33ATTIVO|r]"
L.ShowMoreDetailsOff = "xanDurability: Dettaglio oggetti [|cFF99CC33DISATTIVO|r]"

L.RepairedFromGuild = "Riparato con fondi di gilda."
L.NoGuildFunds = "Fondi di gilda insufficienti per riparare."
L.RepairedAll = "Tutti gli oggetti sono stati riparati."
L.NoFunds = "Fondi insufficienti per riparare."

L.TooltipDragInfo = "[Tieni premuto Shift e trascina per spostare la finestra.]"

L.Equipped = "Equipaggiato"
L.Bags = "Borse"
L.Total = "Totale"
