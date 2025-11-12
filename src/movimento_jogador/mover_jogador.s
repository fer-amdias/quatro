#################################################################
# PROC_MOVER_JOGADOR				       	     	#
# Move o jogador para uma coordenada escolhida.	            	#
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : MODO (0, 1 OU 2)                        		#
#	A1 : POSICAO X                                  	#
#	A2 : POSICAO Y						#
#	A3 : ENDERECO DE TEXTURA DO JOGADOR			#
#	A4 : ENDERECO DO MAPA					#
# RETORNOS:                                                  	#
#       A0 : SE O JOGADOR SE MOVEU (0 OU 1)                  	#
#################################################################

.text

.eqv MODO_MOVER_SEM_CHECAR_PAREDES 0
.eqv MODO_MOVER 1
.eqv MODO_POSICIONAR 2

.eqv HOUVE_MOVIMENTO 1
.eqv NAO_HOUVE_MOVIMENTO 0

############ SUB_PROC de checar se tile eh andavel ############

# parametros:
#	a0 = endereco do mapa
#	a1 = pos X
#	a2 = pos Y
# retornos:
#	a0 = 1 (se andavel), 0 (se nao andavel)
P_MJ1_CHECAR_SE_TILE_EH_ANDAVEL:
			# salva o X e Y do jogador mais a textura do jogador e endereco do mapa
			addi sp, sp, -20
			sw a1, (sp)
			sw a2, 4(sp)
			sw a3, 8(sp)
			sw a4, 12(sp)
			sw ra, 16(sp)
		
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
			lw ra, 16(sp)
			addi sp, sp, 20
			
			# se tile = 1 ou 4, ent temos um nao andavel
			li t0, 1
			beq a0, t0, P_MJ1_TILE_N_EH_ANDAVEL
			li t0, 4
			beq a0, t0, P_MJ1_TILE_N_EH_ANDAVEL
			
P_MJ1_TILE_EH_ANDAVEL:  li a0, 1
			ret
			
			
P_MJ1_TILE_N_EH_ANDAVEL:li a0, 0	
			ret
			
############ fim de subproc ############


PROC_MOVER_JOGADOR:	addi sp, sp, -8
			sw ra, (sp)			# salva o endereco de retorno previo
			sw s0, 4(sp)			# salva s0

			mv s0, a0			# guarda a0 em s0 para manipulacao segura

# prefixo interno: P_MJ1_

# argumentos:
#	a0: M: modo (0, 1, 2)  ---> guardado em s0
#	a1: X: pos X
#	a2: Y: pos Y
#	a3: T: endereco da textura do jogador
#	a4: E: endereco do mapa 
# retorno:
#	a0: V: se o jogador estah vivo (1 ou 0)

			
			# SE M == MODO_MOVER, FACA O ABAIXO

			
######################################## MODO MOVER ########################################

P_MJ1_MODO_MOVER:	
		
			# se modo for mover sem checar paredes OU posicionar, pula a checagem de paredes
			li t0, MODO_MOVER
			bne t0, s0, P_MJ1_MOVER_SEM_CHECAR_PAREDES
			
			lh a6, (a3)			# carrega dimensao X do jogador
			lh a7, 4(a3)			# carrega dimensao Y do jogador
		
			# temos que fazer o seguinte para cada canto do jogador
			
			# eh importante lembrar que o jogador tem uma textura com SEIS aparencias diferentes, Portanto, temos que dividir a dimensao Y do jogador por 6.
			li t0, 6
			div a7, a7, t0			# dimensao Y do jgoador /= 6
			
			# salva esses argumentos na stack para podermos os manipular com seguranca
			addi sp, sp, -8
			sw a1, (sp)
			sw a2, 4(sp)
		
		
P_MJ1_CANTO_1:		mv a0, a4			# coloca o endereco do mapa em a0
							# X jah estah em a1
							# Y jah estah em a2
			jal P_MJ1_CHECAR_SE_TILE_EH_ANDAVEL
			beqz a0, P_MJ1_SEM_MOVIMENTO_0	# se nao for andavel, cancela o movimento
			
P_MJ1_CANTO_2:		add a1, a1, a6			# vai pro canto superior direito
			addi a1, a1, -1			# compensa por comecarmos no primeiro pixel
			
			mv a0, a4			# coloca o endereco do mapa em a0
			jal P_MJ1_CHECAR_SE_TILE_EH_ANDAVEL
			beqz a0, P_MJ1_SEM_MOVIMENTO_0	# se nao for andavel, cancela o movimento
			
P_MJ1_CANTO_3:		add a2, a2, a7			# vai pro canto inferior direito
			addi a2, a2, -1			# compensa por comecarmos no primeiro pixel
			mv a0, a4
			jal P_MJ1_CHECAR_SE_TILE_EH_ANDAVEL
			beqz a0, P_MJ1_SEM_MOVIMENTO_0
			
P_MJ1_CANTO_4:		sub a1, a1, a6			# vai pro canto inferior esquerdo
			addi a1, a1, 1			# compensa por comecarmos no ultimo pixel
			mv a0, a4
			jal P_MJ1_CHECAR_SE_TILE_EH_ANDAVEL
			beqz a0, P_MJ1_SEM_MOVIMENTO_0
			
P_MJ1_SEM_MOVIMENTO_0:	# carrega esses argumentos na stack para podermos os manipular com seguranca
			lw a1, (sp)
			lw a2, 4(sp)	
			addi sp, sp, 8
			
			# se a0 = 0, ha um tile nao andavel
			beqz a0, P_MJ1_SEM_MOVIMENTO
			
P_MJ1_MOVER_SEM_CHECAR_PAREDES:
P_MJ1_MOVER: 


######################################## MOVER ########################################

			
			
			# adicionar a direcao do jogador
			li t0, 6			# cada textura de jogador tem seis frames
			div t0, a3, t0			# entao cada frame vai estar nL/6 linhas de distancia
			# la t1, DIRECAO_JOGADOR		# pega o endereco da direcao do jogador
			# lb t1, (t1)			# carrega a direcao em t1
			
			# t1 = DIR: direcao
			# a3 = nL : n de linhas
			# a
			# mul t1, t1, a3			# multiplica
			
			# 0 = PARA BAIXO
			# 1 = PARA A DIREITA
			# 2 = PARA CIMA
			# 3 = PARA A ESQUERDA
			
			# t1 = pos X; t2 = pos Y
			mv t1, a1
			mv t2, a2
			
			# se o modo for POSICIONAR, nao salve a posicao do jogador
			li t0, MODO_POSICIONAR
			beq s0, t0, P_MJ1_SEM_MOVIMENTO
			
			la t0, POSICAO_JOGADOR
			sh t1, (t0)
			sh t2, 2(t0)
			
			li a0, 1
			
			# salva o valor de retorno (teve movimento)
			addi sp, sp, -4
			sw a0, (sp)
			j P_MJ1_IMPRIMIR
			
P_MJ1_SEM_MOVIMENTO:	addi sp, sp, -4
			li a0, 0
			sw a0, (sp)
			
			# para a impressao, pega o X e Y antigos... pois nao houve movimento.
			la t0, POSICAO_JOGADOR
			lh a1, 0(t0)
			lh a2, 2(t0)
			
P_MJ1_IMPRIMIR:		# para o procedimento PROC_IMPRIMIR_TEXTURA, sao argumentos:
			# 	a0 = aE0 = endereco da textura (.data)
			# 	a1 = aX  = pos X
			# 	a2 = aY  = pos Y
			# 	a3 = aL  = n de linhas da textura
			# 	a4 = aC  = n de colunas da textura
			#	a7 = M   = modo de impressao (0 = tela, 1 = buffer)
			mv a0, a3			# aE0 = T
			lw a4, (a3)			# salva em aC o numero de colunas
			lw a3, 4(a3)			# salva em aL o numero de linhas
			
			## eh importante lembrar que o jogador tem uma textura com SEIS aparencias diferentes, Portanto, temos que dividir a dimensao Y do jogador por 6.
			li t0, 6
			div a3, a3, t0
			
			# tambem temos que pular aC * aL * direcao para chegar no index correspondente ah textura correta!
			mul t0, a3, a4			# idx = aC * aL
			lb t1, DIRECAO_JOGADOR		# carrega a direcao do jogador
			mul t0, t0, t1			# idx = aC * aL * direcao do jogador
			add a0, t0, a0			# aE0 += idx
			
			mv a7, x0			# seleciona o modo como imprimir na tela
			addi a0, a0, 8			# pula os 8 bits
			# argumentos a1 e a2 jah estao posicionados :)
			jal PROC_IMPRIMIR_TEXTURA		# imprime o jogador
			
P_MJ1_FIM:		lw a0, (sp)			# carrega o valor de retorno (0 se sem movimento, 1 se com movimento)
			lw ra, 4(sp)			# carrega o endereco de retorno previo
			lw s0, 8(sp)			# carrega s0 original
			addi sp, sp, 12		
			ret
