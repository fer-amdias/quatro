# EDITOR_IMPRIMIR_UI
# Imprime na tela a interface do usuario no editor de fases

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

E_IU1_RET:
        lw ra, (sp)
        addi sp, sp, 4
        ret