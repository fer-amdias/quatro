# EDITOR_CARREGAR_FASE_V0			       	
# Carrega uma fase de versao 0.X.X.X para a memoria
# ARGUMENTOS:						     	
#	A0 : string com o nome da fase                        
# RETORNOS:                                                  
#       A0 : 0 se houve sucesso em carregar a fase. -1 se ocorreu um erro.

EDITOR_CARREGAR_FASE_V0:
        addi sp, sp, -8
        sw ra, (sp)
        sw s0, 4(sp)             # file descriptor

E_CF3_ABRIR_ARQUIVO:
	# a0 carregado
	li a1, 0	        # read-only
	li a7, 1024             # abrir arquivo
	ecall

	bltz a0, E_CF3_FALHA
	# se a0 < 0, entao nao foi possivel carregar a fase!

        mv s0, a0               # guarda o descritor de arquivo em s0

        # s0 = descritor de arquivo

E_CF3_CALCULAR_TAMANHO:

        # criamos uma nova fase para carregar os dados padrao, para DEPOIS sobrescrever o TILEMAP_BUFFER
        # se nao fizermos isso, FASE_METADATA nao serah atualizada!
        jal EDITOR_NOVA_FASE

        # agora tentamos ler

        mv a0, s0
        la a1, TILEMAP_BUFFER
        li a2, 8                # vamos ler as duas primeiras words
        li a7, 63               # ler
        ecall

        # a0 contem a quantidade de bytes lidos

        li t0, 8
        blt a0, t0, E_CF3_FALHA # se nao conseguimos ler OITO BITS, nao tem esperanca. 

        # pega as dimensoes da textura
        la t0, TILEMAP_BUFFER
        lw t1, (t0)
        lw t2, 4(t0)

        # falha se dimensoes invalidas
        bltz t1, E_CF3_FALHA
        bltz t2, E_CF3_FALHA
        
        mul t0, t1, t2          # pega o tamanho que a textura tem, em bytes

        # falha se overflow
        bltz t0, E_CF3_FALHA
        

E_CF3_LER_ARQUIVO:

        # agora lemos tudo de uma vez
        mv a0, s0               # file descriptor
        la a1, TILEMAP_BUFFER
        addi a1, a1, 8          # pula os bytes que jah lemos
        mv a2, t0               # quantidade
        li a7, 63               # LER
        ecall

        mv a0, s0               
        li a7, 57               # fecha o arquivo
        ecall

E_CF3_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        addi sp, sp, 8
        ret

E_CF3_FALHA:
        mv a0, s0               
        li a7, 57               # fecha o arquivo
        ecall

        li a0, -1               # retorna erro
        j E_CF3_RET