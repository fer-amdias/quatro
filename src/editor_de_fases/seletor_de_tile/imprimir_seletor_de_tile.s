# EDITOR_IMPRIMIR_SELETOR_DE_TILE
# Coloca um outline ao redor do tile selecionado atualmente.

EDITOR_IMPRIMIR_SELETOR_DE_TILE:

        addi sp, sp, -4
        sw ra, (sp)

        # pega as posicoes X e Y do mapa
        la t0, POSICOES_MAPA
        lhu t1, (t0)
        lhu t2, 2(t0)

        li t0, TAMANHO_SPRITE

        # X += SELETOR_DE_TILE_X * TAMANHO_SPRITE
        lb t3, SELETOR_DE_TILE_X
        mul t3, t3, t0
        add t1, t1, t3

        # Y += SELETOR_DE_TILE_Y * TAMANHO_SPRITE
        lb t3, SELETOR_DE_TILE_Y
        mul t3, t3, t0
        add t2, t2, t3

        # imprime um outline ao redor do tile selecionado
        li a0, 0xFF
        mv a1, t1
        mv a2, t2
        add a3, t1, t0
        addi a3, a3, -1
        add a4, t2, t0
        addi a4, a4, -1
        li a5, 1
        li a7, 0
        jal PROC_IMPRIMIR_OUTLINE

        lw ra, (sp)
        addi sp, sp, 4
        ret