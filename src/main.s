#################################################################
# QUATRO	 					       	#
# Um jogo feito como projeto de primeiro semestre para o 	#
# componente Introdu��o a Sistemas Computacionais na 		#
# Universidade de Bras�lia.					#
#								#
# Escrito no primeiro semestre de 2025				#
# Apresentado em 24/07/2025					#
# 							     	#
# v0.1								#
#								#
# Fernando de Almeida Mendes Dias				#
#################################################################

#########################################
#		ATENCAO			#
#					#
# Nao rode esse programa usando o RARS.	#
# Ele nem vai compilar. Utilize, em	#
# vez disso, a versao 1.13.0 8 bit.	#	https://github.com/LeoRiether/FPGRARS/releases/tag/v1.13.0
# 					#
#########################################


.include "memoria.s"

.data
.include "../assets/logoquatro.data"
.include "../assets/texturas/ch0.data"
.include "../assets/fases/ch0_fase1.data"
.include "../assets/fases/ch0_fase2.data"
.include "../assets/fases/ch0_fase3.data"
.include "../assets/fases/ch0_fase4.data"
.include "../assets/fases/ch0_fase5.data"
.include "../assets/fases/ch0_fase6.data"
.include "../assets/fases/ch0_fase7.data"
.include "../assets/fases/ch0_fase8.data"
.include "../assets/fases/ch1_fase1.data"
.include "../assets/fases/ch1_fase2.data"
.include "../assets/fases/ch1_fase3.data"
.include "../assets/fases/ch1_fase4.data"
.include "../assets/fases/ch1_fase5.data"
.include "../assets/texturas/ch1.data"
.include "../assets/texturas/pergaminho_ch1.data"
.include "../assets/texturas/inimigos.data"
.include "../assets/texturas/explosivos.data"
.include "../assets/texturas/placeholder.data"
.include "../assets/texturas/jogador.data"
.include "../assets/texturas/pergaminho.data"
.include "../assets/musicas/internationale.data"
.include "../assets/musicas/intro_tune.data"
.include "../assets/musicas/west__hurrian_song.data"
.include "../assets/audioefeitos/morte.data"
.include "../assets/audioefeitos/morte_ch3.data"
.include "../assets/audioefeitos/powerup.data"
.include "../assets/audioefeitos/powerup_ch3.data"
.include "../assets/audioefeitos/abertura_pergaminho.data"
.include "../assets/audioefeitos/abertura_scroll_ch3.data"

.text

MAIN:

	#### ALOCACAO DO FRAME_BUFFER ####
	li a7, 9
	li a0, 76800
	ecall
	
	sw a0, FRAME_BUFFER_PTR, t0
	
	# adiciona 76800 em a0 usando t0 como temporario
	li t0, 76800
	add a0, a0, t0	
	
	sw a0, FRAME_BUFFER_FIM_PTR, t0

IR_MENU:
	jal ROTINA_MENU_PRINCIPAL
	li t0, 1
	beq a0, t0, CAP1		# ir p
	
	jal ROTINA_CAPITULO_0
	beqz a0, IR_MENU

CAP1:	
	jal ROTINA_CAPITULO_1
	beqz a0, IR_MENU
	
	fim





##############################################################
# Include de prodcedimentos feito no final do codigo, pois   #
# Colocar no topo vai fazer os procedimentos serem chamados  #
# ANTES do nosso codigo que queremos executar                #
##############################################################
.include "imprimir_fase.s"
.include "preencher_tela.s"
.include "imprimir_textura.s" 
.include "calcular_tile_atual.s"
.include "mover_jogador.s"
.include "imprimir_buffer_de_fase.s"
.include "registrar_movimento.s"
.include "desenhar.s"
.include "colocar_bomba.s"
.include "bomba_manager.s"
.include "inimigos_manager.s"
.include "manipular_tilemap.s" 
.include "checar_colisoes.s" 
.include "imprimir_string.s"
.include "mostrar_pergaminho.s"
.include "tocar_audio.s"
.include "imprimir_inteiro.s"
.include "imprimir_hud.s"
.include "menu_principal.s"
.include "capitulo_0.s"
.include "capitulo_1.s"
