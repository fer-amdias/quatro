#################################################################
# PROC_CARREGAR_FASE_V1_0                                       #
# Carrega uma fase de versoes 1.0.X.X do jogo a partir de uma   #
# string com o nome do arquivo.                                 #
# 							        #
# ARGUMENTOS:						        #
#	A0 : NOME DO ARQUIVO DE FASE                            #
#							        #
# RETORNOS:                                                     #
#       A0 : FLAG DE STATUS (1 = OK | -1 = ERRO)                #
#################################################################

.data

CF4_HEADER_BUFF: .space 8       # onde vamos guardar o header do arquivo

.text

PROC_CARREGAR_FASE_V1_0:
        addi sp, sp, -8
        sw ra, (sp)
        sw s0, 4(sp) # file descriptor

P_CF4_ABRIR_ARQUIVO:
	# a0 carregado
	li a1, 0	# read-only
	li a7, 1024     # abrir arquivo
	ecall

	bltz a0, P_CF4_FALHA
	# se a0 < 0, entao nao foi possivel carregar a fase!

        mv s0, a0       # guarda o descritor de arquivo em s0

        # s0 = descritor de arquivo

P_CF4_LER_ARQUIVO:
        # primeiro, pulamos o header e a versao
        mv a0, s0               # file descriptor
        li a1, 8                # 8 bytes (2 words)
        li a2, 1                # a partir da posicao atual
        li a7, 62               # SEEK -- avanca 8 bytes
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
        la a1, MAPA_ORIGINAL_BUFFER
        li a2, 8                # (1 Largura e 1 Altura) * sizeof(word)
        li a7, 63               # LER
        ecall

        la t0, MAPA_ORIGINAL_BUFFER
        lw t1, 0(t0)            # pega a altura
        lw t2, 4(t0)            # pega a largura

        # desinverte
        sw t1, 4(t0)
        sw t2, 0(t0)

        lw t3, TAMANHO_STRUCT_TILE # pega o tamanho de um tile

        mul t4, t1, t2          # pega 
        mul t4, t0, t3          #       largura * altura * sizeof(tile)
                                # que eh a qtd de bytes que estarao no nosso tilemap

        mv a0, s0               # file descriptor
        la a1, MAPA_ORIGINAL_BUFFER
        addi a1, a1, 8          # pula os 8 bytes que jah lemos anteriormente
        mv a2, t4               # pega sizeof(tilemap) calculando anteriormente
        li a7, 63               # LER
        ecall

        # finalmente, criamos a fase
	jal PROC_CRIAR_FASE_NA_MEMORIA

        mv a0, s0              
        li a7, 57               # agora podemos fechar o arquivo
        ecall

        li a0, 1                # retorna sucesso
P_CF4_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        addi sp, sp, 8
        ret

P_CF4_FALHA:
        mv a0, s0              
        li a7, 57               # primeiro fecha o arquivo
        ecall

        li a0, -1               # depois, retorna erro
        j P_CF4_RET