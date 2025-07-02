#################################################################
# PROC_MOVER_JOGADOR				       	     	#
# Move o jogador para uma coordenada escolhida.	            	#
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : MODO (0, 1, 2 OU 3)                        	#
#	A1 : POSICAO X                                  	#
#	A2 : POSICAO Y						#
#	A3 : ENDERECO DE TEXTURA DO JOGADOR			#
#	A4 : ENDERECO DO MAPA					#
#	A5 : ENDERECO DA TEXTURA DO MAPA			#
# RETORNOS:                                                  	#
#       A0 : SE O JOGADOR ESTAH VIVO (0 OU 1)                  	#
#################################################################

.text

.eqv MODO_MOVER_SEM_CHECAR_PAREDES_NEM_INIMIGOS 0
.eqv MODO_MOVER_SEM_CHECAR_INIMIGOS 1
.eqv MODO_MOVER 2
.eqv MODO_POSICIONAR 3

############ SUB_PROC de checar se tile eh andavel ############

# parametros:
#	a0 = endereco do mapa
#	a1 = pos X
#	a2 = pos Y
# retornos:
#	a0 = 1 (se andavel), 0 (se nao andavel)
P_PJ1_CHECAR_SE_TILE_EH_ANDAVEL:

			# salva o X e Y do jogador mais a textura do jogador e endereco do mapa
			addi sp, sp, -16
			sw a1, (sp)
			sw a2, 4(sp)
			sw a3, 8(sp)
			sw a4, 12(sp)
		
			# argumentos do calcular tile:
			#	a0 = endereco do mapa
			#	a1 = pos X
			#	a2 = pos Y
			# retornos interessantes:
			#	a0 = tile (0-255)
			jal PROC_CALCULAR_TILE_ATUAL	
			
			# carrega o X e Y do jogador mais a textura do jogador e endereco do mapa
			lw a1, (sp)
			lw a2, 4(sp)
			lw a3, 8(sp)
			lw a4, 12(sp)
			addi sp, sp, 16
			
			# se tile = 1 ou 4, ent temos um nao andavel
			li t0, 1
			beq a0, t0, P_PJ1_TILE_N_EH_ANDAVEL
			li t0, 4
			beq a0, t0, P_PJ1_TILE_N_EH_ANDAVEL
			
P_PJ1_TILE_EH_ANDAVEL:  li a0, 1
			ret
			
			
P_PJ1_TILE_N_EH_ANDAVEL:li a0, 0	
			ret
			
############ fim de subproc ############


PROC_MOVER_JOGADOR:	addi sp, sp, -8
			sw ra, (sp)			# salva o endereco de retorno previo
			sw a0, 4(sp)			# salva s0

			mv s0, a0			# guarda a0 em s0 para manipulacao segura

# prefixo interno: P_MJ1_

# argumentos:
#	a0: M: modo (0, 1, 2, 3)  ---> guardado em s0
#	a1: X: pos X
#	a2: Y: pos Y
#	a3: T: endereco da textura do jogador
#	a4: E: endereco do mapa 
#	a5: t: endereco da textura do mapa
# retorno:
#	a0: V: se o jogador estah vivo (1 ou 0)



	
			li t0, MODO_MOVER
			bne t0, s0, P_MJ1_MOVER_SEM_CHECAR_INIMIGOS
			
			# SE M == MODO_MOVER, FACA O ABAIXO

######################################## MODO MOVER ########################################

			# temos que checar se um dos quatro cantos na posicao estao ENTRE os pontos
			# de um inimigo.
			
			
# t0 = Q    = QTD_INIMIGOS
# t1 = VI   = VETOR_INIMIGOS
# t2 = TI   = TAMANHO_INIMIGOS
# t3 = TJ_X = TAMANHO_JOGADOR_X
# t4 = TJ_Y = TAMANHO_JOGADOR_Y 

# a1 = X    = posicao X do jogador
# a2 = Y    = posicao Y do jogador



			la t0, INIMIGOS_QUANTIDADE
			lw t0, (t0)			# carrega a qtd de inimigos em t0
			la t1, INIMIGOS_POSICAO		# carrega o vetor de posicao de inimigos em t1
			la t2, INIMIGOS_TAMANHO		
			lw t2, (t2)			# carrega as dimensoes de inimigos em t2
			
			lh t3, (a3)			# carrega dimensao X do jogador
			lh t4, 4(a3)			# carrega dimensao Y do jogador
			
# t5 = IX  = pos X do inimigo
# t6 = IY  = pos Y do inimigo

# a0 = D   = diferenca entre posicoes do jogador e do inimigo para checar colisao
# a4 = CC  = contador de colisao. se CC = 2, houve colisao tanto no X quanto no Y!
			
P_MJ1_LOOP_COLISAO_INIMIGOS:

			lh t5, (t1)			# carrega posicao X do inimigo
			lh t6, 2(t1)			# carrega posicao Y do inimigo
			
			# temos que checar:
			
			# se o X do jogador esta entre o X do inimigo e o X do inimgo + seu tamanho
			# se o Y do jogador esta entre o X do inimigo e o X do inimigo + seu tamanho
			
			# podemos tirar a diferenca entre o X do jogador e o X do inimigo
			# se for maior que zero e menor que tamanho, temos uma colisao
			# o mesmo vale pro Y
			
			# temos que checar isso pros quatro cantos do jogador!
			
#################################################################################
#
#	O codigo abaixo eh bem dificil de entender
#	entao eu vou explicar ele aqui
#	
#	ha dois cantos principais do jogador: o CANTO SUPERIOR ESQUERDO e o CANTO INFERIOR DIREITO
#
#	se um dos cantos estiverem entre o X e o Y do jogador, temos uma colisao
#	se um dos cantos estiver entre o X do jogador e OUTRO estiver entre o Y do jogador, tambem temos uma colisao
#	isso seria equivalente ao canto superior direito ou o canto inferior esquerdo estiverem dentro da hitbox do inimigo.
#
#	para cada um dos dois cantos principais, checamos se o X ou o Y estah em colisao
#	no caso, considere X como a pos x do canto e XI a pos x do inimigo
#			   Y como a pos y do canto e YI a pos y do inimigo
#			   T como dimensao do inimigo (assumindo inimigo quadrado)
#			   C como o contador de colisoes
#		se 0 <= (X - XI) <= T, C++;
#		se 0 <= (Y - YI) <= T, C++;
#
#	se o contador (C) for 2 ou mais, entao uma (ou mais) das condicoes de colisao foram satisfeitas
#	entao imediatamente retornamos que o jogador morreu
#
# 	o codigo estah abaixo:

P_MJ1_PRIMEIRO_CANTO_1:	sub a0, a1, t5			# D = X - IX
			
			# se D < 0, nao houve colisao nesse canto
			blt a0, zero, P_MJ1_PRIMEIRO_CANTO_2
			
			# se D > TJ, nao houve colisao nesse ponto
			bgt a0, t2, P_MJ1_PRIMEIRO_CANTO_2
			
			addi a4, a4, 1			# marcador de colisao
			
			
P_MJ1_PRIMEIRO_CANTO_2: sub a0, a2, t6   		# D = Y - IY

			# se D < 0, nao houve colisao nesse canto
			blt a0, zero, P_MJ1_SEGUNDO_CANTO_1

			# se D > TJ, nao houve colisao nesse ponto
			bgt a0, t2, P_MJ1_SEGUNDO_CANTO_1
			
			addi a4, a4, 1			# marcador de colisao
			
P_MJ1_SEGUNDO_CANTO_1: 	sub t5, t5, t3			# move a hitbox do inimigo para a esquerda
							# (o equivalente a ir pro canto superior direito do jogador)
							# pra checar colisao
						
			sub a0, a1, t5			# D = X - IX
			
			# se D < 0, nao houve colisao nesse canto
			blt a0, zero, P_MJ1_SEGUNDO_CANTO_2
			
			# se D > TJ, nao houve colisao nesse ponto
			bgt a0, t2, P_MJ1_SEGUNDO_CANTO_2
			
			addi a4, a4, 1			# marcador de colisao
			
P_MJ1_SEGUNDO_CANTO_2:	sub t6, t6, t4			# move a hitbox do inimigo para baixo 
							# (o equivalente a ir pro canto inferior direito do jogador)

			sub a0, a2, t6   		# D = Y - IY

			# se D < 0, nao houve colisao nesse canto
			blt a0, zero, P_MJ1_LOOP_CONT_1

			# se D > TJ, nao houve colisao nesse ponto
			bgt a0, t2, P_MJ1_LOOP_CONT_1
			
			addi a4, a4, 1			# marcador de colisao
			
#################################################################################
			
P_MJ1_LOOP_CONT_1:	li a0, 2
			bge a4, a0, P_MJ1_MORTE_1
			
			addi t0, t0, -1			# subtrai 1 da qtd de inimigos para checar
			addi t1, t1, 4			# pula pro proximo inimigo
			
			# se ainda tiver inimigos, continua o loop
			bnez t0, P_MJ1_LOOP_COLISAO_INIMIGOS
			
			mv a0, zero			# reseta a0 para nao mexer com os cheques de modo de movimento abaixo
			
			# agora eh hora de checar tiles ao redor para ver se temos paredes
			# temos que checar pros 4 cantos
			
######################################## MODO MOVER SEM CHECAR INIMIGOS ########################################

P_MJ1_MOVER_SEM_CHECAR_INIMIGOS:
		
			# se modo for mover sem checar paredes nem inimigos OU posicionar, pula a checagem de paredes
			li t0, MODO_MOVER_SEM_CHECAR_INIMIGOS
			bne t0, s0, P_MJ1_MOVER_SEM_CHECAR_PAREDES_NEM_INIMIGOS
			
			lh a6, (a3)			# carrega dimensao X do jogador
			lh a7, 4(a3)			# carrega dimensao Y do jogador
		
			# temos que fazer o seguinte para cada canto do jogador
			
		
P_MJ1_CANTO_1:		mv a0, a4			# coloca o endereco do mapa em a0
							# X jah estah em a1
							# Y jah estah em a2
			jal P_PJ1_CHECAR_SE_TILE_EH_ANDAVEL
			beqz a0, P_MJ1_FIM		# se nao for andavel, cancela o movimento
			
P_MJ1_CANTO_2:		add a1, a1, a6			# vai pro canto superior direito
			
			mv a0, a4			# coloca o endereco do mapa em a0
			jal P_PJ1_CHECAR_SE_TILE_EH_ANDAVEL
			beqz a0, P_MJ1_FIM		# se nao for andavel, cancela o movimento
			
P_MJ1_CANTO_3:		add a2, a2, a7			# vai pro canto inferior direito
			mv a0, a4
			jal P_PJ1_CHECAR_SE_TILE_EH_ANDAVEL
			beqz a0, P_MJ1_FIM
			
P_MJ1_CANTO_4:		sub a1, a1, a6			# vai pro canto inferior esquerdo
			mv a0, a4
			jal P_PJ1_CHECAR_SE_TILE_EH_ANDAVEL
			beqz a0, P_MJ1_FIM
			
			# terminamos de checar e podemos andar
			# mas temos que resetar X e Y
			# X jah estah no lugar (canto esquerdo)
			# mas Y estah no canto errado (inferior)
			sub a2, a2, a7			# vai pro canto superior direito	
			
P_MJ1_MOVER_SEM_CHECAR_PAREDES_NEM_INIMIGOS:
P_MJ1_MOVER: 


######################################## MOVER ########################################

			# t1 = pos X; t2 = pos Y
			mv t1, a1
			mv t2, a2
			
			# para o procedimento PROC_IMPRIMIR_TEXTURA, sao argumentos:
			# 	a0 = aE0 = endereco da textura (.data)
			# 	a1 = aX  = pos X
			# 	a2 = aY  = pos Y
			# 	a3 = aL  = n de linhas da textura
			# 	a4 = aC  = n de colunas da textura
			#	a7 = M   = modo de impressao (0 = tela, 1 = buffer)
			mv a0, a3			# aE0 = T
			lw a4, (a3)			# salva em aC o numero de colunas
			lw a3, 4(a3)			# salva em aL o numero de linhas
			mv a7, x0			# seleciona o modo como imprimir na tela
			# argumentos a1 e a2 jah estao posicionados :)
			jal PROC_IMPRIMIR_TEXTURA		# imprime o jogador
			
			# se o modo for POSICIONAR, nao salve a posicao do jogador
			li t0, MODO_POSICIONAR
			beq s0, t0, P_MJ1_FIM
			
			la t0, POSICAO_JOGADOR
			sw t1, (t0)
			sw t2, 2(t0)
			
			j P_MJ1_FIM 	# terminamos
			
			

P_MJ1_MORTE_1:		mv a0, zero			# se ele morreu
			j P_MJ1_MORTE_2			# pula a proxima instrucao :)


P_MJ1_FIM: 		li a0, 1			# retorna que ele esta vivo
P_MJ1_MORTE_2:		lw ra, (sp)			# carrega o endereco de retorno previo
			lw s0, 4(sp)			# carrega s0 original
			addi sp, sp, 8		
			ret
