.data

.include ".\memoria.asm"
.include "..\example.data"
.include "..\Texturas\placeholder.data"
.include "..\Texturas\jogador.data"

MENSAGEM_DEBUG_INICIALIZACAO: .string "Bom dia! Jogo inicializado.\n"
MENSAGEM_DEBUG_INICIO_JOGO: .string "Inicializando jogo.\n"
MENSAGEM_DEBUG_INICIO_LOOP_PRINCIPAL: .string "Inicializando loop principal.\n"

.text

MAIN: 

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
		

LOOP_MENOR:	
		# argumentos de REGISTRAR_MOVIMENTO:
		#	a0: M: modo
		#		M == 0: Modo mover sem checar paredes nem inimigos
		#		M == 1: Modo mover sem checar inimigos
		#		M == 2: Modo mover
		#		M == 3: modo posicionar
		#	a1: T: endereco da textura do jogador
		#	a2: E: endereco do mapa 
		#	a3: t: endereco da textura do mapa
		# retorno:
		#	a0: V: se o jogador estah vivo (1 ou 0)
						
		jal PROC_IMPRIMIR_BUFFER
		li a0, 0
		la a1, jogador
		la a2, example
		la a3, placeholder
		
		jal PROC_REGISTRAR_MOVIMENTO
		
		j LOOP_MENOR
		
		
		# O QUE PRECISA SER COLOCADO AQUI:
		#	 INTRO DO JOGO
		#	 LOOP DO MENU ( E SELECAO DE OPCOES )
		#	 LOOP MAIOR DO JOGO:
# FEITO				IMPRESSAO DO MAPA		
# FEITO				POSICIONAMENTO DE INIMIGOS (UTILIZANDO UM VETOR NA MEMORIA PARA GUARDAR TODOS ELES)
# FEITO				POSICIONAMENTO DO JOGADOR  (UTILIZANDO POSICAO_JOGADOR)
		#		IMPRESSAO DO INIMIGO E DO JOGADOR
		#		LOOP MENOR DO JOGO:
# FEITO				IMPRIMIR BUFFER DE FASE
		#
		#			REGISTRAR MOVIMENTO DE JOGADOR
		#			REIMPRIMIR JOGADOR
		#
		#			REGISTRAR USO DE BOMBAS
		#			CALCULAR TEMPO RESTANTE DE EXPLOSAO
		#			EXPLODIR BOMBAS IMINENTES
		#			IMPLEMENTAR DANO DA EXPLOSAO
		#
		#			CALCULAR MOVIMENTO DOS INIMIGOS
		#			CALCULAR SE ALGUM INIMIGO TOCOU NO JOGADOR
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
# Include de prodcedimentos feito no final do codigo, sempre #
# Colocar no topo vai fazer os procedimentos serem chamados  #
# ANTES do nosso codigo que queremos executar                #
##############################################################

.include ".\imprimir_fase.asm"
.include ".\preencher_tela.asm"
.include ".\imprimir_textura.asm" 
.include ".\calcular_tile_atual.asm"
.include ".\mover_jogador.asm"
.include ".\imprimir_buffer.asm"
.include ".\registrar_movimento.asm"







