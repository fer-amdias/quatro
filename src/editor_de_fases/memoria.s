#################################################################
# MEMORIA DO EDITOR DE FASE                                     #
#                                                               #
# Fernando de Almeida Mendes Dias				#
#################################################################

.data

.include "../../assets/fases/definicoes_fases.s"
.include "../../assets/locale.s" 
.include "../../assets/logoquatro.data"
.include "../../assets/musicas/intro_tune.data"
.include "../../assets/texturas/inimigos.data"
.include "../../assets/texturas/ch0.data"

FRAME_BUFFER_PTR: 	.word 0xFF100000		# buffer onde vamos guardar todas as mudancas antes de desenha-las na tela
FRAME_BUFFER_FIM_PTR:	.word 0xFF112C00		# endereco final do buffer


FASE_BUFFER: 	  	.byte 0 
		  	.space 76799	# onde manteremos o nivel
FASE_BUFFER_COL:  	.half 0		# quantas colunas tem no mapa no buffer
FASE_BUFFER_LIN:  	.half 0		# quantas linhas tem no mapa no buffer
MUTADO: .byte 0 # boolean

TILEMAP_BUFFER:		.word 0 0	# buffer onde vamos guardar uma versao modificavel do mapa
			.space 192	# 16 * 12 sendo o tamanho maximo do buffer
                        # mesmo que o editor so suporte niveis ate 11 por 11 lol

# uma fase padrao para quando criarmos um novo arquivo
FASE_TEMPLATE: .word 5 5
.byte 1, 1, 1, 1, 1,
      1, 0, 0, 0, 1,
      1, 2, 0, 3, 1,
      1, 0, 0, 0, 1,
      1, 1, 1, 1, 1,

POSICOES_MAPA: .half 0, 0

FASE_DESLOCAMENTO_X: 
FASE_DESLOCAMENTO_Y: .byte 0

ARQUIVO_STR_PATH: .asciz "../assets/fases"
STR_NOME_ARQUIVO: .space 256     # buffer para o nome do arquivo

SELETOR_DE_TILE_X: .byte 0
SELETOR_DE_TILE_Y:  .byte 0

TEXTURA_DO_MAPA: .word ch0

.text

# dimensoes da tela
.eqv LARGURA_VGA 320
.eqv ALTURA_VGA 240

# posicoes de centro de tela
.eqv CENTRO_VGA_X 160
.eqv CENTRO_VGA_Y 120

# posicoes de centro do espaco de fase!
.eqv CENTRO_FASE_X 120
.eqv CENTRO_FASE_Y 120

# enderecos do frame 0 e frame 1
.eqv FRAME_0 0xFF000000
.eqv FRAME_0_FIM 0xFF012C00
.eqv FRAME_1 0xFF100000
.eqv FRAME_1_FIM 0xFF112C00

# magenta
.eqv COR_TRANSPARENTE 199

# tiles
.eqv TAMANHO_SPRITE 20
.eqv AREA_SPRITE 400 
# (20*20)

.include "../macros.s"