#################################################################
# PROC_CARREGAR_ARQUIVO_EM_BUFFER                               #
# Carrega o conteudo de um arquivo binario para um buffer       #
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : nome do arquivo (string)                           #
#       A1 : endereco do buffer                                 #
#       A2 : maximo de bytes a serem lidos                      #
# RETORNOS:                                                  	#
#       A0 : numero de bytes lidos (ou -1 se ocorreu um erro    #
#################################################################

# Prefixo interno: P_CA1_

.text

PROC_CARREGAR_ARQUIVO_EM_BUFFER:

        addi sp, sp, -8
        sw s0, (sp) # file descriptor
        sw s1, 4(sp)# buffer

        mv s1, a1       # salva o endereco do buffer

P_CA1_ABRIR_ARQUIVO:
	# a0 carregado
	li a1, 0	# read-only
	li a7, 1024     # abrir arquivo
	ecall

	bltz a0, P_CA1_RET
	# se a0 < 0, entao nao foi possivel abrir a fase! retorna o erro (-1)

        mv s0, a0       # guarda o descritor de arquivo em s0

        # s0 = descritor de arquivo

P_CA1_LER_ARQUIVO:
        # agora lemos tudo de uma vez
        mv a0, s0               # file descriptor
        mv a1, s1               # buffer
        # a2 carregado
        li a7, 63               # LER
        ecall

        mv s1, a0               # guarda a quantidade de bytes lidos em s1 temporariamente

        mv a0, s0
        li a7, 57       # fechar arquivo
        ecall

        mv a0, s1               # retorna a qtd de bytes lidos

P_CA1_RET:

        lw s0, (sp)
        lw s1, 4(sp)
        addi sp, sp, 8
        ret