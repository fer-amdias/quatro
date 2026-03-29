#################################################################
# ROTINA_CAPITULO_0 					       	#
# Mostra as fases do capitulo 0 (tutorial).			#
# 							     	#
# ARGUMENTOS:						     	#
#	(nenhum)						#
# RETORNOS:                                                  	#
#       (nenhum)                                             	#
#################################################################

CAPITULO_0:
		# int fase, label mapa, int tempo_limite, 
		# label musica, label sfx_powerup, lavel sfx_morte, 
		# label sfx_scroll, label mapa.scroll, 
		# bool mostrar_scroll_no_inicio, bool modo_saida_livre,
		# label textura_de_fundo

.data

ch0_fase0: .string "../assets/fases/ch0_fase0.lvl"
ch0_fase1: .string "../assets/fases/ch0_fase1.lvl"
ch0_fase2: .string "../assets/fases/ch0_fase2.lvl"
ch0_fase3: .string "../assets/fases/ch0_fase3.lvl"
ch0_fase4: .string "../assets/fases/ch0_fase4.lvl"
ch0_fase5: .string "../assets/fases/ch0_fase5.lvl"
ch0_fase6: .string "../assets/fases/ch0_fase6.lvl"
ch0_fase7: .string "../assets/fases/ch0_fase7.lvl"

.text

# PREFIXO_INTERNO: C0_
ROTINA_CAPITULO_0:
		addi sp, sp, -4
		sw ra, (sp)

		li t0, 0
		sw t0, VIDAS_RESTANTES, t1		# reseta as vidas restantes para 0
		
		# FASE(%fase, %capitulo, %nome_mapa, %label_de_morte)
		FASE(0, 0, ch0_fase0, C0_FIM)
		FASE(1, 0, ch0_fase1, C0_FIM)
		FASE(2, 0, ch0_fase2, C0_FIM)
		FASE(3, 0, ch0_fase3, C0_FIM)
		FASE(4, 0, ch0_fase4, C0_FIM)
		FASE(5, 0, ch0_fase5, C0_FIM)
		FASE(6, 0, ch0_fase6, C0_FIM)
		FASE(7, 0, ch0_fase7, C0_FIM)
		
C0_FIM:
		lw ra, (sp)
		addi sp, sp, 4
		ret


		
