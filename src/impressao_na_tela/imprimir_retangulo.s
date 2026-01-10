#################################################################
# PROC_IMPRIMIR_RETANGULO				       	#
# Muda cada pixel do frame fornecido para ter a cor fornecida 	#
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : COR DE PREENCHIMENTO                            	#
#       A1 : X1                                                 #
#       A2 : Y1                                                 #
#       A3 : X2                                                 #
#       A4 : Y2                                                 #
#	A7 : MODO : 0 = tela, 1 = buffer                   	#
# RETORNOS:                                                  	#
#       (nenhum)                                             	#
#################################################################

PROC_IMPRIMIR_RETANGULO: 	
			bne a7, x0, P_IR1_MODO_1	# se n for o modo 0, carrega o buffer

			la t3, FRAME_BUFFER_PTR
			lw t3, (t3)
			j P_IR1_CONT			# pula o codigo de modo 1
			
P_IR1_MODO_1:		la t3, FASE_BUFFER

P_IR1_CONT:		

			li t0, LARGURA_VGA		# t0 = LVGA (largura VGA) // largura do buffer
			mul t0, a2, t0			# t0 = pL = Y1 * LVGA
			add t0, t0, a1			# t0 = pL + X1
			add t3, t3, t0			# BUFFER += pL + X, indo pra posicao em que queremos imprimir
			
# a0 = I  = informacao do pixel de textura atual
# t1 = X  = X atual
# t2 = Y  = Y atual
# t3 = P  = endereco do pixel vga atual
# t4 = Lm = largura maxima permitida
# t5 = Am = altura maxima permitida
# t6 = COR_TRANSPARENTE


# t6 = cor transparente
                        sub t0, a3, a1
                        mv t1, a1
                        mv t2, a2
			li t4, LARGURA_VGA		
			li t5, ALTURA_VGA		
			li t6, COR_TRANSPARENTE		
			j P_IR1_LOOP			# vai pro loop
			
P_IR1_PROXIMA_LINHA:    
			sub t1, t0, t4 			# t1 = C-320 -- lembre-se que a tela eh 240 por 320!
			neg t1, t1			# t1 = 320-C

			add t3, t3, t1			# E += 320-C (t6)

                        mv t1, a1                       # X = X1

			addi t2, t2, 1                  # Y++
				
			# SE Y > Y2 sai do loop
			bgt t2, a4, P_IR1_FIM
			
P_IR1_LOOP:		beq a0, t6, P_IR1_PULA_PIXEL	# SE ( I == COR_TRANSPARENTE ), ENTAO PULA O PIXEL

                        # se X < 0 ou Y < 0 ou X => Lm ou Y => Am
                        bltz t1, P_IR1_PULA_PIXEL        
                        bltz t2, P_IR1_PULA_PIXEL
                        bgt t1, t4, P_IR1_PULA_PIXEL
                        bgt t2, t5, P_IR1_PULA_PIXEL
							# SENAO:
			sb a0,	(t3)			# 	imprime o pixel
P_IR1_PULA_PIXEL:	addi t3, t3, 1			# P++ 
			addi t1, t1, 1			# CC++ 

			# SE X == X2, VAI PARA A PROXIMA LINHA
			beq t1, a3, P_IR1_PROXIMA_LINHA
				
			j P_IR1_LOOP			# continua o loop		
						
							
								
									
P_IR1_FIM:					
			ret	
