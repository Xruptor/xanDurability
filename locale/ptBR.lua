local ADDON_NAME, private = ...
local L = private:NewLocale("ptBR")
if not L then return end

L.SlashBG = "fundo"
L.SlashBGOn = "xanDurability: O fundo agora está [|cFF99CC33MOSTRADO|r]"
L.SlashBGOff = "xanDurability: O fundo agora está [|cFF99CC33OCULTO|r]"
L.SlashBGInfo = "Mostrar o fundo da janela."

L.SlashReset = "redefinir"
L.SlashResetInfo = "Redefinir a posição do quadro."
L.SlashResetAlert = "xanDurability: A posição do quadro foi redefinida!"

L.SlashScale = "escala"
L.SlashScaleSet = "xanDurability: a escala foi definida para [|cFF20ff20%s|r]"
L.SlashScaleSetInvalid = "Escala inválida! O número deve ser de [0.5 - 5]. (0.5, 1, 3, 4.6, etc.)"
L.SlashScaleInfo = "Define a escala do quadro do xanDurability (0.5 - 5)."
L.SlashScaleText = "Escala do quadro do xanDurability"

L.SlashAutoRepair = "autoreparar"
L.SlashAutoRepairOn = "xanDurability: Reparo automático no comerciante está [|cFF99CC33ATIVADO|r]"
L.SlashAutoRepairOff = "xanDurability: Reparo automático no comerciante está [|cFF99CC33DESATIVADO|r]"
L.SlashAutoRepairInfo = "Ativar reparo automático ao visitar um comerciante."

L.SlashAutoRepairGuild = "reparoguilda"
L.SlashAutoRepairGuildOn = "xanDurability: Reparo automático com fundos da guilda está [|cFF99CC33ATIVADO|r]"
L.SlashAutoRepairGuildOff = "xanDurability: Reparo automático com fundos da guilda está [|cFF99CC33DESATIVADO|r]"
L.SlashAutoRepairGuildInfo = "Permite usar fundos da guilda para reparo automático |cFF99CC33(O reparo automático deve estar ativado)|r."

L.ShowMoreDetails = "Mostrar detalhamento do custo de reparo por item e local."
L.ShowMoreDetailsOn = "xanDurability: Detalhamento de itens está [|cFF99CC33ATIVADO|r]"
L.ShowMoreDetailsOff = "xanDurability: Detalhamento de itens está [|cFF99CC33DESATIVADO|r]"

L.RepairedFromGuild = "Reparado com fundos da guilda."
L.NoGuildFunds = "Fundos da guilda insuficientes para reparar."
L.RepairedAll = "Todos os itens foram reparados."
L.NoFunds = "Fundos insuficientes para reparar."

L.TooltipDragInfo = "[Segure Shift e arraste para mover a janela.]"

L.Equipped = "Equipado"
L.Bags = "Bolsas"
L.Total = "Total"
