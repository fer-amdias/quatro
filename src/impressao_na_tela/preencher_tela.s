#################################################################
# PROC_PREENCHER_TELA 				       	     	#
# Muda cada pixel do frame fornecido para ter a cor fornecida 	#
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : COR DE PREENCHIMENTO                            	#
#	A1 : MODO : 0 = tela, 1 = buffer                   	#
# RETORNOS:                                                  	#
#       (nenhum)                                             	#
#################################################################
.text

PROC_PREENCHER_TELA:	beqz a1, P_PT1_EH_TELA		# se A1 == 0, vai pra P_PT1_EH_TELA; senao, fica

P_PT1_EH_FRAME_1:	lw t1, FRAME_BUFFER_PTR		# carrega o endereco do frame buffer
			lw t2, FRAME_BUFFER_FIM_PTR	# endereco final 
			j P_PT1_MAIN			# pula ppra main do procedimento
			
P_PT1_EH_TELA:		li t0, FRAME_0
			lw t1, FRAME_BUFFER_PTR		# carrega o endereco do frame buffer
			bgt t1, t0, P_PT1_PRINTA_FRAME_0
			li t1, FRAME_1
			li t2, FRAME_1_FIM
			j P_PT1_MAIN			# pula pra main do procedimento

P_PT1_PRINTA_FRAME_0:
			li t1, FRAME_0
			li t2, FRAME_0_FIM

P_PT1_MAIN:		# a0 eh a cor de preenchimento
			# ocupando o primeiro byte de a0
			# queremos que o primeiro byte seja repetido 4 vezes
			
			mv t3, a0
			
			slli t0, t3, 8			# shifta um byte pro lado
			add t3, t3, t0			# soma no original
			slli t0, t0, 8			# shifta um byte pro lado
			add t3, t3, t0			# soma no original
			slli t0, t0, 8			# etc...
			add t3, t3, t0			# pronto!
			
			# sao necessarias apenas 3 repeticoes, pois o byte menos significativo de t4 jah tem a cor (que pegamos de a0)

P_PT1_LOOP: 		beq t1,t2,P_PT1_FIM		# Se for o �ltimo endere�o ent�o sai do loop
			sw t3,0(t1)			# escreve a word na mem�ria VGA
			addi t1,t1,4			# soma 4 ao endere�o
			j P_PT1_LOOP				# volta a verificar
			
P_PT1_FIM:              ret
