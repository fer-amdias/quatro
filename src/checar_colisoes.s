#################################################################
# PROC_CHECAR_COLISOES				       	     	#
# Checa colisoes com inimigos e powerups.			#
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : largura do jogador					#
#	A1 : altura do jogador					#
# RETORNOS:                                                  	#
#       A0 : se o jogador continua vivo				#
#	A1 : o tile em que o jogador atualmente estah		#
#################################################################

# prefixo interno: P_CC1_

.data 

       ###### MACRO_CHECAR_COLISAO ######
       # cx = x do canto		#
       # cy = y do canto		#
       # ix = x do inimigo		#
       # iy = y do inimigo		#
       # out = se teve colisao		#
       #				#
       # checa se o canto do jogador	#
       # estah em colisao		#
       ##################################
       
             
 # honestamente estou impressionado com a economia de registradores aqui
.macro checar_colisao_canto(%cx, %cy, %ix, %iy, %out)
	slt %out, %cx, %ix				# %out = x_canto < x_inimigo	
	bnez %out, MCC_SEM_COLISAO 			# se %out != 0, nao hah chance de colisao aqui.

	addi %out, %ix, TAMANHO_SPRITE			# %out = x_inimigo + TAMANHO_SPRITE
	slt %out, %out, %cx				# %out = x_canto > (x_inimigo + TAMANHO_SPRITE)
	
	bnez %out, MCC_SEM_COLISAO	 		# se %out != 0, nao hah chance de colisao aqui.
	
	# se chegamos ateh aqui, os X do inimigo e do canto bateram. temos que checar o Y agora.

	slt %out, %cy, %iy				# %out = y_canto < y_inimigo
	
	bnez %out, MCC_SEM_COLISAO 			# se %out != 0, nao hah chance de colisao aqui.
	
	addi %out, %iy, TAMANHO_SPRITE			# %out = y_inimigo + TAMANHO_SPRITE
	slt %out, %out, %cy				# %out = y_canto > (y_inimigo + TAMANHO_SPRITE)
	
	bnez %out, MCC_SEM_COLISAO			 # se %out != 0, nao hah chance de colisao aqui.
	
	# se chegamos aqui, houve colisao
	li %out, 1
	j MCC_FIM
	
	MCC_SEM_COLISAO: # retornar 0
	li %out, 0
	
	MCC_FIM:
.end_macro

.text
PROC_CHECAR_COLISOES:
			addi sp, sp, -4
			sw ra, (sp)

			
			
			# reorganiza os argumentos
			# a1 = LARGURA_JOGADOR
			# a2 = ALTURA_JOGADOR
			mv a2, a1
			mv a1, a0
			
			li a0, 1			# assume-se de partida que o jogador estah vivo (1)
			
			mv t3, zero			# i = 0
			lw t4, INIMIGOS_QUANTIDADE	# i > qtd de inimigos
			
P_CC1_LOOP_INIMIGOS:	##### for (int i = 0; i < qtd_de_inimigos; i++)

			la t0, INIMIGOS_DIRECAO
			add t0, t3, t0			# pega inimigos.direcao[i]
			
			lbu t0, (t0)			# carrega a direcao do inimigo
			addi t0, t0, -4			# diminui 4
			beqz t0, P_CC1_continue		# se inimigos.posicao[i] == 4: continue; (pula esse inimigo)

			# agora sabemos que o inimigo estah vivo
			slli t0, t3, 2			# t0 = 4 * i 				( cada inimigo tem duas halfwords de posicao )
			la t5, INIMIGOS_POSICAO		# carrega a posicao dos inimigos 
			add t0, t0, t5			# pega inimigos.posicao[i] 
			
			# t5 = x_inimigo
			# t6 = y_inimigo
			lh t5, (t0)
			lh t6, 2(t0)
			
			
			# vamos checar em quais cantos do jogador houve colisao
			# t1 = x do canto
			# t2 = y do canto
			# t5 = x do inimigo
			# t6 = y do inimigo
			# a1 = largura do jogador
			# a2 = altura do jogador
			
			# carrega a posicao do jogador
			la t0, POSICAO_JOGADOR
			lh t1, (t0)
			lh t2, 2(t0)

P_CC1_CANTO_SUPERIOR_ESQUERDO:

			checar_colisao_canto(t1, t2, t5, t6, t0)
			beqz t0, P_CC1_CANTO_SUPERIOR_DIREITO
			# se t0 for 1, houve colisao
			li a0, 0			# marca que morreu
			j P_CC1_break			# sai do loop

P_CC1_CANTO_SUPERIOR_DIREITO:
			
			add t1, t1, a1			# vai pra direita
			checar_colisao_canto(t1, t2, t5, t6, t0)
			beqz t0, P_CC1_CANTO_INFERIOR_DIREITO
			# se t0 for 1, houve colisao
			li a0, 0			# marca que morreu
			j P_CC1_break			# sai do loop

P_CC1_CANTO_INFERIOR_DIREITO:

			add t2, t2, a2			# vai pra baixo
			checar_colisao_canto(t1, t2, t5, t6, t0)
			beqz t0, P_CC1_CANTO_INFERIOR_ESQUERDO
			# se t0 for 1, houve colisao
			li a0, 0			# marca que morreu
			j P_CC1_break			# sai do loop

P_CC1_CANTO_INFERIOR_ESQUERDO:

			sub t1, t1, a1			# vai pra esquerda
			checar_colisao_canto(t1, t2, t5, t6, t0)
			beqz t0, P_CC1_continue		# termina as checagens para esse inimigo
			# se t0 for 1, houve colisao
			li a0, 0			# marca que morreu
			j P_CC1_break			# sai do loop

P_CC1_continue:	
P_CC1_LOOP_CONT:	addi t3, t3, 1			# i++
			blt t3, t4, P_CC1_LOOP_INIMIGOS	# if (i <= qtd_de_inimigos) break;
			
P_CC1_break:		##### fim do loop
			
			addi sp, sp, -4
			sw a0, (sp)			# salva se o jogador continua vivo ou nao
			
			
			# PROC_CALCULAR_TILE_ATUAL			             
			# Calcula o tile atual de uma coordenada X e Y e retorna a   
			# informacao, linha, coluna, x e y.			     
			# 							     
			# ARGUMENTOS:						     
			#	A0 : ENDERECO DO MAPA (.data)			    
			# 	A1 : POSICAO X                                       
			#       A2 : POSICAO Y                                       
			# RETORNOS INTERESSANTES:                                                  
			#       A0 : INFORMACAO DO TILE ATUAL (0-255)	
			
			la a0, TILEMAP_BUFFER
			la t0, POSICAO_JOGADOR
			lh a1, (t0)
			lh a2, 2(t0)
			jal PROC_CALCULAR_TILE_ATUAL
			
			# prepara os argumentos de retorno
			mv a1, a0			# coloca o tile atual em a1
			lw a0, (sp)			# recarrega se o jogador estah vivo ou nao em a0
			addi sp, sp, 4
		
			
P_CC1_FIM:		lw ra, (sp)
			addi sp, sp, 4
			ret				# yippee			
