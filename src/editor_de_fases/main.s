#################################################################
# EDITOR DE FASES DO JOGO QUATRO                                #
#                                                               #
# Fernando de Almeida Mendes Dias				#
#################################################################

.include "./memoria.s"

.text

MAIN:

jal EDITOR_MENU_PRINCIPAL

# finaliza
li a7, 10
ecall



##############################################################
# Include de prodcedimentos feito no final do codigo, pois   #
# Colocar no topo vai fazer os procedimentos serem chamados  #
# ANTES do nosso codigo que queremos executar                #
##############################################################

.include "./menu_principal.s"
.include "./menu_editar.s"
.include "./menu_config.s"
.include "./menu_idioma.s"
.include "./menu_carregar.s"
.include "./carregar_fase.s"
.include "./editor_de_fases.s"
.include "./imprimir_fase_no_fase_buffer.s"
.include "./imprimir_seletor_de_tile.s"
.include "./mover_seletor_de_tile.s"
.include "./alterar_tile_selecionado.s"
.include "./imprimir_ui.s"
.include "./nova_fase.s"
.include "../menus/menu_creditos.s"
.include "../tocar_audio.s"
.include "../impressao_na_tela/imprimir_textura.s"
.include "../impressao_na_tela/preencher_tela.s"
.include "../impressao_na_tela/imprimir_inteiro.s"
.include "../impressao_na_tela/imprimir_string.s"
.include "../impressao_na_tela/imprimir_buffer_de_fase.s"
.include "../impressao_na_tela/imprimir_retangulo.s"
.include "../impressao_na_tela/imprimir_outline.s"
.include "../impressao_na_tela/desenhar.s"