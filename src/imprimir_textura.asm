##############################################################
# PROC_IMPRIMIR_TEXTURA				             #
# Imprime uma textura de tamanho variavel em uma coordenada  #
# X Y.							     #
# 							     #
# ARGUMENTOS:						     #
#	A0 : ENDERECO DA TEXTURA A SER IMPRESSA              #
# 	A1 : POSICAO X                                       #
#       A2 : POSICAO Y                                       #
#       A3 : NUMERO DE LINHAS DA TEXTURA (ALTURA)            #
#       A4 : NUMERO DE COLUNAS DA TEXTURA (LARGURA)          #
#	A7 : MODO DE IMPRESSAO (0: TELA, 1: BUFFER)
# RETORNOS:                                                  #
#       (nenhum)                                             #
##############################################################



.text

.eqv COR_TRANSPARENTE 0xC0  # magenta (192)

# prefixo interno: P_IT1_

# a0 = E0 = endereco da textura (.data)
# a1 = pos X
# a2 = pos Y
# a3 = L = n de linhas da textura
# a4 = C = n de colunas da textura
# a5 = MODO = modo de impressao (0: tela, 1: buffer)


PROC_IMPRIMIR_TEXTURA: 	li t0, 1
			beq a7, t0, P_IT1_MODO_1		# se o modo for 1, carrega o buffer

			la t3, FRAME_DE_IMPRESSAO	# senao, carrega o frame de impressao
			lw t3, (t3)			# endereco do frame
			j P_IT1_CONT			# pula o codigo de modo 1
			
P_IT1_MODO_1:		la t3, FASE_BUFFER

P_IT1_CONT:		

			li t0, 320			# t0 = LVGA (largura VGA) // largura do buffer
			mul t0, a2, t0			# t0 = pL = Y * LVGA
			add t0, t0, a1			# t0 = pL + X
			add t3, t3, t0			# VGA/BUFFER += pL + X, indo pra posicao em que queremos imprimir
			
# t3 = P  = endereco do pixel vga atual
# a0 = E  = endereco do pixel textura atual
# t0 = I  = informacao do pixel de textura atual
# t4 = CL = contador de linhas
# t5 = CC = contador de colunas

# t6 = registrador verdadeiramente temporario
			
			mv t4, zero			# CL = 0
			mv t5, zero			# CC = 0
			j P_IT1_LOOP			# vai pro loop
			
P_IT1_PROXIMA_LINHA:    addi t4, t4, 1 			# CL++
			mv t5, zero			# CC = 0
			addi t6, a4, -320 		# t6 = -320+C -- lembre-se que a tela eh 240 por 320!
			neg t6, t6			# t6 = 320-C
			add t3, t3, t6			# E += 320-C (t6)
				
			# SE CL == L: SAI DO LOOP
			# podemos jogar isso aqui pois soh aqui CL eh incrementado
			beq t4, a3, P_IT1_FIM
			
			
P_IT1_LOOP:		lbu t0, (a0)			# coloca a informacao do pixel em I (I = informacao em P)
			li t6, COR_TRANSPARENTE		# t6 = COR_TRANSPARENTE
			
			beq t0, t6, P_IT1_PULA_PIXEL	# SE ( I == COR_TRANSPARENTE ), ENTAO PULA O PIXEL
							# SENAO:
			sb t0,	(t3)			# 	imprime o pixel
P_IT1_PULA_PIXEL:	addi a0, a0, 1			# E++
			addi t3, t3, 1			# P++ 
			addi t5, t5, 1			# CC++ 
			
			# SE C == CC, VAI PARA A PROXIMA LINHA
			beq a4, t5, P_IT1_PROXIMA_LINHA
				
			j P_IT1_LOOP			# continua o loop		
						
							
								
									
P_IT1_FIM:					
			ret	
