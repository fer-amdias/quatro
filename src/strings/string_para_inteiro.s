#################################################################
# PROC_STRING_PARA_INTEIRO                                      #
# Recebe uma string e retorna um inteiro (e uma flag de erro,   #
# caso a string nao possa ser convertida)                       #
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : String                                             #
#                                                               #
# RETORNOS:                                                  	#
#       A0 : Inteiro                                            #
#       A1 : Flag de erro (1 se houve erro, 0 se nao            #
#################################################################

# Prefixo interno: P_SI1_

PROC_STRING_PARA_INTEIRO:
        li t2, 1                        # comeca com o marcador de sinal como POSITIVO

        lb t0, (a0)                     # pega o primeiro caractere    
        li t1, ' '                      # compara com o espaco
        beq t0, t1, P_IS1_LOOP_DESCARTAR_ESPACOS

        j P_IS1_CONT

P_IS1_LOOP_DESCARTAR_ESPACOS:
        addi a0, a0, 1                  # pula um caractere
        lb t0, (a0)                     # compara ele com o espaco
        beq t0, t1, P_IS1_LOOP_DESCARTAR_ESPACOS # continua descartando se houver mais espacos

P_IS1_CONT:
        li t3, '-'
        bne t0, t3, P_IS1_CONT2         # se o proximo caractere NAO for um sinal de menos, continua normalmente

        li t2, -1                       # coloca o marcador de sinal como NEGATIVO
        addi a0, a0, 1                  # avanca um caractere

P_IS1_CONT2:
        li t3, '+'
        bne t0, t3, P_IS1_SETUP         # se o proximo caractere NAO for um sinal e mais, continua normalmente

        addi a0, a0, 1                  # pula o sinal de +

P_IS1_SETUP:
        # pega nossas lower e upper bounds
        li t3, '0'
        li t4, '9'

        # vamos guardar nosso resultado em t5
        mv t5, zero
P_SI1_LOOP:
        lb t0, (a0)                     # pega o caractere atual
        addi a0, a0, 1                  # vai pro proximo caractere
        beqz t0, P_SI1_PROCESSAR_RESULTADO # sai do loop se chegamos no fim da string
        beq t0, t1, P_SI1_PROCESSAR_RESULTADO # sai do loop se houver um espaco (fim do numero)

        # da erro se sairmos dos caracteres aceitaveis
        blt t0, t3, P_SI1_ERR
        bgt t0, t4, P_SI1_ERR

        # pega t5*8 + t5*2, que eh t5*10
        slli t6, t5, 3
        slli t5, t5, 1
        add t5, t5, t6

        addi t0, t0, -48                  # converte de ASCII para digito
        add t5, t5, t0                  # adiciona o digito ao resultado

        # agora temos t5*10+d. e.g. Se o resultado anterior era 10 e o novo digito eh 8, temos 10*10 + 8 = 108.
        j P_SI1_LOOP # continua


P_SI1_ERR:
        li a0, 0                        # retorna 0
        li a1, 1                        # retorna TRUE para a flag de erro
        ret

P_SI1_PROCESSAR_RESULTADO:
        bgez t2, P_SI1_FIM              # se o marcador de sinal nao for negativo, continua normalmente
        neg t5, t5                      # se for, nega o resultado

P_SI1_FIM:
        mv a0, t5                       # retorna o resultado
        mv a1, zero                     # retorna FALSE para a flag de erro
        ret


