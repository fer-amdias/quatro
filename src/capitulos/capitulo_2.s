#################################################################
# ROTINA_CAPITULO_2					       	#
# Mostra as fases do capitulo 2 (Roma).				#
# 							     	#
# ARGUMENTOS:						     	#
#	(nenhum)						#
# RETORNOS:                                                  	#
#       (nenhum)                                             	#
#################################################################

.text
CAPITULO_2:


# PREFIXO_INTERNO: C2_
ROTINA_CAPITULO_2:
		addi sp, sp, -4
		sw ra, (sp)
		
		li t0, 0
		sw t0, VIDAS_RESTANTES, t1			# reseta as vidas restantes para 0
		
		sh zero, POWERUP_TAMANHO_BOMBA, t0		# REESCREVE OS DOIS POWERUPS PARA 0
		#############
		
		#FASE(%fase, %capitulo, %arquivo_mapa, %textura_do_mapa, %tempo_limite, %textura_dos_inimigos, %textura_do_jogador, %musica_de_fundo, %audioefeito_de_powerup, %audioefeito_de_morte, %audioefeito_de_pergaminho, %endereco_pergaminho, %textura_do_pergaminho, %mostrar_pergaminho_no_inicio, %modo_saida_livre)
		FASE(0, 2, ch2_fase0, ch2, SEM_LIMITE_DE_TEMPO, inimigos, jogador, west__hurrian_song, powerup_ch3, morte_ch3, abertura_scroll_ch3, ch2_fase0.scroll, pergaminho_ch2, 0, 1)
		beqz a0, C2_FIM
		
		FASE(1, 2, ch2_fase1, ch2, 200, inimigos, jogador, west__hurrian_song, powerup_ch3, morte_ch3, abertura_scroll_ch3, ch2_fase1.scroll, pergaminho_ch2, 0, 0)
		beqz a0, C2_FIM
		
		FASE(2, 2, ch2_fase2, ch2, SEM_LIMITE_DE_TEMPO, inimigos, jogador, west__hurrian_song, powerup_ch3, morte_ch3, abertura_scroll_ch3, ch2_fase2.scroll, pergaminho_ch2, 0, 0)
		beqz a0, C2_FIM
		
		FASE(3, 2, ch2_fase3, ch2, 200, inimigos, jogador, west__hurrian_song, powerup_ch3, morte_ch3, abertura_scroll_ch3, ch2_fase3.scroll, pergaminho_ch2, 0, 0)
		beqz a0, C2_FIM
		
		FASE(4, 2, ch2_fase4, ch2, SEM_LIMITE_DE_TEMPO, inimigos, jogador, west__hurrian_song, powerup_ch3, morte_ch3, abertura_scroll_ch3, ch2_fase4.scroll, pergaminho_ch2, 0, 1)
		beqz a0, C2_FIM
		
		j C2_FIM
		
		
C2_FIM:		lw ra, (sp)
		addi sp, sp, 4
		ret
	


		
