#################################################################
# PROC_CHECAR_COLISOES				       	     	#
# Checa colisoes com npcs e powerups.				#
# 							     	#
# ARGUMENTOS:						     	#
#	(sem argumentos)					#
# RETORNOS:                                                  	#
#       A0 : se o jogador continua vivo				#
#	A1 : o tile em que o jogador atualmente estah		#
#################################################################

# prefixo interno: P_CC1_

.data 

.text
PROC_CHECAR_COLISOES:
			addi sp, sp, -4
			sw ra, (sp)
			
			li a0, 1			# assume-se de partida que o jogador estah vivo (1)
			
			mv t3, zero			# i = 0
			lw t4, NPCS_QUANTIDADE	# i > qtd de npcs
			
P_CC1_LOOP_NPCS:	##### for (int i = 0; i < qtd_de_npcs; i++)

			bge t3, t4, P_CC1_break		# checa se devemos sair do loop

			# temos que guardar: 
			.eqv jogador_x 		t1
			.eqv jogador_y 		t2
			.eqv npc_x 		t5
			.eqv npc_y 		t6
			.eqv jogador_largura 	a1
			.eqv jogador_altura  	a2
			.eqv tipo_npc		a3
			.eqv direcao_npc	a4

			.eqv npc_hitbox_x1	a3
			.eqv npc_hitbox_x2	a4
			.eqv npc_hitbox_y1	a5
			.eqv npc_hitbox_y2	a6

			la t0, NPCS_DIRECAO
			add t0, t3, t0			# pega npcs.direcao[i]
			
			lbu direcao_npc, (t0)		# carrega a direcao do npc
			addi t0, direcao_npc, -4	# pega npcs.posicao[i] - 4
			beqz t0, P_CC1_continue		# se npcs.posicao[i] == 4: continue; (pula esse npc)


			# agora temos que saber se o npc eh inimigo!
			la t0, STRUCTS_NPCS
			li t1, NPC_STRUCT_TAMANHO    # pega o tamanho de uma struct
			la t2, NPCS

			add t2, t3, t2			# idx = i + NPCS (pulamos 1 byte por npc)
			lbu tipo_npc, (t2)			# carrega o valor desse npc

			# t2 = tipo de npc (tipo 1 = 0, tipo 2 = 1, ...)
			# t1 = tipo de npc * tamanho struct (pega quantas structs devemos avancar)
			mul t1, t1, tipo_npc 
			add t0, t0, t1		# avanca pra struct certa
			lbu t0, NPC_STRUCT_ATRIBUTO_INIMIGO(t0)

			beqz t0, P_CC1_continue

			# agora sabemos que o npc estah vivo
			slli t0, t3, 2			# t0 = 4 * i 				( cada npc tem duas halfwords de posicao )
			la t5, NPCS_POSICAO		# carrega a posicao dos npcs 
			add t0, t0, t5			# pega npcs.posicao[i] 
			
			# carrega a posicao do npc
			# t5 = x_npc
			# t6 = y_npc
			lh npc_x, (t0)
			lh npc_y, 2(t0)
			
			# carrega a posicao do jogador
			# t1 = x do jogador
			# t2 = y do jogador
			la t0, POSICAO_JOGADOR
			lh jogador_x, (t0)
			lh jogador_y, 2(t0)
			
			# carrega a altura e largura do jogador
			lw jogador_altura, ALTURA_JOGADOR
			lw jogador_largura, LARGURA_JOGADOR
			
			# vamos checar se a caixa de colisao do jogador e a caixa de colisao do npc estao se sobrepondo, utilizando AABB (como no pseudocodigo abaixo)
			# if (jogador.x <= npc.hitbox.x2 &&
			#     jogador.x + jogador.largura => npc.hitbox.x1 &&
			#     jogador.y <= npc.hitbox.y2 &&
			#     jogador.y + jogador.altura => npc.hitbox.y1)
			# {
			#     HOUVE COLISAO
			# }
			# podemos ao contrario checar se qualquer uma das condicoes falhou. Ao falhar de qualquer, damos um continue;.
			



			# temos que recuperar:
			# - o tipo de inimigo
			# - a direcao que ele esta indo
			# para podermos pegar as dimensoes corretas das hitboxes

			li t0, STRUCT_HITBOX_TAMANHO
			mul t0, t0, tipo_npc		# pega a struct referente ao npc

			li a5, STRUCT_HITBOX_FRAME_TAMANHO	# pega o tamanho de um frame
			mul a5, direcao_npc, a5			# pega o frame referente
			add t0, t0, a5				# avanca ate o frame escolhido

			la a6, STRUCT_HITBOX_NPCS
			add t0, a6, t0			# vai ate a posicao que escolhemos

			lb npc_hitbox_x1, (t0)		# x1
			add npc_hitbox_x1, npc_hitbox_x1, npc_x # coordenada absoluta de x1
			addi t0, t0, 1			# avanca pro proximo

			lb npc_hitbox_y1, (t0)		# y1
			add npc_hitbox_y1, npc_hitbox_y1, npc_y # coordenada absoluta de y1
			addi t0, t0, 1			# avanca pro proximo

			lb npc_hitbox_x2, (t0)		# x2
			add npc_hitbox_x2, npc_hitbox_x2, npc_x # coordenada absoluta de x2
			addi t0, t0, 1			# avanca pro proximo

			lb npc_hitbox_y2, (t0)		# y2
			add npc_hitbox_y2, npc_hitbox_y2, npc_y # coordenada absoluta de y2


			# if not (jogador.x <= npc.hitbox.x2) NAO HOUVE COLSIAO
			bgt jogador_x, npc_hitbox_x2, P_CC1_continue
			
			# if not (jogador.x + jogador.largura => npc.hitbox.x1) NAO HOUVE COLISAO
			add t0, jogador_x, jogador_largura
			slt t0, t0, npc_hitbox_x1
			bnez t0, P_CC1_continue
			
			# if not (jogador.y <= npc.hitbox.y2) NAO HOUVE COLISAO
			bgt jogador_y, npc_hitbox_y2, P_CC1_continue
			
			# if not (jogador.y + jogador.altura => npc.hitbox.y1) NAO HOUVE COLISAO
			add t0, jogador_y, jogador_altura
			slt t0, t0, npc_hitbox_y1
			bnez t0, P_CC1_continue
			
			# se chegamos aqui, entao nenhuma condicao falhou
			# logo, houve colisao
			
			# marca que morreu e sai do loop
			li a0, 0
			j P_CC1_break

P_CC1_continue:	
			addi t3, t3, 1			# i++
			j P_CC1_LOOP_NPCS		# continua o loop;
			
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
			lw t0, ALTURA_JOGADOR
			srli t0, t0, 1		# divide por 2
			lw t1, LARGURA_JOGADOR
			srli t1, t1, 1		# divide por 2	
			addi t1, t1, -1		# fator corretivo
			add a1, a1, t1		# centraliza
			add a2, a2, t0		# centraliza
			jal PROC_CALCULAR_TILE_ATUAL
			
			# prepara os argumentos de retorno
			mv a1, a0			# coloca o tile atual em a1
			
			lw a0, (sp)			# recarrega se o jogador estah vivo ou nao em a0
			addi sp, sp, 4
		
			
P_CC1_FIM:		lw ra, (sp)
			addi sp, sp, 4
			ret				# yippee			
