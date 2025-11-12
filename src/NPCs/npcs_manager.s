#################################################################
# PROC_NPCS_MANAGER				       	     	#
# Administra npcs, seus movimentos, colisoes, e mortes          #
# 							     	#
# ARGUMENTOS:						     	#
# 	A0 = endereco do stripe de textura dos npcs		#
#								#
# RETORNOS:                                                  	#
#      (nenhum)							#
#################################################################

# PREFIXO INTERNO: P_IM1_

# NPCS_QUANTIDADE: 	.word 0		# quantidade de npcs no mundo
# NPCS:         	.byte 0 	# alihamento do vetor
# 	          	.space 31 	# cada npc vai ser salvo em um byte, dando um total de 32 npcs nesse vetor
# NPCS_POSICAO: 	.half 0 	# alinhamento do vetor
# 	          	.space 127	# cada npc vai ter uma posicao de half-word (x) e half-word (y).
# NPCS_DIRECAO: 	.byte 0 	# alinhamento do vetor
# 		  	.space 31	# cada npc vai ter uma direcao salvo em um byte.	

# argumentos: 
#	a0 = direcao
#	a1 = pos X do npc
#	a2 = pos Y do npc
# retornos: 
#	a0 = 1 ou 0

.data



.text

PROC_NPCS_MANAGER:	
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
			
			# s0 = vetor NPCS
			# s1 = vetor NPCS_POSICAO
			# s2 = vetor NPCS_DIRECAO
			# s3 = int   NPCS_QUANTIDADE
			# s4 = const TAMANHO_SPRITE -- dimensoes de um npc (sim, ele ocupa um tile todo)
			# s5 = endereco do strip de textura
			# s6 = vetor NPCS_TIMESTAMP
			
			la s0, NPCS
			la s1, NPCS_POSICAO
			la s2, NPCS_DIRECAO
			la s3, NPCS_QUANTIDADE
			li s4, TAMANHO_SPRITE
			mv s5, a0
			la s6, NPCS_TIMESTAMP
		
			addi s5, s5, 8			# pula as words de dimensoes da strip de npc
			
			
			
			# LOOP
			# s7 = i
			# loop vai ateh o valor em s3
			
			# ou seja, faca para cada npc o que estah no loop
			
			mv s7, zero
			lw s3, (s3)			# carrega a quantidade de npcs em s3
			
			beqz s3, PROC_NPCS_MANAGER_FIM	# pula o loop se nao existe nenhum npc
			
P_IM1_PROSSEGUIR:	lbu t2, JOGO_PAUSADO
			beqz t2, P_IM1_PROSSEGUIR2		# se nao estiver pausado, prossiga
			
			# caso contrario, marca como 'pausado'
			li s10, 0
			beqz s3, PROC_NPCS_MANAGER_FIM	# pula o loop se nao existe nenhum npc
			j P_IM1_LOOP_1

P_IM1_PROSSEGUIR2:	
			li s10, 1				# marca como 'despausado'
			
			beqz s3, PROC_NPCS_MANAGER_FIM	# pula o loop se nao existe nenhum npc
	
			
P_IM1_LOOP_1:		
	
			# se estiver fora do cooldown, soh imprime o npc mesmo
			beqz s10, P_IM1_LOOP_1_PRINT

			### primeiro determina se ele tah vivo. senao, nem move ele
			add t1, s2, s7			# idx = i + NPCS_DIRECAO   	(pula pra DIRECAO[i])
			lbu t1, (t1)			# carrega direcao do npc
			li t0, 4
			beq t1, t0, P_IM1_LOOP_1_PRINT	# se for 4, ele estah morto, ent n move ele lol

			# t1 = posicao[i]
			slli t0, s7, 2			# idx = 4 * i     		(queremos pular 1 word para cada i)
			add t1, s1, t0			# idx += NPCS_POSICAO   	(pula pra POSICAO[i])
			
			#### agora vamos checar o tile no meio da hitbox. se o tile for 100, o npc acabou de esbarrar em uma explosao e deve morrer.
			
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
			lh a1, (t1)			# carrega pos X do npc como argumento
			lh a2, 2(t1)			# carrega pos Y do npc como argumento
			
			# temos que mover a checagem para o meio do npc
			# calculemos um fator corretor
			srli t0, s4, 1			# divide o TAMANHO_SPRITE por 2
			
			# adiciona o fator corretor 
			add a1, a1, t0
			add a2, a2, t0
			
			jal PROC_CALCULAR_TILE_ATUAL
			
			li t0, 100
			bge a0, t0, P_IM1_MATAR_NPC
			j P_IM1_MOVER_NPC
			
			
P_IM1_MATAR_NPC:	
			add t1, s2, s7			# idx = i + NPCS_DIRECAO   	(pula pra DIRECAO[i])
			li t0, 4
			sb t0, (t1)			# salva a direcao como 4 (morreu)
			
			# marca que um npc morreu
			la t0, CONTADOR_NPCS
			lb t1, (t0)
			addi t1, t1, -1
			sb t1, (t0)


			# agora temos que saber se o npc eh inimigo!
			la t0, STRUCTS_NPCS
			li t1, NPC_STRUCT_TAMANHO    # pega o tamanho de uma struct

			add t2, s7, s0			# idx = i + NPCS (pulamos 1 byte por npc)
			lbu t2, (t2)			# carrega o valor desse npc
			addi t2, t2, -10		# subtrai 10

			# t2 = tipo de npc (tipo 1 = 0, tipo 2 = 1, ...)
			# t3 = tipo de npc * tamanho struct (pega quantas structs devemos avancar)
			mul t3, t1, t2 
			add t0, t0, t3		# avanca pra struct certa
			lbu t1, NPC_STRUCT_ATRIBUTO_INIMIGO(t0)

			beqz t1, P_IM1_LOOP_1_PRINT  # se nao for, termina
			# se for, decrementa o contador de inimigos

			la t0, CONTADOR_INIMIGOS
			lb t1, 0(t0)
			addi t1, t1, -1
			sb t1, (t0)

			j P_IM1_LOOP_1_PRINT
			

P_IM1_MOVER_NPC:	# agora chamemos a funcao de movimento 

			# PROC_MOVIMENTO_NPC_X  			       	     	
			# Calcula a direcao de movimento do NPC X                      
			# 							     	
			# ARGUMENTOS:						     	
			#       A0 = direcao do NPC                                     
			#       A1 = pos X do NPC                                       
			#       A2 = pos Y do NPC                                       
			#	A3 = timestamp do NPC	
			#       A4 = velocidade do NPC		
			# RETORNOS:                                                  	
			#       A0 = direcao de movimento (-1, caso fique parado)

			add t1, s2, s7			# idx = i + NPCS_DIRECAO   	(pula pra DIRECAO[i])	
			lb a0, (t1)

			slli t0, s7, 2			# idx = 4 * i     		(queremos pular 1 word para cada i)
			add t1, s1, t0			# t1 = idx + NPCS_POSICAO   (pula pra POSICAO[i])
			lh a1, (t1)			# carrega pos X do npc como argumento
			lh a2, 2(t1)			# carrega pos Y do npc como argumento

			add a3, s6, t0			# a3 = idx + NPCS_TIMESTAMP (carrega o endereco da timestamp do npc)




			# agora temos que determinar: 1. a velocidade, e 2. qual proc chamar.
			# isso pode ser acessado em definicoes_npcs.s (STRUCTS_NPCS)
			la t0, STRUCTS_NPCS
			li t1, NPC_STRUCT_TAMANHO    # pega o tamanho de uma struct

			add t2, s7, s0			# idx = i + NPCS (pulamos 1 byte por npc)
			lbu t2, (t2)			# carrega o valor desse npc
			addi t2, t2, -10		# subtrai 10

			# t2 = tipo de npc (tipo 1 = 0, tipo 2 = 1, ...)
			# t3 = tipo de npc * tamanho struct (pega quantas structs devemos avancar)
			mul t3, t1, t2 
			add t0, t0, t3		# avanca pra struct certa
			lhu t1, NPC_STRUCT_ATRIBUTO_VELOCIDADE(t0)
			lbu t2, NPC_STRUCT_ATRIBUTO_TIPO_DE_MOVIMENTO(t0)

			# coloca o atributo de velocidade
			mv a4, t1

			# agora temos que determinar qual proc chamar, baseado no tipo de movimento.

			li t0, 1
			beq t0, t2, P_IM1_MOVIMENTO_1

			li t0, 2
			beq t0, t2, P_IM1_MOVIMENTO_2

			li t0, 3
			beq t0, t2, P_IM1_MOVIMENTO_3

			j P_IM1_MOVIMENTO_DEFAULT

P_IM1_MOVIMENTO_1:
			jal PROC_MOVIMENTO_NPC_1
			j P_IM1_MOVER_NPC_CONT
P_IM1_MOVIMENTO_2:
			jal PROC_MOVIMENTO_NPC_2
			j P_IM1_MOVER_NPC_CONT
P_IM1_MOVIMENTO_3:
			jal PROC_MOVIMENTO_NPC_3
			j P_IM1_MOVER_NPC_CONT
P_IM1_MOVIMENTO_DEFAULT:
			jal PROC_MOVIMENTO_NPC_1
			j P_IM1_MOVER_NPC_CONT

P_IM1_MOVER_NPC_CONT:
			

			bltz a0, P_IM1_LOOP_1_PRINT	# se a direcao for -1, soh printa o npc mesmo

			# senao, move

# argumento: a0 - direcao
P_IM1_PSEUDOPROC_MOVER:	
# eh isso mesmo, pseudoproc			
			# t1 = endereco da direcao do npc
			add t1, s2, s7			# t1 = i + NPCS_DIRECAO   	(pula pra DIRECAO[i])

			# t2 = endereco da posicao do npc
			slli t0, s7, 2			# idx = 4 * i     		(queremos pular 1 word para cada i)
			add t2, s1, t0			# t2 = idx + NPCS_POSICAO   (pula pra POSICAO[i])
			lh t3, (t2)			# carrega pos X do npc como argumento
			lh t4, 2(t2)			# carrega pos Y do npc como argumento

			beqz a0, P_IM1_MOVER_SUL
			
			li t0, 1
			beq a0, t0, P_IM1_MOVER_LESTE
			
			li t0, 2
			beq a0, t0, P_IM1_MOVER_NORTE
			
			li t0, 3
			beq a0, t0, P_IM1_MOVER_OESTE
			
			j P_IM1_MORRER
			
P_IM1_MOVER_SUL:	# t3 = X; t4 = Y

			# print_literal_ln("AO SUL!")

			addi t4, t4, 1	# y++
			sb x0, (t1)	# direcao = 0 (sul)
			
			j P_IM1_LOOP_1_MOVER_FINAL
			
P_IM1_MOVER_LESTE:	
			addi t3, t3, 1	# x++
			li t0, 1
			sb t0, (t1)	# direcao = 1 (leste)
			
			# print_literal_ln("AO LESTE!")
			
			j P_IM1_LOOP_1_MOVER_FINAL
			
P_IM1_MOVER_NORTE:	

			addi t4, t4, -1	# y--
			li t0, 2
			sb t0, (t1)	# direcao = 2 (norte)
			
			# print_literal_ln("AO NORTE!!")
			
			j P_IM1_LOOP_1_MOVER_FINAL
			
P_IM1_MOVER_OESTE:	
			addi t3, t3, -1	# x--
			li t0, 3
			sb t0, (t1)	# direcao = 3 (oeste)
			
			# print_literal_ln("AO OESTE!")
			
			j P_IM1_LOOP_1_MOVER_FINAL
			
			### transicao pro print
			
P_IM1_MORRER:		li t0, 4
			sb t0, (t1)	# direcao = 4 (morte)
			
P_IM1_LOOP_1_MOVER_FINAL:
		
		
			slli t0, s7, 2			# idx = 4 * i     		(queremos pular 1 word para cada i)
			
			add t0, s1, t0			# idx += NPCS_POSICAO   	(pula pra POSICAO[i])
			sh t3, (t0)			# guarda X
			sh t4, 2(t0)			# guarda Y 
		
			### hora de printar o npc
P_IM1_LOOP_1_PRINT:	
			# temos que calcular qual vai ser a textura do npc
			# vai ser npc-10 * AREA_SPRITE * 5  + AREA_SPRITE * direcao
			# isso eh pq o npc comeca a contar do 10 e cada npc tem 5 quadradinhos na strip :3
			
			
			li t0, 5
			li t2, AREA_SPRITE
			mul t1, t2, t0			# t1 = 5 * AREA_SPRITE
			
			add t0, s7, s0			# idx = i + NPCS (pulamos 1 byte por npc)
			
			lbu t0, (t0)			# carrega o valor desse npc
			addi t0, t0, -10		# subtrai 10
			
			mul t1, t1, t0			# idx = npc-10 * AREA_SPRITE * 5
			
			add a0, t1, s5			# ENDERECO DA TEXTURA A SER IMPRESSA: textura strip + idx
			
			add t1, s2, s7			# idx = i + NPCS_DIRECAO   	(pula pra DIRECAO[i])
			lbu t1, (t1)			# carrega o valor de direcao do npc
			mul t1, t2, t1			# t1 = AREA_SPRITE * direcao
			
			add a0, t1, a0			# ENDERECO DA TEXTURA A SER IMPRESSA += t1
			
			### agora peguemos as posicoes x e y
			slli t0, s7, 2			# idx = 4 * i     		(queremos pular 1 word para cada i)
			add t0, s1, t0			# idx += NPCS_POSICAO   	(pula pra POSICAO[i])
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


P_IM1_LOOP_1_CONT_1:	addi s7, s7, 1		# i++
			blt s7, s3, P_IM1_LOOP_1# se i < qtd de npcs, continuar
			
			
# mds quanta linha hein
# eh ah ia pra vc ahi
# haja dedo pra digitar e cerebro pra debugar mds do ceu
			
PROC_NPCS_MANAGER_FIM:

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
