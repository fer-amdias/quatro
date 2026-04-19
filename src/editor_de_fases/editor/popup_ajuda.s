# EDITOR_POPUP_AJUDA
# mostra instrucoes para o jogador.


.eqv POPUP_AJUDA_X 1
.eqv POPUP_AJUDA_Y 31

EDITOR_POPUP_AJUDA:
        addi sp, sp, -12
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)

        j E_PA1_DRAW_CYCLE

E_PA1_IDLE:
        sleep(10)
E_PA1_LOOP:
	li a0, 0
        jal PROC_TOCAR_AUDIO	
        
        li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,E_PA1_IDLE          # Se nao hah tecla pressionada entao nao faz NADA

        lw t2, 4(t1)                    # consome o caractere

        # se QUALQUER TECLA FOR PRESSIONADA, retorna
        j E_PA1_RET

E_PA1_DRAW_CYCLE:
        jal SHADER_OBSCURECER_TELA

        li a0, 0xA0
        li a1, POPUP_AJUDA_X
        li a2, POPUP_AJUDA_Y
        li a3, LARGURA_VGA
        sub a3, a3, a1
        addi a3, a3, -1
        li a4, ALTURA_VGA
        sub a4, a4, a2
        addi a4, a4, -1
        li a7, 0
        jal PROC_IMPRIMIR_RETANGULO

        li a0, 0xFF
        li a1, POPUP_AJUDA_X
        addi a1, a1, 2
        li a2, POPUP_AJUDA_Y
        addi a2, a2, 2
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
        li s0, POPUP_AJUDA_X
        li s1, POPUP_AJUDA_Y
        addi s0, s0, 10                 # x
        addi s1, s1, 10                 # y

        imprimir_string_reg(locale_EDITOR_AJUDA, s0, s1, 0xC7FF, 0)
        addi s1, s1, 150
        imprimir_string_reg(locale_EDITOR_FECHAR, s0, s1, 0xC7FF, 0)
        jal PROC_DESENHAR
        j E_PA1_LOOP

E_PA1_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        addi sp, sp, 12
        ret