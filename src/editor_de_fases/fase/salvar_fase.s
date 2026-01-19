# EDITOR_SALVAR_FASE				       	
# Carrega uma textura de um binario para o buffer de fase
# ARGUMENTOS:						     	
#	A0 : string com o nome da textura                          
# RETORNOS:                                                  
#       A0 : quantidade de bytes lidos. -1 se houve uma falha.

EDITOR_SALVAR_FASE:

        addi sp, sp, -4
        sw s0, (sp) # file descriptor

E_SF2_ABRIR_ARQUIVO:
	# a0 carregado
	li a1, 1	# write-create
	li a7, 1024     # abrir arquivo
	ecall

	bltz a0, E_SF2_FALHA
	# se a0 < 0, entao nao foi possivel abrir a fase!

        mv s0, a0       # guarda o descritor de arquivo em s0

        # s0 = descritor de arquivo

        # a quantidade de bytes a serem escritos eh o tamanho do tilemap (L * C) + metadata (8 bytes)
        la t0, TILEMAP_BUFFER
        lw t1, (t0)
        lw t2, 4(t0)
        mul t0, t1, t2
        addi t0, t0, 8

E_SF2_ESCREVER:
        # agora escrevemos
        mv a0, s0               # file descriptor
        la a1, TILEMAP_BUFFER
        mv a2, t0               # quantidade
        li a7, 64               # ESCREVER
        ecall

E_SF2_RET:
        mv t0, a0               # guarda temporariamente a qtd de bytes escritos em t0

        mv a0, s0               # coloca
        li a7, 57       # fechar arquivo
        ecall

        mv a0, t0               # retorna quantos bytes foram escritos

        lw s0, (sp)
        addi sp, sp, 4
        ret

E_SF2_FALHA:
        li a0, -1               # retorna erro
        j E_SF2_RET