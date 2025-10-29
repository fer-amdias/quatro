#################################################################
# 		  DEFINICAO DE STATS DE NPCS                    #
#################################################################
#								#
#  Aqui, se guarda as structs e definicoes sobre NPCs,          #
#  como velocidade e se eh inimigo.                             #
#								#
#  COMO USO ESSE MODULO?					#
#  Basta dar um .include "./definicoes_npcs.s" no inicio de     #
#  memoria.s.	                                                #
#								#
#################################################################


.data

.eqv NAO_EH_INIMIGO     0
.eqv EH_INIMIGO         1

.eqv NPC_STRUCT_TAMANHO 2       

STRUCT_NPCS:
        # NPC 1 - Seta vermelha
        .byte 100                # VELOCIDADE
        .byte EH_INIMIGO        # INIMIGO?
        
        # NPC 2 - Sentinelas Babilonicas
        .byte 100                # VELOCIDADE
        .byte EH_INIMIGO        # INIMIGO?

        # NPC 3 - Ratos
        .byte 160                # VELOCIDADE
        .byte NAO_EH_INIMIGO    # INIMIGO?

        # NPC 4 - Legionarios Romanos
        .byte 60                # VELOCIDADE
        .byte EH_INIMIGO        # INIMIGO?

        # NPC 5 - Filosofos
        .byte 80                 # VELOCIDADE
        .byte NAO_EH_INIMIGO    # INIMIGO?
