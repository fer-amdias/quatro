#################################################################
# PROC_CARREGAR_TEXTURA				       	        #
# Carrega uma textura de um binario para um buffer              #
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : string com o nome da textura                       #
#       A1 : buffer para qual leremos                           #
# RETORNOS:                                                  	#
#       A0 : o endereco do buffer                               #
#       A1 : bytes lidos                                        #
#################################################################

.data

CT1_DATA_CODIGO_DE_ERRO: .string "FALHA_CARREGAMENTO_DE_TEXTURA"

.text

PROC_CARREGAR_TEXTURA:

        addi sp, sp, -8
        sw s0, (sp) # file descriptor
        sw s1, 4(sp)# buffer

        mv s1, a1       # salva o endereco do buffer

P_CT1_ABRIR_ARQUIVO:
	# a0 carregado
	li a1, 0	# read-only
	li a7, 1024     # abrir arquivo
	ecall

	bltz a0, P_CT1_FALHA
	# se a0 < 0, entao nao foi possivel abrir a fase!

        mv s0, a0       # guarda o descritor de arquivo em s0

        # s0 = descritor de arquivo

P_CT1_CALCULAR_TAMANHO:
        # a0 carregado
        mv a1, s1       # buffer argumento
        li a2, 8        # vamos ler as duas primeiras words
        li a7, 63       # ler
        ecall

        # a0 contem a quantidade de bytes lidos

        li t0, 8
        blt a0, t0, P_CT1_FALHA # se nao conseguimos ler OITO BYTES, nao tem esperanca. 

        # pega as dimensoes da textura
        lw t1, (s1)
        lw t2, 4(s1)
        
        mul t0, t1, t2          # pega o tamanho que a textura tem, em bytes
        
        addi s1, s1, 8          # pula os bytes que jah lemos

P_CT1_LER_ARQUIVO:
        # agora lemos tudo de uma vez
        mv a0, s0               # file descriptor
        mv a1, s1               # buffer
        mv a2, t0               # quantidade
        li a7, 63               # LER
        ecall
        bltz a0, P_CT1_FALHA    # se retornou erro, vai pra tela de erro

        mv a0, s0
        li a7, 57       # fechar arquivo
        ecall

        lw s0, (sp)
        lw s1, 4(sp)
        addi sp, sp, 8
        ret

P_CT1_FALHA:

        la a0, CT1_DATA_CODIGO_DE_ERRO
        j ROTINA_ERRO_FATAL