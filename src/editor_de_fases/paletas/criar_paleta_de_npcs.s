# EDITOR_CRIAR_PALETA_DE_NPCs
# Cria a paleta de tiles disponiveis com base na textura fornecida.
#
# ARGUMENTOS:
# a0 - textura de inimigos

EDITOR_CRIAR_PALETA_DE_NPCS:

la t1, PALETA_DE_NPCS_VALOR_MAXIMO

lw t2, 4(a0) # carrega o numero de linhas
li t3, TAMANHO_SPRITE
li t0, 5
mul t3, t3, t0          # 5 tiles por inimigo
div t2, t2, t3

# o valor tem que estar em [BYTE_NPC_0, BYTE_NPC_0+QTD-1]
addi t2, t2, BYTE_NPC_0 
addi t2, t2, -1

# reseta os seletores
sb zero, SELETOR_DE_PALETA_X, t0
sb zero, SELETOR_DE_PALETA_Y, t0

sb t2, (t1)

ret