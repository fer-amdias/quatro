# EDITOR_MENU_EDITOR_DE_FASES
# Mostra o menu do editor de fases.
#
# RETORNO:
#       a0 : flag de retorno.
#       0 = SUCCESS. 1 = RETURN_TO_MAIN_MENU.


.eqv MENU_EDITOR_DE_FASES_X 45
.eqv MENU_EDITOR_DE_FASES_Y 54

EDITOR_MENU_EDITOR_DE_FASES:
        addi sp, sp, -12
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)

E_ME2_OBSCURECER_TELA:
        jal SHADER_OBSCURECER_TELA
        j E_ME2_DRAW_CYCLE

E_ME2_IDLE:
        sleep(10)
E_ME2_LOOP:
        li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,E_ME2_IDLE          # Se nao hah tecla pressionada entao nao faz NADA
  	lw t2,4(t1)  			# le o valor da tecla 

        li t0, 27       # ESC
        beq t2, t0, E_ME2_RETURN_TO_EDITOR
        li t0, 8        # BACKSPACE
        beq t2, t0, E_ME2_RETURN_TO_EDITOR
        li t0, '1'
        beq t2, t0, E_ME2_CARREGAR_TEXTURA
        li t0, '2'
        beq t2, t0, E_ME2_REDIMENSIONAR_MAPA
        li t0, '3'
        beq t2, t0, E_ME2_SALVAR
        li t0, '4'
        beq t2, t0, E_ME2_SALVAR_COMO
        li t0, '9'
        beq t2, t0, E_ME2_RETURN_TO_MAIN_MENU

        j E_ME2_IDLE    # se nao for uma tecla valida, nao faz nada

E_ME2_DRAW_CYCLE:

        li a0, 0xA0
        li a1, MENU_EDITOR_DE_FASES_X
        li a2, MENU_EDITOR_DE_FASES_Y
        li a3, LARGURA_VGA
        sub a3, a3, a1
        li a4, ALTURA_VGA
        sub a4, a4, a2
        li a7, 0
        jal PROC_IMPRIMIR_RETANGULO

        li a0, 0xFF
        li a1, MENU_EDITOR_DE_FASES_X
        addi a1, a1, 5
        li a2, MENU_EDITOR_DE_FASES_Y
        addi a2, a2, 5
        li a3, LARGURA_VGA
        sub a3, a3, a1
        li a4, ALTURA_VGA
        sub a4, a4, a2
        li a5, 1
        li a7, 0
        jal PROC_IMPRIMIR_OUTLINE

        # coordenadas em que imprimiremos as strings
        li s0, MENU_EDITOR_DE_FASES_X
        li s1, MENU_EDITOR_DE_FASES_Y
        addi s0, s0, 10                 # x
        addi s1, s1, 10                 # y

        imprimir_string_reg(EDITOR_UI_OPTIONS, s0, s1, 0xC7FF, 0)
        addi s1, s1, 30
        imprimir_string_reg(EDITOR_OPCOES_CARREGAR_TEXTURA, s0, s1, 0xC7FF, 0)
        addi s1, s1, 15
        imprimir_string_reg(EDITOR_OPCOES_REDIMENSIONAR_MAPA, s0, s1, 0xC7FF, 0)
        addi s1, s1, 15
        imprimir_string_reg(EDITOR_OPCOES_SALVAR, s0, s1, 0xC7FF, 0)
        addi s1, s1, 15
        imprimir_string_reg(EDITOR_OPCOES_SALVAR_COMO, s0, s1, 0xC7FF, 0)
        addi s1, s1, 15
        imprimir_string_reg(EDITOR_OPCOES_RETORNAR, s0, s1, 0xC7FF, 0)
        addi s1, s1, 15
        imprimir_string_reg(EDITOR_OPCOES_VOLTAR, s0, s1, 0xC7FF, 0)

        jal PROC_DESENHAR

        j E_ME2_LOOP

E_ME2_RETURN_TO_EDITOR:
        mv a0, zero
        j E_ME2_RET

E_ME2_RETURN_TO_MAIN_MENU:
        li a0, 1
        j E_ME2_RET

E_ME2_CARREGAR_TEXTURA:
        jal EDITOR_MENU_CARREGAR_TEXTURA
        j E_ME2_RETURN_TO_EDITOR

E_ME2_REDIMENSIONAR_MAPA:
        jal EDITOR_MENU_REDIMENSIONAR_MAPA
        j E_ME2_RETURN_TO_EDITOR

E_ME2_SALVAR:
        lb t0, STR_NOME_ARQUIVO # pega o primeiro caractere do nome do arquivo
        beqz t0, E_ME2_SALVAR_COMO # se for vazio, o arquivo nao possui nome

        la a0, ARQUIVO_STR_PATH
	jal EDITOR_SALVAR_FASE
        # retorno: quantos bytes foram lidos, -1 se houve um erro
        # passamos pro menu de fase salva
        jal EDITOR_MENU_FASE_SALVA

        j E_ME2_DRAW_CYCLE
E_ME2_SALVAR_COMO:
        jal EDITOR_MENU_SALVAR_FASE_COMO
        j E_ME2_RETURN_TO_EDITOR
        j E_ME2_DRAW_CYCLE

E_ME2_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        addi sp, sp, 12
        ret