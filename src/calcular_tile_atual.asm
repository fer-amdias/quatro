##############################################################
# PROC_CALCULAR_TILE_ATUAL			             #
# Calcula o tile atual de uma coordenada X e Y e retorna a   #
# 							     #
# 							     #
# ARGUMENTOS:						     #
#	A0 : ENDERECO DO MAPA (.data)			     #
# 	A1 : POSICAO X                                       #
#       A2 : POSICAO Y                                       #
# RETORNOS:                                                  #
#       A0 : INFORMACAO DO TILE ATUAL (0-255)		     #
#	A1 : COLUNA EM QUE O TILE ESTAH LOCALIZADO NO .data  #
#	A2 : LINHA EM QUE O TILE ESTAH LOCALIZADO NO .data   #
#	A3 : POSICAO X DO TILE				     #
#	A4 : POSICAO Y DO TILE				     #
##############################################################


.text
.eqv TAMANHO_SPRITE 20	# tamanho padrao de um tile

PROC_CALCULAR_TILE_ATUAL:

			# temos que calcular que valor esse X e Y dah e em que tile ele estah. 
			la t0, POSICOES_MAPA		# carregamos a posicao do mapa em t0. aqui teremos X em (t0) e Y em 1(t0).
			lb t1, 0(t0)			# POSICAO_MAPA_X
			lb t2, 1(t0)			# POSICAO_MAPA_Y
			
			# t1 = X
			# t2 = Y
			sub t1, a1, t1 			# X = aX - POSICAO_MAPA_X
			sub t2, a2, t2 			# Y = aY - POSICAO_MAPA_Y 
			
			# t0 = tamanho_sprite (qqr dimensao assumindo tile quadrado (naturalmente)
			li t0, TAMANHO_SPRITE
			
			# se dividirmos pelo tamanho do sprite, conseguiremos a posicao X e Y em respeito a cada tile (em vez de cada pixel)
			div t1, t1, t0			# X /= tamanho_sprite
			div t2, t2, t0			# Y /= tamanho_sprite
	
			lw t0, (a0)			# t0 = N_COL : Numero de Colunas (primeiro valor no endereco do mapa)
	
			# t0 = idx
			mul t0, t2, t0			# idx = Y * N_COL
			add t0, t0, t1			# idx += X
			addi t0, t0, 8			# pula os bytes de largura e altura / numero de colunas e linhas
			add a0, a0, t0			# E += IDX (pula pro tile desejado)
			
		######## retornar pos do canto superior esquerdo do mapa ########
			
			# t3 = pos X do mapa
			# t4 = pos Y do mapa
			# t5 = pos X na tela do tile
			# t6 = pos Y na tela do tile
			la t0, POSICOES_MAPA
			lb t3, (t0)			# carrega a pos X do mapa
			lb t4, 1(t0)			# carrega a pos Y do mapa
			
			# t0 = tamanho_sprite (qqr dimensao assumindo tile quadrado (naturalmente)
			li t0, TAMANHO_SPRITE
			
			mul t5, t1, t0			# X *= tamanho_sprite
			mul t6, t2, t0			# Y *= tamanho_sprite
			
			add t5, t5, t3			# X += pos X do mapa
			add t6, t6, t4			# Y += pos Y do mapa
			
		######## retornos ########
			lb a0, (a0) 			# ret_a0 = informacao do TILE
			mv a1, t1			# ret_a1 = X do tile em respeito a cada tile
			mv a2, t2			# ret_a2 = Y do tile em respeito a cada tile
			mv a3, t5			# ret_a3 = X do tile em respeito ao canto superior esquerdo na tela
			mv a4, t6			# ret_a4 = Y do tile em respeito ao canto superior esquerdo na tela
			
			ret	#yippee
			
			
