# EDITOR_MENU_FASE_SALVA
# Mostra o menu que fala se a fase foi salva ou nao.
#
# ARGUMENTOS
# A0 - Status
#       ( >= 0: SUCESSO, < 0: FALHA )

.eqv MENU_FASE_SALVA_X 30
.eqv MENU_FASE_SALVA_Y 106

.data

STATUS: .byte 0
.text

EDITOR_MENU_FASE_SALVA:
        addi sp, sp, -12
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)

        sb a0, STATUS, t0               # salva o status 

E_FS1_OBSCURECER_TELA:
        jal SHADER_OBSCURECER_TELA
        j E_FS1_DRAW_CYCLE

E_FS1_IDLE:
        sleep(10)
E_FS1_LOOP:
        li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,E_RM1_IDLE          # Se nao hah tecla pressionada entao nao faz NADA

        # se QUALQUER TECLA FOR PRESSIONADA, retorna
        j E_FS1_RET

E_FS1_DRAW_CYCLE:
        li a0, 0xA0
        li a1, MENU_FASE_SALVA_X
        li a2, MENU_FASE_SALVA_Y
        li a3, LARGURA_VGA
        sub a3, a3, a1
        addi a3, a3, -1
        li a4, ALTURA_VGA
        sub a4, a4, a2
        addi a4, a4, -1
        li a7, 0
        jal PROC_IMPRIMIR_RETANGULO

        li a0, 0xFF
        li a1, MENU_FASE_SALVA_X
        addi a1, a1, 5
        li a2, MENU_FASE_SALVA_Y
        addi a2, a2, 5
        li a3, LARGURA_VGA
        sub a3, a3, a1
        addi a3, a3, -1
        li a4, ALTURA_VGA
        sub a4, a4, a2
        addi a4, a4, -1
        li a5, 1
        li a7, 0
        jal PROC_IMPRIMIR_OUTLINE

        # coordenadas em que imprimiremos as strings
        li s0, MENU_FASE_SALVA_X
        li s1, MENU_FASE_SALVA_Y
        addi s0, s0, 10                 # x
        addi s1, s1, 10                 # y

        lb t0, STATUS
        bltz t0, E_FS1_SALVAR_FALHO

E_FS1_SALVAR_BEM_SUCEDIDO:

        imprimir_string_reg(EDITOR_ARQUIVO_SALVO, s0, s1, 0xC7FF, 0)
        j E_FS1_DRAW_CYCLE_CONT

E_FS1_SALVAR_FALHO:

        imprimir_string_reg(EDITOR_ERRO_SALVAR, s0, s1, 0xC7FF, 0)

E_FS1_DRAW_CYCLE_CONT:

        jal PROC_DESENHAR
        j E_FS1_LOOP

E_FS1_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        addi sp, sp, 12
        ret