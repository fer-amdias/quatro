##############################################################
# PROC_IMPRIMIR FASE 				       	     #
# Imprime um mapa, dado um endereco do mapa e da textura do  #
# mapa. Tambem salva a posicao dele na memoria.              #
# 							     #
# ARGUMENTOS:						     #
#	A0 : ENDERECO DO MAPA A SER IMPRESSO                 #
# 	A1 : ENDERECO DA TEXTURA DO MAPA                     #
# RETORNOS:                                                  #
#       (nenhum)                                             #
##############################################################

# prefixo interno: P_IF1_


.data
.include "..\example.data"
.include "..\Texturas\placeholder.data"


.text



# posicoes de centro de tela
.eqv CENTRO_VGA_X 160
.eqv CENTRO_VGA_Y 120

# tamanho de uma textura de mapa
.eqv TAMANHO_SPRITE 20
.eqv AREA_SPRITE 400


# a0 = endereco do mapa
# a1 = endereco da textura


# s0 = Em = endereço do mapa
# s1 = L  = n de linhas no mapa
# s2 = C  = n de colunas no mapa
# s3 = CC = contador de colunas
# s4 = CL = contador de linhas
# s5 = Et = endereço da textura desse mapa

# s6 = X  = posicao X de impressao da proxima textura
# s7 = Y  = posicao Y de impressao da proxima textura

# s8 = A  = area do sprite


# como estamos usando os registradores salvos... precisamos garantir que tudo esteja como estava quando retornarmos a funcao.

PROC_IMPRIMIR_FASE:		# guarda os registradores na stack
				addi sp, sp, -36
				sw   s0, 0(sp)
				sw   s1, 4(sp)
				sw   s2, 8(sp)
				sw   s3, 12(sp)
				sw   s4, 16(sp)
				sw   s5, 20(sp)
				sw   s6, 24(sp)
				sw   s7, 28(sp)
				sw   s8, 32(sp)


				mv s0, a0 			# carrega o endereço da fase de a0 para s0 (Em)
				lw s1, (s0)			# carrega o n de linhas em s1 (L)
				lw s2, 4(s0)			# carrega o n de colunas em s2 (C)
				addi s0, s0, 8			# pula os words de linha e coluna para os bytes de informacao
				
				# devemos agora calcular a posicao X e Y que o mapa deve estar
				# primeiramente, devemos multiplicar L e C pelo tamanho do sprite para ter
				li t0, TAMANHO_SPRITE
				mul s1, s1, t0			# L *= TAMANHO_SPRITE
				mul s2, s2, t0			# C *= TAMANHO_SPRITE
				
				# agora devemos propriamente centralizar a imagem
				# a impressao começara do canto superior esquerdo
				# entao temos que calcular onde ele vai estar
				# na verdade eh bem simples
				# a distancia do canto superor esquerdo pro centro eh L/2 e C/2
				# entao botamos X = CENTRO_VGA_X - C/2
				# igualmente, 	Y = CENTRO_VGA_Y - L/2
				
				srli s6, s2, 1     		# X = C/2
				neg s6, s6			# X = -C/2
				addi s6, s6, CENTRO_VGA_X       # X = CENTRO_VGA_X - C/2  	   
			
				srli s7, s1, 1     		# Y = L/2
				neg s7, s7			# Y = -L/2
				addi s7, s7, CENTRO_VGA_Y       # Y = CENTRO_VGA_Y - L/2
				
				mv s3, zero			# CC = 0
				mv s4, zero  	   		# CL = 0
				mv s5, a1	 		# carrega o endereco da textura
				addi s5, s5, 8			# pula pros bytes de informacao

# t0 = tI = informacao do tile

				li s8, AREA_SPRITE		# A = AREA_SPRITE
P_IF1_LOOP_1:			lbu t0, (s0)			# tI = informacao em Em
				mul t0, t0, s8			# t0 = tI * 400
				
				# para o procedimento PROC_IMPRIMIR_TEXTURA, sao argumentos:
				# a0 = aE0 = endereco da textura (.data)
				# a1 = aX  = pos X
				# a2 = aY  = pos Y
				# a3 = aL  = n de linhas da textura
				# a4 = aC  = n de colunas da textura
				
				
				add a0, s5, t0			# aE0 = eT + (tI * 400) = pula pra textura associada com o tile
				mv a1, s6			# aX = X
				mv a2, s7			# aY = Y
				li a3, TAMANHO_SPRITE		# aL = L
				li a4, TAMANHO_SPRITE		# aC = C
				
				jal PROC_IMPRIMIR_TEXTURA	# chamada o procedimento de impressao de textura
				
				# fim do procedimento
				
				addi s0, s0, 1			# Em++
				addi s3, s3, TAMANHO_SPRITE	# CC += TAMANHO_SPRITE
				addi s6, s6, TAMANHO_SPRITE     # X += TAMANHO_SPRITE
				
				# SE C = CC: PROXIMA LINHA
				beq s2, s3, P_IF1_PROXIMA_LINHA
				
				# SENAO, REPETE O LOOP
				j P_IF1_LOOP_1
				
P_IF1_PROXIMA_LINHA:		sub s6, s6, s2			# X -= C, voltando ele pra posicao inicial
				addi s7, s7, TAMANHO_SPRITE	# Y += TAMANHO_SPRITE
				addi s4, s4, TAMANHO_SPRITE	# CL += TAMANHO_SPRITE
				mv s3, zero			# CC = 0
				
				# SE L = CL: FINALIZA A IMPRESSAO
				beq s1, s4, P_IF1_FIM
				j P_IF1_LOOP_1

P_IF1_FIM:			# traz os registradores salvos de volta da stack
				lw   s0, 0(sp)
				lw   s1, 4(sp)
				lw   s2, 8(sp)
				lw   s3, 12(sp)
				lw   s4, 16(sp)
				lw   s5, 20(sp)
				lw   s6, 24(sp)
				lw   s7, 28(sp)
				lw   s8, 32(sp)
				addi sp, sp, 36



				ret
					
##############################################################
# Include de prodcedimentos feito no final do codigo, sempre #
# Colocar no topo vai fazer os procedimentos serem chamados  #
# ANTES do nosso codigo que queremos executar                #
##############################################################

.include ".\imprimir_textura.asm"
				
				





