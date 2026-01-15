# EDITOR_IMPRIMIR_UI
# Imprime na tela a interface do usuario no editor de fases

.data

STR_X: .asciz "x"

.text

EDITOR_IMPRIMIR_UI:

        addi sp, sp, -4
        sw ra, (sp)

        lb t0, STR_NOME_ARQUIVO
        beqz t0, E_IU1_IMPRIMIR_UNTITLED

E_IU1_IMPRIMIR_STR_NOME_ARQUIVO:
        imprimir_string(STR_NOME_ARQUIVO, 234, 20, 0xC7FF, 1)
        j E_IU1_CONT

E_IU1_IMPRIMIR_UNTITLED:
        imprimir_string(ARQUIVO_SEM_TITULO, 234, 20, 0xC7FF, 0)

E_IU1_CONT:

        imprimir_string(EDITOR_UI_ESC, 234, 45, 0xC7FF, 0)
        imprimir_string(EDITOR_UI_OPTIONS, 234, 55, 0xC7FF, 0)

E_IU1_IMPRIMIR_DIMENSOES:
        lw a0, TILEMAP_BUFFER
        li t0, 10
        bge a0, t0, E_IU1_IMPRIMIR_N_DE_LINHAS_MAIOR_QUE_10

	li a1, 110		# x 
        j E_IU1_IMPRIMIR_DIMENSOES_CONT

E_IU1_IMPRIMIR_N_DE_LINHAS_MAIOR_QUE_10:
        li a1, 102
E_IU1_IMPRIMIR_DIMENSOES_CONT:
        li a2, 1		# y
	li a3, 0xC7FF
	jal PROC_IMPRIMIR_INTEIRO

        imprimir_string(STR_X, 120, 1, 0xC7FF, 1)

        la a0, TILEMAP_BUFFER
        lw a0, 4(a0)
	li a1, 130		# x 
	li a2, 1		# y
	li a3, 0xC7FF
	jal PROC_IMPRIMIR_INTEIRO

E_IU1_IMPRIMIR_PALETA:

        jal EDITOR_IMPRIMIR_SELETOR_DE_TILE

E_IU1_IMPRIMIR_UI_PALETA_TILES:

        li a0, 0x00
        li a1, PALETAS_X
        li a2, PALETAS_Y
        
        # ao redor da paleta
        addi a3, a1, TAMANHO_SPRITE
        addi a3, a3, -1

        # ate o fim da paleta
        li a4, TAMANHO_SPRITE
        li t1, 7
        mul a4, a4, t1
        addi a4, a4, 12
        add a4, a4, a2
        addi a4, a4, -1
        li a7, 0

        # com uma grossura de dois
        addi a1, a1, -2
        addi a2, a2, -2
        addi a3, a3, 2
        addi a4, a4, 2

        jal PROC_IMPRIMIR_RETANGULO

E_IU1_IMPRIMIR_SETAS_PALETA_TILES:

        lb t0, PALETA_DE_TILES_Y
        blez t0, E_IU1_PULAR_SETA_PARA_CIMA_PALETA_TILES

        la a0, seta_para_cima
        li a1, PALETAS_X
        li a2, PALETAS_Y
        lw a3, (a0)
        lw a4, 4(a0)
        li a7, 0
        addi a0, a0, 8
        addi a1, a1, -14 
        jal PROC_IMPRIMIR_TEXTURA

E_IU1_PULAR_SETA_PARA_CIMA_PALETA_TILES:

        lb t0, PALETA_DE_TILES_Y
        lb t1, PALETA_DE_TILES_VALOR_MAXIMO
        sub t1, t1, t0                  # diferenca entre o Y e o Y maximo
        # se essa diferenca nao for maior que 6, nao podemos escrolar
        li t0, 6
        ble t1, t0, E_IU1_PULAR_SETA_PARA_BAIXO_PALETA_TILES

        la a0, seta_para_baixo
        li a1, PALETAS_X
        li a2, PALETAS_Y

        # no fim da paleta
        li t0, TAMANHO_SPRITE
        li t1, 7
        mul t0, t0, t1
        addi t0, t0, 12
        add a2, a2, t0
        addi a2, a2, -10

        lw a3, (a0)
        lw a4, 4(a0)
        li a7, 0
        addi a0, a0, 8
        addi a1, a1, -14 
        jal PROC_IMPRIMIR_TEXTURA

E_IU1_PULAR_SETA_PARA_BAIXO_PALETA_TILES:

E_IU1_IMPRIMIR_UI_PALETA_NPCS:

        li a0, 0x00
        li a1, PALETAS_X
        addi a1, a1, DISTANCIA_ENTRE_PALETAS
        addi a1, a1, TAMANHO_SPRITE
        li a2, PALETAS_Y
        
        # ao redor da paleta
        addi a3, a1, TAMANHO_SPRITE
        addi a3, a3, -1

        # ate o fim da paleta
        li a4, TAMANHO_SPRITE
        li t1, 7
        mul a4, a4, t1
        addi a4, a4, 12
        add a4, a4, a2
        addi a4, a4, -1
        li a7, 0

        # com uma grossura de dois
        addi a1, a1, -2
        addi a2, a2, -2
        addi a3, a3, 2
        addi a4, a4, 2

        jal PROC_IMPRIMIR_RETANGULO

E_IU1_IMPRIMIR_SETAS_PALETA_NPCS:

        lb t0, PALETA_DE_NPCS_Y
        blez t0, E_IU1_PULAR_SETA_PARA_CIMA_PALETA_NPCS

        la a0, seta_para_cima
        li a1, PALETAS_X
        addi a1, a1, DISTANCIA_ENTRE_PALETAS
        addi a1, a1, TAMANHO_SPRITE
        addi a1, a1, TAMANHO_SPRITE
        li a2, PALETAS_Y
        lw a3, (a0)
        lw a4, 4(a0)
        li a7, 0
        addi a0, a0, 8
        addi a1, a1, 4
        jal PROC_IMPRIMIR_TEXTURA

E_IU1_PULAR_SETA_PARA_CIMA_PALETA_NPCS:

        lb t0, PALETA_DE_NPCS_Y
        lb t1, PALETA_DE_NPCS_VALOR_MAXIMO
        li t2, BYTE_NPC_0
        sub t1, t1, t2                  # pega o valor maximo relativo ao NPC 0
        sub t1, t1, t0                  # diferenca entre o Y e o Y maximo
        # se essa diferenca nao for maior que 6, nao podemos escrolar
        li t0, 6
        ble t1, t0, E_IU1_PULAR_SETA_PARA_BAIXO_PALETA_NPCS

        la a0, seta_para_baixo
        li a1, PALETAS_X
        addi a1, a1, DISTANCIA_ENTRE_PALETAS
        addi a1, a1, TAMANHO_SPRITE
        addi a1, a1, TAMANHO_SPRITE
        li a2, PALETAS_Y

        # no fim da paleta
        li t0, TAMANHO_SPRITE
        li t1, 7
        mul t0, t0, t1
        addi t0, t0, 12
        add a2, a2, t0
        addi a2, a2, -10

        lw a3, (a0)
        lw a4, 4(a0)
        li a7, 0
        addi a0, a0, 8
        addi a1, a1, 4
        jal PROC_IMPRIMIR_TEXTURA

E_IU1_PULAR_SETA_PARA_BAIXO_PALETA_NPCS:

        lw a0, TEXTURA_DO_MAPA
        la a1, inimigos
        jal EDITOR_IMPRIMIR_PALETAS

        jal EDITOR_IMPRIMIR_SELETOR_DE_PALETA



E_IU1_RET:
        lw ra, (sp)
        addi sp, sp, 4
        ret