#################################################################
# ROTINA_CAPITULO_0 					       	#
# Mostra as fases do capitulo 0 (tutorial).			#
# 							     	#
# ARGUMENTOS:						     	#
#	(nenhum)						#
# RETORNOS:                                                  	#
#       (nenhum)                                             	#
#################################################################
.include "memoria.s"

.data
.include "../assets/texturas/ch0.data"
.include "../assets/fases/ch0_fase1.data"
.include "../assets/fases/ch0_fase2.data"
.include "../assets/fases/ch0_fase3.data"
.include "../assets/fases/ch0_fase4.data"
.include "../assets/fases/ch0_fase5.data"
.include "../assets/fases/ch0_fase6.data"
.include "../assets/fases/ch0_fase7.data"
.include "../assets/fases/ch0_fase8.data"
.include "../assets/texturas/inimigos.data"
.include "../assets/texturas/explosivos.data"
.include "../assets/fases/example.data"
.include "../assets/texturas/placeholder.data"
.include "../assets/texturas/jogador.data"
.include "../assets/texturas/pergaminho.data"
.include "../assets/musicas/internationale.data"
.include "../assets/audioefeitos/morte.data"
.include "../assets/audioefeitos/powerup.data"
.include "../assets/audioefeitos/abertura_pergaminho.data"

PERGAMINHO_NO_INICIO: .word 0
MODO_SAIDA_LIVRE:     .word 0

CAPITULO_0:
		# int fase, label mapa, int tempo_limite, 
		# label musica, label sfx_powerup, lavel sfx_morte, label sfx_scroll, 
		# label mapa.scroll, bool mostrar_scroll_no_inicio, bool modo_saida_livre
.macro FASE_C0 (%fase, %arquivo_mapa, %tempo_limite, %musica_de_fundo, %audioefeito_de_powerup, %audioefeito_de_morte, %audioefeito_de_pergaminho, %endereco_pergaminho, %mostrar_pergaminho_no_inicio, %modo_saida_livre)
		addi sp, sp, -4
		sw ra, (sp)
FASE%fase :		
		# se a saida estah coberta por um bloco quebravel ou nao
		li t0, %modo_saida_livre
		sw t0, MODO_SAIDA_LIVRE, t1
		
		li t0, %mostrar_pergaminho_no_inicio
		sw t0, PERGAMINHO_NO_INICIO, t1

		lw t0, TRACK1_ATIVO
		lw t1, TRACK1_INICIO_POINTER
		la t2, %musica_de_fundo
		bne t1, t2, TOCAR_MUSICA%fase
		
		bnez t0, PULAR_MUSICA%fase		# deixa a musica tocando

TOCAR_MUSICA%fase : 
		## tocar musica	
		li a0, 1			# modo (adicionar audio)
		la a1, %musica_de_fundo		# a musica escolhida
		li a2, 1			# na track 1
		li a3, 1			# no modo de loop
		jal PROC_TOCAR_AUDIO   

PULAR_MUSICA%fase :
		# imprime a fase :)
		la a0, %arquivo_mapa
		la a1, ch0
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

LOOP%fase :	
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
		beqz a0, MORTE%fase			# mata o jogador (claro)
		
		li t0, POWERUP_1
		beq a1, t0, mPOWERUP_TAMANHO_BOMBA%fase
		
		li t0, POWERUP_2
		beq a1, t0, mPOWERUP_QTD_BOMBAS%fase
		
		li t0, PERGAMINHO
		beq a1, t0, mPERGAMINHO%fase
		
		li t0, 100
		bge a1, t0, MORTE%fase		# jogador esteve na explosao
		
		lw t0, PERGAMINHO_NO_INICIO
		bnez t0, TUTORIAL_DISPLAY%fase	# se pergaminho_no_inicio = 1, mostra o pergaminho
		
		li t0, SAIDA
		beq a1, t0, mSAIDA%fase
		
		j LOOP_MENOR_CONT%fase
		
mPOWERUP_TAMANHO_BOMBA%fase :	

		li a0, 1			# toca
		la a1, %audioefeito_de_powerup	# o efeito de powerup
		li a2, 2			# no track 2
		li a3, 0			# sem loop
		jal PROC_TOCAR_AUDIO  

		li t0, 1
		sb t0, POWERUP_TAMANHO_BOMBA, t1
		sobrescrever_tile_atual(0, ch0)	# marca o tile onde tava o powerup como vazio
		j LOOP_MENOR_CONT%fase
		
mPOWERUP_QTD_BOMBAS%fase :	
		li a0, 1			# toca
		la a1, %audioefeito_de_powerup	# o efeito de powerup
		li a2, 2			# no track 2
		li a3, 0			# sem loop
		jal PROC_TOCAR_AUDIO  

		li t0, 1
		sb t0, POWERUP_QTD_BOMBAS, t1
		sobrescrever_tile_atual(0, ch0)	# marca o tile como vazio
		j LOOP_MENOR_CONT%fase
		
mSAIDA%fase : 
		lb t0, CONTADOR_INIMIGOS
		bnez t0, LOOP_MENOR_CONT%fase	# se ainda houver inimigos, nao deixa o jogador sair
		j VITORIA%fase			# se nao houver, vence a fase

mPERGAMINHO%fase :	
		lb t0, PERGAMINHO_NA_TELA
		bnez t0, mPERGAMINHO_2%fase
		# toca efeito sonoro de abertura de pergaminho
		li a0, 1
		la a1, %audioefeito_de_pergaminho
		li a2, 2
		li a3, 0
		jal PROC_TOCAR_AUDIO  
mPERGAMINHO_2%fase :	
		#	A0 : endereco da textura de pergaminho			
		#	A1 : endereco do texto do pergaminho			
		#	A2 : endereco da textura do mapa			
		la a0, pergaminho
		la a1, %endereco_pergaminho
		la a2, ch0
		jal PROC_MOSTRAR_PERGAMINHO
LOOP_MENOR_CONT%fase :
		
		lb t0, PERGAMINHO_NA_TELA
		beqz t0, LOOP_MENOR_CONT3%fase
		
		la a0, pergaminho
		la a1, %endereco_pergaminho
		la a2, ch0
		jal PROC_MOSTRAR_PERGAMINHO
		
		
		# se o pergaminho estah na tela, devemos continuar a mostra-lo
		
		j LOOP_MENOR_CONT3%fase
TUTORIAL_DISPLAY%fase :
		la a0, pergaminho
		la a1, %endereco_pergaminho
		la a2, ch0
		jal PROC_MOSTRAR_PERGAMINHO
		
		lb t0, PERGAMINHO_NA_TELA
		bnez t0, LOOP_MENOR_CONT3%fase
LOOP_MENOR_CONT2%fase :
		sw zero, PERGAMINHO_NO_INICIO, t0		# desativa o pergaminho na tela
		sobrescrever_tile_atual(2, ch0)	# desfaz a destruicao do tile atual pelo proc mostrar_pergaminho
LOOP_MENOR_CONT3%fase :	

		lw t0, SEGUNDOS_RESTANTE_Q10
		li t1, %tempo_limite
		bltz t1, LOOP_MENOR_CONT4%fase	# se nao houver limite de tempo, nao checa ele
		
		bltz t0, MORTE%fase		# se houver, mata o jogador se ele chegar a 0 segundos

LOOP_MENOR_CONT4%fase :
		la a0, explosivos
		la a1, ch0
		la a2, %arquivo_mapa
		jal PROC_BOMBA_MANAGER

		li a0, 0			# capitulo 0
		li a1, %fase
		li a2, 0xC7FF
		jal PROC_IMPRIMIR_HUD

		jal PROC_DESENHAR
		
		li a0, 0			# soh toca o audio mesmo
		jal PROC_TOCAR_AUDIO
		
		j LOOP%fase				# repete o game loop	
MORTE%fase :		
		jal PROC_DESENHAR	

		li a0, 1			# modo tocar
		la a1, %audioefeito_de_morte
		li a2, 1		# track 1 pra sobrescrever a musica
		li a3, 0		# sem loop
		jal PROC_TOCAR_AUDIO 
		
		csrr t0, time
		sw t0, MORTE_TIMESTAMP, t1	# salva a timestamp da morte
MORTE_LOOP%fase :	
		mv a0, zero			# modo continuar tocando
		jal PROC_TOCAR_AUDIO 
		
		csrr t0, time
		li t1, -5000
		add t0, t0, t1			# subtrai 5 segundos do tempo atual
		
		lw t1, MORTE_TIMESTAMP
		blt t0, t1, MORTE_LOOP%fase		# espera passar 5 segundos para continuar
		
		lb t0, VIDAS_RESTANTES
		beqz t0, DERROTA%fase
		addi t0, t0, -2 		# atualiza as vidas restantes (-2 pra compensar com o +1 da fase)
		sb t0, VIDAS_RESTANTES, t1
		
		j FASE%fase
VITORIA%fase :
		li a0, 1
		j FIM
DERROTA%fase :	
		li a0, 0
FIM: 
		lw ra, (sp)
		addi sp, sp, 4
.end_macro

.text

# PREFIXO_INTERNO: C0_
ROTINA_CAPITULO_0:
		addi sp, sp, -4
		sw ra, (sp)
		
		#### ALOCACAO DO FRAME_BUFFER ####
		li a7, 9
		li a0, 76800
		ecall
		
		sw a0, FRAME_BUFFER_PTR, t0
		
		# adiciona 76800 em a0 usando t0 como temporario
		li t0, 76800
		add a0, a0, t0	
		
		sw a0, FRAME_BUFFER_FIM_PTR, t0
		
		#############
		
		jal C0_FASE1
		beqz a0, C0_FIM
		
		jal C0_FASE2	
		beqz a0, C0_FIM
		
		jal C0_FASE3
		beqz a0, C0_FIM
		
		jal C0_FASE4
		beqz a0, C0_FIM
		
		jal C0_FASE5
		beqz a0, C0_FIM
		
		jal C0_FASE6
		beqz a0, C0_FIM
		
		jal C0_FASE7
		beqz a0, C0_FIM
		
		jal C0_FASE8
		beqz a0, C0_FIM
		
		j C0_FIM
		

C0_FASE1:
		# int fase, label mapa, int tempo_limite, 
		# label musica, label sfx_powerup, lavel sfx_morte, label sfx_scroll, 
		# label mapa.scroll, bool mostrar_scroll_no_inicio, bool modo_saida_livre
		FASE_C0 (1, ch0_fase1, -1, internationale, powerup, morte, abertura_pergaminho, ch0_fase1.scroll, 1, 1)
		ret
		
C0_FASE2:	FASE_C0 (2, ch0_fase2, -1, internationale, powerup, morte, abertura_pergaminho, ch0_fase2.scroll, 1, 1)
		ret
		
C0_FASE3:	FASE_C0 (3, ch0_fase3, -1, internationale, powerup, morte, abertura_pergaminho, ch0_fase3.scroll, 1, 1)
		ret
		
C0_FASE4:
		FASE_C0 (4, ch0_fase4, -1, internationale, powerup, morte, abertura_pergaminho, ch0_fase4.scroll, 1, 1)
		ret

C0_FASE5:
		FASE_C0 (5, ch0_fase5, -1, internationale, powerup, morte, abertura_pergaminho, ch0_fase5.scroll, 0, 0)
		ret

C0_FASE6:

		FASE_C0 (6, ch0_fase6, 100, internationale, powerup, morte, abertura_pergaminho, ch0_fase6.scroll, 0, 0)
		ret

C0_FASE7:

		FASE_C0 (7, ch0_fase7, 100, internationale, powerup, morte, abertura_pergaminho, ch0_fase7.scroll, 0, 0)
		ret

C0_FASE8:
		
		FASE_C0 (8, ch0_fase8, -1, internationale, powerup, morte, abertura_pergaminho, ch0_fase8.scroll, 0, 0)
		ret
		
		
C0_FIM:		lw ra, (sp)
		addi sp, sp, 4
		fim

##############################################################
# Include de prodcedimentos feito no final do codigo, pois   #
# Colocar no topo vai fazer os procedimentos serem chamados  #
# ANTES do nosso codigo que queremos executar                #
##############################################################
.include "imprimir_fase.s"
.include "preencher_tela.s"
.include "imprimir_textura.s" 
.include "calcular_tile_atual.s"
.include "mover_jogador.s"
.include "imprimir_buffer_de_fase.s"
.include "registrar_movimento.s"
.include "desenhar.s"
.include "colocar_bomba.s"
.include "bomba_manager.s"
.include "inimigos_manager.s"
.include "manipular_tilemap.s" 
.include "checar_colisoes.s" 
.include "imprimir_string.s"
.include "mostrar_pergaminho.s"
.include "tocar_audio.s"
.include "imprimir_inteiro.s"
.include "imprimir_hud.s"

		