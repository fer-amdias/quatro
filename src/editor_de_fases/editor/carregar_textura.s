# EDITOR_CARREGAR_TEXTURA				       	
# Carrega uma textura de um binario para o buffer fornecido
# ARGUMENTOS:						     	
#	A0 : string com o nome da textura    
#       A1 : buffer para colocar textura                      
# RETORNOS:                                                  
#       A0 : quantidade de bytes lidos. -1 se houve uma falha.

.data

CT1_BUFFER_DIMENSOES: .space 8

.text

EDITOR_CARREGAR_TEXTURA:
        addi sp, sp, -8
        sw s0, (sp) # file descriptor
        sw s1, 4(sp) # buffer destino

E_CT1_ABRIR_ARQUIVO:
        mv s1, a1       # guarda o buffer destino

	# a0 carregado
	li a1, 0	# read-only
	li a7, 1024     # abrir arquivo
	ecall

	bltz a0, E_CT1_FALHA
	# se a0 < 0, entao nao foi possivel abrir a fase!

        mv s0, a0       # guarda o descritor de arquivo em s0

        # s0 = descritor de arquivo
        # s1 = endereco do buffer destino

E_CT1_CALCULAR_TAMANHO:
        # a0 carregado
        la a1, CT1_BUFFER_DIMENSOES
        li a2, 8        # vamos ler as duas primeiras words
        li a7, 63       # ler
        ecall

        # a0 contem a quantidade de bytes lidos

        li t0, 8
        blt a0, t0, E_CT1_FALHA # se nao conseguimos ler OITO BYTES, nao tem esperanca. 

        # pega as dimensoes da textura
        la t0, CT1_BUFFER_DIMENSOES
        lw t1, (t0)
        lw t2, 4(t0)

        # falha se dimensoes invalidas
        bltz t1, E_CT1_FALHA
        bltz t2, E_CT1_FALHA
        
        mul t0, t1, t2          # pega o tamanho que a textura tem, em bytes

        # falha se overflow
        bltz t0, E_CT1_FALHA

        # coloca as dimensoes no buffer
        sw t1, (s1)
        sw t2, 4(s1)
        addi s1, s1, 8
        

E_CT1_LER_ARQUIVO:
        # agora lemos tudo de uma vez
        mv a0, s0               # file descriptor
        mv a1, s1               # buffer de textura
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
        lw s1, 4(sp)
        addi sp, sp, 8
        ret

E_CT1_FALHA:
        li a0, -1               # retorna erro
        j E_CT1_RET