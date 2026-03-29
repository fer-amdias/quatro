#################################################################
# ROTINA_CAPITULO_1					       	#
# Mostra as fases do capitulo 1 (Babilonia).			#
# 							     	#
# ARGUMENTOS:						     	#
#	(nenhum)						#
# RETORNOS:                                                  	#
#       (nenhum)                                             	#
#################################################################

CAPITULO_1:

.data

ch1_fase0: .string "../assets/fases/ch1_fase0.lvl"
ch1_fase1: .string "../assets/fases/ch1_fase1.lvl"
ch1_fase2: .string "../assets/fases/ch1_fase2.lvl"
ch1_fase3: .string "../assets/fases/ch1_fase3.lvl"
ch1_fase4: .string "../assets/fases/ch1_fase4.lvl"

.text

# PREFIXO_INTERNO: C1_
ROTINA_CAPITULO_1:
		addi sp, sp, -4
		sw ra, (sp)
		
		li t0, 0
		sw t0, VIDAS_RESTANTES, t1			# reseta as vidas restantes para 0
		
		# REESCREVE OS DOIS POWERUPS PARA 0
		sb zero, POWERUP_TAMANHO_BOMBA, t0		
		sb zero, POWERUP_QTD_BOMBAS, t0

		# FASE(%fase, %capitulo, %nome_mapa, %label_de_morte)
		FASE(0, 1, ch1_fase0, C1_FIM)
		FASE(1, 1, ch1_fase1, C1_FIM)
		FASE(2, 1, ch1_fase2, C1_FIM)
		FASE(3, 1, ch1_fase3, C1_FIM)
		FASE(4, 1, ch1_fase4, C1_FIM)


		
		j C1_FIM
		
		
C1_FIM:		lw ra, (sp)
		addi sp, sp, 4
		ret
	


		
