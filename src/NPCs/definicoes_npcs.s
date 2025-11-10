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

.eqv NPC_STRUCT_ATRIBUTO_VELOCIDADE 0
.eqv NPC_STRUCT_ATRIBUTO_INIMIGO 2
.eqv NPC_STRUCT_ATRIBUTO_TIPO_DE_MOVIMENTO 3
.eqv NPC_STRUCT_TAMANHO 4

STRUCTS_NPCS:
        # NPC 1 - Seta vermelha
        .half 100               # VELOCIDADE
        .byte EH_INIMIGO        # INIMIGO?
        .byte 1                 # TIPO DE MOVIMENTO (QUAL PROC CHAMAR)    
        
        # NPC 2 - Sentinelas Babilonicas
        .half 100               # VELOCIDADE
        .byte EH_INIMIGO        # INIMIGO?
        .byte 1                 # TIPO DE MOVIMENTO  

        # NPC 3 - Ratos
        .half 80                # VELOCIDADE
        .byte NAO_EH_INIMIGO    # INIMIGO?
        .byte 2                 # TIPO DE MOVIMENTO

        # NPC 4 - Legionarios Romanos
        .half 60                # VELOCIDADE
        .byte EH_INIMIGO        # INIMIGO?
        .byte 1                 # TIPO DE MOVIMENTO

        # NPC 5 - Filosofos
        .half 100               # VELOCIDADE
        .byte NAO_EH_INIMIGO    # INIMIGO?
        .byte 3                 # TIPO DE MOVIMENTO
