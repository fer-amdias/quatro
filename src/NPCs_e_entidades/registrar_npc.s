#################################################################
# PROC_REGISTRAR_NPC                                            #
# Adiciona um NPC ah fase na memoria.                           #
# 							        #
# ARGUMENTOS:						        #
#	A0 : NUMERO DO NPC                                      #
#	A1 : X                                                  #
#       A2 : Y                                                  #
#							        #
# RETORNOS:                                                     #
#       (nenhum)                                                #
#################################################################

# Prefixo interno: P_RN1_

PROC_REGISTRAR_NPC:						
        # t1 = endereco do contador
        # t2 = contador de npcs
        la t1, CONTADOR_NPCS
        lbu t2, (t1)

        # agora temos que saber se eh inimigo
        la t3, STRUCTS_NPCS
        li t4, NPC_STRUCT_TAMANHO    # pega o tamanho de uma struct

        # t5 = tipo de npc * tamanho struct (pega quantas structs devemos avancar)
        mul t5, a0, t4
        add t3, t3, t5		# avanca pra struct certa
        lbu t4, NPC_STRUCT_ATRIBUTO_INIMIGO(t3)	# pega se eh inimigo
        beqz t4, P_RN1_REGISTRAR_NPC_CONT        # se n eh, n conta como inimigo
        
        # se EH inimigo, incrementa o contador de inimigos
        la t4, CONTADOR_INIMIGOS
        lb t5, 0(t4)
        addi t5, t5, 1
        sb t5, (t4)

P_RN1_REGISTRAR_NPC_CONT:
        la t0, NPCS_DIRECAO	# Vdi : Vetor direcao de npcs
        add t0, t2, t0          # avanca CONTADOR_NPCS posicoes
        lbu t4, NPC_STRUCT_ATRIBUTO_DIRECAO_INICIAL(t3)	# pega a direcao inicial dele
        sb t4, (t0)             # salva no lugar apropriado

        la t0, NPCS
        add t0, t2, t0          # avanca CONTADOR_NPCS posicoes
        sb a0, (t0)			# salva o npc no vetor de npcs

        la t0, NPCS_POSICAO
        slli t6, t2, 2                  # pega 4 * CONTADOR_NPC
        add t0, t6, t0                  # avanca CONTADOR_NPC words
        sh a1, (t0)			# salva a posicao X do npc no vetor de posicao (Vpi)
        sh a2, 2(t0)			# salva a posicao Y do npc no vetor de posicao (Vpi)
        
        # terminamos!
        addi t2, t2, 1

        sb t2, (t1)			# atualiza o contador de npcs
        
        la t1, NPCS_QUANTIDADE
        sw t2, (t1)			# atualiza a quantidade de npcs

        ret