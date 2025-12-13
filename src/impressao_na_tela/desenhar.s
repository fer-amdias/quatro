##############################################################
# PROC_DESENHAR		 				     #
# Imprime buffer de frame na tela			     #
# 							     #
# ARGUMENTOS:						     #
#	(nenhum)					     #
# RETORNOS:                                                  #
#       (nenhum)                                             #
##############################################################

.text

PROC_DESENHAR:		lw t1, FRAME_BUFFER_PTR		# carrega o endereco do frame buffer
			lw t2, FRAME_BUFFER_FIM_PTR	# endereco final 
			li t3, FRAME_0			# 0xFF000000 - endereco inicial
	
			li t0, 0xFF200604	
			lw t1, FRAME_BUFFER_PTR
			li t2, FRAME_0
			bne t1, t2, P_D1_TROCAR_P_FRAME_1

P_D1_TROCAR_P_FRAME_0:
			sw zero,0(t0)
			li t0, FRAME_1
			sw t0, FRAME_BUFFER_PTR, t1
			li t0, FRAME_1_FIM
			sw t0, FRAME_BUFFER_FIM_PTR, t1
			ret
P_D1_TROCAR_P_FRAME_1:
			li t1, 1
			sw t1,0(t0)
			li t0, FRAME_0
			sw t0, FRAME_BUFFER_PTR, t1
			li t0, FRAME_0_FIM
			sw t0, FRAME_BUFFER_FIM_PTR, t1
			ret
			
P_D1_FIM: 		ret	# yippee
	
