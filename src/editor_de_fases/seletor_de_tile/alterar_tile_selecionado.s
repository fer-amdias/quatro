# EDITOR_ALTERAR_TILE_SELECIONADO
# altera o tile no seletor de tile para o valor fornecido.
#
# ARGUMENTOS:
# a0 - valor a ser colocado

EDITOR_ALTERAR_TILE_SELECIONADO:

lb t0, SELETOR_DE_TILE_X
lb t1, SELETOR_DE_TILE_Y

la t2, TILEMAP_BUFFER
lw t3, 4(t2)     # pega a quantidade de colunas 
addi t2, t2, 8          # pula informacoes

mul t1, t1, t3   # pula Y linhas
add t1, t1, t0   # pula X colunas

lw t0, TAMANHO_STRUCT_TILE
mul t1, t1, t0   # ajusta para o tamanho certo por tile

add t2, t2, t1   # vai para o endereco
sb a0, (t2)      # salva o novo valor

ret



