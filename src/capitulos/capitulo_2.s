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

.data

ch2_fase0: .string "../assets/fases/ch2_fase0.lvl"
ch2_fase1: .string "../assets/fases/ch2_fase1.lvl"
ch2_fase2: .string "../assets/fases/ch2_fase2.lvl"
ch2_fase3: .string "../assets/fases/ch2_fase3.lvl"
ch2_fase4: .string "../assets/fases/ch2_fase4.lvl"

.text


# PREFIXO_INTERNO: C2_
ROTINA_CAPITULO_2:
		addi sp, sp, -4
		sw ra, (sp)
		
		li t0, 0
		sw t0, VIDAS_RESTANTES, t1			# reseta as vidas restantes para 0
		
		sh zero, POWERUP_TAMANHO_BOMBA, t0		# REESCREVE OS DOIS POWERUPS PARA 0
		#############
		
		FASE(0, 2, ch2_fase0, C2_FIM)
		FASE(1, 2, ch2_fase1, C2_FIM)
		FASE(2, 2, ch2_fase2, C2_FIM)
		FASE(3, 2, ch2_fase3, C2_FIM)
		FASE(4, 2, ch2_fase4, C2_FIM)
		
		j C2_FIM
		
		
C2_FIM:		lw ra, (sp)
		addi sp, sp, 4
		ret
	


		
