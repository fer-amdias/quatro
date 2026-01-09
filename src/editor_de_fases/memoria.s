#################################################################
# MEMORIA DO EDITOR DE FASE                                     #
#                                                               #
# Fernando de Almeida Mendes Dias				#
#################################################################

.data

.include "../../assets/locale.s" 
.include "../../assets/logoquatro.data"
.include "../../assets/musicas/intro_tune.data"

FRAME_BUFFER_PTR: 	.word 0xFF100000		# buffer onde vamos guardar todas as mudancas antes de desenha-las na tela
FRAME_BUFFER_FIM_PTR:	.word 0xFF112C00		# endereco final do buffer


# mantemos eles so pros procedimentos compilarem :P
FASE_BUFFER: 	  	
FASE_BUFFER_COL:  	
FASE_BUFFER_LIN:  	.byte 0

MUTADO: .byte 0 # boolean

.text

# dimensoes da tela
.eqv LARGURA_VGA 320
.eqv ALTURA_VGA 240

# posicoes de centro de tela
.eqv CENTRO_VGA_X 160
.eqv CENTRO_VGA_Y 120

# enderecos do frame 0 e frame 1
.eqv FRAME_0 0xFF000000
.eqv FRAME_0_FIM 0xFF012C00
.eqv FRAME_1 0xFF100000
.eqv FRAME_1_FIM 0xFF112C00

# magenta
.eqv COR_TRANSPARENTE 199

.include "../macros.s"