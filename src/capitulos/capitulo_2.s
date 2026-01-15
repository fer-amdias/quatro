#################################################################
# ROTINA_CAPITULO_2					       	#
# Mostra as fases do capitulo 2 (Roma).				#
# 							     	#
# ARGUMENTOS:						     	#
#	(nenhum)						#
# RETORNOS:                                                  	#
#       (nenhum)                                             	#
#################################################################

CAPITULO_2:


# PREFIXO_INTERNO: C2_
ROTINA_CAPITULO_2:
		addi sp, sp, -4
		sw ra, (sp)
		
		li t0, 0
		sw t0, VIDAS_RESTANTES, t1			# reseta as vidas restantes para 0
		
		sh zero, POWERUP_TAMANHO_BOMBA, t0		# REESCREVE OS DOIS POWERUPS PARA 0
		#############

		la a0, CAPITULO_2_TEXTURA
		la a1, TEXTURA_DO_MAPA_BUFFER
		jal PROC_CARREGAR_TEXTURA
		
		#FASE(%fase, %capitulo, %arquivo_mapa, %textura_do_mapa, %tempo_limite, %textura_dos_inimigos, %textura_do_jogador, %musica_de_fundo, %audioefeito_de_powerup, %audioefeito_de_morte, %audioefeito_de_pergaminho, %endereco_pergaminho, %textura_do_pergaminho, %mostrar_pergaminho_no_inicio, %modo_saida_livre, %textura_de_fundo)
		FASE(0, 2, ch2_fase0, TEXTURA_DO_MAPA_BUFFER, SEM_LIMITE_DE_TEMPO, inimigos, jogador, seikilos_epitaph13, powerup_ch3, morte_ch2, abertura_scroll_ch3, ch2_fase0.scroll, pergaminho_ch2, 0, 1, fundo_ch2)
		beqz a0, C2_FIM
		
		FASE(1, 2, ch2_fase1, TEXTURA_DO_MAPA_BUFFER, 150, inimigos, jogador, seikilos_epitaph13, powerup_ch3, morte_ch2, abertura_scroll_ch3, ch2_fase1.scroll, pergaminho_ch2, 0, 0, fundo_ch2)
		beqz a0, C2_FIM
		
		FASE(2, 2, ch2_fase2, TEXTURA_DO_MAPA_BUFFER, SEM_LIMITE_DE_TEMPO, inimigos, jogador, seikilos_epitaph13, powerup_ch3, morte_ch2, abertura_scroll_ch3, ch2_fase2.scroll, pergaminho_ch2, 0, 0, fundo_ch2)
		beqz a0, C2_FIM
		
		FASE(3, 2, ch2_fase3, TEXTURA_DO_MAPA_BUFFER, 150, inimigos, jogador, seikilos_epitaph13, powerup_ch3, morte_ch2, abertura_scroll_ch3, ch2_fase3.scroll, pergaminho_ch2, 0, 0, fundo_ch2)
		beqz a0, C2_FIM
		
		FASE(4, 2, ch2_fase4, TEXTURA_DO_MAPA_BUFFER, SEM_LIMITE_DE_TEMPO, inimigos, jogador, seikilos_epitaph, powerup_ch3, morte_ch2, abertura_scroll_ch3, ch2_fase4.scroll, pergaminho_ch2, 0, 1, fundo_ch2)
		beqz a0, C2_FIM
		
		j C2_FIM
		
		
C2_FIM:		lw ra, (sp)
		addi sp, sp, 4
		ret
	


		
