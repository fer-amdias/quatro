# EDITOR_CARREGAR_FASE			       	
# Carrega uma fase para a memoria.
# ARGUMENTOS:						     	
#	A0 : string com o nome da fase                        
# RETORNOS:                                                  
#       A0 : 0 se houve sucesso em carregar a fase. -1 se ocorreu um erro.

.data

CF1_BUFF_HEADER: .word 4
CF1_BUFF_VERSAO: .word 4

CF1_HEADER_V1_EM_DIANTE: .byte '4' 'L' 'V' 'L'
CF1_VERSAO_1_0_0_0: .byte 1, 0, 0, 0

.text

EDITOR_CARREGAR_FASE:

        addi sp, sp, -12
        sw ra, (sp)
        sw s0, 4(sp) # file descriptor
        sw s1, 8(sp) # nome do arquivo

E_CF1_ABRIR_ARQUIVO:
        mv s1, a0       # salva o nome do arquivo

	# a0 carregado
	li a1, 0	# read-only
	li a7, 1024     # abrir arquivo
	ecall

	bltz a0, E_CF1_FALHA
	# se a0 < 0, entao nao foi possivel carregar a fase!

        mv s0, a0       # guarda o descritor de arquivo em s0

        # s0 = descritor de arquivo
E_CF1_LER_HEADER:

        mv a0, s0       # pega o arquivo aberto atual
        la a1, CF1_BUFF_HEADER
        li a2, 4        # vamos ler o header (1 word)
        li a7, 63       # ler
        ecall

        lw t0, CF1_BUFF_HEADER  # pega o header lido
        lw t1, CF1_HEADER_V1_EM_DIANTE # pega o header de um arquivo de fase

        bne t0, t1, E_CF1_CARREGAR_ARQUIVO_ANTIGO

E_CF1_CARREGAR_ARQUIVO_V1_EM_DIANTE:
        mv a0, s0       # pega o arquivo aberto atual
        la a1, CF1_BUFF_VERSAO
        li a2, 4        # vamos ler a versao (1 word)
        li a7, 63       # ler
        ecall

        lw t0, CF1_BUFF_VERSAO
        lw t1, CF1_VERSAO_1_0_0_0

        # descarta o numero de build e de bug fix
        # (lembre-se que a memoria eh little-endian: 
        # quando lermos uma word, em vez de pegar B3 B2 B1 B0, 
        # vamos pegar B0 B1 B2 B3
        # entao devemos descartar os dois MAIORES bytes para
        # descartar build e bug fix!)
        slli t0, t0, 16
        slli t1, t1, 16

        beq t0, t1, E_CF1_CARREGAR_ARQUIVO_V1_0

        j E_CF1_FALHA   # se chegamos aqui, nao conhecemos como implementar a versao atual

E_CF1_CARREGAR_ARQUIVO_V1_0:
        mv a0, s0       # coloca o descritor de arquivo
        li a7, 57       # fecha ele
        ecall

        mv a0, s1       # recupera o nome do arquivo e diz para esse procedimento o abrir
        jal EDITOR_CARREGAR_FASE_V1_0
        bltz a0, E_CF1_FALHA # se retornou falha, retorna falha tbm
        j E_CF1_SUCESSO

E_CF1_CARREGAR_ARQUIVO_ANTIGO:
        mv a0, s0       # coloca o descritor de arquivo
        li a7, 57       # fecha ele
        ecall

        mv a0, s1       # recupera o nome do arquivo e diz para esse procedimento o abrir
        jal EDITOR_CARREGAR_FASE_V0
        bltz a0, E_CF1_FALHA # se retornou falha, retorna falha tbm
        j E_CF1_SUCESSO

E_CF1_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        addi sp, sp, 12
        ret

E_CF1_SUCESSO:
        li a0, 1        # retorna sucesso
        j E_CF1_RET

E_CF1_FALHA:
        mv a0, s0       # coloca o descritor de arquivo
        li a7, 57       # fecha ele
        ecall

        li a0, -1       # retorna erro
        j E_CF1_RET