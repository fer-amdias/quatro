#################################################################
# EDITOR DE FASES DO JOGO QUATRO                                #
#                                                               #
# Fernando de Almeida Mendes Dias				#
#################################################################

.include "./memoria.s"


.data

TEXTURA_INICIAL: "../assets/texturas/ch0.bin"

.text

MAIN:

la a0, TEXTURA_INICIAL
jal EDITOR_CARREGAR_TEXTURA
jal EDITOR_MENU_PRINCIPAL

# finaliza
li a7, 10
ecall



##############################################################
# Include de prodcedimentos feito no final do codigo, pois   #
# Colocar no topo vai fazer os procedimentos serem chamados  #
# ANTES do nosso codigo que queremos executar                #
##############################################################

.include "./menus_tela_inicial/menu_principal.s"
.include "./menus_tela_inicial/menu_editar.s"
.include "./menus_tela_inicial/menu_config.s"
.include "./menus_tela_inicial/menu_idioma.s"
.include "./menus_tela_inicial/menu_carregar.s"
.include "./fase/carregar_fase.s"
.include "./fase/imprimir_fase_no_fase_buffer.s"
.include "./fase/nova_fase.s"
.include "./seletor_de_tile/imprimir_seletor_de_tile.s"
.include "./seletor_de_tile/mover_seletor_de_tile.s"
.include "./seletor_de_tile/alterar_tile_selecionado.s"
.include "./paletas/criar_paleta_de_npcs.s"
.include "./paletas/criar_paleta_de_tiles.s"
.include "./paletas/imprimir_paletas.s"
.include "./paletas/imprimir_seletor_de_paleta.s"
.include "./paletas/mover_seletor_de_paleta.s"
.include "./paletas/valor_do_seletor_de_paleta.s"
.include "./editor/imprimir_ui.s"
.include "./editor/editor_de_fases.s"
.include "./editor/menu_editor_de_fases.s"
.include "./editor/menu_carregar_textura.s"
.include "./editor/carregar_textura.s"
.include "../menus/menu_creditos.s"
.include "../tocar_audio.s"
.include "../impressao_na_tela/imprimir_textura.s"
.include "../impressao_na_tela/preencher_tela.s"
.include "../impressao_na_tela/obscurecer_tela.s"
.include "../impressao_na_tela/imprimir_inteiro.s"
.include "../impressao_na_tela/imprimir_string.s"
.include "../impressao_na_tela/imprimir_buffer_de_fase.s"
.include "../impressao_na_tela/imprimir_retangulo.s"
.include "../impressao_na_tela/imprimir_outline.s"
.include "../impressao_na_tela/desenhar.s"