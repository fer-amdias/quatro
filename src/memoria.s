#################################################################
# 		  REGISTRO DE MEMORIA DO JOGO 		 	#
#################################################################
#								#
#  Aqui, tudo que precisa ser acessado "globalmente" serah	#
#  registrado e guardado, como vetores "globais". Tudo serah	#
#  visivel para todo e qualquer codigo do programa.		#
#								#
#  Nao guarde informacao aqui acessada apenas por um		#
#  procedimento, nem informacao utilizada somente na MAIN.	#
#								#
#  Tome cuidado com as labels que utilizar aqui, pois elas nao  #
#  podem ser redeclaradas nem sobrescritas em lugar nenhum.	#
#								#
# 								#
#  COMO USO ESSE MODULO?					#
#  Basta dar um .include "./memoria.asm" no inicio do		#
#  da main. 							#
#								#
#################################################################

.include "macros.s"

# tamanho de uma textura de mapa
.eqv TAMANHO_SPRITE 20
.eqv AREA_SPRITE 400
.eqv FRAME_0 0xFF000000
.eqv FRAME_0_FIM 0xFF012C00
.eqv STRUCT_BOMBAS_OFFSET 12

.data

POSICOES_MAPA: .half 0, 0
POSICAO_JOGADOR: .half 0, 0

DIRECAO_JOGADOR: .byte 0
			# 0 = PARA BAIXO
			# 1 = PARA A DIREITA
			# 2 = PARA CIMA
			# 3 = PARA A ESQUERDA


FASE_ATUAL: .byte 0

INIMIGOS_QUANTIDADE: 	.word 0		# quantidade de inimigos no mundo
INIMIGOS:         	.byte 0 	# alihamento do vetor
	          	.space 31 	# cada inimigo vai ser salvo em um byte, dando um total de 32 inimigos nesse vetor
INIMIGOS_POSICAO: 	.half 0 	# alinhamento do vetor
	          	.space 127	# cada inimigo vai ter uma posicao de half-word (x) e half-word (y).
INIMIGOS_DIRECAO: 	.byte 0 	# alinhamento do vetor
		  	.space 31	# cada inimigo vai ter uma direcao salvo em um byte.	
INIMIGOS_TAMANHO:	.word 20	# cada inimigo eh 20 por 20 por padrao			

CONTADOR_INIMIGOS: .byte 0										

FASE_BUFFER: 	  	.byte 0 
		  	.space 76799	# onde manteremos o background de cada nivel, quase como uma layer
FASE_BUFFER_COL:  	.half 0		# quantas colunas tem no mapa no buffer
FASE_BUFFER_LIN:  	.half 0		# quantas linhas tem no mapa no buffer

FRAME_BUFFER_PTR: 	.word 0		# buffer onde vamos guardar todas as mudancas antes de desenha-las na tela
FRAME_BUFFER_FIM_PTR:	.byte 0		# endereco final do buffer

TILEMAP_BUFFER:		.word 0 0	# buffer onde vamos guardar uma versao modificavel do mapa
			.space 192	# 16 * 12 sendo o tamanho maximo do buffer
			
			# struct BOMBAS {
BOMBAS:			.half 0   	# short int POSICAO_X;			(0 a 240)
			.half 0 	# short int POSICAO_Y;			(0 a 320)
			.byte 0		# bool EXISTE;				(0 ou 1)
			.byte 0		# unsigned char CONTAGEM_REGRESSIVA;    (0 a 3)
			.space 2	# (espacamento)
			.word 0xFFFFFFFF# int timestamp_de_transicao		(timestamp de quanto a gente quer diminiuir a contagem)
			# }
			
			# espaco pra 3 mais bombas
			.space 12
			.space 12
			.space 12
		
