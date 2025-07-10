##############################################################
# PROC_DESENHAR		 				     #
# Mostra 			                             #
# 							     #
# ARGUMENTOS:						     #
#	(nenhum)
# RETORNOS:                                                  #
#       (nenhum)                                             #
##############################################################

.text

PROC_DESENHAR:		lw t1, FRAME_BUFFER_PTR		# carrega o endereco do frame buffer
			lw t2, FRAME_BUFFER_FIM_PTR	# endereco final 
			li t3, FRAME_0			# 0xFF000000 - endereco inicial
			li t4, FRAME_0_FIM		# 0xFF012C00 - endereco final
	
P_D1_LOOP: 		beq t1,t2,P_D1_FIM		# Se for o ulltimo endereco entao sai do loop
			lw t0, (t1)			# le uam word no buffer
			sw t0, (t3)			# escreve a word na memoria VGA
			
			# soma 4 aos enderecos (vai p/ proxima word)
			addi t1, t1, 4			
			addi t3, t3, 4
			
			j P_D1_LOOP			# volta a verificar
			
P_D1_FIM: 		ret	# yippee
	
