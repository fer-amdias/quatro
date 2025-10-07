#################################################################
# PROC_IMPRIMIR_HUD				       	     	#
# Imprime a HUD.						#
# 							     	#
# ARGUMENTOS:						     	#
#	a0 = capitulo atual (0 - 9)				#
#	a1 = fase atual (0 - 9)					#
#	a2 = cor do HUD como 0x0000BBFF (background-foreground)	#
# RETORNOS:                                                  	#
#       (nenhum)                                             	#
#################################################################

# Prefixo interno: P_IH1_
.data


.text

PROC_IMPRIMIR_HUD:
		addi sp, sp, -8
		sw ra, (sp)
		sw a2, 4(sp)		# salva a cor
		
		
		
P_IH1_FASE_ATUAL:
		la t0, HUD_FASE_ATUAL
		selecionar_texto_rg(t0, t2, t3, t0)  # carrega a string

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
		mv a4, zero		# imprime do arquivo de localisacao	
		jal PROC_IMPRIMIR_STRING
		
			
P_IH1_TEMPO_RESTANTE:
		

		lw t0, SEGUNDOS_RESTANTE_Q10
		blt t0, x0, P_IH1_INIMIGOS_RESTANTES	# nao imprime o tempo se ele for negativo
		srai t0, t0, 10			# transforma de ponto fixo Q10 pra inteiro
		
		# PROC_IMPRIMIR_INTEIRO				       	     	
		# Imprime um inteiro na tela.					
		# 							     	
		# ARGUMENTOS:						     	
		#	A0 : inteiro						
		#	A1 : X							
		#	A2 : Y						
		#	A3 : cores (0x0000bbff)			
		mv a0, t0		# inteiro
		li a1, 152		# x 
		li a2, 8		# y
		lw a3, 4(sp)
		mv a4, zero		# imprime do arquivo de localisacao	
		jal PROC_IMPRIMIR_INTEIRO
		
P_IH1_INIMIGOS_RESTANTES:
		la t0, HUD_INIMIGOS_RESTANTES
		selecionar_texto_rg(t0, t2, t3, t0)  # carrega a string

		lb t1, CONTADOR_INIMIGOS# pega o numero de inimigos restantes
		addi t1, t1, 48		# converte para caractere
		sb t1, 11(t0)		# substitui na string
		
		la a0, HUD_INIMIGOS_RESTANTES	# carrega a string
		li a1, 217
		li a2, 8		# imprime em (217, 8)
		lw a3, 4(sp)
		mv a4, zero		# imprime do arquivo de localisacao	
		jal PROC_IMPRIMIR_STRING
		
P_IH1_VIDAS_RESTANTES:
		lb t1, VIDAS_RESTANTES

		la t0, HUD_VIDAS_RESTANTES
		selecionar_texto_rg(t0, t2, t3, t0)  # carrega a string

		addi t1, t1, 48			# transforma em caractere
		sb t1, 7(t0)			# atualiza a string
		
		la a0, HUD_VIDAS_RESTANTES	# carrega a string
		li a1, 8
		li a2, 224		# imprime em (8, 8)
		lw a3, 4(sp)
		mv a4, zero		# imprime do arquivo de localisacao	
		jal PROC_IMPRIMIR_STRING
		
		
P_IH1_FIM:
		lw ra, (sp)
		# descarta a2
		addi sp, sp, 8
		ret
		
		
			
			
			

			

