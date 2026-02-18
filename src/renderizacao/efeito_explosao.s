#################################################################
# PROC_EFEITO_EXPLOSAO				       	     	#
# Treme a tela e toca o som de explosao                         #
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : MODO                                               #
#       (0 = Comecar efeito de explosao, 1 = continuar efeito)  #
# RETORNOS:                                                  	#
#       NENHUM                                                  #
#################################################################

# PREFIXO INTERNO: P_EE1_

# usar multiplos de 4 pra auxiliar na divisao
.eqv TEMPO_EFEITO_BOMBA 128

.data

EFEITO_EXPLOSAO_TIMESTAMP: .word 0

.text

PROC_EFEITO_EXPLOSAO:
        beqz a0, P_EE1_COMECAR_EFEITO
        
        csrr t0, time
        lw t1, EFEITO_EXPLOSAO_TIMESTAMP
        sub t0, t0, t1

        # desativa o efeito se o tempo de explosao tiver acabado ou se as configuracoes nao permitirem ele
        lb t1, EFEITO_EXPLOSAO
        beqz t1, P_EE1_DESATIVAR_EFEITO
        li t1, TEMPO_EFEITO_BOMBA
        bge t0, t1, P_EE1_DESATIVAR_EFEITO


P_EE1_CONTINUAR_EFEITO:
        # l =
        #       2, se nao passou metade do tempo
        #       1, se passou metade do tempo
        #
        # pega numeros aleatorios a, b em [0, 2l]
        # a -= l, b -= l
        # tela_deslocamento_x = a
        # tela_deslocamento_y = b
        # ret

        # t0 = tempo elapsado
        # t1 = tempo maximo
        # t2 = metado do tempo

        srli t2, t1, 1

        # t2 = se nao passou metade do tempo
        slt t2, t0, t2

        # t2 = 2(t2+1) = 4 se t2 = 1, 2 se t2 = 0
        addi t2, t2, 1
        #slli t2, t2, 1

        # t2 = l

        # t3 = 2l+1
        slli t3, t2, 1
        addi t3, t3, 1

        csrr a0, time			        # index do gerador
        mv a1, t3                               # 2l+1
	li a7, 42                               # RandIntRange
	ecall                                   # chama RandIntRange [0, 2l+1[ 

        # numero aleatorio 1 em t0
        mv t0, a0                            

        csrr a0, time			        # index do gerador
        mv a1, t3                               # 2l+1
	li a7, 42                               # RandIntRange
	ecall                                   # chama RandIntRange [0, 2l+1[    

        # numero aleatorio 2 em t1
        mv t1, a0               

        # subtrai l. t0 e t1 agora estao em [-l,+l]
        sub t0, t0, t2
        sub t1, t1, t2

        sb t0, FASE_DESLOCAMENTO_X, t2
        sb t1, FASE_DESLOCAMENTO_Y, t2

        ret
P_EE1_DESATIVAR_EFEITO:
        sb zero, FASE_DESLOCAMENTO_X, t0
        sb zero, FASE_DESLOCAMENTO_Y, t0
        ret

P_EE1_COMECAR_EFEITO:
        csrr t0, time
        sw t0, EFEITO_EXPLOSAO_TIMESTAMP, t1

        lb t0, EXPLOSOES_MUTADAS
        bnez t0, P_EE1_RET

        # toca o efeito sonoro de bomba
	li a0, 37		
        li a1, 2000		# 2000 ms
        li a2, 127		# instrumento de explosao
        li a3, 127		# volume maximo
        li a7, 31		# MidiOut
        ecall

P_EE1_RET:
        ret