# EDITOR_MOVER_SELETOR_DE_PALETA
# Move o seletor de paleta e os Ys das paletas
#
# a0 = dX
# a1 = dY

EDITOR_MOVER_SELETOR_DE_PALETA:

# X + dX < 0:
# X + dX > 1:
# Y + dY < 0:
# Y + dY > 6:
# faz nada lmao

# handle mudanca entre paletas (altura diferentes por exemplo)...

# caso contrario:

        lb t0, SELETOR_DE_PALETA_X
        lb t1, SELETOR_DE_PALETA_Y

        add t2, t0, a0                  # X + dX
        add t3, t1, a1                  # Y + dY

        bltz t2, E_MS2_RET              # if X+dX<0 ret
        bltz t3, E_MS2_SCROLL_PARA_CIMA # if Y+dY<0 scroll
        li t4, 1
        bgt t2, t4, E_MS2_RET           # if X+dX>1 ret
        li t4, 6
        bgt t3, t4, E_MS2_SCROLL_PARA_BAIXO # if Y+dY>6 scroll

        bgtz a0, E_MS2_IR_PALETA_DE_NPCS
        bltz a0, E_MS2_IR_PALETA_DE_TILES

        beqz t0, E_MS2_PALETA_DE_TILES
        j E_MS2_PALETA_DE_NPCS

        j E_MS2_SALVAR_VALORES

E_MS2_IR_PALETA_DE_NPCS:

        lb t0, PALETA_DE_NPCS_VALOR_MAXIMO
        li t4, BYTE_NPC_0
        sub t0, t0, t4                          # pega o valor maximo relativo ao vetor de NPCs

        lb t1, PALETA_DE_NPCS_Y
        sub t0, t0, t1                          # pega VALOR_MAXIMO-Y = Y_MAXIMO
        ble t3, t0, E_MS2_SALVAR_VALORES        # se Y+dY <= Y_MAXIMO, nao faz nada
        # senao, trunca
        mv t3, t0                               # Y+dY = Y_MAXIMO

        j E_MS2_SALVAR_VALORES

E_MS2_IR_PALETA_DE_TILES:

        lb t0, PALETA_DE_TILES_VALOR_MAXIMO
        lb t1, PALETA_DE_TILES_Y
        sub t0, t0, t1                          # pega VALOR_MAXIMO-Y = Y_MAXIMO
        ble t3, t0, E_MS2_SALVAR_VALORES        # se Y+dY <= Y_MAXIMO, nao faz nada
        # senao, trunca
        mv t3, t0                               # Y+dY = Y_MAXIMO

        j E_MS2_SALVAR_VALORES

E_MS2_PALETA_DE_TILES:
        lb t0, PALETA_DE_TILES_VALOR_MAXIMO
        lb t1, PALETA_DE_TILES_Y
        sub t0, t0, t1                          # pega VALOR_MAXIMO-Y = Y_MAXIMO
        bgt t3, t0, E_MS2_RET                   # se Y+dY > Y_MAXIMO ret
        j E_MS2_SALVAR_VALORES

E_MS2_PALETA_DE_NPCS:

        lb t0, PALETA_DE_NPCS_VALOR_MAXIMO
        li t4, BYTE_NPC_0
        sub t0, t0, t4                          # pega o valor maximo relativo ao vetor de NPCs

        lb t1, PALETA_DE_NPCS_Y
        sub t0, t0, t1                          # pega VALOR_MAXIMO-Y = Y_MAXIMO
        bgt t3, t0, E_MS2_RET                   # se Y+dY > Y_MAXIMO ret
        j E_MS2_SALVAR_VALORES

E_MS2_SCROLL_PARA_CIMA:
        bgtz t0, E_MS2_SCROLL_PRA_CIMA_NPCS     # se for NPCs, vai pro trem de NPCs

E_MS2_SCROLL_PRA_CIMA_TILES:
        lb t1, PALETA_DE_TILES_Y
        beqz t1, E_MS2_RET                      # se o Y da paleta de tiles ja esta em 0, retorna
        addi t1, t1, -1                         # scrolla pra cima
        sb t1, PALETA_DE_TILES_Y, t0            # salva o scroll
        j E_MS2_RET                             # nao altera X e Y
E_MS2_SCROLL_PRA_CIMA_NPCS:
        lb t1, PALETA_DE_NPCS_Y
        beqz t1, E_MS2_RET                      # se o Y da paleta de tiles ja esta em 0, retorna
        addi t1, t1, -1                         # scrolla pra cima
        sb t1, PALETA_DE_NPCS_Y, t0            # salva o scroll
        j E_MS2_RET                             # nao altera X e Y

E_MS2_SCROLL_PARA_BAIXO:
        bgtz t0, E_MS2_SCROLL_PRA_BAIXO_NPCS     # se for NPCs, vai pro trem de NPCs
E_MS2_SCROLL_PRA_BAIXO_TILES:
        lb t0, PALETA_DE_TILES_VALOR_MAXIMO
        lb t1, PALETA_DE_TILES_Y
        sub t0, t0, t1                          # pega VALOR_MAXIMO-Y = Y_MAXIMO
        bgt t3, t0, E_MS2_RET                   # retorna se Y ultrapassaria o valor maximo

        addi t1, t1, 1                          # scrolla pra baixo
        sb t1, PALETA_DE_TILES_Y, t0            # salva o scroll

        j E_MS2_RET                             # nao altera X e Y


E_MS2_SCROLL_PRA_BAIXO_NPCS:
        lb t0, PALETA_DE_NPCS_VALOR_MAXIMO
        li t4, BYTE_NPC_0
        sub t0, t0, t4                          # pega o valor maximo relativo ao vetor de NPCs

        lb t1, PALETA_DE_NPCS_Y
        sub t0, t0, t1                          # pega VALOR_MAXIMO-Y = Y_MAXIMO
        bgt t3, t0, E_MS2_RET                   # retorna se Y ultrapassaria o valor maximo

        addi t1, t1, 1                          # scrolla pra baixo
        sb t1, PALETA_DE_NPCS_Y, t0             # salva o scroll

        j E_MS2_RET                             # nao altera X e Y


E_MS2_SALVAR_VALORES:
        # salva as novas coordenadas
        sb t2, SELETOR_DE_PALETA_X, t0
        sb t3, SELETOR_DE_PALETA_Y, t1

E_MS2_RET:
        ret 



# SCROLLING:

# devemos escrolar quando:
# 
