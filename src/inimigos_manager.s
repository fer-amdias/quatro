#################################################################
# PROC_INIMIGOS_MANAGER				       	     	#
# Administra inimigos, seus movimentos, colisoes, e mortes      #
# 							     	#
# ARGUMENTOS:						     	#
# 	A0 = endereco do stripe de textura dos inimigos		#
#								#
# RETORNOS:                                                  	#
#      (nenhum)							#
#################################################################

# PREFIXO INTERNO: P_IM1_

# INIMIGOS_QUANTIDADE: 	.word 0		# quantidade de inimigos no mundo
# INIMIGOS:         	.byte 0 	# alihamento do vetor
# 	          	.space 31 	# cada inimigo vai ser salvo em um byte, dando um total de 32 inimigos nesse vetor
# INIMIGOS_POSICAO: 	.half 0 	# alinhamento do vetor
# 	          	.space 127	# cada inimigo vai ter uma posicao de half-word (x) e half-word (y).
# INIMIGOS_DIRECAO: 	.byte 0 	# alinhamento do vetor
# 		  	.space 31	# cada inimigo vai ter uma direcao salvo em um byte.	

# argumentos: 
#	a0 = direcao
#	a1 = pos X do inimigo
#	a2 = pos Y do inimigo
# retornos: 
#	a0 = 1 ou 0

.data
INIMIGOS_COOLDOWN_TIMESTAMP: .word 0

.text
P_IM1_SUBPROC_EH_ANDAVEL:
			# s0 = pos X2
			# s1 = pos Y2
			# (as posicoes que vao ser utilizadas na segunda checagem)
			# (temos que checar 2x o mesmo tile pra saber se o inimigo cabe)
			addi sp, sp, -12
			sw s0, (sp)
			sw s1, 4(sp)
			sw ra, 8(sp)
			
			### oia o switch de direcoes
			
			beq a0, zero, P_IM1_D0
			li t0, 1
			beq a0, t0, P_IM1_D1
			li t0, 2
			beq a0, t0, P_IM1_D2
			li t0, 3
			beq a0, t0, P_IM1_D3
			j P_IM1_NAO_EH_ANDAVEL
			
			#### D0 ####
P_IM1_D0:
			# temos que checar os tiles ao sul
			add a2, a2, s4			# checa o tile diretamente embaixo do inimigo (s4 = TAMANHO_SPRITE)
			
			mv s1, a2			# guarda a mesma pos Y pra segunda checagem
			mv s0, a1			# guarda pos X
			
			# na segunda checagem, vai pro canto superior direito do proximo tile (y += TAMANHO_SPRITE; x += TAMANHO_SPRITE - 1)
			add s0, s0, s4
			addi s0, s0, -1
			j P_IM1_SUPBROC_EH_ANDAVEL_CONT
			
			#### D1 ####
P_IM1_D1:		
			# temos que checar os tiles ao leste
			add a1, a1, s4			# checa o tile diretamente ah direita do inimigo (s4 = TAMANHO_SPRITE)
			
			mv s0, a1			# guarda a mesma pos X pra segunda checagem
			mv s1, a2			# guarda pos Y
			
			# na segunda checagem, vai pro canto inferior esquerdo do proximo tile (y += TAMANHO_SPRITE - 1; x += TAMANHO_SPRITE)
			add s1, s1, s4
			addi s1, s1, -1
			j P_IM1_SUPBROC_EH_ANDAVEL_CONT

			#### D2 ####
P_IM1_D2:
			# temos que checar os tiles ao norte
			addi a2, a2, -1			# checa o tile diretamente em cima
			
			mv s1, a2			# guarda a mesma pos Y pra segunda checagem
			mv s0, a1			# guarda pos X
			
			# na segunda checagem, vai pro canto inferior direito do proximo tile (y += 1; x += TAMANHO_SPRITE - 1)
			add s0, s0, s4
			addi s0, s0, -1
			j P_IM1_SUPBROC_EH_ANDAVEL_CONT

			#### D3 ####
P_IM1_D3:
			# temos que checar os tiles ao oeste
			addi a1, a1, -1			# checa o tile diretamente ah esquerda do inimigo 
			
			mv s0, a1			# guarda a mesma pos X pra segunda checagem
			mv s1, a2			# guarda pos Y
			
			# na segunda checagem, vai pro canto inferior esquerdo do proximo tile (y += TAMANHO_SPRITE - 1; x += 1)
			add s1, s1, s4
			addi s1, s1, -1
			j P_IM1_SUPBROC_EH_ANDAVEL_CONT
			
P_IM1_SUPBROC_EH_ANDAVEL_CONT:

			# PROC_CALCULAR_TILE_ATUAL			             
			# Calcula o tile atual de uma coordenada X e Y e retorna a   
			# informacao, linha, coluna, x e y.			     
			# 							     
			# ARGUMENTOS:						     
			#	A0 : ENDERECO DO MAPA (.data)			     
			# 	A1 : POSICAO X                                       
			#       A2 : POSICAO Y                                       
			# RETORNOS:                                                  
			#       A0 : INFORMACAO DO TILE ATUAL (0-255)	
			
			la a0, TILEMAP_BUFFER
# 			a1 jah posicionado
# 			a2 jah posicionado
			jal PROC_CALCULAR_TILE_ATUAL
			
			
			li t0, 4
			beq a0, t0, P_IM1_NAO_EH_ANDAVEL		# se for parede quebravel, N EH ANDAVEL
			li t0, 1
			beq a0, t0, P_IM1_NAO_EH_ANDAVEL		# se for parede normal. N EH ANDAVEL
			li t0, 100
			bge a0, t0, P_IM1_INIMIGO_NAO_SABE_QUE_ESTAH_EXPLODINDO	# se tiver uma explosao. finge ignorancia :) -- o inimigo tem que conseguir entrar na explosao e morrer.
			li t0, 50
			bge a0, t0, P_IM1_NAO_EH_ANDAVEL		# se tiver uma bomba. N EH ANDAVEL
P_IM1_INIMIGO_NAO_SABE_QUE_ESTAH_EXPLODINDO:			
			
			#### segunda checagem
			la a0, TILEMAP_BUFFER
			mv a1, s0
			mv a2, s1
			jal PROC_CALCULAR_TILE_ATUAL
			
			li t0, 4
			beq a0, t0, P_IM1_NAO_EH_ANDAVEL		# se for parede quebravel, N EH ANDAVEL
			li t0, 1
			beq a0, t0, P_IM1_NAO_EH_ANDAVEL		# se for parede normal. N EH ANDAVEL
			
			# se chegamos ateh aqui, entao o tile eh andavel
			
P_IM1_EH_ANDAVEL:	li a0, 1
			j P_IM1_SUBPROC_EH_ANDAVEL_FIM
			
P_IM1_NAO_EH_ANDAVEL:	li a0, 0

P_IM1_SUBPROC_EH_ANDAVEL_FIM:
			mv t0, a0
			mv a0, t0
		
			lw s0, (sp)
			lw s1, 4(sp)
			lw ra, 8(sp)
			addi sp, sp, 12
			
			ret
##########################################################################



PROC_INIMIGOS_MANAGER:

			addi sp, sp, -48
			sw s0, (sp)
			sw s1, 4(sp)
			sw s2, 8(sp)
			sw s3, 12(sp)
			sw s4, 16(sp)
			sw s5, 20(sp)
			sw s6, 24(sp)
			sw s7, 28(sp)
			sw s8, 32(sp)
			sw ra, 36(sp)
			sw s9, 40(sp)
			sw s10, 44(sp)
			
			# s0 = vetor INIMIGOS
			# s1 = vetor INIMIGOS_POSICAO
			# s2 = vetor INIMIGOS_DIRECAO
			# s3 = int   INIMIGOS_QUANTIDADE
			# s4 = const TAMANHO_SPRITE -- dimensoes de um inimigo (sim, ele ocupa um tile todo)
			# s5 = endereco do strip de textura
			
			la s0, INIMIGOS
			la s1, INIMIGOS_POSICAO
			la s2, INIMIGOS_DIRECAO
			la s3, INIMIGOS_QUANTIDADE
			li s4, TAMANHO_SPRITE
			mv s5, a0
		
			addi s5, s5, 8			# pula as words de dimensoes da strip de inimigo
			
			
			
			# LOOP
			# s6 = i
			# loop vai ateh o valor em s3
			
			# ou seja, faca para cada inimigo o que estah no loop
			
			mv s6, zero
			lw s3, (s3)			# carrega a quantidade de inimigos em s3
			
			### AGORA TEMOS QUE CHECAR SE PODEMOS MOVER OS INIMIGOS
			# s10 = fora do cooldown (1 ou 0)
			
			la t0, INIMIGOS_COOLDOWN_TIMESTAMP		
			lw t1, (t0)				# pega o cooldown dessa proc
			
			csrr t2, time				# le o tempo
			bge t2, t1, P_IM1_PROSSEGUIR		# se for maior que o cooldown, podemos prosseguir com a funcao
			
			li s10, 0				# senao, marca como estando no cooldown
			j P_IM1_LOOP_1
			
P_IM1_PROSSEGUIR:	lbu t2, JOGO_PAUSADO
			beqz t2, P_IM1_PROSSEGUIR2		# se nao estiver pausado, prossiga
			
			# caso contrario, marca como 'estando no cooldown'
			li s10, 0
			j P_IM1_LOOP_1

P_IM1_PROSSEGUIR2:	csrr t2, time
			addi t1, t2, 30				# adiciona 30 milisegundos no cooldown -- 33 ciclos por segundo -- >2 tiles por segundo (considerando tamanho_tile = 20
			sw t1, (t0)				# guarda a nova timestamp
			
			la t0, SEGUNDOS_RESTANTE_Q10		# atualiza os segundos restantes na fase (sim, ESSE PROCEDIMENTO UTILIZA 
			lw t1, (t0)				# carrega os segundos atuais
			addi t1, t1, -30			# subtrai 30/1024 (eh necessario arredondar aqui pq estamos usando ponto fixo binario enquanto o registrador time usa decimal.
			sw t1, (t0)				# guarda o novo valor
			
			
			li s10, 1				# marca como fora do cooldown
	
			
P_IM1_LOOP_1:		
	
			# se estiver fora do cooldown, soh imprime o inimigo mesmo
			beqz s10, P_IM1_LOOP_1_PRINT

			### primeiro determina se ele tah vivo. senao, nem move ele
			add t1, s2, s6			# idx = i + INIMIGOS_DIRECAO   	(pula pra DIRECAO[i])
			lbu t1, (t1)			# carrega direcao do inimigo
			li t0, 4
			beq t1, t0, P_IM1_LOOP_1_PRINT	# se for 4, ele estah morto, ent n move ele lol

			# t1 = posicao[i]
			slli t0, s6, 2			# idx = 4 * i     		(queremos pular 1 word para cada i)
			add t1, s1, t0			# idx += INIMIGOS_POSICAO   	(pula pra POSICAO[i])
			
			#### agora vamos checar o tile no meio da hitbox. se o tile for 100, o inimigo acabou de esbarrar em uma explosao e deve morrer.
			
			# PROC_CALCULAR_TILE_ATUAL			             
			# Calcula o tile atual de uma coordenada X e Y e retorna a   
			# informacao, linha, coluna, x e y.			     
			# 							     
			# ARGUMENTOS:						     
			#	A0 : ENDERECO DO MAPA (.data)			     
			# 	A1 : POSICAO X                                       
			#       A2 : POSICAO Y                                       
			# RETORNOS:                                                  
			#       A0 : INFORMACAO DO TILE ATUAL (0-255)		     
			
			la a0, TILEMAP_BUFFER
			lh a1, (t1)			# carrega pos X do inimigo como argumento
			lh a2, 2(t1)			# carrega pos Y do inimigo como argumento
			
			# temos que mover a checagem para o meio do inimigo
			# calculemos um fator corretor
			srli t0, s4, 1			# divide o TAMANHO_SPRITE por 2
			
			# adiciona o fator corretor 
			add a1, a1, t0
			add a2, a2, t0
			
			jal PROC_CALCULAR_TILE_ATUAL
			
			li t0, 100
			bge a0, t0, P_IM1_MATAR_INIMIGO
			j P_IM1_MOVER_INIMIGO
			
			
P_IM1_MATAR_INIMIGO:	slli t0, s6, 2			# idx = 4 * i     		(queremos pular 1 word para cada i)
			add t1, s1, t0			# idx += INIMIGOS_POSICAO   	(pula pra POSICAO[i])
			
			add t1, s2, s6			# idx = i + INIMIGOS_DIRECAO   	(pula pra DIRECAO[i])
			li t0, 4
			sb t0, (t1)			# salva a direcao como 4 (morreu)
			
			# marca que um inimigo morreu
			la t0, CONTADOR_INIMIGOS
			lb t1, (t0)
			addi t1, t1, -1
			sb t1, (t0)
			j P_IM1_LOOP_1_PRINT
			

P_IM1_MOVER_INIMIGO:	###
			### agora temos que determinar que tiles estao de que lado do inimigo ###
			
			add t1, s2, s6			# idx = i + INIMIGOS_DIRECAO   	(pula pra DIRECAO[i])
			lbu s8, (t1)			# carrega a direcao do inimigo
			
			# s7 = TILE ESQUERDA (ESQ)
			# s8 = TILE FRENTE   (FRN)
			# s9 = TILE DIREITA  (DIR)
			
			#### S7 : 1 direcao a frente -- exceto se a direcao for 3, entao eh 0
			li t0, 3
			beq s8, t0, P_IM1_ESQ_CORRECAO	# corrige se a direcao for 3
			
			addi s7, s8, 1			# caso contrario, pega 1 direcao ah frente
			
			j P_IM1_CONT_ESQ

P_IM1_ESQ_CORRECAO:	mv s7, x0			# a esquerda eh a direcao 0 se corrigida
P_IM1_CONT_ESQ:		

#			s8 jah setada

			#### S9 : 1 direcao atras -- exceto se a direcao for 0, entao eh 3
			beqz s8, P_IM1_DIR_CORRECAO	# corrige se a direcao for 0
			
			addi s9, s8, -1			# caso contrario, pega 1 direcao atras
			j P_IM1_CONT_DIR

P_IM1_DIR_CORRECAO:	li t0, 3
			mv s9, t0			# a direita eh a direcao 3 se corrigida
P_IM1_CONT_DIR:		
			# eh vazio mesmo. n resta nada a ser feito :D

# chegou a hora
P_IM1_CALCULAR_MOVIMENTO_INIMIGO:

			addi sp, sp, -8
			sw s0, (sp)
			sw s1, 4(sp)
			
			# vamos guardas as posicoes dos inimigos em s0 e s1
			# s0 = X
			# s1 = Y
			
			slli t0, s6, 2			# idx = 4 * i     		(queremos pular 1 word para cada i)
			add t1, s1, t0			# idx += INIMIGOS_POSICAO   	(pula pra POSICAO[i])
			
			lh s0, (t1)			# s0 = x
			lh s1, 2(t1)			# s1 = y
			
			### agora temos que checar se a frente eh andavel
			
			# a0 = direcao; a1 = pos X; a2 = pos Y
			mv a0, s8
			mv a1, s0
			mv a2, s1
			jal P_IM1_SUBPROC_EH_ANDAVEL
			
			# salva s8 pra usarmos mais a frente
			addi sp, sp, -4
			sw s8, (sp)
			
			beqz a0, P_IM1_FRENTE_NAO_ANDAVEL


P_IM1_FRENTE_ANDAVEL:

			

			# temos que determinar o range A e B em que vamos sortear um numero aleatorio.
			# se o numero for 0 = anda pra esquerda; 1 ou 2, frente; 3, direita. Se fizermos A = 1, entao a esuqerda vai ser ignorada; B = 2, a direita. 
			# s8 = A

			# checa se a esquerda eh andavel
			mv a0, s7
			mv a1, s0
			mv a2, s1
			jal P_IM1_SUBPROC_EH_ANDAVEL
			
			# ah esse ponto talvez vc deve estar se perguntando pq tudo estah em portugues
			# afinal, todo desenvolvedor, em algum nivel, usa o codigo pra expressar quanto
			# ele sabe falar gringo. Eu, no entanto, ateh fiz os commits do github em
			# portugues. 
			# 
			# o motivo de eu escrever tudo em portugues eh porque a gente tah no brasil
			# talvez isso clareie mais a coisas
			# eh a segunda melhor coisa depois de usar a antiga Lingua Geral, mas ela estah
			# extinta. eu num sei falar ela, soh mineiro mesmo e olhe lah.
			#
			# eu sei que isso nao eh coisa a se escrever no proc_inimigos_manager mas
			# o codigo eh meu e eu comento o que eu quiser
			
			# alias o github estah disponivel em https://github.com/fer-amdias/quatro
			
			# s8 = A
			
			# se andavel: 
			#	A = 1 - 1 = 0
			# senao:
			#	A = 1 - 0 = 1
			
			li t0, 1
			sub s8, t0, a0
			
			# checa se a direita eh andavel
			mv a0, s9
			mv a1, s0
			mv a2, s1
			jal P_IM1_SUBPROC_EH_ANDAVEL
			
			# t0 = B
			
			# se andavel: 
			#	B = 1 - 1 + 2 = 2
			# senao:
			#	B = 1 - 0 + 2 = 3
			
			li t0, 1
			sub t0, t0, a0
			addi t0, t0, 2
			
			# temos nosso range!!!!!!!!!!!!!!!!!!!!!!!!!!!
			# agora soh devemos sortear um numero aleatorio
			
			# seta a seed aleatoria como o tempo atual em ms e o index como o ciclo atual
			csrr a1, time
			csrr a0, cycle
			li a7, 40
			ecall				# coloca a seed
			
			# RandIntRange = ecall 42
			# pega um numero entre [0, a0]
			# temos que ser criativos para conseguir um numero entre [A, B]
			# podemos pegar um numero entre [0, B-A]
			# e somar A depois. problema resolvido.
			
			csrr a0, cycle				# index do gerador
			sub a1, t0, s8				# B-A
			li a7, 42
			ecall
			
			add t0, a0, s8			# numero entre [0, B-A] agora entre [A, B]
			# t0 = numero escolhido
			
			# s0 = X; s1 = Y
			###### LOGICA DE MOVIMENTO ######
			
P_IM1_SWITCH1_ESQ:	bnez t0, P_IM1_SWITCH1_FRT	
			#> se t0 == 0:  	MOVER PRA ESQUERDA
			
			mv a0, s7
			j P_IM1_PSEUDOPROC_MOVER 	# move pra esquerda
			
P_IM1_SWITCH1_FRT:	li t1, 2
			bgt t0, t1, P_IM1_SWITCH1_DIR
			#> se t0 == 1 ou 2: 	MOVER PRA FRENTE
			
			lw s8, (sp)
			
			mv a0, s8
			j P_IM1_PSEUDOPROC_MOVER 	# move pra frente
			
P_IM1_SWITCH1_DIR:	li t1, 3
			bne t0, t1, P_IM1_SWITCH1_FIM
			#> se t0 == 3: 		MOVER PRA DIREITA
			
			mv a0, s9
			j P_IM1_PSEUDOPROC_MOVER
			
P_IM1_SWITCH1_FIM:	## ISSO NAO DEVE ACONTECER
	
			# sai com codigo 100
			li a0, 100
			li a7, 93
			ecall

P_IM1_FRENTE_NAO_ANDAVEL:

			# checa se a esquerda eh andavel
			mv a0, s7
			mv a1, s0
			mv a2, s1
			jal P_IM1_SUBPROC_EH_ANDAVEL
			
			# s8 = 1 se esquerda for andavel, 0 se esqyerda nao for andavel
			mv s8, a0
			
			# checa se a direita eh andavel
			mv a0, s9
			mv a1, s0
			mv a2, s1
			jal P_IM1_SUBPROC_EH_ANDAVEL
			
			# t0 = direita OU esquerda andavel
			or t0, a0, s8
			
			# nao dah pra andar 
			beqz t0, P_IM1_SOH_ATRAS_ANDAVEL
			
			# t0 = direita E esquerda andavel
			and t0, a0, s8
			bnez t0, P_IM1_DECIDIR_ESQUERDA_DIREITA
			
			# se esquerda = 1, anda pra esquerda
			bnez s8, P_IM1_ESQUERDA_ANDAVEL
			j P_IM1_DIREITA_ANDAVEL
					
P_IM1_DECIDIR_ESQUERDA_DIREITA:
			# o desafio de todo adolescente
			
			# seta a seed aleatoria como o tempo atual em ms e o index como o ciclo atual
			csrr a1, time
			csrr a0, cycle
			li a7, 40
			ecall				# coloca a seed
			
			# RandIntRange = ecall 42
			# pega um numero entre [0, 1]
			
			csrr a0, cycle				# index do gerador
			li a1, 1				
			li a7, 42
			ecall
			
			# se a0 = 0, anda pra direita. se a0 = 1, anda pra esquerda.
			bnez a0, P_IM1_DIREITA_ANDAVEL

P_IM1_ESQUERDA_ANDAVEL:

			mv a0, s7			# move pra esquerda
			j P_IM1_PSEUDOPROC_MOVER

P_IM1_DIREITA_ANDAVEL:

			mv a0, s9			# move pra direita
			j P_IM1_PSEUDOPROC_MOVER

P_IM1_SOH_ATRAS_ANDAVEL:

			# s8 = atras
			# vamos calcular a partir da esquerda
			# atras = esquerda + 1, EXCETO se esquerda = 3; nesse caso, atras = 0.
			
			li t0, 3
			beq t0, s7, P_IM1_CORRIGIR_ATRAS
			
			addi s8, s7, 1			# atras = esquerda + 1
			j P_IM1_SOH_ATRAS_ANDAVEL_CONT

P_IM1_CORRIGIR_ATRAS:	li s8, 0			# corrige atras pra 0
P_IM1_SOH_ATRAS_ANDAVEL_CONT:

			# a0 = direcao; a1 = posX; a2 = posY
			# checa se atras eh andavel
			mv a0, s8
			mv a1, s0
			mv a2, s1
			jal P_IM1_SUBPROC_EH_ANDAVEL
			
			
			mv t0, a0
			beqz a0, P_IM1_NAO_DAH_PRA_ANDAR
			
			
			mv a0, s8			# anda pra tras
			j P_IM1_PSEUDOPROC_MOVER

P_IM1_NAO_DAH_PRA_ANDAR:

			addi sp, sp, 4				# descarta s8
			j P_IM1_LOOP_1_MOVER_FINAL 		# nao hah movimento!!!



# argumento: a0 - direcao
P_IM1_PSEUDOPROC_MOVER:	
# eh isso mesmo, pseudoproc
			# a direcao frontal (s8) pode ser abandonada agora)
			addi sp, sp, 4
			
			# t1 = endereco da direcao do inimigo
			add t1, s2, s6			# idx = i + INIMIGOS_DIRECAO   	(pula pra DIRECAO[i])

			beqz a0, P_IM1_MOVER_SUL
			
			li t0, 1
			beq a0, t0, P_IM1_MOVER_LESTE
			
			li t0, 2
			beq a0, t0, P_IM1_MOVER_NORTE
			
			li t0, 3
			beq a0, t0, P_IM1_MOVER_OESTE
			
			j P_IM1_MORRER
			
P_IM1_MOVER_SUL:	# s0 = X; s1 = Y

			# print_literal_ln("AO SUL!")

			addi s1, s1, 1	# y++
			sb x0, (t1)	# direcao = 0 (sul)
			
			j P_IM1_LOOP_1_MOVER_FINAL
			
P_IM1_MOVER_LESTE:	
			addi s0, s0, 1	# x++
			li t0, 1
			sb t0, (t1)	# direcao = 1 (leste)
			
			# print_literal_ln("AO LESTE!")
			
			j P_IM1_LOOP_1_MOVER_FINAL
			
P_IM1_MOVER_NORTE:	

			addi s1, s1, -1	# y--
			li t0, 2
			sb t0, (t1)	# direcao = 2 (norte)
			
			# print_literal_ln("AO NORTE!!")
			
			j P_IM1_LOOP_1_MOVER_FINAL
			
P_IM1_MOVER_OESTE:	
			addi s0, s0, -1	# x--
			li t0, 3
			sb t0, (t1)	# direcao = 3 (oeste)
			
			# print_literal_ln("AO OESTE!")
			
			j P_IM1_LOOP_1_MOVER_FINAL
			
			### transicao pro print
			
P_IM1_MORRER:		li t0, 4
			sb t0, (t1)	# direcao = 4 (morte)
			
P_IM1_LOOP_1_MOVER_FINAL:
		
			# t3 = posX; t4 = posY;
			mv t3, s0
			mv t4, s1
		
			lw s0, (sp)
			lw s1, 4(sp)
			addi sp, sp, 8
			
			slli t0, s6, 2			# idx = 4 * i     		(queremos pular 1 word para cada i)
			
			add t0, s1, t0			# idx += INIMIGOS_POSICAO   	(pula pra POSICAO[i])
			sh t3, (t0)
			sh t4, 2(t0)
		
			### hora de printar o inimigo
P_IM1_LOOP_1_PRINT:

			# temos que calcular qual vai ser a textura do inimigo
			# vai ser inimigo-10 * AREA_SPRITE * 5  + AREA_SPRITE * direcao
			# isso eh pq o inimigo comeca a contar do 10 e cada inimigo tem 5 quadradinhos na strip :3
			
			
			li t0, 5
			li t2, AREA_SPRITE
			mul t1, t2, t0			# t1 = 5 * AREA_SPRITE
			
			add t0, s6, s0			# idx = i + INIMIGOS (pulamos 1 byte por inimigo)
			
			lbu t0, (t0)			# carrega o valor desse inimigo
			addi t0, t0, -10		# subtrai 10
			
			mul t1, t1, t0			# idx = inimigo-10 * AREA_SPRITE * 5
			
			add a0, t1, s5			# ENDERECO DA TEXTURA A SER IMPRESSA: textura strip + idx
			
			add t1, s2, s6			# idx = i + INIMIGOS_DIRECAO   	(pula pra DIRECAO[i])
			lbu t1, (t1)			# carrega o valor de direcao do inimigo
			mul t1, t2, t1			# t1 = AREA_SPRITE * direcao
			
			add a0, t1, a0			# ENDERECO DA TEXTURA A SER IMPRESSA += t1
			
			### agora peguemos as posicoes x e y
			slli t0, s6, 2			# idx = 4 * i     		(queremos pular 1 word para cada i)
			add t0, s1, t0			# idx += INIMIGOS_POSICAO   	(pula pra POSICAO[i])
			lhu a1, (t0)			# carrega a pos X
			lhu a2, 2(t0)			# carrega a pos Y
			
			### salva as dimensoes como AREA_SPRITE x AREA_SPRITE (correto)
			mv a3, s4
			mv a4, s4
			
			### imprimir no frame_buffer
			li a7, 0
			

			#		PROC_IMPRIMIR_TEXTURA			     
			#	A0 : ENDERECO DA TEXTURA A SER IMPRESSA              
			# 	A1 : POSICAO X                                      
			#       A2 : POSICAO Y                                       
			#       A3 : NUMERO DE LINHAS DA TEXTURA (ALTURA)            
			#       A4 : NUMERO DE COLUNAS DA TEXTURA (LARGURA)          
			#	A7 : MODO DE IMPRESSAO 				     
			#			(0: FRAME_BUFFER, 1: FASE_BUFFER)    
			
			
			jal PROC_IMPRIMIR_TEXTURA


P_IM1_LOOP_1_CONT_1:	addi s6, s6, 1		# i++
			blt s6, s3, P_IM1_LOOP_1# se i < qtd de inimigos, continuar
			
			
# mds quanta linha hein
# eh ah ia pra vc ahi
# haja dedo pra digitar e cerebro pra debugar mds do ceu
			
PROC_INIMIGOS_MANAGER_FIM:
			lw s0, (sp)
			lw s1, 4(sp)
			lw s2, 8(sp)
			lw s3, 12(sp)
			lw s4, 16(sp)
			lw s5, 20(sp)
			lw s6, 24(sp)
			lw s7, 28(sp)
			lw s8, 32(sp)
			lw ra, 36(sp)
			lw s9, 40(sp)
			lw s10, 44(sp)
			addi sp, sp, 48
			
			ret
