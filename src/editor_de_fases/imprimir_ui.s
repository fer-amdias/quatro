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

E_IU1_RET:
        lw ra, (sp)
        addi sp, sp, 4
        ret