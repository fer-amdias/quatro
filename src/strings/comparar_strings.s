#################################################################
# PROC_COMPARAR_STRINGS                                         #
# Recebe duas strings. Retorna um valor negativo se a primeira  #
# for alfabeticamente menor que a segunda, um valor positivo se #
# a primeira for maior, e 0 se as duas forem iguais.            #
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : String 1                                           #
#       A1 : String 2                                           #
#                                                               #
# RETORNOS:                                                  	#
#       A0 : Valor de retorno                                   #
#################################################################

# Prefixo interno: P_CS2_

PROC_COMPARAR_STRINGS:

P_CS2_LOOP:
        lb t0, (a0)             # carrega s1[i]
        lb t1, (a1)             # carrega s2[i]
        bne t0, t1, P_CS2_FIM   # se os caracteres do index atual nao forem iguais, ja podemos saber qual eh alfabeticamente menor
        beqz t0, P_CS2_FIM      # se chegarmos ao final da String 1, ja podemos saber tbm
        addi a0, a0, 1          # incrementa o index
        addi a1, a1, 1          # incrementa o index
        j P_CS2_LOOP            # continua o loop

P_CS2_FIM:
        sub a0, t0, t1          # retorna s1[i] - s2[i]. 
                                        #Se s1 for menor alfabeticamente, o resultado sera negativo.
                                        #Se s1 == s2, o resultado sera 0.
                                        #Se s2 for menor alfabeticamente, o resultado sera positivo
        ret