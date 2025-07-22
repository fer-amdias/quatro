.include "memoria.s"

.data
.include "Texturas/inimigos.data"
.include "Texturas/explosivos.data"
.include "example.data"
.include "Texturas/placeholder.data"
.include "Texturas/jogador.data"
.include "Texturas/pergaminho.data"

MENSAGEM_DEBUG_INICIALIZACAO: .string "Bom dia! Jogo inicializado.\n"
MENSAGEM_DEBUG_INICIO_JOGO: .string "Inicializando jogo.\n"
MENSAGEM_DEBUG_INICIO_LOOP_PRINCIPAL: .string "Inicializando loop principal.\n"
.text

MAIN: 
		
		#### ALOCACAO DO FRAME_BUFFER ####
		li a7, 9
		li a0, 76800
		ecall
		
		sw a0, FRAME_BUFFER_PTR, t0
		
		# adiciona 76800 em a0 usando t0 como temporario
		li t0, 76800
		add a0, a0, t0	
		
		sw a0, FRAME_BUFFER_FIM_PTR, t0
		

		# PROC_PREENCHER_TELA tem dois argumentos: a0 (cor a preencher) e a1 (frame a preencher)

		li a0, 0x00			# preto
		li a1, 0			# frame 0
		jal PROC_PREENCHER_TELA		# preenche a tela de preto
		
		# PROC_IMPRIMIR_FASE tem dois argumentos: 
		#	a0 (endereco do mapa);
		#	a1 (endereco da textura); 
		
		la a0, example
		la a1, placeholder
		jal PROC_IMPRIMIR_FASE
		
		li s0, 1 
		
		### PEGAR LARGURA E ALTURA DO JOGADOR ###
		la t0, jogador
		lw s1, (t0)		
		lw s2, 4(t0)
		
		# corrige a altura do jogador
		li t0, 6
		div s2, s2, t0
		
		# s0 = LARGURA DO JOGADOR
		# s1 = ALTURA DO JOGADOR

LOOP_MENOR:	

		li a0, 0x00			# preto
		li a1, 1
		jal PROC_PREENCHER_TELA		# preenche a tela de preto
						
		jal PROC_IMPRIMIR_BUFFER_DE_FASE
		
		# argumentos de REGISTRAR_MOVIMENTO:
		#	a0: M: modo
		#		M == 0: Modo mover sem checar paredes
		#		M == 1: Modo mover
		#		M == 2: Modo posicionar
		#	a1: T: endereco da textura do jogador
		#	a2: E: endereco do mapa 
		# retorno:
		#	a0: V: se o jogador estah vivo (1 ou 0)
		
		li a0, 1
		la a1, jogador
		la a2, TILEMAP_BUFFER
		jal PROC_REGISTRAR_MOVIMENTO
		
		la a0, inimigos
		jal PROC_INIMIGOS_MANAGER
		
		la a0, explosivos
		la a1, placeholder
		la a2, example
		jal PROC_BOMBA_MANAGER
		
		# PROC_CHECAR_COLISOES				       	     	
		# ARGUMENTOS:						     	
		#	A0 : largura do jogador					
		#	A1 : altura do jogador					
		# RETORNOS:                                                  	
		#       A0 : se o jogador continua vivo				
		#	A1 : o tile em que o jogador atualmente estah		
		
		mv a0, s1
		mv a1, s2
		jal PROC_CHECAR_COLISOES
		
		# se o jogador nao estah vivo
		beqz a0, FIM			# mata o jogador (claro)
		
		li t0, POWERUP_1
		beq a1, t0, mPOWERUP_TAMANHO_BOMBA
		
		li t0, POWERUP_2
		beq a1, t0, mPOWERUP_QTD_BOMBAS
		
		li t0, PERGAMINHO
		beq a1, t0, mPERGAMINHO
		
		li t0, 100
		bge a1, t0, FIM			# jogador esteve na explosao
		
		j LOOP_MENOR_CONT
		
mPOWERUP_TAMANHO_BOMBA:	
		li t0, 1
		sb t0, POWERUP_TAMANHO_BOMBA, t1
		sobrescrever_tile_atual(0, placeholder)	# marca o tile onde tava o powerup como vazio
		j LOOP_MENOR_CONT
mPOWERUP_QTD_BOMBAS:	
		li t0, 1
		sb t0, POWERUP_QTD_BOMBAS, t1
		sobrescrever_tile_atual(0, placeholder)	# marca o tile como vazio
		j LOOP_MENOR_CONT
mPERGAMINHO:	
		#	A0 : endereco da textura de pergaminho			
		#	A1 : endereco do texto do pergaminho			
		#	A2 : endereco da textura do mapa			
		la a0, pergaminho
		la a1, example.scroll
		la a2, placeholder
		jal PROC_MOSTRAR_PERGAMINHO
LOOP_MENOR_CONT:
		
		lb t0, PERGAMINHO_NA_TELA
		beqz t0, LOOP_MENOR_CONT2
		
		la a0, pergaminho
		la a1, example.scroll
		la a2, placeholder
		jal PROC_MOSTRAR_PERGAMINHO
		
		# se o pergaminho estah na tela, devemos continuar a mostra-lo
	
LOOP_MENOR_CONT2:	
		jal PROC_DESENHAR
		
		j LOOP_MENOR
		
		
		# O QUE PRECISA SER COLOCADO AQUI:
		#	 INTRO DO JOGO
		#	 LOOP DO MENU ( E SELECAO DE OPCOES )
		#	 LOOP MAIOR DO JOGO:
# FEITO				IMPRESSAO DO MAPA		
# FEITO				POSICIONAMENTO DE INIMIGOS (UTILIZANDO UM VETOR NA MEMORIA PARA GUARDAR TODOS ELES)
# FEITO				POSICIONAMENTO DO JOGADOR  (UTILIZANDO POSICAO_JOGADOR)
# FEITO				IMPRESSAO DO INIMIGO E DO JOGADOR
		#		LOOP MENOR DO JOGO:
# FEITO				IMPRIMIR BUFFER DE FASE
		#
# FEITO					REGISTRAR MOVIMENTO DE JOGADOR
# FEITO					REIMPRIMIR JOGADOR
		#
# FEITO					REGISTRAR USO DE BOMBAS
# FEITO					CALCULAR TEMPO RESTANTE DE EXPLOSAO
# FEITO					EXPLODIR BOMBAS IMINENTES
# FEITO			IMPLEMENTAR DANO DA EXPLOSAO				
		#
# FEITO					CALCULAR MOVIMENTO DOS INIMIGOS
# FEITO					CALCULAR SE ALGUM INIMIGO TOCOU NO JOGADOR
		#
		#			ATUALIZAR HEADS-UP DISPLAY
		#			MOSTRAR VIDAS RESTANTES, TEMPO RESTANTE, INIMIGOS RESTANTES, BOMBAS DISPONIVEIS, N DO CAPITULO E FASE
		#
		#			TOCAR AUDIO
		#			TOCAR MUSICA
		
		
			
		
FIM:		print (MENSAGEM_DEBUG_INICIALIZACAO)
		quebra_de_linha

		li a7, 10			# syscall pra terminar o programa
		ecall				# estritamente necessario pra impedir que o programa continue ate entrar no codigo dentro dos includes. 
		




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




