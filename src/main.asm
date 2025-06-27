.data

.include ".\memoria.asm"
.include "..\example.data"
.include "..\Texturas\placeholder.data"

MENSAGEM_DEBUG_INICIALIZACAO: .string "Bom dia! Jogo inicializado."
MENSAGEM_DEBUG_INICIO_JOGO: .string "Inicializando jogo."
MENSAGEM_DEBUG_INICIO_LOOP_PRINCIPAL: .string "Inicializando loop principal."

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
		
		# O QUE PRECISA SER COLOCADO AQUI:
		#	 INTRO DO JOGO
		#	 LOOP DO MENU ( E SELECAO DE OPCOES )
		#	 LOOP MAIOR DO JOGO:
# FEITO				IMPRESSAO DO MAPA		
# FEITO				POSICIONAMENTO DE INIMIGOS (UTILIZANDO UM VETOR NA MEMORIA PARA GUARDAR TODOS ELES)
# FEITO				POSICIONAMENTO DO JOGADOR  (UTILIZANDO POSICAO_PLAYER)
		#		IMPRESSAO DO INIMIGO E DO JOGADOR
		#		LOOP MENOR DO JOGO:
		#			REGISTRAR MOVIMENTO DE JOGADOR
		#			DESIMPRIMIR JOGADOR (E O(S) TILE(S) QUE ELE ESTAVA)
		#			REIMPRIMIR JOGADOR
		#
		#			REGISTRAR USO DE BOMBAS
		#			CALCULAR TEMPO RESTANTE DE EXPLOSAO
		#			EXPLODIR BOMBAS IMINENTES
		#			IMPLEMENTAR DANO DA EXPLOSAO
		#
		#			CALCULAR MOVIMENTO DOS INIMIGOS
		#			DESIMPRIMIR INIMIGOS
		#			DESIMPRIMIR OS TILES EM QUE OS INIMIGOS ESTAVAM
		#			REIMPRIMIR OS TILES EM QUE OS INIMIGOS ESTAVAM
		#			CALCULAR SE ALGUM INIMIGO TOCOU NO JOGADOR
		#
		#			TOCAR AUDIO
		#			TOCAR MUSICA
			
		
FIM:		


		li a7, 10			# syscall pra terminar o programa
		ecall				# estritamente necessario pra impedir que o programa continue ate entrar no codigo dentro dos includes. 
		




##############################################################
# Include de prodcedimentos feito no final do codigo, sempre #
# Colocar no topo vai fazer os procedimentos serem chamados  #
# ANTES do nosso codigo que queremos executar                #
##############################################################

.include ".\imprimir_fase.asm"
.include ".\preencher_tela.asm"
#.include ".\imprimir_textura.asm" --- comentado pois imprimir_fase.asm jah inclui o procedimento







