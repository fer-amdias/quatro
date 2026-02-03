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

.include "../assets/fases/definicoes_fases.s"
.include "../assets/npcs/definicoes_npcs.s"
.include "../assets/npcs/hitboxes.s"
.include "macros.s"

# dimensoes da tela
.eqv LARGURA_VGA 320
.eqv ALTURA_VGA 240

# posicoes de centro de tela
.eqv CENTRO_VGA_X 160
.eqv CENTRO_VGA_Y 120

# tamanho de uma textura de mapa
.eqv TAMANHO_SPRITE 20	# mantenha divisivel por 4, por gentileza
.eqv AREA_SPRITE 400
.eqv FRAME_0 0xFF000000
.eqv FRAME_0_FIM 0xFF012C00
.eqv FRAME_1 0xFF100000
.eqv FRAME_1_FIM 0xFF112C00

.eqv STRUCT_BOMBAS_OFFSET 12

# offsets da struct de bomba
.eqv BOMBAS_POS_X  0
.eqv BOMBAS_POS_Y  2
.eqv BOMBAS_EXISTE 4
.eqv BOMBAS_CONTAGEM_REGRESSIVA 5
.eqv BOMBAS_MS_DE_TRANSICAO 8

.eqv TILE_SAIDA	3
.eqv TILE_POWERUP_1  5
.eqv TILE_POWERUP_2  6
.eqv TILE_ELEVADOR   7
.eqv TILE_PERGAMINHO 8

.eqv MAX_VIDAS 4	# maximo de vidas possiveis

.eqv SEM_LIMITE_DE_TEMPO 999	# um contorno para poder usar numeros negativos em macros (o FPGRARS nao deixa) -- 

.eqv COR_TRANSPARENTE 199 

.eqv TAMANHO_MAX_TEXTURA_DE_MAPA 15000	# o maximo de bytes que uma textura de mapa pode ter

.eqv TAMANHO_MAX_TILEMAP 192		# o armazenamento maximo de tiles em um tilemap (L * H) sem contar os 2 bytes iniciais

.data

NULL:			.word 0			# endereco nulo

JOGO_PAUSADO: 		.byte 0
MUTADO: 		.byte 0
PERGAMINHO_NA_TELA: 	.byte 0			# se eh para estarmos mostrando um scroll na tela atualmente
MODO_SAIDA_LIVRE:       .word 0

ENTER_COOLDOWN: .word 0

SEGUNDOS_RESTANTES:	.word 100		# quantos segundos ateh a fase acabar. Padrao: 100 segundos  

VIDAS_RESTANTES:	.byte 1			# quantas vidas o jogador ainda tem (1 inicial + 1 por fase)
# caso esteje cacando onde que os segundos sao atualizados: npcs manager, P_IM1_PROSSEGUIR2. eu sei, lugar nada a ver, mas eh o mais pratico.

POSICOES_MAPA: .half 0, 0

POSICAO_JOGADOR: 
JOGADOR_X: .half 0
JOGADOR_Y: .half 0

DIRECAO_JOGADOR: .byte 0
			# 0 = PARA BAIXO
			# 1 = PARA A DIREITA
			# 2 = PARA CIMA
			# 3 = PARA A ESQUERDA
			
ALTURA_JOGADOR: .word 0
LARGURA_JOGADOR: .word 0




# era pra npcs ser um vetor de structs mas eu soh fui ter essa ideia quando fiz as bombas serem vetores de structs, e ahi n dava mais tempo de refatorar o codigo

NPCS_QUANTIDADE: 	.word 0		# quantidade de npcs inicialmente no mundo
NPCS:         		.byte 0 	# alihamento do vetor
	          	.space 31 	# cada npc vai ser salvo em um byte, dando um total de 32 npcs nesse vetor
NPCS_POSICAO: 		.half 0 	# alinhamento do vetor
	          	.space 127	# cada npc vai ter uma posicao de half-word (x) e half-word (y).
NPCS_DIRECAO:	 	.byte 0 	# alinhamento do vetor
		  	.space 31	# cada npc vai ter uma direcao salvo em um byte.		
NPCS_TIMESTAMP:     	.word 0  
			.space 127      # cada npc vai ter uma timestamp de seu ultimo movimento.	

CONTADOR_NPCS: 		.byte 0		# quantidade de npcs atualmente vivos							

CONTADOR_INIMIGOS: 	.byte 0		# quantidade de inimigos atualmente vivos

FASE_BUFFER: 	  	.byte 0 
		  	.space 76799	# onde manteremos o background de cada nivel, quase como uma layer
FASE_BUFFER_COL:  	.half 0		# quantas colunas tem no mapa no buffer
FASE_BUFFER_LIN:  	.half 0		# quantas linhas tem no mapa no buffer

FRAME_BUFFER_PTR: 	.word 0xFF100000		# buffer onde vamos guardar todas as mudancas antes de desenha-las na tela
FRAME_BUFFER_FIM_PTR:	.word 0xFF112C00		# endereco final do buffer

TILEMAP_BUFFER:		.word 0 0	# buffer onde vamos guardar uma versao modificavel do mapa
			.space TAMANHO_MAX_TILEMAP

MAPA_ORIGINAL_BUFFER:	.word 0 0	# buffer onde vamos guardar a versao original do mapa
			.space TAMANHO_MAX_TILEMAP
			
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


# Deslocamento da impressao de fase_buffer & NPCs, usado pra "tremer" a tela em explosoes
FASE_DESLOCAMENTO_X:    .byte 0
FASE_DESLOCAMENTO_Y:	.byte 0

TEXTURA_DO_MAPA_BUFFER:	.space TAMANHO_MAX_TEXTURA_DE_MAPA
