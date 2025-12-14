#################################################################
# PROC_IMPRIMIR_BUFFER_DE_FASE 				       	#
# Imprime o buffer de fase no buffer de frame, fazendo com que	#
# ela apareca na tela						#
#								#
# ARGUMENTOS:						     	#
#	(nenhum)						#
#							     	#
# RETORNOS:                                                  	#
#       (nenhum)						#
#################################################################

# PREFIXO INTERNO:
# P_IB1_

.text

#	t1 = IDX_FRAME_BUFFER
#	t2 = pos X do canto superior esquerdo do mapa
#	t3 = pos Y do canto superior esquerdo do mapa

# 	t6 = IDX_BUFFER

PROC_IMPRIMIR_BUFFER_DE_FASE:	la t0, POSICOES_MAPA		# pega as posicoes do canto superior esquerdo do mapa
				lhu t2, (t0)			# carrega a posicao X do canto superior esquerdo do mapa
				lhu t3, 2(t0)			# carrega a posicao Y do canto superior esquero do mapa
				
				
				lw t1, FRAME_BUFFER_PTR		# endereco do endereco do frame buffer, onde imprimimos tudo durante o draw cycle
				
				la t6, FASE_BUFFER		# t6 = endereco do buffer
				
				li t0, LARGURA_VGA		# t0 = LVGA (largura VGA)
				mul t0, t3, t0			# t0 = pL = Y * LVGA
				add t0, t0, t2			# t0 = pL + X
				add t1, t1, t0			# IDX_FRAME_BUFFER = FRAME_BUFFER + pL + X, indo pra posicao em que queremos imprimir
				add t6, t6, t0			# IDX_FASE_BUFFER = FASE_BUFFER + pL + X, indo pra posicao em que queremos imprimir

				mv t4, zero			# CL = 0
				mv t5, zero			# CC = 0
				
#	t2 = nL = n Linhas do mapa
#	t3 = nC = n Colunas do mapa
#	t4 = CL = contador de linhas
#	t5 = CC = contador de colunas

				# carrega as dimensoes da fase no buffer
				
				la t0, FASE_BUFFER_LIN
				lhu t2, (t0)

				la t0, FASE_BUFFER_COL
				lhu t3, (t0)
				

P_IB1_LOOP_PRINTAR_NA_TELA:	lb t0, (t6)			# carrega o pixel localizado em IDX_BUFFER
				sb t0, (t1)			# salva o pixel localizado em IDX_BUFFER em IDX_FRAME_BUFFER
				
				addi t5, t5, 1			# CC++
				
				addi t1, t1, 1			# IDX_FRAME_BUFFER++
				addi t6, t6, 1			# IDX_FASE_BUFFER++
				
				# se CC >= nC: proxima linha
				bge t5, t3, P_IB1_TELA_PROX_LINHA
				
				j P_IB1_LOOP_PRINTAR_NA_TELA

P_IB1_TELA_PROX_LINHA:		
				li t5, LARGURA_VGA
				sub t0, t3, t5 			# t0 = -320+nC -- lembre-se que a tela eh 240 por 320!
				neg t0, t0			# t0 = 320-nC
				add t1, t0, t1			# IDX_FRAME_BUFFER += 320 - nC
				add t6, t0, t6			# IDX_FASE_BUFFER += 320 - nC

				mv t5, zero			# CC = 0
				addi t4, t4, 1			# CL++
				
				# se CL >= nL: finalizar
				bge t4, t2, P_IB1_FIM	
				
				j P_IB1_LOOP_PRINTAR_NA_TELA
				
P_IB1_FIM:			ret
