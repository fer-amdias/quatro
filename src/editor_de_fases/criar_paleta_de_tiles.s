# EDITOR_CRIAR_PALETA_DE_TILES
# Cria a paleta de tiles disponiveis com base na textura fornecida.
#
# ARGUMENTOS:
# a0 - textura do mapa

EDITOR_CRIAR_PALETA_DE_TILES:

la t1, PALETA_DE_TILES_VALOR_MAXIMO

lw t2, 4(a0) # carrega o numero de linhas
li t3, TAMANHO_SPRITE
div t2, t2, t3
addi t2, t2, -1         # o valor tem que estar em [0, QTD-1]
sb t2, (t1)

ret