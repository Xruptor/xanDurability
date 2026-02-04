local ADDON_NAME, private = ...
local L = private:NewLocale("frFR")
if not L then return end

L.SlashBG = "fond"
L.SlashBGOn = "xanDurability: Le fond est maintenant [|cFF99CC33AFFICHÉ|r]"
L.SlashBGOff = "xanDurability: Le fond est maintenant [|cFF99CC33MASQUÉ|r]"
L.SlashBGInfo = "Afficher l'arrière-plan de la fenêtre."

L.SlashReset = "réinitialiser"
L.SlashResetInfo = "Réinitialiser la position du cadre."
L.SlashResetAlert = "xanDurability: La position du cadre a été réinitialisée !"

L.SlashScale = "échelle"
L.SlashScaleSet = "xanDurability: l'échelle a été définie sur [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "Échelle invalide ! Le nombre doit être entre [0.5 - 5]. (0.5, 1, 3, 4.6, etc.)"
L.SlashScaleInfo = "Définit l'échelle du cadre xanDurability (0.5 - 5)."
L.SlashScaleText = "Échelle du cadre xanDurability"

L.SlashAutoRepair = "autoréparer"
L.SlashAutoRepairOn = "xanDurability: La réparation automatique chez le marchand est [|cFF99CC33ACTIVÉE|r]"
L.SlashAutoRepairOff = "xanDurability: La réparation automatique chez le marchand est [|cFF99CC33DÉSACTIVÉE|r]"
L.SlashAutoRepairInfo = "Activer la réparation automatique lors de la visite d'un marchand."

L.SlashAutoRepairGuild = "réparerguilde"
L.SlashAutoRepairGuildOn = "xanDurability: Réparation automatique avec fonds de guilde [|cFF99CC33ACTIVÉE|r]"
L.SlashAutoRepairGuildOff = "xanDurability: Réparation automatique avec fonds de guilde [|cFF99CC33DÉSACTIVÉE|r]"
L.SlashAutoRepairGuildInfo = "Autorise l'utilisation des fonds de guilde pour la réparation automatique |cFF99CC33(La réparation automatique doit être activée)|r."

L.ShowMoreDetails = "Afficher le détail des coûts de réparation par objet et emplacement."
L.ShowMoreDetailsOn = "xanDurability: Le détail des objets est [|cFF99CC33ACTIVÉ|r]"
L.ShowMoreDetailsOff = "xanDurability: Le détail des objets est [|cFF99CC33DÉSACTIVÉ|r]"

L.RepairedFromGuild = "Réparé avec les fonds de guilde."
L.NoGuildFunds = "Fonds de guilde insuffisants pour réparer."
L.RepairedAll = "Tous les objets ont été réparés."
L.NoFunds = "Fonds insuffisants pour réparer."

L.TooltipDragInfo = "[Maintenez Shift et faites glisser pour déplacer la fenêtre.]"

L.Equipped = "Équipé"
L.Bags = "Sacs"
L.Total = "Total"
