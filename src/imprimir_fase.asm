##############################################################
# PROC_IMPRIMIR FASE 				       	     #
# Imprime um mapa, dado um endereco do mapa e da textura do  #
# mapa. Tambem salva a posicao dele na memoria.              #
# 							     #
# ARGUMENTOS:						     #
#	A0 : ENDERECO DO MAPA A SER IMPRESSO                 #
# 	A1 : ENDERECO DA TEXTURA DO MAPA                     #
#							     #
# RETORNOS:                                                  #
#       A0 : QUANTIDADE DE INIMIGOS REGISTRADOS              #
##############################################################

# prefixo interno: P_IF1_


.data
CONTADOR_INIMIGOS: .byte 0

.text



# posicoes de centro de tela
.eqv CENTRO_VGA_X 160
.eqv CENTRO_VGA_Y 120

# tamanho de uma textura de mapa
.eqv TAMANHO_SPRITE 20
.eqv AREA_SPRITE 400


# a0 = endereco do mapa
# a1 = endereco da textura


# s0  = Em  = endere�o do mapa
# s1  = L   = n de linhas no mapa
# s2  = C   = n de colunas no mapa
# s3  = CC  = contador de colunas
# s4  = CL  = contador de linhas
# s5  = Et  = endere�o da textura desse mapa

# s6  = X   = posicao X de impressao da proxima textura
# s7  = Y   = posicao Y de impressao da proxima textura

# s8  = A   = area do sprite

# s9  = Vi  = endereco do vetor de inimigos
# s10 = Vpi = endereco do vetor de posicao dos inimigos
# s11 = Vdi = endereco do vetor de direcao dos inimigos


# como estamos usando os registradores salvos... precisamos garantir que tudo esteja como estava quando retornarmos o procedimento. 
# Como essa nao eh uma *leaf procedure*, ou seja, chamamos outros procedimentos dentro dele, temos que salvar ra tambem

PROC_IMPRIMIR_FASE:		# guarda os registradores na stack
				addi sp, sp, -52
				sw   s0, 0(sp)
				sw   s1, 4(sp)
				sw   s2, 8(sp)
				sw   s3, 12(sp)
				sw   s4, 16(sp)
				sw   s5, 20(sp)
				sw   s6, 24(sp)
				sw   s7, 28(sp)
				sw   s8, 32(sp)
				sw   s9, 36(sp)
				sw   s10, 40(sp)
				sw   s11, 44(sp)
				sw   ra,  48(sp)

				# salva os argumentos de funcao
				mv s0, a0			# endereco do mapa    				(Em)
				mv s5, a1	 		# endereco da textura 				(Et)
				addi s5, s5, 8			# pula pros bytes de informacao da textura
				
				# salva o endereco dos vetores 
				la s9, INIMIGOS			# Vi  : Vetor de inimigos
				la s10, INIMIGOS_POSICAO	# Vpi : Vetor posicao de inimigos
				la s11, INIMIGOS_DIRECAO	# Vdi : Vetor direcao de inimigos
				
				lw s1, (s0)			# carrega o n de linhas em s1 (L)
				lw s2, 4(s0)			# carrega o n de colunas em s2 (C)
				addi s0, s0, 8			# pula os words de linha e coluna para os bytes de informacao
				
				# devemos agora calcular a posicao X e Y que o mapa deve estar
				# primeiramente, devemos multiplicar L e C pelo tamanho do sprite para ter
				li t0, TAMANHO_SPRITE
				mul s1, s1, t0			# L *= TAMANHO_SPRITE
				mul s2, s2, t0			# C *= TAMANHO_SPRITE
				
				# agora temos o tamanho do mapa em pixels, e devemos salva-lo na memoria para utilizacao do buffer
				
				la t0, FASE_BUFFER_COL		# n de colunas da fase no buffer
				sh s2, (t0)
				
				la t0, FASE_BUFFER_LIN		# n de linhas da fase no buffer
				sh s1, (t0)		
				
				# agora devemos propriamente centralizar a imagem
				# a impressao come�ara do canto superior esquerdo
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
				
				la t0, POSICOES_MAPA		# carrega o endereco de posicao do mapa
				sb s6, (t0)			# salva a posicao X do canto superior esquerdo do mapa
				sb s7, 1(t0)			# salva a posicao Y do canto superior esquero do mapa
				
				mv s3, zero			# CC = 0
				mv s4, zero  	   		# CL = 0
				

# t0 = tI = informacao do tile
# t6 = tI * AREA_SPRITE
				
				li s8, AREA_SPRITE		# A = AREA_SPRITE
P_IF1_LOOP_1:			lbu t0, (s0)			# tI = informacao em Em
				mul t6, t0, s8			# t6 = tI * AREA_SPRITE
				
				# se o numero do tile for 10 ou mais, temos que registrar o inimigo no vetor necessario
				li t1, 10
				bge t0, t1, P_IF1_REGISTRAR_INIMIGO
				
				# se o numero do tile for 2, essa eh a posicao de comeco do jogo! temos que posicionar o jogador
				li t1, 2
				beq t0, t1, P_IF1_REGISTRAR_JOGADOR
				j P_IF1_LOOP_CONT

# QUANDO ENCONTRARMOS UM TILE DE INIMIGO:		
P_IF1_REGISTRAR_INIMIGO:	# ficamos sem registradores para contar o n de inimigos
				# entao guardamos na memoria
				
				
				# t1 = endereco do contador
				# t2 = contador de inimigos
				la t1, CONTADOR_INIMIGOS
				lbu t2, (t1)
				
				sb t0, (s9)			# salva o inimigo no vetor de inimigos (Vi)
				sh s6, (s10)			# salva a posicao X do inimigo no vetor de posicao (Vpi)
				sh s7, 2(s10)			# salva a posicao Y do inimigo no vetor de posicao (Vpi)
				
				li t3, 0
				sb t3, (s11)			# zera a direcao em Vdi, para ser calculada quando eles forem posicionados
				
				addi s9, s9, 1			# avanca pro proximo byte no endereco do vetor
				addi s10, s10, 4		# avanca uma word (duas half-words) no endereco do vetor de posicao
				addi s11, s11, 1		# avanca um byte no endereco do vetor de direcao
				addi t2, t2, 1			# adiciona um no contador de inimigos
				
				# terminamos!
				sb t2, (t1)			# bota o valor de volta no endereco
				
				li t6, 0			# seta tI*400 para 0
								# isso vai fazer com que uma casa em branco seja colocada no tile sob os pes do inimigo
								
				j P_IF1_LOOP_CONT		# continua o loop
				
				
				
# SE ENCONTRARMOS UM TILE DE COMECO DE FASE:
P_IF1_REGISTRAR_JOGADOR:	la t1, POSICAO_JOGADOR
				sh s6, 0(t1)			# salva posicao X do tile nas coordenadas do jogador
				sh s7, 2(t1)			# salva posicao Y do tile nas coordenadas do jogor
				
				# era so isso mesmo
				
				
P_IF1_LOOP_CONT:		# para o procedimento PROC_IMPRIMIR_TEXTURA, sao argumentos:
				# 	a0 = aE0 = endereco da textura (.data)
				# 	a1 = aX  = pos X
				# 	a2 = aY  = pos Y
				# 	a3 = aL  = n de linhas da textura
				# 	a4 = aC  = n de colunas da textura

				add a0, s5, t6			# aE0 = eT + (tI * 400) = pula pra textura associada com o tile
				mv a1, s6			# aX = X
				mv a2, s7			# aY = Y
				li a3, TAMANHO_SPRITE		# aL = L
				li a4, TAMANHO_SPRITE		# aC = C
				li a7, 1			# printa no BUFFER
				
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
				# sim, eu sei, eu nao devia ter usado registradores salvo, eu devia ter usado os temporarios, etc
				# sim, dava pra otimizar esse uso horrivel de registradores, mas, tipo, n
				# n vou
				lw   s0, 0(sp)
				lw   s1, 4(sp)
				lw   s2, 8(sp)
				lw   s3, 12(sp)
				lw   s4, 16(sp)
				lw   s5, 20(sp)
				lw   s6, 24(sp)
				lw   s7, 28(sp)
				lw   s8, 32(sp)
				lw   s9, 36(sp)
				lw   s10, 40(sp)
				lw   s11, 44(sp)
				lw   ra,  48(sp)
				addi sp, sp, 52
				
				la t0, CONTADOR_INIMIGOS
				lb a0, (t0)			# salva o valor de retorno (quantidade de inimigos contados)
				sb zero, (t0)			# zera o contador pra uso futuro


				ret
					
		
				





