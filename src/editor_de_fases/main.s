#################################################################
# EDITOR DE FASES DO JOGO QUATRO                                #
#                                                               #
# Fernando de Almeida Mendes Dias				#
#################################################################

.include "./memoria.s"


.data

INTRO_TUNE: "../assets/musicas/intro_tune.bin"

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

# MENUS
.include "./menus_tela_inicial/menu_principal.s"
.include "./menus_tela_inicial/menu_editar.s"
.include "./menus_tela_inicial/menu_config.s"
.include "./menus_tela_inicial/menu_idioma.s"
.include "./menus_tela_inicial/menu_carregar.s"
.include "../menus/menu_creditos.s"

# FASES
.include "./fase/carregar_fase.s"
.include "./fase/imprimir_fase_no_fase_buffer.s"
.include "./fase/nova_fase.s"
.include "./fase/salvar_fase.s"

# SELETOR DE TILE
.include "./seletor_de_tile/imprimir_seletor_de_tile.s"
.include "./seletor_de_tile/mover_seletor_de_tile.s"
.include "./seletor_de_tile/alterar_tile_selecionado.s"

# PALETAS
.include "./paletas/criar_paleta_de_npcs.s"
.include "./paletas/criar_paleta_de_tiles.s"
.include "./paletas/imprimir_paletas.s"
.include "./paletas/imprimir_seletor_de_paleta.s"
.include "./paletas/mover_seletor_de_paleta.s"
.include "./paletas/valor_do_seletor_de_paleta.s"

# EDITOR EM SI
.include "./editor/imprimir_ui.s"
.include "./editor/editor_de_fases.s"
.include "./editor/carregar_textura.s"

# MENUS DO EDITOR
.include "./editor/menu_editor_de_fases.s"
.include "./editor/menu_redimensionar_mapa.s"
.include "./editor/menu_salvar_fase_como.s"
.include "./editor/menu_fase_salva.s"
.include "./editor/menus_metadata/menu_config_de_metadata.s"
.include "./editor/menus_metadata/menu_config_de_texturas.s"
.include "./editor/menus_metadata/menu_config_de_audio.s"
.include "./editor/menus_metadata/menu_config_de_texto.s"
.include "./editor/menus_metadata/menu_config_de_tempo.s"
.include "./editor/menus_metadata/menu_config_de_marcadores.s"
.include "./editor/menus_metadata/menu_carregar_padrao_de_fundo.s"
.include "./editor/menus_metadata/criar_menu_carregar_textura.s"
.include "./editor/menus_metadata/criar_menu_carregar_audio.s"

# REDIMENSIONAMENTO
.include "./modelo_de_redimensionamento/imprimir_modelo.s"
.include "./modelo_de_redimensionamento/redimensionar_mapa.s"
.include "./modelo_de_redimensionamento/redimensionar_modelo.s"

# AUDIO
.include "../audio/tocar_audio.s"

# STRINGS
.include "../strings/comparar_strings.s"
.include "../strings/copiar_string.s"
.include "../strings/inteiro_para_string.s"
.include "../strings/string_para_inteiro.s"
.include "../strings/tamanho_string.s"

# LOCALIZACAO
.include "../localizacao/obter_traducao.s" 

# RENDERIZACAO
.include "../renderizacao/imprimir_textura.s"
.include "../renderizacao/preencher_tela.s"
.include "../renderizacao/imprimir_inteiro.s"
.include "../renderizacao/imprimir_string.s"
.include "../renderizacao/imprimir_buffer_de_fase.s"
.include "../renderizacao/imprimir_retangulo.s"
.include "../renderizacao/imprimir_outline.s"
.include "../renderizacao/desenhar.s"

# SHADERS
.include "../shaders/obscurecer_tela.s"

# ARQUIVOS
.include "../arquivos/carregar_arquivo_em_buffer.s"
