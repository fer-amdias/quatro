#################################################################
# ROTINA_CAPITULO_1					       	#
# Mostra as fases do capitulo 1 (Babilonia).			#
# 							     	#
# ARGUMENTOS:						     	#
#	(nenhum)						#
# RETORNOS:                                                  	#
#       (nenhum)                                             	#
#################################################################

.text
CAPITULO_1:


# PREFIXO_INTERNO: C1_
ROTINA_CAPITULO_1:
		addi sp, sp, -4
		sw ra, (sp)
		
		li t0, 0
		sw t0, VIDAS_RESTANTES, t1			# reseta as vidas restantes para 0
		
		sh zero, POWERUP_TAMANHO_BOMBA, t0		# REESCREVE OS DOIS POWERUPS PARA 0
		#############
		
		#FASE(%fase, %capitulo, %arquivo_mapa, %textura_do_mapa, %tempo_limite, %textura_dos_inimigos, %textura_do_jogador, %musica_de_fundo, %audioefeito_de_powerup, %audioefeito_de_morte, %audioefeito_de_pergaminho, %endereco_pergaminho, %textura_do_pergaminho, %mostrar_pergaminho_no_inicio, %modo_saida_livre, %textura_de_fundo)
		FASE(1, 1, ch1_fase1, ch1, 70, inimigos, jogador, west__hurrian_song, powerup_ch3, morte_ch3, abertura_scroll_ch3, ch1_fase1.scroll, pergaminho_ch1, 0, 0, NULL)
		beqz a0, C1_FIM
		
		FASE(2, 1, ch1_fase2, ch1, 80, inimigos, jogador, west__hurrian_song, powerup_ch3, morte_ch3, abertura_scroll_ch3, ch1_fase2.scroll, pergaminho_ch1, 0, 0, NULL)
		beqz a0, C1_FIM
		
		FASE(3, 1, ch1_fase3, ch1, 100, inimigos, jogador, west__hurrian_song, powerup_ch3, morte_ch3, abertura_scroll_ch3, ch1_fase3.scroll, pergaminho_ch1, 0, 0, NULL)
		beqz a0, C1_FIM
		
		FASE(4, 1, ch1_fase4, ch1, 80, inimigos, jogador, west__hurrian_song, powerup_ch3, morte_ch3, abertura_scroll_ch3, ch1_fase4.scroll, pergaminho_ch1, 0, 0, NULL)
		beqz a0, C1_FIM
		
		FASE(5, 1, ch1_fase5, ch1, SEM_LIMITE_DE_TEMPO, inimigos, jogador, west__hurrian_song, powerup_ch3, morte_ch3, abertura_scroll_ch3, ch1_fase5.scroll, pergaminho_ch1, 0, 0, NULL)
		beqz a0, C1_FIM
		
		j C1_FIM
		
		
C1_FIM:		lw ra, (sp)
		addi sp, sp, 4
		ret
	


		
