#################################################################
# PROC_TEMPO_MANAGER 				       	     	#
# Seta ou atualiza o tempo limite da fase                       #
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : modo (0 = setar novo tempo, 1 = tick)              #
#	A1 : (CASO MODO 0: novo tempo a ser setado)             #
# RETORNOS:                                                  	#
#       (nenhum)                                             	#
#################################################################

# prefixo interno: P_TM1_

.data

ULTIMA_ATUALIZACAO_TIMESTAMP: .word 0

.text

PROC_TEMPO_MANAGER:

                beqz a0, P_TM1_SETAR_TEMPO     

                lw t0, ULTIMA_ATUALIZACAO_TIMESTAMP     # carrega a ultima vez que atualizamos os segundos
                addi t0, t0, 1000                       # adiciona 1 segundo ao timestamp 

                csrr t1, time                       

                bgt t1, t0, P_TM1_TICK                  # decrementa em 1 segundo o tempo atual se o tempo atual estah mais de um segundo a frente do timestamp
                                                
                ret                                     # senao, nao faz nada

# modo 0
P_TM1_SETAR_TEMPO:

                csrr t0, time
                sw t0, ULTIMA_ATUALIZACAO_TIMESTAMP, t1 # coloca AGORA como a ultima atualizacao
                sw a1, SEGUNDOS_RESTANTES, t1           # seta os segundos restantes
                ret

P_TM1_TICK:
                csrr t0, time
                sw t0, ULTIMA_ATUALIZACAO_TIMESTAMP, t1 # coloca AGORA como a ultima atualizacao
                lw t0, SEGUNDOS_RESTANTES
                bltz t0, P_TM1_FIM                      # nao atualiza se o tempo for negativo! significa que nao hah limite de tempo
                addi t0, t0, -1
                sw t0, SEGUNDOS_RESTANTES, t1           # subtrai um dos segundos restantes

P_TM1_FIM:
                ret







