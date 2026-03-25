#################################################################
# PROC_CARREGAR_FASE                                            #
# Carrega uma fase no jogo a partir de uma string com o nome do #
# arquivo.                                                      #
# 							        #
# ARGUMENTOS:						        #
#	A0 : NOME DO ARQUIVO DE FASE                            #
#							        #
# RETORNOS:                                                     #
#       A0 : FLAG DE STATUS (1 = OK, -1 = ERRO)                 #
#################################################################

# Prefixo interno: P_CF2_

.data

CF2_BUFF_HEADER: .word 4
CF2_BUFF_VERSAO: .word 4

CF2_HEADER_V1_EM_DIANTE: .byte '4' 'L' 'V' 'L'
CF2_VERSAO_1_0_0_0: .byte 1, 0, 0, 0

.text

PROC_CARREGAR_FASE:

        addi sp, sp, -12
        sw ra, (sp)
        sw s0, 4(sp) # file descriptor
        sw s1, 8(sp) # nome do arquivo

P_CF2_ABRIR_ARQUIVO:
        mv s1, a0       # salva o nome do arquivo

	# a0 carregado
	li a1, 0	# read-only
	li a7, 1024     # abrir arquivo
	ecall

	bltz a0, P_CF2_FALHA
	# se a0 < 0, entao nao foi possivel carregar a fase!

        mv s0, a0       # guarda o descritor de arquivo em s0

        # s0 = descritor de arquivo
P_CF2_LER_HEADER:

        mv a0, s0       # pega o arquivo aberto atual
        la a1, CF2_BUFF_HEADER
        li a2, 4        # vamos ler o header (1 word)
        li a7, 63       # ler
        ecall

        lw t0, CF2_BUFF_HEADER  # pega o header lido
        lw t1, CF2_HEADER_V1_EM_DIANTE # pega o header de um arquivo de fase

        bne t0, t1, P_CF2_FALHA # se nao for uma fase valida ou se for uma fase do modelo antigo, NAO carrega. 

P_CF2_CARREGAR_ARQUIVO_V1_EM_DIANTE:
        mv a0, s0       # pega o arquivo aberto atual
        la a1, CF2_BUFF_VERSAO
        li a2, 4        # vamos ler a versao (1 word)
        li a7, 63       # ler
        ecall

        lw t0, CF2_BUFF_VERSAO
        lw t1, CF2_VERSAO_1_0_0_0

        # descarta o numero de build e de bug fix
        srli t0, t0, 16
        srli t1, t1, 16

        beq t0, t1, P_CF2_CARREGAR_ARQUIVO_V1_0

        j P_CF2_FALHA   # se chegamos aqui, nao conhecemos como implementar a versao atual

P_CF2_CARREGAR_ARQUIVO_V1_0:
        mv a0, s0       # coloca o descritor de arquivo
        li a7, 57       # fecha ele
        ecall

        mv a0, s1       # recupera o nome do arquivo e diz para esse procedimento o abrir
        jal PROC_CARREGAR_FASE_V1_0
        bltz a0, P_CF2_FALHA # se retornou falha, retorna falha tbm

        j P_CF2_SUCESSO

P_CF2_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        addi sp, sp, 12
        ret

P_CF2_SUCESSO:
        li a0, 1        # retorna sucesso
        j P_CF2_RET

P_CF2_FALHA:
        mv a0, s0       # coloca o descritor de arquivo
        li a7, 57       # fecha ele
        ecall

        li a0, -1       # retorna erro
        j P_CF2_RET