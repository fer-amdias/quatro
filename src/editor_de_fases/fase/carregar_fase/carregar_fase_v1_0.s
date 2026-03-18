# EDITOR_CARREGAR_FASE_V1_0			       	
# Carrega uma fase de versoes 1.0.X.X para a memoria.
# ARGUMENTOS:						     	
#	A0 : string com o nome da fase                        
# RETORNOS:                                                  
#       A0 : 0 se houve sucesso em carregar a fase. -1 se ocorreu um erro.

EDITOR_CARREGAR_FASE_V1_0:
        addi sp, sp, -8
        sw ra, (sp)
        sw s0, 4(sp) # file descriptor

E_CF2_ABRIR_ARQUIVO:
	# a0 carregado
	li a1, 0	# read-only
	li a7, 1024     # abrir arquivo
	ecall

	bltz a0, E_CF2_FALHA
	# se a0 < 0, entao nao foi possivel carregar a fase!

        mv s0, a0       # guarda o descritor de arquivo em s0

        # s0 = descritor de arquivo

E_CF2_LER_ARQUIVO:
        # primeiro, lemos os header e a versao
        mv a0, s0               # file descriptor
        la a1, FASE_ARQUIVO_HEADER
        li a2, 8                # duas words
        li a7, 63               # LER
        ecall

        # depois, lemos a metadata
        mv a0, s0               # file descriptor
        la a1, FASE_METADATA
        li a2, 128              # tamanho de uma string na versao 1.0
        li t0, 10
        mul a2, a2, t0          # sao 10 strings!!
        addi a2, a2, 16         # (2 marcadores + 1 limite de tempo + tamanho_struct_tile) * sizeof(word)
        li a7, 63               # LER
        ecall

        # finalmente, lemos as dimensoes do mapa
        mv a0, s0               # file descriptor
        la a1, TILEMAP_BUFFER
        li a2, 8                # (1 Largura e 1 Altura) * sizeof(word)
        li a7, 63               # LER
        ecall

        la t0, TILEMAP_BUFFER
        lw t1, 0(t0)            # pega a largura
        lw t2, 4(t0)            # pega a altura

        lw t3, TAMANHO_STRUCT_TILE # pega o tamanho de um tile

        mul t4, t1, t2          # pega 
        mul t4, t0, t3          #       largura * altura * sizeof(tile)
                                # que eh a qtd de bytes que estarao no nosso tilemap

        mv a0, s0               # file descriptor
        la a1, TILEMAP_BUFFER
        addi a1, a1, 8          # pula os 8 bytes que jah lemos anteriormente
        mv a2, t4               # pega sizeof(tilemap) calculando anteriormente
        li a7, 63               # LER
        ecall

        mv a0, s0              
        li a7, 57               # agora podemos fechar o arquivo
        ecall

        # agora temos tudo em memoria
        # vamos pegar todas as strings que colocamos na metadata e carrega-las propriamente para os buffers associados

        jal EDITOR_CARREGAR_METADADOS

        li a0, 1                # retorna sucesso
E_CF2_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        addi sp, sp, 8
        ret

E_CF2_FALHA:
        mv a0, s0              
        li a7, 57               # primeiro fecha o arquivo
        ecall

        li a0, -1               # depois, retorna erro
        j E_CF2_RET