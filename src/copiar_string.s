#################################################################
# PROC_COPIAR_STRING				       	     	#
# Copia o conteudo de uma string a outra                        #
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : Endereco da string origem                          #
#       A1 : Endereco da string destino                         #
#       A2 : Quantidade de bytes (0 = ate o fim da origem)      #
# RETORNOS:                                                  	#
#       (nenhum)                                                #
#################################################################

PROC_COPIAR_STRING:
        beq a0, a1, P_CS1_RET
        beqz a2, P_CS_LOOP_ATE_O_FINAL_DA_ORIGEM
P_CS_LOOP:
        lb t0, (a0)
        sb t0, (a1)
        addi a0, a0, 1
        addi a1, a1, 1
        addi a2, a2, -1
        beqz a2, P_CS1_RET
        j P_CS_LOOP
P_CS_LOOP_ATE_O_FINAL_DA_ORIGEM:
        lb t0, (a0)
        beqz t0, P_CS1_RET
        sb t0, (a1)
        addi a0, a0, 1
        addi a1, a1, 1
        j P_CS_LOOP_ATE_O_FINAL_DA_ORIGEM
P_CS1_RET:
        ret