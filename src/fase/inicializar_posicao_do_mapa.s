#################################################################
# PROC_INICIALIZAR_POSICAO_DO_MAPA                              #
# Calcula os dados inicias de posicao do mapa.                  #
# 							        #
# ARGUMENTOS:						        #
#	(nenhum)                                                #
#							        #
# RETORNOS:                                                     #
#       (nenhum)                                                #
#################################################################

PROC_INICIALIZAR_POSICAO_DO_MAPA:
        la t0, MAPA_ORIGINAL_BUFFER 
        lw t1, (t0) # Largura (L)
        lw t2, 4(t0) # Altura (H)
        la t3, POSICOES_MAPA		# carrega o endereco de posicao do mapa

        # pega L e H em pixeis
        li t0, TAMANHO_SPRITE
        mul t1, t1, t0
        mul t2, t2, t0

        srli t0, t1, 1     		# X = L/2
        neg t0, t0			# X = -L/2
        addi t0, t0, CENTRO_VGA_X       # X = CENTRO_VGA_X - L/2  	   
        sh t0, (t3)

        srli t0, t2, 1     		# Y = H/2
        neg t0, t0			# Y = -H/2
        addi t0, t0, CENTRO_VGA_Y       # Y = CENTRO_VGA_Y - H/2
        sh t0, 2(t3)			# salva a posicao Y do canto superior esquerdo do mapa

        ret