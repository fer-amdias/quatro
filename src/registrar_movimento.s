#################################################################
# PROC_REGISTRAR_MOVIMENTO				       	#
# Registra input do teclado e move na direcao escolhida		#
# Basicamente um wrapper para PROC_MOVER_JOGADOR		#
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : MODO (0, 1, 2 OU 3)                        	#
#	A1 : ENDERECO DE TEXTURA DO JOGADOR			#
#	A2 : ENDERECO DO MAPA					#
# RETORNOS:                                                  	#
#       A0 : SE O JOGADOR ESTAH VIVO (0 OU 1)                  	#
#################################################################

.text

PROC_REGISTRAR_MOVIMENTO:
			addi sp, sp, -4			# abre espaco na stack
			sw ra, (sp)			# salva o registrador de retorno anterior
		
			li t1,0xFF200000		# carrega o endere�o de controle do KDMMIO
			lw t0,0(t1)			# Le bit de Controle Teclado
			andi t0,t0,0x0001		# mascara o bit menos significativo
		   	beq t0,zero,P_RM1_SEM_MOVIMENTO_1 # Se n�o h� tecla pressionada ent�o vai para FIM
		  	lw t2,4(t1)  			# le o valor da tecla 
			
			li t0, 97
			blt t2, t0, P_RM1_SEM_MOVIMENTO_1
			
# Do procedimento PROC_MOVER_JOGADOR		
# argumentos:
#	a0: M: modo (0, 1, 2, 3)
#	a1: X: pos X
#	a2: Y: pos Y
#	a3: T: endereco da textura do jogador
#	a4: E: endereco do mapa 
# retorno:
#	a0: V: se o jogador estah vivo (1 ou 0)
			mv a4, a2
			mv a3, a1
			
			la t0, POSICAO_JOGADOR
			lhu a1, (t0)		# pos X do jogador
			lhu a2, 2(t0) 		# pos y do jogador
			
			# 0 = PARA BAIXO
			# 1 = PARA A DIREITA
			# 2 = PARA CIMA
			# 3 = PARA A ESQUERDA
			la t1, DIRECAO_JOGADOR
			
			li t0, 'w'
			beq t2, t0, P_RM1_W
			li t0, 'a'
			beq t2, t0, P_RM1_A
			li t0, 's'
			beq t2, t0, P_RM1_S
			li t0, 'd'
			beq t2, t0, P_RM1_D
			li t0, 8	# backspace
			beq t2, t0, P_RM1_BACKSPACE
			
			j P_RM1_SEM_MOVIMENTO_2
			
P_RM1_W:		addi a2, a2, -1		# move para cima
			li t2, 2
			sb t2, (t1)		# coloca a direcao como para cima (2)
			j P_RM1_MOVER
			
P_RM1_A:		addi a1, a1, -1		# move para esquerda
			li t2, 3
			sb t2, (t1)		# coloca a direcao como para a esquerda (3)
			j P_RM1_MOVER
			
P_RM1_S:		addi a2, a2, 1		# move para baixo
			sb x0, (t1)		# coloca a direcao como para baixo (0) 
			j P_RM1_MOVER
			
P_RM1_D:		addi a1, a1, 1		# move para a direita
			li t2, 1
			sb t2, (t1)		# coloca a direcao como para a direita (1)
			j P_RM1_MOVER
P_RM1_BACKSPACE:	fim

P_RM1_SEM_MOVIMENTO_1:  mv a5, a3
			mv a4, a2
			mv a3, a1
			la t0, POSICAO_JOGADOR
			lhu a1, (t0)		# pos X do jogador
			lhu a2, 2(t0) 		# pos y do jogador
			
P_RM1_SEM_MOVIMENTO_2:	li a0, 3
			
P_RM1_MOVER:		call PROC_MOVER_JOGADOR		# finaliza o movimento	
	
P_RM1_FIM:		lw ra, (sp)
			addi sp, sp, 4			# recupera o registrador de retorno anterior
			ret

	
	
	
