# EDITOR_IMPRIMIR_FASE_NO_FASE_BUFFER
# Imprime a fase no fase buffer lol
#
# ARGUMENTOS:
# a0 = textura do mapa
# a1 = textura dos NPCs

.text

EDITOR_IMPRIMIR_FASE_NO_FASE_BUFFER:

        addi sp, sp, -40
        sw ra, (sp)
        sw s0, 4(sp)    
        sw s1, 8(sp)
        sw s2, 12(sp)
        sw s3, 16(sp)
        sw s4, 20(sp)
        sw s5, 24(sp)
        sw s6, 28(sp)
        sw s7, 32(sp)   
        sw s8, 36(sp)

        # s0 = endereco do tilemap
        # s1 = altura do mapa em pixeis
        # s2 = largura do mapa em pixeis
        # s3 = Y atual 
        # s4 = X atual
        # s5 = contador de linhas
        # s6 = contador de colunas
        # s7 = endereco da textura do mapa
        # s8 = endereco da textura dos NPCs

        la s0, TILEMAP_BUFFER           
        lw s1, (s0)			# carrega o n de linhas em s1 (L)
        lw s2, 4(s0)			# carrega o n de colunas em s2 (C)
        addi s0, s0, 8                  # avanca para o conteudo do tilemap



        # devemos agora calcular a posicao X e Y que o mapa deve estar
        # primeiramente, devemos multiplicar L e C pelo tamanho do sprite para ter
        li t0, TAMANHO_SPRITE
        mul s1, s1, t0			# L *= TAMANHO_SPRITE
        mul s2, s2, t0			# C *= TAMANHO_SPRITE
        
        # agora temos o tamanho do mapa em pixels, e devemos salva-lo na memoria para utilizacao do buffer
        sh s1, FASE_BUFFER_LIN, t0
        sh s2, FASE_BUFFER_COL, t0	
        
        # agora devemos propriamente centralizar a imagem
        # a distancia do canto superor esquerdo pro centro eh L/2 e C/2
        # entao botamos X = CENTRO_FASE_X - C/2
        # igualmente, 	Y = CENTRO_FASE_Y - L/2
        
        srli s4, s2, 1     		# X = C/2
        neg s4, s4			# X = -C/2
        addi s4, s4, CENTRO_FASE_X       # X = CENTRO_VGA_X - C/2  	   

        srli s3, s1, 1     		# Y = L/2
        neg s3, s3			# Y = -L/2
        addi s3, s3, CENTRO_FASE_Y       # Y = CENTRO_VGA_Y - L/2
        
        la t0, POSICOES_MAPA		# carrega o endereco de posicao do mapa
        sh s4, (t0)			# salva a posicao X do canto superior esquerdo do mapa
        sh s3, 2(t0)			# salva a posicao Y do canto superior esquero do mapa
        
        mv s5, zero			# CL = 0
        mv s6, zero  	   		# CC = 0

        mv s7, a0                       # guarda a textura do mapa

        mv s8, a1

E_IF1_LOOP:

        
        lb t0, (s0)                     # informacao do tile atual

        li t1, BYTE_NPC_0               # onde se inicia os NPCs
        bge t0, t1, E_IF1_LOOP_IMPRIMIR_NPC # se o tile for igual ou maior que o valor inicial de um NPC, ele eh um NPC

        lw t1, 4(s7)                     # pega a altura da textura
        li t2, TAMANHO_SPRITE           # pega as dimensoes de um tile
        mul t2, t2, t0                  # multiplica a altura de um tile pela altura da textura
        bge t2, t1, E_IF1_LOOP_SUBSTITUIR_TILE  # se o tile nao estiver presente na textura, substitui por 0 

        j E_IF1_LOOP_IMPRIMIR_TILE

E_IF1_LOOP_IMPRIMIR_NPC:

        # PRIMEIRO IMPRIMIMOS UM TILE VAZIO!!!
        addi a0, s7, 8			# pula as words de informacao, imprimindo no comeco da textura (tile 0)
        mv a1, s4			# aX = X
        mv a2, s3			# aY = Y
        li a3, TAMANHO_SPRITE		# aL = L
        li a4, TAMANHO_SPRITE		# aC = C
        li a7, 1			# printa no buffer de fase
        
        jal PROC_IMPRIMIR_TEXTURA	

        lb t0, (s0)                     # recarrega o tile, perdido no procedimento anterior
        li t1, BYTE_NPC_0
        sub t0, t0, t1                  # pega o NPC relativo ao NPC 0
        
        li t1, AREA_SPRITE
        li t2, 5
        mul t1, t1, t2                  # 5 tiles por NPC

        mul t0, t0, t1                  # pega AREA_SPRITE * tile

        # 	a0 = endereco da textura (.data)
        # 	a1 = pos X
        # 	a2 = pos Y
        # 	a3 = n de linhas da textura
        # 	a4 = n de colunas da textura
        add a0, s8, t0			# aE0 = endereco_textura + (npc * area_tile) = pula pra textura associada com o npc
        addi a0, a0, 8                  # pula as words de informacao
        mv a1, s4			# aX = X
        mv a2, s3			# aY = Y
        li a3, TAMANHO_SPRITE		# aL = L
        li a4, TAMANHO_SPRITE		# aC = C
        li a7, 1			# printa no buffer de fase
        jal PROC_IMPRIMIR_TEXTURA	

        j E_IF1_LOOP_CONT

E_IF1_LOOP_SUBSTITUIR_TILE:
        li t0, 0                        # substitui o tile pelo tile 0 (vazio, so chao mesmo)

E_IF1_LOOP_IMPRIMIR_TILE:
        li t1, AREA_SPRITE
        mul t0, t0, t1                  # pega AREA_SPRITE * tile

        # 	a0 = endereco da textura (.data)
        # 	a1 = pos X
        # 	a2 = pos Y
        # 	a3 = n de linhas da textura
        # 	a4 = n de colunas da textura
        add a0, s7, t0			# aE0 = endereco_textura + (tile * area_tile) = pula pra textura associada com o tile
        addi a0, a0, 8                  # pula as words de informacao
        mv a1, s4			# aX = X
        mv a2, s3			# aY = Y
        li a3, TAMANHO_SPRITE		# aL = L
        li a4, TAMANHO_SPRITE		# aC = C
        li a7, 1			# printa no buffer de fase
        
        jal PROC_IMPRIMIR_TEXTURA	
        
        # fim do procedimento

E_IF1_LOOP_CONT:
        
        addi s0, s0, 1			# Endereco_tilemap++
        addi s6, s6, TAMANHO_SPRITE	# CC += TAMANHO_SPRITE
        addi s4, s4, TAMANHO_SPRITE     # X += TAMANHO_SPRITE
        
        # SE C = CC: PROXIMA LINHA
        beq s2, s6, P_IF1_PROXIMA_LINHA
        
        # SENAO, REPETE O LOOP
        j E_IF1_LOOP
        
P_IF1_PROXIMA_LINHA:		

        sub s4, s4, s2			# X -= C, voltando ele pra posicao inicial
        addi s3, s3, TAMANHO_SPRITE	# Y += TAMANHO_SPRITE
        addi s5, s5, TAMANHO_SPRITE	# CL += TAMANHO_SPRITE
        mv s6, zero			# CC = 0


        # SE L < CL: CONTINUA A IMPRESSAO, NAO TERMINAMOS
        bgt s1, s5, E_IF1_LOOP

        lw ra, (sp)
        lw s0, 4(sp)    
        lw s1, 8(sp)
        lw s2, 12(sp)
        lw s3, 16(sp)
        lw s4, 20(sp)
        lw s5, 24(sp)
        lw s6, 28(sp)
        lw s7, 32(sp)  
        lw s8, 36(sp) 
        addi sp, sp, 40
ret