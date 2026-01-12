# EDITOR_MOVER_SELETOR_DE_TILE
# Move o seletor de tile por um deslocamento de coordenadas
#
# Argumentos:
# a0 - X a ser adicionado
# a1 - Y a ser adicionado

EDITOR_MOVER_SELETOR_DE_TILE:

        la t1, TILEMAP_BUFFER
        lw t2, (t1)     # linhas
        lw t1, 4(t1)      # colunas

E_MS1_X:
        beqz a0, E_MS1_Y
        la t0, SELETOR_DE_TILE_X

        lb t3, (t0)     # x     
        add t3, t3, a0  # novo x
  
        # o range permitido de x eh [0, colunas-1]
        bltz t3, E_MS1_X_MINIMO # se novo x < 0, coloca ele como 0
        bge t3, t1, E_MS1_X_MAXIMO # se novo x >= colunas, coloca ele como colunas-1

        j E_MS1_X_CONT

E_MS1_X_MINIMO:
        mv t3, zero
        j E_MS1_X_CONT

E_MS1_X_MAXIMO:
        mv t3, t1
        addi t3, t3, -1

E_MS1_X_CONT:
        sb t3, (t0)     # salva o novo X

E_MS1_Y:
        beqz a1, E_MS1_RET
        la t0, SELETOR_DE_TILE_Y
        lb t3, (t0)     # y
        add t3, t3, a1  # novo y

        # o range permitido de y eh [0, colunas-1]
        bltz t3, E_MS1_Y_MINIMO # se novo y < 0, coloca ele como 0
        bge t3, t2, E_MS1_Y_MAXIMO # se novo y >= colunas, coloca ele como colunas-1

        j E_MS1_Y_CONT

E_MS1_Y_MINIMO:
        mv t3, zero
        j E_MS1_Y_CONT

E_MS1_Y_MAXIMO:
        mv t3, t2
        addi t3, t3, -1

E_MS1_Y_CONT:
        sb t3, (t0)     # salva o novo Y

E_MS1_RET:
        ret

