#################################################################
# PROC_INTEIRO_PARA_STRING                                      #
# Recebe uma word e coloca-a como string em um buffer           #
# fornecido.                                                    #
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : Inteiro                                            #
#       A1 : String 2                                           #
#                                                               #
# RETORNOS:                                                  	#
#       (nenhum)                                                #
#################################################################

# Prefixo interno: P_IS2_

PROC_INTEIRO_PARA_STRING:
        li t1, 10               # guarda 10 para divisao dentro do loop
        mv t3, zero             # t3 = contador de digitos
        bgez a0, P_IS2_LOOP     # se o numero nao for negativo, nao devemos inverte-lo

P_IS2_NEGATIVO:
        li t0, '-'
        sb t0, (a1)             # coloca um sinal de negativo
        addi a1, a1, 1          # avanca um caractere
        neg a0, a0              # pega o numero em sua forma positiva

P_IS2_LOOP:
        div t0, a0, t1          # pega a0/10
        rem t2, a0, t1          # pega a0%10 (o digito menos significativo)
        addi t3, t3, 1          # conta um digito
        addi sp, sp, -1         
        sb t2, (sp)             # salva o digito na stack
        mv a0, t0               # coloca a0/10 como o novo numero
        bnez t0, P_IS2_LOOP     # se a0/10 != 0, ent ainda nao lemos o ultimo digito

P_IS2_CONVERTER:
        lb t0, (sp)             # pega um digito da stack
        addi sp, sp, 1          # tira o digito
        addi t0, t0, 48         # converte para ASCII
        sb t0, (a1)             # coloca na string
        addi a1, a1, 1          # vai pro proximo caractere
        addi t3, t3, -1         # decrementa o contador de digitos
        bnez t3, P_IS2_CONVERTER# se ainda tiver digitos faltando, continua
        sb zero, (a1)           # coloca um /0 no final da string

P_IS2_RET:
        ret                     # retorna nada 