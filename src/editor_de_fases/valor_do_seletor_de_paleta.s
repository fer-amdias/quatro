# EDITOR_VALOR_DO_SELETOR_DE_PALETA
# Pega o valor do tile selecionado atualmente

EDITOR_VALOR_DO_SELETOR_DE_PALETA:

li t0, BYTE_NPC_0
lb t1, SELETOR_DE_PALETA_X
beqz t1, E_VS1_TILES            # handle tiles se x==0

# senao, handle NPCs
E_VS1_NPCS:
lb t0, PALETA_DE_NPCS_Y
addi t0, t0, BYTE_NPC_0
j E_VS1_CONT

E_VS1_TILES:
lb t0, PALETA_DE_TILES_Y

E_VS1_CONT:

lb t1, SELETOR_DE_PALETA_Y
add a0, t0, t1                  # a0 = t0 + Y
ret                             # retorna o valor corretamente
