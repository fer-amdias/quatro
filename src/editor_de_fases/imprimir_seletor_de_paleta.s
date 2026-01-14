# EDITOR_IMPRIMIR_SELETOR_DE_PALETA
# Imprime a outline do seletor de paleta na tela.

EDITOR_IMPRIMIR_SELETOR_DE_PALETA:
addi sp, sp, -4
sw ra, (sp)

lb t0, SELETOR_DE_PALETA_X
lb t1, SELETOR_DE_PALETA_Y

li t2, 30               # distancia entre as paletas
li t3, 22               # distancia entre os tiles

mul t0, t2, t0          # X = 30X
mul t1, t3, t1          # Y = 22Y

li a0, 0xFF

# coordenadas das paletas
addi a1, t0, 255
addi a2, t1, 66

addi a3, a1, TAMANHO_SPRITE
addi a4, a2, TAMANHO_SPRITE

# o sprite so vai do pixel 0 ao TAMANHO_SPRITE-1
addi a3, a3, -1
addi a4, a4, -1

li a5, 2
li a7, 0
jal PROC_IMPRIMIR_OUTLINE

lw ra, (sp)
addi sp, sp, 4
ret