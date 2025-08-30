#################################################################
# PROC_CHECAR_COLISOES				       	     	#
# Checa colisoes com inimigos e powerups.			#
# 							     	#
# ARGUMENTOS:						     	#
#	(sem argumentos)					#
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

.text
PROC_CHECAR_COLISOES:
			addi sp, sp, -4
			sw ra, (sp)
			
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
			
			# carrega a posicao do inimigo
			# t5 = x_inimigo
			# t6 = y_inimigo
			lh t5, (t0)
			lh t6, 2(t0)
			
			# carrega a posicao do jogador
			# t1 = x do jogador
			# t2 = y do jogador
			la t0, POSICAO_JOGADOR
			lh t1, (t0)
			lh t2, 2(t0)
			
			# carrega a altura e largura do jogador
			lw a1, ALTURA_JOGADOR
			lw a2, LARGURA_JOGADOR
			
			# vamos checar se a caixa de colisao do jogador e a caixa de colisao do inimigo estao se sobrepondo, utilizando AABB (como no pseudocodigo abaixo)
			# if (jogador.x < inimigo.x + inimigo.largura &&
			#     jogador.x + jogador.largura > inimigo.x &&
			#     jogador.y < inimigo.y + inimigo.altura &&
			#     jogador.y + jogador.altura > inimigo.y)
			# {
			#     HOUVE COLISAO
			# }
			# podemos ao contrario checar se qualquer uma das condicoes falhou. Ao falhar de qualquer, damos um continue;.
			
			# temos que guardar: 
			.eqv jogador_x 		t1
			.eqv jogador_y 		t2
			.eqv inimigo_x 		t5
			.eqv inimigo_y 		t6
#			.eqv inimigo_largura 	TAMANHO_SPRITE	  (nao funciona no FPGRARS)
#			.eqv inimigo_altura 	TAMANHO_SPRITE    (nao funciona no FPGRARS)  
			.eqv jogador_largura 	a1
			.eqv jogador_altura  	a2
			
			# if not (jogador.x < inimigo.x + inimigo.largura) NAO HOUVE COLSIAO
			addi t0, inimigo_x, TAMANHO_SPRITE
			slt t0, jogador_x, t0
			beqz t0, P_CC1_continue
			
			# if not (jogador.x + jogador.largura > inimigo.x) NAO HOUVE COLISAO
			add t0, jogador_x, jogador_largura
			slt t0, inimigo_x, t0
			beqz t0, P_CC1_continue
			
			# if not (jogador.y < inimigo.y + inimigo.altura) NAO HOUVE COLISAO
			addi t0, inimigo_y, TAMANHO_SPRITE
			slt t0, jogador_y, t0
			beqz t0, P_CC1_continue
			
			# if not (jogador.y + jogador.altura > inimigo.y) NAO HOUVE COLISAO
			add t0, jogador_y, jogador_altura
			slt t0, inimigo_y, t0
			beqz t0, P_CC1_continue
			
			# se chegamos aqui, entao nenhuma condicao falhou
			# logo, houve colisao
			
			# marca que morreu e sai do loop
			li a0, 0
			j P_CC1_break

P_CC1_continue:	
			addi t3, t3, 1			# i++
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
