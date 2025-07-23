#################################################################
# PROC_IMPRIMIR_HUD				       	     	#
# Imprime a HUD.						#
# 							     	#
# ARGUMENTOS:						     	#
#	a0 = capitulo atual (0 - 9)				#
#	a1 = fase atual (0 - 9)					#
# RETORNOS:                                                  	#
#       (nenhum)                                             	#
#################################################################

# Prefixo interno: P_IH1_
.data
HUD_FASE_ATUAL: .string "CH C, FASE F"
HUD_INIMIGOS_RESTANTES: .string "INIMIGOS:  X"
HUD_VIDAS_RESTANTES: .string "VIDAS: X"


.text

PROC_IMPRIMIR_HUD:
		addi sp, sp, -4
		sw ra, (sp)
		
		
		
P_IH1_FASE_ATUAL:
		la t0, HUD_FASE_ATUAL
		mv t1, a0		# pega o inteiro de capitulo
		addi t1, t1, 48		# converte para caractere
		sb t1, 3(t0)		# substitui na string
		mv t1, a1		# pega o inteiro de fase
		addi t1, t1, 48		# converte para caractere
		sb t1, 11(t0)		# substitui na string
		
		la a0, HUD_FASE_ATUAL	# carrega a string
		li a1, 8
		li a2, 8		# imprime em (8, 8)
		li a3, 0x0000C7FF
		jal PROC_IMPRIMIR_STRING
		
			
P_IH1_TEMPO_RESTANTE:
		

		lw t0, SEGUNDOS_RESTANTE_Q10
		srai t0, t0, 10			# transforma de ponto fixo Q10 pra inteiro
		
		# PROC_IMPRIMIR_INTEIRO				       	     	
		# Imprime um inteiro na tela.					
		# 							     	
		# ARGUMENTOS:						     	
		#	A0 : inteiro						
		#	A1 : X							
		#	A2 : Y						
		#	A3 : cores (0x0000bbff)			
		mv a0, t0
		li a1, 152
		li a2, 8		# imprime em (152, 8) 
		li a3, 0x0000C7FF
		jal PROC_IMPRIMIR_INTEIRO
		
P_IH1_INIMIGOS_RESTANTES:
		la t0, HUD_INIMIGOS_RESTANTES
		lb t1, CONTADOR_INIMIGOS# pega o numero de inimigos restantes
		addi t1, t1, 48		# converte para caractere
		sb t1, 11(t0)		# substitui na string
		
		la a0, HUD_INIMIGOS_RESTANTES	# carrega a string
		li a1, 217
		li a2, 8		# imprime em (217, 8)
		li a3, 0x0000C7FF
		jal PROC_IMPRIMIR_STRING
		
P_IH1_VIDAS_RESTANTES:
		la t0, VIDAS_RESTANTES
		lbu t1, (t0)
		la t0 HUD_VIDAS_RESTANTES
		addi t1, t1, 48			# transforma em caractere
		sb t1, 7(t0)			# atualiza a string
		
		la a0, HUD_VIDAS_RESTANTES	# carrega a string
		li a1, 8
		li a2, 224		# imprime em (8, 8)
		li a3, 0x0000C7FF
		jal PROC_IMPRIMIR_STRING
		
		
P_IH1_FIM:
		lw ra, (sp)
		addi sp, sp, 4
		ret
		
		
			
			
			

			

