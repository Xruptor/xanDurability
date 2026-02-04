local ADDON_NAME, private = ...
local L = private:NewLocale("esMX")
if not L then return end

L.SlashBG = "fondo"
L.SlashBGOn = "xanDurability: El fondo ahora está [|cFF99CC33MOSTRADO|r]"
L.SlashBGOff = "xanDurability: El fondo ahora está [|cFF99CC33OCULTO|r]"
L.SlashBGInfo = "Mostrar el fondo de la ventana."

L.SlashReset = "reiniciar"
L.SlashResetInfo = "Restablecer la posición del marco."
L.SlashResetAlert = "xanDurability: ¡La posición del marco ha sido restablecida!"

L.SlashScale = "escala"
L.SlashScaleSet = "xanDurability: la escala se ha establecido en [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "¡Escala no válida! El número debe ser de [0.5 - 5]. (0.5, 1, 3, 4.6, etc.)"
L.SlashScaleInfo = "Establece la escala del marco de xanDurability (0.5 - 5)."
L.SlashScaleText = "Escala del marco de xanDurability"

L.SlashAutoRepair = "autoreparar"
L.SlashAutoRepairOn = "xanDurability: La reparación automática en el vendedor está [|cFF99CC33ACTIVADA|r]"
L.SlashAutoRepairOff = "xanDurability: La reparación automática en el vendedor está [|cFF99CC33DESACTIVADA|r]"
L.SlashAutoRepairInfo = "Activar la reparación automática al visitar un vendedor."

L.SlashAutoRepairGuild = "reparargremio"
L.SlashAutoRepairGuildOn = "xanDurability: Reparación automática con fondos de hermandad está [|cFF99CC33ACTIVADA|r]"
L.SlashAutoRepairGuildOff = "xanDurability: Reparación automática con fondos de hermandad está [|cFF99CC33DESACTIVADA|r]"
L.SlashAutoRepairGuildInfo = "Permite usar fondos de hermandad para la reparación automática |cFF99CC33(La reparación automática debe estar activada)|r."

L.ShowMoreDetails = "Mostrar el desglose de costos de reparación por objeto y ubicación."
L.ShowMoreDetailsOn = "xanDurability: El desglose de objetos está [|cFF99CC33ACTIVADO|r]"
L.ShowMoreDetailsOff = "xanDurability: El desglose de objetos está [|cFF99CC33DESACTIVADO|r]"

L.RepairedFromGuild = "Reparado con fondos de hermandad."
L.NoGuildFunds = "Fondos de hermandad insuficientes para reparar."
L.RepairedAll = "Se repararon todos los objetos."
L.NoFunds = "Fondos insuficientes para reparar."

L.TooltipDragInfo = "[Mantén Shift y arrastra para mover la ventana.]"

L.Equipped = "Equipado"
L.Bags = "Bolsas"
L.Total = "Total"
