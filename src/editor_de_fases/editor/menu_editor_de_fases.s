
.eqv MENU_EDITOR_DE_FASES_X 40
.eqv MENU_EDITOR_DE_FASES_Y 54

.eqv MENU_EDITOR_DE_FASES_UI_X 60

EDITOR_MENU_EDITOR_DE_FASES:
        addi sp, sp, -12
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)

E_ME2_OBSCURECER_TELA:

        # temos que copiar o frame atual para o frame buffer, depois escurecer o frame buffer, e colocar ele de novo no lugar
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
        beq t2, t0, E_ME2_RET
        li t0, 8        # BACKSPACE
        beq t2, t0, E_ME2_RET

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

E_ME2_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        addi sp, sp, 12
        ret