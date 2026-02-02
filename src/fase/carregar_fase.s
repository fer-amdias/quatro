#################################################################
# PROC_CARREGAR_FASE                                            #
# Carrega uma fase no jogo a partir de uma string com o nome do #
# arquivo.                                                      #
# 							        #
# ARGUMENTOS:						        #
#	A0 : NOME DO ARQUIVO DE FASE                            #
#							        #
# RETORNOS:                                                     #
#       (nenhum)                                                #
#################################################################

# Prefixo interno: P_CF2_

.data

CF2_DATA_CODIGO_DE_ERRO: .string "FALHA_CARREGAMENTO_DE_FASE"

.text

PROC_CARREGAR_FASE:
        addi sp, sp, -4
        sw ra, (sp)

	# a0 carregado
	li a1, 0	# read-only
	li a7, 1024     # abrir arquivo
	ecall

	bltz a0, E_CT1_FALHA
	# se a0 < 0, entao nao foi possivel carregar a fase!

        mv t0, a0       # guarda o descritor de arquivo em t0

        #a0 carregado
        la a1, MAPA_ORIGINAL_BUFFER     # vamos guardar no buffer de mapa
        li a2, 8        # vamos ler as duas primeiras words
        li a7, 63       # ler
        ecall

        # a0 contem a quantidade de bytes lidos

        li t1, 8
        blt a0, t1, E_CT1_FALHA # se nao conseguimos ler OITO BITS, nao tem esperanca. 

        # pega as dimensoes do tilemap
        la t1, MAPA_ORIGINAL_BUFFER
        lw t2, (t1)
        lw t3, 4(t1)

        # desinverte elas 
        sw t3, (t1)
        sw t2, 4(t1)

        # falha se dimensoes invalidas
        bltz t2, E_CT1_FALHA
        bltz t3, E_CT1_FALHA
        
        mul t1, t2, t3          # pega o tamanho que a textura tem, em bytes

        # falha se overflow
        bltz t1, E_CT1_FALHA
        
        # falha se dimensoes invalidas
        li t2, TAMANHO_MAX_TILEMAP
        bgt t1, t2, E_CT1_FALHA

E_CT1_LER_ARQUIVO:
        # agora lemos tudo de uma vez
        mv a0, t0               # file descriptor
        la a1, MAPA_ORIGINAL_BUFFER
        addi a1, a1, 8          # pula os bits que jah lemos
        mv a2, t1               # quantidade
        li a7, 63               # LER
        ecall

E_CT1_FIM_CARREGAMENTO:
        mv t1, a0               # guarda temporariamente a qtd de bytes lidos em t1

        mv a0, t0               # descritor de arquivo
        li a7, 57               # fechar arquivo
        ecall

        mv a0, t1               # retorna quantos bytes foram lidos

        jal PROC_INICIALIZAR_POSICAO_DO_MAPA

        jal PROC_CRIAR_FASE_NA_MEMORIA

        lw ra, (sp)
        addi sp, sp, 4
        ret

E_CT1_FALHA:
        la a0, CF2_DATA_CODIGO_DE_ERRO
        j ROTINA_ERRO_FATAL
