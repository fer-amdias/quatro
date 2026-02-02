#################################################################
# QUATRO	 					       	#
# Um jogo feito como projeto de primeiro semestre para o 	#
# componente Introducao a Sistemas Computacionais na 		#
# Universidade de Brasilia.					#
#								#
# CH 1 e 2 escritos no primeiro semestre de 2025		#
# e presentados em 24/07/2025.					#
# 								#
# O jogo é agora mantido como prática de assembly para a ISA	#
# RV32IM.							#
# 							     	#
# v0.2.0							#
#								#
# Fernando de Almeida Mendes Dias				#
#################################################################

#########################################
#		ATENCAO			#
#					#
# Nao rode esse programa usando o RARS.	#
# Ele nem vai compilar. Utilize, em	#
# vez disso, a versao 1.13.0 8 bit do	#	https://github.com/LeoRiether/FPGRARS/releases/tag/v1.13.0
# emulador FPGRARS. ele jah vem 	#
# incluido no programa.			#
# 					#
#########################################


.include "memoria.s"
.include "../assets/locale.s"

# alguem (eu) podia fazer um codigo que desse autoinclude nos trem tudo
# senao, tem que atualizar aqui manualmente a inclusao de qqr arquivo em assets
.data
.include "../assets/logoquatro.data"
.include "../assets/texturas/fundo_ch2.data"
.include "../assets/texturas/pergaminho.data"
.include "../assets/texturas/pergaminho_ch1.data"
.include "../assets/texturas/pergaminho_ch2.data"
.include "../assets/texturas/inimigos.data"
.include "../assets/texturas/explosivos.data"
.include "../assets/texturas/placeholder.data"
.include "../assets/texturas/jogador.data"
.include "../assets/musicas/internationale.data"
.include "../assets/musicas/intro_tune.data"
.include "../assets/musicas/west__hurrian_song.data"
.include "../assets/musicas/seikilos_epitaph13.data"
.include "../assets/musicas/seikilos_epitaph.data"
.include "../assets/audioefeitos/morte.data"
.include "../assets/audioefeitos/morte_ch2.data"
.include "../assets/audioefeitos/morte_ch3.data"
.include "../assets/audioefeitos/powerup.data"
.include "../assets/audioefeitos/powerup_ch3.data"
.include "../assets/audioefeitos/abertura_pergaminho.data"
.include "../assets/audioefeitos/abertura_scroll_ch3.data"

.text

MAIN:
MENU:
	jal ROTINA_MENU_PRINCIPAL	# retorna a0: capitulo escolhido
	beqz a0, CAP0			# ir p capitulo 0
	li t0, 1
	beq a0, t0, CAP1		# ir p capitulo 1 
	li t0, 2
	beq a0, t0, CAP2		# ir p capitulo 2
	j MENU				# volta pro menu se o retorno for invalido

CAP0:
	jal ROTINA_CAPITULO_0
	beqz a0, MENU

CAP1:	
	jal ROTINA_CAPITULO_1
	beqz a0, MENU

CAP2:
	jal ROTINA_CAPITULO_2
	beqz a0, MENU
	
	j MENU			# fim


##############################################################
# Include de prodcedimentos feito no final do codigo, pois   #
# Colocar no topo vai fazer os procedimentos serem chamados  #
# ANTES do nosso codigo que queremos executar                #
##############################################################
.include "./fase/fase.s"
.include "./fase/imprimir_fase.s"
.include "./impressao_na_tela/desenhar.s"
.include "./impressao_na_tela/imprimir_buffer_de_fase.s"
.include "./impressao_na_tela/imprimir_inteiro.s"
.include "./impressao_na_tela/imprimir_padrao_de_fundo.s"
.include "./impressao_na_tela/imprimir_string.s"
.include "./impressao_na_tela/imprimir_textura.s"
.include "./impressao_na_tela/preencher_tela.s"
.include "./gui/imprimir_hud.s"
.include "./gui/mostrar_pergaminho.s"
.include "./menus/menu_principal.s"
.include "./menus/menu_jogar.s"
.include "./menus/menu_config.s"
.include "./menus/menu_creditos.s"
.include "./movimento_jogador/mover_jogador.s"
.include "./movimento_jogador/registrar_movimento.s"
.include "./NPCs/movimento_npc_1.s"
.include "./NPCs/movimento_npc_2.s"
.include "./NPCs/movimento_npc_3.s"
.include "./NPCs/npcs_manager.s"
.include "./tiles_e_tilemap/calcular_tile_atual.s"
.include "./tiles_e_tilemap/manipular_tilemap.s"
.include "./tiles_e_tilemap/tile_andavel.s"
.include "./capitulos/capitulo_0.s"
.include "./capitulos/capitulo_1.s"
.include "./capitulos/capitulo_2.s"
.include "bomba_manager.s"
.include "checar_colisoes.s"
.include "colocar_bomba.s"
.include "debug.s"
.include "efeito_explosao.s"
.include "tempo_manager.s"
.include "tocar_audio.s"
.include "carregar_textura.s"
.include "erro_fatal.s"