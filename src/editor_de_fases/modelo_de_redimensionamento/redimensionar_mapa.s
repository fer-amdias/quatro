# EDITOR_REDIMENSIONAR_MAPA
# Redimensiona o tilemap para ter as dimensoes escolhidas.
#
# ARGUMENTOS:
# a0 - Nova largura
# a1 - Nova altura

.data

TEMP_TILEMAP_BUFFER:    .word 0 0
                        .space 192

.text

EDITOR_REDIMENSIONAR_MAPA:

        # retorna se os argumentos estiverem mal-formatados
        blez a0, E_EM3_RET
        blez a1, E_EM3_RET

        la t1, TILEMAP_BUFFER
        la t2, TEMP_TILEMAP_BUFFER

        # salva as novas dimensoes
        sw a0, 4(t2)
        sw a1, (t2)

        # pega a altura e largura original
        lw t5, 4(t1)
        lw t6, (t1)

        addi t1, t1, 8          # pula informacoes
        addi t2, t2, 8

        # X = 0, Y = 0
        mv t3, zero
        mv t4, zero

        # t1 = endereco do tilemap original
        # t2 = endereco do tilemap temp

        # t3 = X
        # t4 = Y

        # t5 = L0 = largura original
        # t6 = H0 = altura original

        # a0 = L = largura nova
        # a1 = H = altura nova

        j E_RM3_LOOP

E_RM3_PROXIMA_LINHA:
        addi t4, t4, 1                  # Y++
        beq t4, a1, E_RM3_LOOP_FIM      # se Y = H, chegamos no final
        mv t3, zero                     # X = 0

E_RM3_LOOP:
        beqz t3, E_RM3_TILE_BORDA       # se X = 0, eh um tile de borda
        beqz t4, E_RM3_TILE_BORDA       # se Y = 0, eh um tile de borda
        mv t0, a0
        addi t0, t0, -1
        beq t3, t0, E_RM3_TILE_BORDA    # se X = L-1, eh um tile de borda
        mv t0, a1
        addi t0, t0, -1
        beq t4, t0, E_RM3_TILE_BORDA    # se Y = H-1, eh um tile de borda

        # se X >= L0 ou Y >= H0, o tile nao ta no tilemap
        # senao, ele ta
        bge t3, t5, E_RM3_FORA_DO_TILEMAP_ORIGINAL
        bge t4, t6, E_RM3_FORA_DO_TILEMAP_ORIGINAL

E_RM3_NO_TILEMAP_ORIGINAL:
        mul t0, t4, t5   # pula Y linhas
        add t0, t0, t3   # e X colunas
        add t0, t0, t1   # vai no endereco do tile X,Y
        lb t0, (t0)      # pega a informacao dele

        sb t0, (t2)      # salva no endereco atual do tilemap temp

        # checa se o tile era de borda. Se sim, devemos substitui-lo por uma parede.
        mv t0, t5
        addi t0, t0, -1
        beq t0, t3, E_RM3_DELETAR_BORDA
        mv t0, t6
        addi t0, t0, -1
        beq t0, t4, E_RM3_DELETAR_BORDA
        j E_RM3_LOOP_CONT

E_RM3_FORA_DO_TILEMAP_ORIGINAL:
        sb zero, (t2)
        j E_RM3_LOOP_CONT

E_RM3_TILE_BORDA:
        li t0, 1
        sb t0, (t2)     # guarda uma parede no lugar
        j E_RM3_LOOP_CONT

E_RM3_DELETAR_BORDA:
        mv t0, zero
        sb t0, (t2)     # guarda uma parede no lugar

E_RM3_LOOP_CONT:
        addi t2, t2, 1  # vai pro proximo tile
        addi t3, t3, 1  # X++
        beq t3, a0, E_RM3_PROXIMA_LINHA # vai pra proxima linha se X = L
        j E_RM3_LOOP    # continua o loop

E_RM3_LOOP_FIM:

# agora devemos copiar o conteudo do novo tilemap pro antigo
        mul t0, a0, a1  # pega a quantidade de bytes que devemos copiar (L * H)
        addi t0, t0, 8  # mais os bytes de informacao
        la t1, TEMP_TILEMAP_BUFFER
        la t2, TILEMAP_BUFFER
E_RM3_LOOP_2:

# pega o conteudo no temp e coloca no buffer certo byte por byte, ateh acabar
        lb t3, (t1)
        sb t3, (t2)
        addi t1, t1, 1          # avanca pro proximo byte
        addi t2, t2, 1          # avanca pro proximo byte
        addi t0, t0, -1
        beqz t0, E_EM3_RET      # se chegamos no final, saimos
        j E_RM3_LOOP_2          # senao, continuamos


E_EM3_RET:
        ret