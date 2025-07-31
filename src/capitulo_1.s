#################################################################
# ROTINA_CAPITULO_1					       	#
# Mostra as fases do capitulo 1 (Babilonia).			#
# 							     	#
# ARGUMENTOS:						     	#
#	(nenhum)						#
# RETORNOS:                                                  	#
#       (nenhum)                                             	#
#################################################################

.data

.text

CAPITULO_1:
		# int capitulo, int fase, label mapa, int tempo_limite, 
		# label musica, label sfx_powerup, lavel sfx_morte, label sfx_scroll, 
		# label mapa.scroll, bool modo_saida_livre
.macro FASE_C1 (%capitulo, %fase, %arquivo_mapa, %tempo_limite, %musica_de_fundo, %audioefeito_de_powerup, %audioefeito_de_morte, %audioefeito_de_pergaminho, %endereco_pergaminho, %modo_saida_livre)
		addi sp, sp, -4
		sw ra, (sp)
FASE_C1%fase :		
		# se a saida estah coberta por um bloco quebravel ou nao
		li t0, %modo_saida_livre
		sw t0, MODO_SAIDA_LIVRE, t1
		
		lw t0, TRACK1_ATIVO
		lw t1, TRACK1_INICIO_POINTER
		la t2, %musica_de_fundo
		bne t1, t2, TOCAR_MUSICA_C1%fase
		
		bnez t0, PULAR_MUSICA_C1%fase		# deixa a musica tocando

TOCAR_MUSICA_C1%fase : 
		## tocar musica	
		li a0, 1			# modo (adicionar audio)
		la a1, %musica_de_fundo		# a musica escolhida
		li a2, 1			# na track 1
		li a3, 1			# no modo de loop
		jal PROC_TOCAR_AUDIO   

PULAR_MUSICA_C1%fase :
		# imprime a fase :)
		la a0, %arquivo_mapa
		la a1, ch1
		li a2, %tempo_limite		
		jal PROC_IMPRIMIR_FASE
		
		### PEGAR LARGURA E ALTURA DO JOGADOR ###
		la t0, jogador
		lw s1, (t0)		
		lw s2, 4(t0)
		
		# corrige a altura do jogador
		li t0, 6
		div s2, s2, t0
		
		# s1 = LARGURA DO JOGADOR
		# s2 = ALTURA DO JOGADOR

LOOP_C1%fase :	
		li a0, 0x00			# preto
		li a1, 1
		jal PROC_PREENCHER_TELA		# preenche a tela de preto
						
		jal PROC_IMPRIMIR_BUFFER_DE_FASE
		
		li a0, 1			# modo (0 = mover sem checar paredes, 1 = modo mover, 2 = modo posicionar)
		la a1, jogador			# endereco da textura do jogador
		la a2, TILEMAP_BUFFER		# endereco do mapa (nesse caso o buffer mesmo)
		jal PROC_REGISTRAR_MOVIMENTO
		
		la a0, inimigos
		jal PROC_INIMIGOS_MANAGER	
		
		mv a0, s1		# largura do jogador
		mv a1, s2		# altura do jogador
		jal PROC_CHECAR_COLISOES
		
		# se o jogador nao estah vivo
		beqz a0, MORTE_C1%fase			# mata o jogador (claro)
		
		li t0, POWERUP_1
		beq a1, t0, mPOWERUP_TAMANHO_BOMBA_C1%fase
		
		li t0, POWERUP_2
		beq a1, t0, mPOWERUP_QTD_BOMBAS_C1%fase
		
		li t0, PERGAMINHO
		beq a1, t0, mPERGAMINHO_C1%fase
		
		li t0, 100
		bge a1, t0, MORTE_C1%fase		# jogador esteve na explosao
		
		li t0, SAIDA
		beq a1, t0, mSAIDA_C1%fase
		
		li t0, ELEVADORR
		beq a1, t0, mSAIDA_C1%fase
		
		j LOOP_MENOR_CONT_C1%fase
		
mPOWERUP_TAMANHO_BOMBA_C1%fase :	

		li a0, 1			# toca
		la a1, %audioefeito_de_powerup	# o efeito de powerup
		li a2, 2			# no track 2
		li a3, 0			# sem loop
		jal PROC_TOCAR_AUDIO  

		li t0, 1
		sb t0, POWERUP_TAMANHO_BOMBA, t1
		sobrescrever_tile_atual(0, ch1)	# marca o tile onde tava o powerup como vazio
		j LOOP_MENOR_CONT_C1%fase
		
mPOWERUP_QTD_BOMBAS_C1%fase :	
		li a0, 1			# toca
		la a1, %audioefeito_de_powerup	# o efeito de powerup
		li a2, 2			# no track 2
		li a3, 0			# sem loop
		jal PROC_TOCAR_AUDIO  

		li t0, 1
		sb t0, POWERUP_QTD_BOMBAS, t1
		sobrescrever_tile_atual(0, ch1)	# marca o tile como vazio
		j LOOP_MENOR_CONT_C1%fase
		
mSAIDA_C1%fase : 
		lb t0, CONTADOR_INIMIGOS
		bnez t0, LOOP_MENOR_CONT_C1%fase	# se ainda houver inimigos, nao deixa o jogador sair
		j VITORIA_C1%fase			# se nao houver, vence a fase

mPERGAMINHO_C1%fase :	
		lb t0, PERGAMINHO_NA_TELA
		bnez t0, mPERGAMINHO_2_C1%fase
		# toca efeito sonoro de abertura de pergaminho
		li a0, 1
		la a1, %audioefeito_de_pergaminho
		li a2, 2
		li a3, 0
		jal PROC_TOCAR_AUDIO  
mPERGAMINHO_2_C1%fase :	
		#	A0 : endereco da textura de pergaminho			
		#	A1 : endereco do texto do pergaminho			
		#	A2 : endereco da textura do mapa			
		la a0, pergaminho_ch1
		la a1, %endereco_pergaminho
		la a2, ch1
		jal PROC_MOSTRAR_PERGAMINHO
LOOP_MENOR_CONT_C1%fase :
		
		lb t0, PERGAMINHO_NA_TELA
		beqz t0, LOOP_MENOR_CONT3_C1%fase
		
		la a0, pergaminho_ch1
		la a1, %endereco_pergaminho
		la a2, ch1
		jal PROC_MOSTRAR_PERGAMINHO
		
		
		# se o pergaminho estah na tela, devemos continuar a mostra-lo
		
		j LOOP_MENOR_CONT3_C1%fase

LOOP_MENOR_CONT3_C1%fase :	

		lw t0, SEGUNDOS_RESTANTE_Q10
		li t1, %tempo_limite
		bltz t1, LOOP_MENOR_CONT4_C1%fase	# se nao houver limite de tempo, nao checa ele
		
		bltz t0, MORTE_C1%fase		# se houver, mata o jogador se ele chegar a 0 segundos

LOOP_MENOR_CONT4_C1%fase :
		la a0, explosivos
		la a1, ch1
		la a2, %arquivo_mapa
		jal PROC_BOMBA_MANAGER

		li a0, 1			# capitulo 1
		li a1, %fase
		li a2, 0xC7FF
		jal PROC_IMPRIMIR_HUD

		jal PROC_DESENHAR
		
		li a0, 0			# soh toca o audio mesmo
		jal PROC_TOCAR_AUDIO
		
		j LOOP_C1%fase				# repete o game loop	
MORTE_C1%fase :		
		jal PROC_DESENHAR	

		li a0, 1			# modo tocar
		la a1, %audioefeito_de_morte
		li a2, 1		# track 1 pra sobrescrever a musica
		li a3, 0		# sem loop
		jal PROC_TOCAR_AUDIO 
		
		csrr t0, time
		sw t0, MORTE_TIMESTAMP, t1	# salva a timestamp da morte
MORTE_LOOP_C1%fase :	
		mv a0, zero			# modo continuar tocando
		jal PROC_TOCAR_AUDIO 
		
		csrr t0, time
		li t1, -5000
		add t0, t0, t1			# subtrai 5 segundos do tempo atual
		
		lw t1, MORTE_TIMESTAMP
		blt t0, t1, MORTE_LOOP_C1%fase		# espera passar 5 segundos para continuar
		
		lb t0, VIDAS_RESTANTES
		beqz t0, DERROTA_C1%fase
		addi t0, t0, -2 		# atualiza as vidas restantes (-2 pra compensar com o +1 da fase)
		sb t0, VIDAS_RESTANTES, t1
		
		j FASE_C1%fase
DERROTA_C1%fase :
		li a0, 0
		j FIM_C1%fase
		
VITORIA_C1%fase :
		li a0, 1
FIM_C1%fase : 
		lw ra, (sp)
		addi sp, sp, 4
.end_macro

.text

# PREFIXO_INTERNO: C1_
ROTINA_CAPITULO_1:
		addi sp, sp, -4
		sw ra, (sp)
		
		li t0, 1
		sw t0, VIDAS_RESTANTES, t1
		#############
		
		jal C1_FASE1
		beqz a0, C1_FIM
		
		jal C1_FASE2	
		beqz a0, C1_FIM
		
		jal C1_FASE3
		beqz a0, C1_FIM
		
		jal C1_FASE4
		beqz a0, C1_FIM
		
		jal C1_FASE5
		beqz a0, C1_FIM
		
		j C1_FIM
		

C1_FASE1:
		# int capitulo, int fase, label mapa, int tempo_limite, 
		# label musica, label sfx_powerup, lavel sfx_morte, label sfx_scroll, 
		# label mapa.scroll,bool modo_saida_livre
		FASE_C1 (1, 1, ch1_fase1, 70, west__hurrian_song, powerup_ch3, morte_ch3, abertura_scroll_ch3, ch1_fase1.scroll, 0)
		ret
		
C1_FASE2:	FASE_C1 (1, 2, ch1_fase2, 80, west__hurrian_song, powerup_ch3, morte_ch3, abertura_scroll_ch3, ch1_fase2.scroll, 0)
		ret
		
C1_FASE3:	FASE_C1 (1, 3, ch1_fase3, 100, west__hurrian_song, powerup_ch3, morte_ch3, abertura_scroll_ch3, ch1_fase3.scroll, 0)
		ret
		
C1_FASE4:
		FASE_C1 (1, 4, ch1_fase4, 80, west__hurrian_song, powerup_ch3, morte_ch3, abertura_scroll_ch3, ch1_fase4.scroll, 0)
		ret

C1_FASE5:
		FASE_C1 (1, 5, ch1_fase5, -1, west__hurrian_song, powerup_ch3, morte_ch3, abertura_scroll_ch3, ch1_fase5.scroll, 0)
		ret
		
		
C1_FIM:		lw ra, (sp)
		addi sp, sp, 4
		ret
	


		