#################################################################
# MEMORIA DO EDITOR DE FASE                                     #
#                                                               #
# Fernando de Almeida Mendes Dias				#
#################################################################

.data

NULL: .word 0

.include "../../assets/fases/definicoes_fases.s"
.include "../../assets/locale.s" 
.include "../../assets/logoeditor.data"
.include "../../assets/texturas/inimigos.data"
.include "../../assets/elementos_de_ui/seta_para_baixo.data"
.include "../../assets/elementos_de_ui/seta_para_cima.data"

FRAME_BUFFER_PTR: 	.word 0xFF100000		# buffer onde vamos guardar todas as mudancas antes de desenha-las na tela
FRAME_BUFFER_FIM_PTR:	.word 0xFF112C00		# endereco final do buffer

FASE_BUFFER: 	  	.byte 0 
		  	.space 76799	# onde manteremos o nivel
FASE_BUFFER_COL:  	.half 0		# quantas colunas tem no mapa no buffer
FASE_BUFFER_LIN:  	.half 0		# quantas linhas tem no mapa no buffer
MUTADO: .byte 0 # boolean

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

PALETA_DE_TILES_Y: .byte 0
PALETA_DE_TILES_VALOR_MAXIMO: .byte 0

PALETA_DE_NPCS_Y: .byte 0
PALETA_DE_NPCS_VALOR_MAXIMO: .byte 0

SELETOR_DE_PALETA_X: .byte 0
SELETOR_DE_PALETA_Y: .byte 0

MODELO_DE_REDIMENSIONAMENTO_LARGURA: .byte 5
MODELO_DE_REDIMENSIONAMENTO_ALTURA:  .byte 5

TEXTURA_DO_MAPA: .word TEXTURA_BUFFER
TEXTURA_DOS_NPCS: .word TEXTURA_NPCS_BUFFER
TEXTURA_FUNDO: .word TEXTURA_FUNDO_BUFFER

TEXTURA_BUFFER: .space 30000    # para a textura a ser carregada, se houver

TEXTURA_NPCS_BUFFER: .space 60000   # para a textura de NPCs a ser carregada, se houver

TEXTURA_FUNDO_BUFFER: .space 10000  # para a textura de fundo a ser carregada, se houver



# Metadata da fase

.eqv TAMANHO_STRING_METADATA            128     

FASE_ARQUIVO_HEADER:                    .byte '4', 'L', 'V', 'L'# marcador de header de arquivo
FASE_ARQUIVO_VERSAO:                    .byte 1, 0, 0, 0        # versao 1.0.0.0

FASE_METADATA:
FASE_TEXTURA_DE_FUNDO:                  .space TAMANHO_STRING_METADATA
FASE_TEXTURA:                           .space TAMANHO_STRING_METADATA
FASE_TEXTURA_NPCS:                      .space TAMANHO_STRING_METADATA
FASE_TEXTURA_JOGADOR:                   .space TAMANHO_STRING_METADATA
FASE_TEXTURA_PERGAMINHO:                .space TAMANHO_STRING_METADATA
FASE_AUDIO_SOUNDTRACK:                  .space TAMANHO_STRING_METADATA
FASE_AUDIO_POWERUP:                     .space TAMANHO_STRING_METADATA
FASE_AUDIO_MORTE:                       .space TAMANHO_STRING_METADATA
FASE_AUDIO_PERGAMINHO:                  .space TAMANHO_STRING_METADATA
FASE_TEXTO_PERGAMINHO:                  .space TAMANHO_STRING_METADATA
FASE_LIMITE_DE_TEMPO:                   .space 4
FASE_PERGAMINHO_NO_INICIO:              .space 4
FASE_SAIDA_LIVRE:                       .space 4
TAMANHO_STRUCT_TILE:                    .word 1       

TILEMAP_BUFFER:		.word 0 0	# buffer onde vamos guardar uma versao modificavel do mapa
			.space 1024


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

# posicao das paletas de tiles e npcs
.eqv PALETAS_X 251
.eqv PALETAS_Y 70
.eqv DISTANCIA_ENTRE_PALETAS 10

.include "../macros.s"