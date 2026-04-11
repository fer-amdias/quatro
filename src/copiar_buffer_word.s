#################################################################
# PROC_COPIAR_BUFFER_WORD                                       #
# Carrega um numero de words de um buffer para outro            #
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : Buffer origem                                      #
#       A1 : Buffer destino                                     #
#       A2 : Qtd de words                                       #
# RETORNOS:                                                  	#
#       (nenhum)                                                #
#################################################################

# Prefixo interno: P_CB2_

PROC_COPIAR_BUFFER_WORD:
        blez a2, P_CB2_FIM
P_CB2_LOOP:
        lw t0, (a0)
        sw t0, (a1)
        addi a0, a0, 4
        addi a1, a1, 4
        addi a2, a2, -1
        bgtz a2, P_CB2_LOOP # continua copiando se ainda faltam words
P_CB2_FIM:
        ret