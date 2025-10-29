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

ESTAVA_PAUSADO_ANTERIORMENTE: .byte 0
DEFASAGEM_PAUSA:              .word 0

.text

PROC_TEMPO_MANAGER:

                beqz a0, P_TM1_SETAR_TEMPO     

                lb t0, JOGO_PAUSADO
                bnez t0, P_TM1_PAUSADO                  # nao atualiza o tempo se estiver pausado

                lb t0, ESTAVA_PAUSADO_ANTERIORMENTE
                bnez t0, P_TM1_DESPAUSAR                # carrega o tempo de antes, caso estava pausado

                lw t0, ULTIMA_ATUALIZACAO_TIMESTAMP     # carrega a ultima vez que atualizamos os segundos
                addi t0, t0, 1000                       # adiciona 1s ao timestamp 

                csrr t1, time                       
                bge t1, t0, P_TM1_TICK                  # da um tick no tempo atual se o tempo atual estah 1s ou mais a frente do anterior                                    
                ret                                     # senao, nao faz nada

# modo 0
P_TM1_SETAR_TEMPO:

                csrr t0, time
                sw t0, ULTIMA_ATUALIZACAO_TIMESTAMP, t1 # coloca AGORA como a ultima atualizacao
                sw a1, SEGUNDOS_RESTANTES, t1           # seta os segundos restantes
                #sw x0, DEFASAGEM_PAUSA, t1              # zera a defasagem
                ret

P_TM1_PAUSADO:
                # se estava pausado anteriormente, nao tem nada que devemos fazer
                lb t0, ESTAVA_PAUSADO_ANTERIORMENTE
                bnez t0, P_TM1_FIM

                # se nao estava, precisamos guardar o timestamp atual e a defasagem!
                lw t0, ULTIMA_ATUALIZACAO_TIMESTAMP     # carrega a ultima vez que atualizamos os segundos
                csrr t1, time                           # carrega o tempo atual
                sub t0, t1, t0                          # pega a diferenca entre os tempos (quanto tempo desde a ultima atualizacao)
                sw t0, DEFASAGEM_PAUSA, t1              # guarda a diferenca 
                
                li t0, 1
                sb t0, ESTAVA_PAUSADO_ANTERIORMENTE, t1 # guarda que estava pausado!
                ret                                     # nada mais a ser feito

P_TM1_DESPAUSAR:
                sb x0, ESTAVA_PAUSADO_ANTERIORMENTE, t0 # guarda que nao estava pausado

                csrr t0, time                           # pega o tempo atual
                lw t1, DEFASAGEM_PAUSA
                sub t0, t0, t1                          # subtrai a defasagem de quando pausamos
                # isso faz com que o tempo que tinha passado desde o ultimo tick ateh a pausa seja contabilizado

                sw t0, ULTIMA_ATUALIZACAO_TIMESTAMP, t1 # guarda o timestamp corrigido
                j PROC_TEMPO_MANAGER                    # chama a proc de novo


P_TM1_TICK:
                csrr t0, time
                sw t0, ULTIMA_ATUALIZACAO_TIMESTAMP, t1 # coloca AGORA como a ultima atualizacao
                lw t0, SEGUNDOS_RESTANTES
                bltz t0, P_TM1_FIM                      # nao atualiza se o tempo for negativo! significa que nao hah limite de tempo
                addi t0, t0, -1
                sw t0, SEGUNDOS_RESTANTES, t1           # subtrai um dos segundos restantes

P_TM1_FIM:
                ret







