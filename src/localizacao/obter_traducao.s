#################################################################
# PROC_OBTER_TRADUCAO                                           #
# Retorna o endereço da string de tradução em locale.s de uma   #
# chave fornecida.                                              #
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : Chave de locale                                    #
#                                                               #
# RETORNOS:                                                  	#
#       A0 : Endereco da string de traducao                     #
#               (retorna a propria chave se n encontrada)       #
#       A1 : Se a chave foi encontrada (1 se sim, 0 se nao)     #
#################################################################

# Prefixo interno: P_OT1_

PROC_OBTER_TRADUCAO:
        addi sp, sp, -24
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)
        sw s2, 12(sp)
        sw s3, 16(sp)
        sw s4, 20(sp)

        mv s0, a0                       # guarda o modo

        la s1, offset                   # pega o endereco da tabela de offsets
        la s2, strblock                 # pega as strings do jogo
        lb s3, qtd_de_linguas           # pega a quantidade de linguas 
        slli s3, s3, 2                  # multiplica qtd_linguas por 4 (tamanho de uma word)
        la s4, offset_fim               # pega o endereco do fim da tabela de offsets
P_OT1_LOOP:
        bge s1, s4, P_OT1_N_ENCONTRADA  # se &(offset[i]) >= &offset_fim, retorna que nao encontramos

        lw t0, (s1)                     # pega a entrada de offset atual da tabela na coluna 0 (tags)
        add a1, s2, t0                 # pega strblock+[offset], conseguindo a tag correspondente
        mv a0, s0                       # pega a chave fornecida
        jal PROC_COMPARAR_STRINGS       # compara as duas strings

        beqz a0, P_OT1_ENCONTRADA       # se elas forem iguais, retorna a traducao desejada

        add s1, s1, s3                  # pula [qtd_linguas] words, pulando para a proxima linha na mesma coluna
        j P_OT1_LOOP

P_OT1_ENCONTRADA:
        lb t0, lingua_atual
        slli t0, t0, 2                      # pega lingua_atual*sizeof(word)
        add s1, s1, t0                  # avanca [lingua_atual] colunas, para a coluna certa
        lw t0, (s1)                     # pega o valor de offset da tabela
        add a0, s2, t0                  # retorna o endereco correto em strblock
        li a1, 1                        # retorna flag de chave encontrada como TRUE
        j P_OT1_RET

P_OT1_N_ENCONTRADA:
        mv a0, s0                       # retorna a propria chave
        mv a1, zero                     # retorna flag de chave encontrada como FALSE
        j P_OT1_RET

P_OT1_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        lw s2, 12(sp)
        lw s3, 16(sp)
        lw s4, 20(sp)
        addi sp, sp, 24
        ret
        