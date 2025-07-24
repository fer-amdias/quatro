##############################################################
# PROC_IMPRIMIR FASE 				       	     #
# Imprime um mapa, dado um endereco do mapa e da textura do  #
# mapa. Tambem salva a posicao dele e cria um tilemap        #
# modificavel na memoria.             			     #
# 							     #
# ARGUMENTOS:						     #
#	A0 : ENDERECO DO MAPA A SER IMPRESSO                 #
# 	A1 : ENDERECO DA TEXTURA DO MAPA                     #
#	A2 : LIMITE DE SEGUNDOS DA FASE			     #
#							     #
# RETORNOS:                                                  #
#       A0 : QUANTIDADE DE INIMIGOS REGISTRADOS              #
##############################################################

# prefixo interno: P_IF1_
.text



# posicoes de centro de tela
.eqv CENTRO_VGA_X 160
.eqv CENTRO_VGA_Y 120


# a0 = endereco do mapa
# a1 = endereco da textura


# s0  = Em  = endereco do mapa
# s1  = L   = n de linhas no mapa
# s2  = C   = n de colunas no mapa
# s3  = CC  = contador de colunas
# s4  = CL  = contador de linhas
# s5  = Et  = endereco da textura desse mapa

# s6  = X   = posicao X de impressao da proxima textura
# s7  = Y   = posicao Y de impressao da proxima textura

# s8  = A   = area do sprite

# s9  = Vi  = endereco do vetor de inimigos
# s10 = Vpi = endereco do vetor de posicao dos inimigos
# s11 = Vdi = endereco do vetor de direcao dos inimigos


P_IF1_SUBPROC_CRIAR_TILEMAP:
	# t2 = linhas * colunas (total de bytes)
	mul t2, s2, s1
	
	# t1 = Etm
	la t1, TILEMAP_BUFFER
	
	# t6 = Em = endereco inicial do mapa (sem contar words de linha e coluna)	
	mv t6, s0
	
	# adiciona linhas e colunas aos primeiros enderecos do mapa
	sw s1, (t1)
	sw s2, 4(t1)
	addi t1, t1, 8
	
	# os tres blocos especiais que estarao escondidos como paredes quebraveis
	li t3, 5
	# li t4, 6	 # colocado um pouco abaixo em t3
	li t5, 3
	# pega tudo que estah no arquivo de mapa e passa pro buffer
	
	lw t4, MODO_SAIDA_LIVRE		# ver se podemos deixar a saida descoberta
P_IF1_TILEMAP_LOOP:
	li t3, 5			# como usamos ele de novo mais em baixo, temos que recarregalo aqui no loop
    	lb t0, 0(t6)
    	
    	# se for um bloco especial, mascara no tilemap como parede quebravel
    	beq t0, t3, P_IF1_TILEMAP_LOOP_COLOCAR_PAREDE #marrapaz que nome grande
    	
    	li t3, 6
    	beq t0, t3, P_IF1_TILEMAP_LOOP_COLOCAR_PAREDE
    	
	bnez t4, P_IF1_TILEMAP_LOOP_SAIDALIVRE		
    	beq t0, t5, P_IF1_TILEMAP_LOOP_COLOCAR_PAREDE # cobre a saida se o modo saida livre estiver desligado
   
P_IF1_TILEMAP_LOOP_SAIDALIVRE: 	
    	# se for um inimigo, bota um tile andavel no lugar
    	li t3, 10
    	bge t0, t3, P_IF1_TILEMAP_LOOP_IGNORAR_INIMIGO
    	j P_IF1_TILEMAP_LOOP_CONT
    	
P_IF1_TILEMAP_LOOP_IGNORAR_INIMIGO:
	li t0, 0
	j P_IF1_TILEMAP_LOOP_CONT
    
# mascara como 4 (parede quebravel)
P_IF1_TILEMAP_LOOP_COLOCAR_PAREDE:
	li t0, 4
    	
P_IF1_TILEMAP_LOOP_CONT:    	
   	sb t0, 0(t1)
   	addi t6, t6, 1
    	addi t1, t1, 1
    	addi t2, t2, -1
    	bnez t2, P_IF1_TILEMAP_LOOP
    
P_IF1_TILEMAP_FIM:
	ret




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

				slli t0, a2, 10
				sw t0, SEGUNDOS_RESTANTE_Q10, t1

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
				
				jal P_IF1_SUBPROC_CRIAR_TILEMAP
				
				sw zero, INIMIGOS_QUANTIDADE, t0
				sb zero, CONTADOR_INIMIGOS, t0
				
				
				
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
				sh s6, (t0)			# salva a posicao X do canto superior esquerdo do mapa
				sh s7, 2(t0)			# salva a posicao Y do canto superior esquero do mapa
				
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
				
				# se o numero for 3 (fim da fase), 5 (power up 1) ou 6 (power up 2), temos que esconder o bloco atras de um bloco quebravel
				li t1, 6
				beq t0, t1, P_IF1_ESCONDER_TILE
				li t1, 5
				beq t0, t1, P_IF1_ESCONDER_TILE
				
				lw t1, MODO_SAIDA_LIVRE	
				bnez t1, P_IF1_LOOP_CONT # nao esconde a saida se o modo eh saida livre
				
				li t1, 3
				beq t0, t1, P_IF1_ESCONDER_TILE
				
				j P_IF1_LOOP_CONT
				
				
# QUANDO ENCONTRAR-MOS UM TILE QUE FICA ESCONDIDO DETRAS DE UM BLOCO QUEBRAVEL... imprimimos um bloco quebravel
P_IF1_ESCONDER_TILE:		li t0, 4
				mul t6, t0, s8			# t6 = I_bloco_quebravel * AREA_SPRITE

				# e soh
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
				sb t2, (t1)			# atualiza o contador de inimigos
				
				la t1, INIMIGOS_QUANTIDADE
				sw t2, (t1)			# atualiza a quantidade de inimigos
				
				li t6, 0			# seta tI*400 para 0
								# isso vai fazer com que uma casa em branco seja colocada no tile sob os pes do inimigo
								
				j P_IF1_LOOP_CONT		# continua o loop
				
				
				
# SE ENCONTRARMOS UM TILE DE COMECO DE FASE:
P_IF1_REGISTRAR_JOGADOR:	la t1, POSICAO_JOGADOR
				addi t0, s6, 4
				sh t0, 0(t1)			# salva posicao X do tile nas coordenadas do jogador
				
				addi t0, s7, 4
				sh t0, 2(t1)			# salva posicao Y do tile nas coordenadas do jogor
				
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
				
				# adiciona uma vida
				la t0, VIDAS_RESTANTES
				lb t1, (t0)
				li t2, MAX_VIDAS
				bge t1, t2, P_IF1_MAX_VIDAS	# se vidas >= MAX_VIDAS, nao incrementa (eh o maximo
				addi t1, t1, 1
				sb t1, (t0)
P_IF1_MAX_VIDAS:

				ret
					
		
				





