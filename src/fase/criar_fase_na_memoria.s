#################################################################
# PROC_CRIAR_FASE_NA_MEMORIA                                    #
# Carrega as informacoes de uma fase, como tilemap, NPCs e      #
# posicao do jogador, alem de texturas.                         #
# 							        #
# ARGUMENTOS:						        #
#	(nenhum)                                                #
#							        #
# RETORNOS:                                                     #
#       (nenhum)                                                #
#################################################################

# Prefixo interno: P_CF1_

PROC_CRIAR_FASE_NA_MEMORIA:
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

        # redimensiona, primeiramente, o mapa para a quantidade de bytes que desejamos
        la a0, MAPA_ORIGINAL_BUFFER
        lw a1, TAMANHO_STRUCT_TILE
        li a2, TILE_STRUCT_TAMANHO
        jal PROC_REDIMENSIONAR_STRUCT_TILE

        li t0, TILE_STRUCT_TAMANHO
        sw t0, TAMANHO_STRUCT_TILE, t1          # salva o novo tamanho de bytes do tilemap
        # continuando...

        la t0, MAPA_ORIGINAL_BUFFER
        # salva as linhas e colunas no buffer de tilemap
        la s0, TILEMAP_BUFFER                   # s0 serah o tilemap
        lw s1, (t0)                             # s1 serah usado como largura
	sw s1, (s0)
	lw t1, 4(t0)
        sw t1, 4(s0)

        addi s0, s0, 8                      # avanca para depois das words de informacao

	# s0 = Etm, endereco do tilemap buffer

        # s1 = N de colunas (C)

        # s2 = linhas * colunas * bytes/tile (total de bytes)
        li t0, TILE_STRUCT_TAMANHO
	mul s2, s1, t1
        mul s2, s2, t0

	# s3 = Em = endereco inicial do mapa (sem contar words de linha e coluna)	
	la s3, MAPA_ORIGINAL_BUFFER
        addi s3, s3, 8

        # s4 = FASE_SAIDA_LIVRE
	lw s4, FASE_SAIDA_LIVRE		# ver se podemos deixar a saida descoberta

        jal PROC_INICIALIZAR_POSICAO_DO_MAPA

        # s5 = X
        # s6 = Y
        la t0, POSICOES_MAPA
        lh s5, (t0)
        lh s6, 2(t0)

        # s7 = CC, contador de colunas
        mv s7, zero
        
        # s8 = Tamanho_Struct_Tile
        li s8, TILE_STRUCT_TAMANHO

        # zera os NPCs e inimigos
        sw zero, NPCS_QUANTIDADE, t0
        sb zero, CONTADOR_NPCS, t0
        sb zero, CONTADOR_INIMIGOS, t0

P_CF1_LOOP:
    	lb t0, (s3)                     # pega o tile atual
    	
    	# se for um bloco especial, mascara no tilemap como parede quebravel
        li t1, 3                                # saida
	bnez s4, P_CF1_LOOP_PULAR_SAIDA         # se SAIDA_LIVRE = 1, nao cobre a saida
    	beq t0, t1, P_CF1_LOOP_COLOCAR_PAREDE

P_CF1_LOOP_PULAR_SAIDA: 	
    	li t1, 5                                # powerup bomba mais forte
    	beq t0, t1, P_CF1_LOOP_COLOCAR_PAREDE
    			
        li t1, 6                                # powerup mais bombas
    	beq t0, t1, P_CF1_LOOP_COLOCAR_PAREDE
   
    	# se for um npc, registra ele
    	li t1, BYTE_NPC_0
    	bge t0, t1, P_CF1_LOOP_REGISTRAR_NPC

        # se for um tile de comeco de fase, registra o jogador
        li t1, 2
        beq t0, t1, P_CF1_REGISTRAR_JOGADOR
    	j P_CF1_LOOP_CONT
    	
P_CF1_LOOP_REGISTRAR_NPC:
        mv a0, t0                               # coloca o inimigo como o byte registrado
        li t1, BYTE_NPC_0
        sub a0, a0, t1                          # corrige para ser relativo ao NPC 0
        mv a1, s5                               # coloca X
        mv a2, s6                               # coloca Y
        jal PROC_REGISTRAR_NPC
	li t0, 0                                # substitui o tile por 0
	j P_CF1_LOOP_CONT
    
# mascara como 4 (parede quebravel)
P_CF1_LOOP_COLOCAR_PAREDE:
	li t0, 4
        j P_CF1_LOOP_CONT

# registra o jogador
P_CF1_REGISTRAR_JOGADOR:	
        la t1, POSICAO_JOGADOR
        addi t2, s5, 4
        sh t2, 0(t1)			# salva posicao X do tile nas coordenadas do jogador
        
        addi t2, s6, 4
        sh t2, 2(t1)			# salva posicao Y do tile nas coordenadas do jogor
        
        # era so isso mesmo
    	
P_CF1_LOOP_CONT:    	
   	sb t0, 0(s0)                            # guarda o tile no tilemap
   	add s3, s3, s8                          # proximo tile
    	add s0, s0, s8                          # proximo tile
    	sub s2, s2, s8                          # diminui o contador de tiles em 1
        addi s5, s5, TAMANHO_SPRITE             # X++
        addi s7, s7, 1                          # CC++
        blt s7, s1, P_CF1_LOOP                  # continua se o proximo X eh menor que a largura

P_CF1_LOOP_PROXIMA_LINHA:
        lh s5, POSICOES_MAPA                    # reseta X
        addi s6, s6, TAMANHO_SPRITE             # Y++
        mv s7, zero                             # CC = 0
        bnez s2, P_CF1_LOOP                     # se contador != 0, continua


# agora resetamos o estado das bombas
P_CF1_RESETAR_BOMBAS:		
        # t0 = endereco do struct de bombas
        la t0, BOMBAS
        
        # o loop vai de i = 0 a i = 3
        li t1, 0
        li t2, 4
P_CF1_LOOP_BOMBAS:
        # desativa as bombas
        sb x0, BOMBAS_EXISTE(t0)

        addi t0, t0, STRUCT_BOMBAS_OFFSET 	# desloca o array em uma posicao
        addi t1, t1, 1				# i++
        blt t1, t2, P_CF1_LOOP_BOMBAS		# se i < 4, continuar

P_CF1_CARREGAR_METADADOS:
        # carrega todas as texturas do mapa

        la a0, FASE_TEXTURA_DE_FUNDO
        la a1, BUFFER_TEXTURA_DE_FUNDO
        li a2, TAMANHO_MAX_TEXTURA_DE_FUNDO
        jal PROC_CARREGAR_ARQUIVO_EM_BUFFER

        la a0, FASE_TEXTURA
        la a1, BUFFER_TEXTURA
        li a2, TAMANHO_MAX_TEXTURA_DE_MAPA
        jal PROC_CARREGAR_ARQUIVO_EM_BUFFER

        la a0, FASE_TEXTURA_NPCS
        la a1, BUFFER_TEXTURA_NPCS
        li a2, TAMANHO_MAX_TEXTURA_DOS_NPCS
        jal PROC_CARREGAR_ARQUIVO_EM_BUFFER

        la a0, FASE_TEXTURA_JOGADOR
        la a1, BUFFER_TEXTURA_JOGADOR
        li a2, TAMANHO_MAX_TEXTURA_DO_JOGADOR
        jal PROC_CARREGAR_ARQUIVO_EM_BUFFER

        la a0, FASE_TEXTURA_PERGAMINHO
        la a1, BUFFER_TEXTURA_PERGAMINHO
        li a2, TAMANHO_MAX_TEXTURA_DO_PERGAMINHO
        jal PROC_CARREGAR_ARQUIVO_EM_BUFFER

        # salva outros dados
        lw t0, FASE_LIMITE_DE_TEMPO

        addi t0, t0, -1 # correcao
        
        sw t0, SEGUNDOS_RESTANTES, t1

P_CF1_RET:
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