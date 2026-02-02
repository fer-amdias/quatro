##############################################################
# PROC_IMPRIMIR_TILEMAP_NO_FASE_BUFFER 		             #
# Imprime o tilemap no buffer de fase.                       #
# 							     #
# ARGUMENTOS:						     #
# 	A0 : ENDERECO DA TEXTURA DO MAPA                     #
#							     #
# RETORNOS:                                                  #
#       (nenhum)                                             #
##############################################################

# Prefixo interno: P_IT2_

.text

PROC_IMPRIMIR_TILEMAP_NO_FASE_BUFFER:
        addi sp, sp, -32
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)
        sw s2, 12(sp)
        sw s3, 16(sp)
        sw s4, 20(sp)
        sw s5, 24(sp)
        sw s6, 28(sp)

        # Primeiro, as dimensoes do buffer
        la s0, TILEMAP_BUFFER           # endereco do tilemap
        lw s1, (s0)                     # L (largura)
        lw s2, 4(s0)                    # H (altura)
        addi s0, s0, 8                  # pula a L e H

        li t0, TAMANHO_SPRITE
        mul s1, s1, t0			# L *= TAMANHO_SPRITE
        mul s2, s2, t0			# H *= TAMANHO_SPRITE
        
        # agora temos o tamanho do mapa em pixels, e devemos salva-lo na memoria para utilizacao do buffer
        la t0, FASE_BUFFER_COL		# n de colunas da fase no buffer
        sh s1, (t0)
        
        la t0, FASE_BUFFER_LIN		# n de linhas da fase no buffer
        sh s2, (t0)	

        la t0, POSICOES_MAPA
        lh s3, (t0)                     # X do mapa (X0)
        lh s4, 2(t0)                    # Y do mapa (Y0)

        add s1, s1, s3                  # Xm (X maximo) = L + X0
        add s2, s2, s4                  # Ym (Y maximo) = H + Y

        li s5, AREA_SPRITE		# carrega AREA_SPRITE

        mv s6, a0
        addi s6, s6, 8                  # pula as words de dimensao

        # s0 = eT = endereco atual no tilemap_buffer
        # s1 = Xm
        # s2 = Ym
        # s3 = X
        # s4 = Y
        # s5 = AREA_SPRITE	
        # s6 = textura do mapa        

        # t0 = tI = informacao do tile
P_IT2_LOOP:			
        lbu t0, (s0)			# tI = informacao em Em

        # para o procedimento PROC_IMPRIMIR_TEXTURA, sao argumentos:
        # 	a0 = aE0 = endereco da textura (.data)
        # 	a1 = aX  = pos X
        # 	a2 = aY  = pos Y
        # 	a3 = aL  = n de linhas da textura
        # 	a4 = aC  = n de colunas da textura

        mul t1, t0, s5                  # pega (tI * AREA_SPRITE)
        add a0, s6, t1			# aE0 = textura + (tI * AREA_SPRITE) = pula pra textura associada com o tile
        mv a1, s3			# aX = X
        mv a2, s4			# aY = Y
        li a3, TAMANHO_SPRITE		# aL = L
        li a4, TAMANHO_SPRITE		# aC = C
        li a7, 1			# printa no BUFFER
        jal PROC_IMPRIMIR_TEXTURA	# chamada o procedimento de impressao de textura
        
        addi s0, s0, 1			# eT++
        addi s3, s3, TAMANHO_SPRITE     # X += TAMANHO_SPRITE
        
        # SE X != Xm, continua o loop
        bne s3, s1, P_IT2_LOOP
        # senao:
P_IT2_PROXIMA_LINHA:		
        lh s3, POSICOES_MAPA            # recarrega X
        addi s4, s4, TAMANHO_SPRITE	# Y += TAMANHO_SPRITE
        
        # SE Y != Ym: CONTINUA A IMPRESSAO, NAO TERMINAMOS
        bne s4, s2, P_IT2_LOOP

P_IT2_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        lw s2, 12(sp)
        lw s3, 16(sp)
        lw s4, 20(sp)
        lw s5, 24(sp)
        lw s6, 28(sp)
        addi sp, sp, 32
        ret