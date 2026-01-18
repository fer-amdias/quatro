# EDITOR_CARREGAR_TEXTURA				       	
# Carrega uma textura de um binario para o buffer de fase
# ARGUMENTOS:						     	
#	A0 : string com o nome da textura                          
# RETORNOS:                                                  
#       A0 : quantidade de bytes lidos. -1 se houve uma falha.

EDITOR_CARREGAR_TEXTURA:

        addi sp, sp, -4
        sw s0, (sp) # file descriptor

E_CT1_ABRIR_ARQUIVO:
	# a0 carregado
	li a1, 0	# read-only
	li a7, 1024     # abrir arquivo
	ecall

	bltz a0, E_CT1_FALHA
	# se a0 < 0, entao nao foi possivel abrir a fase!

        mv s0, a0       # guarda o descritor de arquivo em s0

        # s0 = descritor de arquivo

E_CT1_CALCULAR_TAMANHO:
        # a0 carregado
        la a1, TEXTURA_BUFFER
        li a2, 8        # vamos ler as duas primeiras words
        li a7, 63       # ler
        ecall

        # a0 contem a quantidade de bytes lidos

        li t0, 8
        blt a0, t0, E_CT1_FALHA # se nao conseguimos ler OITO BYTES, nao tem esperanca. 

        # pega as dimensoes da textura
        la t0, TEXTURA_BUFFER
        lw t1, (t0)
        lw t2, 4(t0)
        
        mul t0, t1, t2          # pega o tamanho que a textura tem, em bytes
        

E_CT1_LER_ARQUIVO:
        # agora lemos tudo de uma vez
        mv a0, s0               # file descriptor
        la a1, TEXTURA_BUFFER
        addi a1, a1, 8          # pula os bytes que jah lemos
        mv a2, t0               # quantidade
        li a7, 63               # LER
        ecall

        mv t0, a0               # guarda temporariamente a qtd de bytes lidos em t0

        mv a0, s0               # coloca
        li a7, 57       # fechar arquivo
        ecall

        mv a0, t0               # retorna quantos bytes foram lidos

E_CT1_RET:

        lw s0, (sp)
        addi sp, sp, 4
        ret

E_CT1_FALHA:
        li a0, -1               # retorna erro
        j E_CT1_RET