# EDITOR_SALVAR_FASE				       	
# Carrega uma textura de um binario para o buffer de fase
# ARGUMENTOS:						     	
#	A0 : string com o nome da fase                          
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

E_SF2_ESCREVER_HEADER:

        mv a0, s0                       # file descriptor
        la a1, FASE_ARQUIVO_HEADER      # buffer de onde vamos escrever
        li a2, 8                        # 8 bytes de header
        li a7, 64               # ESCREVER
        ecall

E_SF2_ESCREVER_METADATA:

        # para calcular o tamanho da metadata:
        li t0, TAMANHO_STRING_METADATA
        li t1, 10               # os 10 nomes de arquivos
        mul t0, t0, t1          
        
        addi t0, t0, 16         # os 4 marcadores

        mv a0, s0               # file descriptor
        la a1, FASE_METADATA    # buffer de onde vamos escrever
        mv a2, t0               # quantidade
        li a7, 64               # ESCREVER
        ecall

E_SF2_ESCREVER_TILEMAP:

        # a quantidade de tiles a serem escritos eh o tamanho do tilemap (L * C)
        la t0, TILEMAP_BUFFER
        lw t1, (t0)
        lw t2, 4(t0)
        mul t0, t1, t2

        # a qtd de bytes eh tiles*sizeof(tile) + largura e comprimento (8 bytes)
        lw t1, TAMANHO_STRUCT_TILE
        mul t0, t0, t1
        addi t0, t0, 8

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