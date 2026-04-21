#################################################################
# PROC_ARQUIVO_EXISTE                                           #
# Retorna o status de existencia de um arquivo.                 #
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : nome do arquivo (string)                           #
# RETORNOS:                                                  	#
#       A0 : se existe (1) ou nao (0)                           #
#################################################################


PROC_ARQUIVO_EXISTE:
        # a0 carregado
        li a1, 0	# read-only
	li a7, 1024     # abrir arquivo
	ecall

        li t0, -1
        slt t0, t0, a0     # seta t0 como 1 se o arquivo existe, 0 se nao

        # a0 carregado
        li a7, 57       # fecha o arquivo
        ecall

        mv a0, t0       # retorna o estado de existencia do arquivo em questao
        ret

