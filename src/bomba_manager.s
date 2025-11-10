#################################################################
# PROC_BOMBA_MANAGER				       	     	#
# Lida com cada bomba presente na memoria, administrando	#
# countdowns e explosoes.		           		#
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : endereco da textura de bombas			#
#	A1 : endereco da textura do mapa			#
#	A2 : endereco do mapa em si				#
# RETORNOS:                                                  	#
#       (nenhum)						#
#################################################################

# PREFIXO INTERNO: P_BM1_


# ARGUMENTOS:
#	a0 = igual
#	a1 = igual
#	a2 = igual
#	a3 = X do tile
#	a4 = Y do tile
# RETORNOS:
#	tudo igual lol
P_BM1_SUBPROC_EXPLODIR:

			# salva os argumentos
			addi sp, sp, -24
			sw a0, (sp)
			sw a1, 4(sp)
			sw a2, 8(sp)
			sw a3, 12(sp)
			sw a4, 16(sp)
			sw ra, 20(sp)

			la t2, POSICOES_MAPA
			lh t0, (t2)				# x do mapa
			lh t1, 2(t2)				# y do mapa
			
			# se x ou y estiverem fora do mapa, nao explode.
			blt a3, t0, P_BM1_SUBPROC_EXPLODIR_FIM
			blt a4, t1, P_BM1_SUBPROC_EXPLODIR_FIM
		
			li t2, 320				# largura vga
			sub t0, t2, t0				# x final do mapa = vga - x do mapa
			li t2, 240				# altura vga
			sub t1, t2, t1				# y final do mapa = vga - y do mapa
			
			# se x ou y estiverem fora do mapa, nao explode
			bgt a3, t0, P_BM1_SUBPROC_EXPLODIR_FIM
			bgt a4, t1, P_BM1_SUBPROC_EXPLODIR_FIM
			
			# toca o efeito sonoro de bomba
			li a0, 37		
			li a1, 2000		# 1000 ms
			li a2, 127		# instrumento de explosao
			li a3, 127		# volume maximo
			li a7, 31		# MidiOut
			ecall
			
			lw a0, (sp)
			lw a1, 4(sp)
			
			
			# PROC_CALCULAR_TILE_ATUAL			           						     
			# ARGUMENTOS:						     
			#	A0 : ENDERECO DO MAPA (.data)			     
			# 	A1 : POSICAO X                                       
			#       A2 : POSICAO Y   
			# RETORNOS INTERESSANTES:
			#       A0 : INFORMACAO DO TILE ATUAL (0-255)		     
			#	A1 : COLUNA EM QUE O TILE ESTAH LOCALIZADO NO .data  
			#	A2 : LINHA EM QUE O TILE ESTAH LOCALIZADO NO .data   
			
			lw a0, 8(sp)
			lw a1, 12(sp)
			lw a2, 16(sp)
			
			jal PROC_CALCULAR_TILE_ATUAL
			
			# se o tile eh uma parede, nao explode ele
			li t0, 1
			beq a0, t0, P_BM1_SUBPROC_EXPLODIR_FIM
			
			# se o tile for maior que 100 (tile explodindo), nao precisa explodir ele mais
			li t0, 100
			bge a0, t0, P_BM1_SUBPROC_EXPLODIR_FIM
			
			#		PROC_IMPRIMIR_TEXTURA			     	
			#	A0 : ENDERECO DA TEXTURA A SER IMPRESSA              
			# 	A1 : POSICAO X                                      
			#       A2 : POSICAO Y                                       
			#       A3 : NUMERO DE LINHAS DA TEXTURA (ALTURA)            
			#       A4 : NUMERO DE COLUNAS DA TEXTURA (LARGURA)          
			#	A7 : MODO DE IMPRESSAO 				     
			#			(0: FRAME_BUFFER, 1: FASE_BUFFER) 
			
			
			li t0, 3				# t0 = 3 (pos onde fica a explosao no arquivo .data de explosivos
			li t1, AREA_SPRITE			# t1 = AREA_SPRITE
			mul t0, t1, t0				# t0 = IDX = AREA_SPRITE * 3
			
			lw a0, (sp)
			add a0, a0, t0				# endereco da textura += IDX
			
			# carrega a pos X e a pos Y
			lw a3, 12(sp)
			lw a4, 16(sp)
			mv a1, a3
			mv a2, a4

			
			
			# dimensoes de um tile
			li a3, TAMANHO_SPRITE
			li a4, TAMANHO_SPRITE
			
			# modo de impressao = na fase buffer
			li a7, 1
			
			jal PROC_IMPRIMIR_TEXTURA
			
			
			# adiciona 100 para marcar explosao
			lw a1, 12(sp)
			lw a2, 16(sp)
			jal VIRTUALPROC_EXPLODIR_TILE_EM_TILEMAP
			
			
			
			
			
			
P_BM1_SUBPROC_EXPLODIR_FIM:	
			# retorna os argumentos intactos	
			lw a0, (sp)
			lw a1, 4(sp)
			lw a2, 8(sp)
			lw a3, 12(sp)
			lw a4, 16(sp)
			lw ra, 20(sp)
			addi sp, sp, 24
			ret

##############################

P_BM1_SUBPROC_RESTAURAR:

			# ARGUMENTOS:
			#	a0 = igual
			#	a1 = igual
			#	a2 = igual
			#	a3 = X do tile
			#	a4 = Y do tile
			# RETORNOS:
			#	tudo igual lol

			# salva os argumentos
			addi sp, sp, -24
			sw a0, (sp)
			sw a1, 4(sp)
			sw a2, 8(sp)
			sw a3, 12(sp)
			sw a4, 16(sp)
			sw ra, 20(sp)

			la t2, POSICOES_MAPA
			lh t0, (t2)				# x do mapa
			lh t1, 2(t2)				# y do mapa
			
			# se x ou y estiverem fora do mapa, nao restaura.
			blt a3, t0, P_BM1_SUBPROC_RESTAURAR_FIM
			blt a4, t1, P_BM1_SUBPROC_RESTAURAR_FIM
		
			li t2, 320				# largura vga
			sub t0, t2, t0				# x final do mapa = vga - x do mapa
			li t2, 240				# altura vga
			sub t1, t2, t1				# y final do mapa = vga - y do mapa
			
			# se x ou y estiverem fora do mapa, nao restaura.
			bgt a3, t0, P_BM1_SUBPROC_RESTAURAR_FIM
			bgt a4, t1, P_BM1_SUBPROC_RESTAURAR_FIM
			
			# PROC_CALCULAR_TILE_ATUAL			           						     
			# ARGUMENTOS:						     
			#	A0 : ENDERECO DO MAPA (.data)			     
			# 	A1 : POSICAO X                                       
			#       A2 : POSICAO Y   
			# RETORNOS INTERESSANTES:
			#       A0 : INFORMACAO DO TILE ATUAL (0-255)		     
			#	A1 : COLUNA EM QUE O TILE ESTAH LOCALIZADO NO .data  
			#	A2 : LINHA EM QUE O TILE ESTAH LOCALIZADO NO .data   
			
			la a0, TILEMAP_BUFFER
			mv a1, a3
			mv a2, a4
			
			jal PROC_CALCULAR_TILE_ATUAL
			
			li t0, 100			# minimo para um tile ser explodido
			bgt t0, a0, P_BM1_SUBPROC_RESTAURAR_FIM
			
			### agora no tilemap
			li a0, -100				# desfaz a explosao
			lw a1, 12(sp)				# pos x
			lw a2, 16(sp)				# pos y
			li a7, 1				# modo incrementar
			jal PROC_MANIPULAR_TILEMAP
			
			li t0, 4
			beq a0, t0, P_BM1_DELETAR_PAREDE
			
			j P_BM1_RESTAURAR_CONT
			
P_BM1_DELETAR_PAREDE:
			# hora de checar o que tinha "debaixo" da parede
			lw a0, 8(sp)
			lw a1, 12(sp)
			lw a2, 16(sp)
			
			jal PROC_CALCULAR_TILE_ATUAL
			
			# a0 = tile no arquivo
			
			li t0, 4
			beq a0, t0, P_BM1_PULAR_PAREDE		# se o tile for 4, entao n tinha nada atras da parede, e portanto, devemos substitui-la com absolutamente nada (tile andavel)
			
			# restaura com o valor original
			# a0 jah carregado
			lw a1, 12(sp)				# pos x
			lw a2, 16(sp)				# pos y
			li a7, 0				# modo escrita
			jal PROC_MANIPULAR_TILEMAP
			j P_BM1_RESTAURAR_CONT
			
P_BM1_PULAR_PAREDE:	# deixa tile como vazio
			li a0, 0
			lw a1, 12(sp)				# pos x
			lw a2, 16(sp)				# pos y
			li a7, 0				# modo escrita
			jal PROC_MANIPULAR_TILEMAP
P_BM1_RESTAURAR_CONT:	
			### imprimindo na tilemap e no fase buffer           				
			lw a1, 4(sp)				# a1 = endereco da textura do mapa
			lw a3, 12(sp)
			lw a4, 16(sp)
			
			addi a1, a1, 8				# pula bytes de informacao
			
			li t1, AREA_SPRITE
			mul a0, a0, t1				# idx = conteudo do tile * area sprite
			add a1, a1, a0				# endereco += idx
			
			mv a0, a1				# coloca a0 ( endereco da textura ) para procedimento de imprimir textura
			
			mv a1, a3				# a1 = pos X
			mv a2, a4				# a2 = pos Y
			li a3, TAMANHO_SPRITE			# carrega dimensoes da bomba (tamanho de um tile)
			li a4, TAMANHO_SPRITE			# carrega dimensoes da bomba (tamanho de um tile)
			li a7, 1 				# seta modo de impressao como FASE_BUFFER
			
			jal PROC_IMPRIMIR_TEXTURA

P_BM1_SUBPROC_RESTAURAR_FIM:

			# retorna os argumentos intactos	
			lw a0, (sp)
			lw a1, 4(sp)
			lw a2, 8(sp)
			lw a3, 12(sp)
			lw a4, 16(sp)
			lw ra, 20(sp)
			addi sp, sp, 24
			ret



PROC_BOMBA_MANAGER:	





			addi sp, sp, -16
			sw ra, (sp)
			sw s0, 4(sp)
			sw s1, 8(sp)
			sw s2, 12(sp)
			
			# nao administra as bombas se o jogo estiver pausado
			lb t0, JOGO_PAUSADO
			bnez t0, P_BM1_FIM
			
			addi a0, a0, 8				# pula 2 words, as words de informacao de dimensoes da textura

			# s0 = ESB = endereco do struct de bombas
			la s0, BOMBAS
			
			# o loop vai de i = 0 a i = 3
			li s1, 0
			li s2, 4
			
			lbu t0, POWERUP_QTD_BOMBAS
			bnez t0, P_BM1_LOOP_1
			
			li s2, 1	# se o powerup de qtd de bombas nao tiver sido pego, so deixa o jogador usar um espaco de bomba
	
			# for (i = 0; i < 4; i++)
P_BM1_LOOP_1:		csrr t2, time				# t2 = time
			lw t3, BOMBAS_MS_DE_TRANSICAO(s0)	# t3 = ms em que a bomba explode
			blt t2, t3, P_BM1_LOOP_1_CONT		# se t2 < t3, entao a bomba nao deve explodir. Devemos pula-la entao.
			lbu t3, BOMBAS_EXISTE(s0)
			beqz t3, P_BM1_LOOP_1_CONT
			
			# caso contrario:
			addi t2, t2, 1000			# adiciona 1 segundo aos milisegundos
			sw t2, BOMBAS_MS_DE_TRANSICAO(s0)	# salva o novo tempo
			lbu t2, BOMBAS_CONTAGEM_REGRESSIVA(s0)	# pega a contagem regressiva
			addi t2, t2, -1				# subtrai 1
			sb t2, BOMBAS_CONTAGEM_REGRESSIVA(s0)	# salva a nova contagem
			
			beqz t2, P_BM1_LOOP_1_EXPLODIR
			bltz t2, P_BM1_LOOP_1_FINALIZAR_EXPLOSAO
			
			addi t2, t2, -3				# pega a contagem - 3
			neg t2, t2				# transforma em 3 - contagem
			
			#		PROC_IMPRIMIR_TEXTURA			     	
			#	A0 : ENDERECO DA TEXTURA A SER IMPRESSA              
			# 	A1 : POSICAO X                                      
			#       A2 : POSICAO Y                                       
			#       A3 : NUMERO DE LINHAS DA TEXTURA (ALTURA)            
			#       A4 : NUMERO DE COLUNAS DA TEXTURA (LARGURA)          
			#	A7 : MODO DE IMPRESSAO 				     
			#			(0: FRAME_BUFFER, 1: FASE_BUFFER) 
			
			# salva a textura da bomba
			addi sp, sp, -16
			sw a0, (sp)
			sw a1, 4(sp)
			sw a2, 8(sp)
			
			
			li t3, AREA_SPRITE
			mul t3, t3, t2				# t3 = idx = (3 - contagem) * AREA_SPRITE
			add a0, a0, t3				# textura da bomba += idx (pula pra textura desejada)
			
			lhu a1, BOMBAS_POS_X(s0)		# carrega pos x
			lhu a2, BOMBAS_POS_Y(s0)		# carrega pos y
			li a3, TAMANHO_SPRITE			# carrega dimensoes da bomba (tamanho de um tile)
			li a4, TAMANHO_SPRITE			# carrega dimensoes da bomba (tamanho de um tile)
			li a7, 1 				# seta modo de impressao como FASE_BUFFER
			
			jal PROC_IMPRIMIR_TEXTURA
			
			# recupera a textura da bomba
			lw a0, (sp)
			lw a1, 4(sp)
			lw a2, 8(sp)
			addi sp, sp, 16
			
			j P_BM1_LOOP_1_CONT
			
P_BM1_LOOP_1_EXPLODIR:  

			lhu a3, BOMBAS_POS_X(s0)		# carrega pos x
			lhu a4, BOMBAS_POS_Y(s0)		# carrega pos y
			jal P_BM1_SUBPROC_EXPLODIR
			
			li t0, TAMANHO_SPRITE
			sub a4, a4, t0				# vai pro tile acima
			jal P_BM1_SUBPROC_EXPLODIR
				
			li t0, TAMANHO_SPRITE
			add a4, a4, t0		
			add a4, a4, t0				# vai pro tile abaixo
			jal P_BM1_SUBPROC_EXPLODIR
			
			li t0, TAMANHO_SPRITE
			sub a4, a4, t0
			add a3, a3, t0				# vai pro tile ah direita
			jal P_BM1_SUBPROC_EXPLODIR
			
			li t0, TAMANHO_SPRITE
			sub a3, a3, t0
			sub a3, a3, t0		# vai pro tile ah esquerda
			jal P_BM1_SUBPROC_EXPLODIR
			
			# checa se o jogador pegou o powerup de tamanho de bomba
			lbu t0, POWERUP_TAMANHO_BOMBA
			beqz t0, P_BM1_LOOP_1_CONT	
			
			# se sim, aumenta o tamanho da explosao
			
			lhu a3, BOMBAS_POS_X(s0)		# carrega pos x
			lhu a4, BOMBAS_POS_Y(s0)		# carrega pos y
			
			li t0, TAMANHO_SPRITE
			slli t0, t0, 1				# multiplica por 2, pulando 2 tiles em vez de 1
			sub a4, a4, t0				# vai pro tile acima
			jal P_BM1_SUBPROC_EXPLODIR
				
			li t0, TAMANHO_SPRITE
			slli t0, t0, 1				# multiplica por 2, pulando 2 tiles em vez de 1
			add a4, a4, t0		
			add a4, a4, t0				# vai pro tile abaixo
			jal P_BM1_SUBPROC_EXPLODIR
			
			li t0, TAMANHO_SPRITE
			slli t0, t0, 1				# multiplica por 2, pulando 2 tiles em vez de 1
			sub a4, a4, t0
			add a3, a3, t0				# vai pro tile ah direita
			jal P_BM1_SUBPROC_EXPLODIR
			
			li t0, TAMANHO_SPRITE
			slli t0, t0, 1				# multiplica por 2, pulando 2 tiles em vez de 1
			sub a3, a3, t0
			sub a3, a3, t0		# vai pro tile ah esquerda
			jal P_BM1_SUBPROC_EXPLODIR
			
			j P_BM1_LOOP_1_CONT


P_BM1_LOOP_1_FINALIZAR_EXPLOSAO:
			lhu a3, BOMBAS_POS_X(s0)		# carrega pos x
			lhu a4, BOMBAS_POS_Y(s0)		# carrega pos y   
			jal P_BM1_SUBPROC_RESTAURAR
			
			li t0, TAMANHO_SPRITE
			sub a4, a4, t0				# vai pro tile acima
			jal P_BM1_SUBPROC_RESTAURAR
				
			li t0, TAMANHO_SPRITE
			add a4, a4, t0		
			add a4, a4, t0				# vai pro tile abaixo
			jal P_BM1_SUBPROC_RESTAURAR
			
			li t0, TAMANHO_SPRITE
			sub a4, a4, t0
			add a3, a3, t0				# vai pro tile ah direita
			jal P_BM1_SUBPROC_RESTAURAR
			
			li t0, TAMANHO_SPRITE
			sub a3, a3, t0
			sub a3, a3, t0				# vai pro tile ah esquerda
			jal P_BM1_SUBPROC_RESTAURAR
			
			sb x0, BOMBAS_EXISTE(s0)		# deleta a bomba
			
			# checa se o jogador pegou o powerup de tamanho de bomba
			lbu t0, POWERUP_TAMANHO_BOMBA
			beqz t0, P_BM1_LOOP_1_CONT	
			
			# se sim, aumenta o tamanho da explosao
			
			lhu a3, BOMBAS_POS_X(s0)		# carrega pos x
			lhu a4, BOMBAS_POS_Y(s0)		# carrega pos y   
			
			li t0, TAMANHO_SPRITE
			slli t0, t0, 1				# multiplica por 2, pulando 2 tiles em vez de 1
			sub a4, a4, t0				# vai pro tile acima
			jal P_BM1_SUBPROC_RESTAURAR
				
			li t0, TAMANHO_SPRITE
			slli t0, t0, 1				# multiplica por 2, pulando 2 tiles em vez de 1
			add a4, a4, t0		
			add a4, a4, t0				# vai pro tile abaixo
			jal P_BM1_SUBPROC_RESTAURAR
			
			li t0, TAMANHO_SPRITE
			slli t0, t0, 1				# multiplica por 2, pulando 2 tiles em vez de 1
			sub a4, a4, t0
			add a3, a3, t0				# vai pro tile ah direita
			jal P_BM1_SUBPROC_RESTAURAR
			
			li t0, TAMANHO_SPRITE
			slli t0, t0, 1				# multiplica por 2, pulando 2 tiles em vez de 1
			sub a3, a3, t0
			sub a3, a3, t0				# vai pro tile ah esquerda
			jal P_BM1_SUBPROC_RESTAURAR
			
P_BM1_LOOP_1_CONT:	addi s0, s0, STRUCT_BOMBAS_OFFSET 	# desloca o array em uma posicao
			addi s1, s1, 1				# i++
			blt s1, s2, P_BM1_LOOP_1		# se i < 4, continuar
			
			
P_BM1_FIM:		lw ra, (sp)
			lw s0, 4(sp)
			lw s1, 8(sp)
			lw s2, 12(sp)
			addi sp, sp, 16
			
			ret
			

