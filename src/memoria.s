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
#  Basta dar um .include "./memoria.s" no inicio da main.	#
#								#
#################################################################

.include "macros.s"

# tamanho de uma textura de mapa
.eqv TAMANHO_SPRITE 20
.eqv AREA_SPRITE 400
.eqv FRAME_0 0xFF000000
.eqv FRAME_0_FIM 0xFF012C00

.eqv STRUCT_BOMBAS_OFFSET 12

# offsets da struct de bomba
.eqv BOMBAS_POS_X  0
.eqv BOMBAS_POS_Y  2
.eqv BOMBAS_EXISTE 4
.eqv BOMBAS_CONTAGEM_REGRESSIVA 5
.eqv BOMBAS_MS_DE_TRANSICAO 8

.eqv POWERUP_1  5
.eqv POWERUP_2  6
.eqv ELEVADOR 	7
.eqv PERGAMINHO 8

.data
junk: .space 8  # algo fica escrevendo aqui e eu nao sei oq eh. portanto, estou criando essa zona de lixo pra evitar que os dados sejam sobrescritos.

JOGO_PAUSADO: 		.byte 0
PERGAMINHO_NA_TELA: 	.byte 0			# se eh para estarmos mostrando um scroll na tela atualmente

SEGUNDOS_RESTANTE_Q10:	.word 102400		# quantos segundos ateh a fase acabar, com 10 casas binairias (/1024). Padrao: 100 segundos  
VIDAS_RESTANTES:	.byte 1			# quantas vidas o jogador ainda tem (1 inicial + 1 por fase)
# caso esteje cacando onde que os segundos sao atualizados: inimigos manager, P_IM1_PROSSEGUIR2. eu sei, lugar nada a ver, mas eh o mais pratico.

POSICOES_MAPA: .half 0, 0
POSICAO_JOGADOR: .half 0, 0

DIRECAO_JOGADOR: .byte 0
			# 0 = PARA BAIXO
			# 1 = PARA A DIREITA
			# 2 = PARA CIMA
			# 3 = PARA A ESQUERDA




# era pra inimigos ser um vetor de structs mas eu soh fui ter essa ideia quando fiz as bombas serem vetores de structs, e ahi n dava mais tempo de refatorar o codigo

INIMIGOS_QUANTIDADE: 	.word 0		# quantidade de inimigos inicialmente no mundo
INIMIGOS:         	.byte 0 	# alihamento do vetor
	          	.space 31 	# cada inimigo vai ser salvo em um byte, dando um total de 32 inimigos nesse vetor
INIMIGOS_POSICAO: 	.half 0 	# alinhamento do vetor
	          	.space 127	# cada inimigo vai ter uma posicao de half-word (x) e half-word (y).
INIMIGOS_DIRECAO: 	.byte 0 	# alinhamento do vetor
		  	.space 31	# cada inimigo vai ter uma direcao salvo em um byte.		

CONTADOR_INIMIGOS: 	.byte 0		# quantidade de inimigos atualmente vivos							

FASE_BUFFER: 	  	.byte 0 
		  	.space 76799	# onde manteremos o background de cada nivel, quase como uma layer
FASE_BUFFER_COL:  	.half 0		# quantas colunas tem no mapa no buffer
FASE_BUFFER_LIN:  	.half 0		# quantas linhas tem no mapa no buffer

FRAME_BUFFER_PTR: 	.word 0		# buffer onde vamos guardar todas as mudancas antes de desenha-las na tela
FRAME_BUFFER_FIM_PTR:	.word 0		# endereco final do buffer

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
		
POWERUP_TAMANHO_BOMBA:	.byte 0
POWERUP_QTD_BOMBAS:	.byte 0

MORTE_TIMESTAMP:	.word 0 	# timestamp de quando o jogador morreu

