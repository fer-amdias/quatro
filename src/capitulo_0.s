#################################################################
# ROTINA_CAPITULO_0 					       	#
# Mostra as fases do capitulo 0 (tutorial).			#
# 							     	#
# ARGUMENTOS:						     	#
#	(nenhum)						#
# RETORNOS:                                                  	#
#       (nenhum)                                             	#
#################################################################

.data

.text

CAPITULO_0:
		# int fase, label mapa, int tempo_limite, 
		# label musica, label sfx_powerup, lavel sfx_morte, label sfx_scroll, 
		# label mapa.scroll, bool mostrar_scroll_no_inicio, bool modo_saida_livre

.text

# PREFIXO_INTERNO: C0_
ROTINA_CAPITULO_0:
		addi sp, sp, -4
		sw ra, (sp)
		
		li t0, 0
		sw t0, VIDAS_RESTANTES, t1		# reseta as vidas restantes para 0
		#############
		
		# int fase, int capitulo, label mapa, int tempo_limite, 
		# label textura_inimigos, label textura_jogador
		# label musica, label sfx_powerup, lavel sfx_morte, label sfx_scroll, 
		# label mapa.scroll, bool mostrar_scroll_no_inicio, label textura_do_pergaminho
		# bool modo_saida_livre
		FASE(1, 0, ch0_fase1, ch0, SEM_LIMITE_DE_TEMPO, inimigos, jogador, internationale, powerup, morte, abertura_pergaminho, ch0_fase1.scroll, pergaminho, 1, 1)
		beqz a0, C0_FIM
		
		FASE(2, 0, ch0_fase2, ch0, SEM_LIMITE_DE_TEMPO, inimigos, jogador, internationale, powerup, morte, abertura_pergaminho, ch0_fase2.scroll, pergaminho, 1, 1)
		beqz a0, C0_FIM
		
		FASE(3, 0, ch0_fase3, ch0, SEM_LIMITE_DE_TEMPO, inimigos, jogador, internationale, powerup, morte, abertura_pergaminho, ch0_fase3.scroll, pergaminho, 1, 1)
		beqz a0, C0_FIM
		
		FASE(4, 0, ch0_fase4, ch0, SEM_LIMITE_DE_TEMPO, inimigos, jogador, internationale, powerup, morte, abertura_pergaminho, ch0_fase4.scroll, pergaminho, 1, 1)
		beqz a0, C0_FIM
		
		FASE(5, 0, ch0_fase5, ch0, SEM_LIMITE_DE_TEMPO, inimigos, jogador, internationale, powerup, morte, abertura_pergaminho, ch0_fase5.scroll, pergaminho, 0, 0)
		beqz a0, C0_FIM
		
		FASE(6, 0, ch0_fase6, ch0, 100, inimigos, jogador, internationale, powerup, morte, abertura_pergaminho, ch0_fase6.scroll, pergaminho, 0, 0)
		beqz a0, C0_FIM
		
		FASE(7, 0, ch0_fase7, ch0, 100, inimigos, jogador, internationale, powerup, morte, abertura_pergaminho, ch0_fase7.scroll, pergaminho, 0, 0)
		beqz a0, C0_FIM
		
		FASE(8, 0, ch0_fase8, ch0, SEM_LIMITE_DE_TEMPO, inimigos, jogador, internationale, powerup, morte, abertura_pergaminho, ch0_fase8.scroll, pergaminho, 0, 0)
		beqz a0, C0_FIM
		
C0_FIM:
		lw ra, (sp)
		addi sp, sp, 4
		ret


		
