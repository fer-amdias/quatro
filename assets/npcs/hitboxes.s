#################################################################
# 		  DEFINICAO DE HITBOX DE NPCS                   #
#################################################################
#								#
#  Aqui, se guarda as hitboxes de cada NPC.                     #
#								#
#  COMO USO ESSE MODULO?					#
#  Basta dar um .include no inicio de memoria.s.	        #
#								#
#################################################################

.eqv HITBOX_FRAME_0 0
.eqv HITBOX_FRAME_1 4
.eqv HITBOX_FRAME_2 8
.eqv HITBOX_FRAME_3 12

.eqv HITBOX_X1 0
.eqv HITBOX_X2 1
.eqv HITBOX_Y1 2
.eqv HITBOX_Y2 3

.eqv STRUCT_HITBOX_FRAME_TAMANHO 4
.eqv STRUCT_HITBOX_TAMANHO 16

STRUCT_HITBOX_NPCS:

        # ESTRUTURA: .byte x1 y1 x2 y2
        # esses sao os cantos do retangulo que forma a hitbox
        # x1 e y1 sao coordenadas do canto superior esquerdo
        # x2 e y2 sao coordenadas do canto superior direito

        # NPC 1 - Seta vermelha (tutorial)
        .byte 0 0 19 19
        .byte 0 0 19 19
        .byte 0 0 19 19
        .byte 0 0 19 19

        # NPC 2 - Sentinelas Babilonicas
        .byte 2 3 17 19
        .byte 1 3 17 19
        .byte 2 3 17 19
        .byte 2 3 18 19

        # NPC 3 - Ratos                 hitbox para NPCs passivos sao inuteis, mas incluidos por boa pratica
        .byte 5 0 14 19
        .byte 0 5 19 12
        .byte 5 0 14 19
        .byte 0 5 19 12

        # NPC 4 - Legionarios Romanos
        .byte 3 0 13 19
        .byte 5 0 15 19
        .byte 5 0 13 19
        .byte 4 0 14 19

        # NPC 5 - Filosofos
        .byte 4 1 15 19
        .byte 6 1 13 19
        .byte 4 1 15 19
        .byte 6 1 13 19

        # NPC 6 - Seta verde (tutorial)
        .byte 0 0 19 19
        .byte 0 0 19 19
        .byte 0 0 19 19
        .byte 0 0 19 19