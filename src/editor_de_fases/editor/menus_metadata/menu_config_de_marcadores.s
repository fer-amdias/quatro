# EDITOR_MENU_CONFIG_DE_MARCADORES
# Mostra o menu de selecao de marcadores (saida livre e pergaminho no inicio)


.eqv MENU_CONFIG_DE_MARCADORES_X 5
.eqv MENU_CONFIG_DE_MARCADORES_Y 64

EDITOR_MENU_CONFIG_DE_MARCADORES:
        addi sp, sp, -12
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)

        j E_MM2_DRAW_CYCLE

E_MM2_IDLE:
        sleep(10)
E_MM2_LOOP:
	li a0, 0
        jal PROC_TOCAR_AUDIO	
        
        li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,E_MM2_IDLE          # Se nao hah tecla pressionada entao nao faz NADA
  	lw t2,4(t1)  			# le o valor da tecla

        li t0, 27       # ESC
        beq t2, t0, E_MM2_RET
        li t0, 8        # BACKSPACE
        beq t2, t0, E_MM2_RET
        li t0, '1'
        beq t2, t0, E_MM2_MARCADOR_PERGAMINHO
        li t0, '2'
        beq t2, t0, E_MM2_MARCADOR_SAIDA_LIVRE


        j E_MM2_IDLE    # se nao for uma tecla valida, nao faz nada

E_MM2_DRAW_CYCLE:
        jal SHADER_OBSCURECER_TELA

        li a0, 0xA0
        li a1, MENU_CONFIG_DE_MARCADORES_X
        li a2, MENU_CONFIG_DE_MARCADORES_Y
        li a3, LARGURA_VGA
        sub a3, a3, a1
        li a4, ALTURA_VGA
        sub a4, a4, a2
        li a7, 0
        jal PROC_IMPRIMIR_RETANGULO

        li a0, 0xFF
        li a1, MENU_CONFIG_DE_MARCADORES_X
        addi a1, a1, 5
        li a2, MENU_CONFIG_DE_MARCADORES_Y
        addi a2, a2, 5
        li a3, LARGURA_VGA
        sub a3, a3, a1
        li a4, ALTURA_VGA
        sub a4, a4, a2
        li a5, 1
        li a7, 0
        jal PROC_IMPRIMIR_OUTLINE

        # coordenadas em que imprimiremos as strings
        li s0, MENU_CONFIG_DE_MARCADORES_X
        li s1, MENU_CONFIG_DE_MARCADORES_Y
        addi s0, s0, 10                 # x
        addi s1, s1, 10                 # y

        imprimir_string_reg(EDITOR_MENU_MARCADORES, s0, s1, 0xC7FF, 0)
        addi s1, s1, 30

        # imprime HABILITAR/DESABILITAR PERGAMINHO NO INICIO conforme marcador
        lw t0, FASE_PERGAMINHO_NO_INICIO
        beqz t0, E_MM2_DRAW_PERGAMINHO_HABILITAR
        imprimir_string_reg(EDITOR_MENU_PERGAMINHO_INICIO_DISABLE, s0, s1, 0xC7FF, 0)

        j E_MM2_DRAW_CYCLE_CONT
        

E_MM2_DRAW_PERGAMINHO_HABILITAR:
        imprimir_string_reg(EDITOR_MENU_PERGAMINHO_INICIO_ENABLE, s0, s1, 0xC7FF, 0)

E_MM2_DRAW_CYCLE_CONT:
        addi s1, s1, 15

        lw t0, FASE_SAIDA_LIVRE
        beqz t0, E_MM2_DRAW_SAIDA_LIVRE_HABILITAR
        imprimir_string_reg(EDITOR_MENU_SAIDA_LIVRE_DISABLE, s0, s1, 0xC7FF, 0)

        j E_MM2_DRAW_CYCLE_CONT2

E_MM2_DRAW_SAIDA_LIVRE_HABILITAR:
        imprimir_string_reg(EDITOR_MENU_SAIDA_LIVRE_ENABLE, s0, s1, 0xC7FF, 0)

E_MM2_DRAW_CYCLE_CONT2:
        addi s1, s1, 30
        imprimir_string_reg(EDITOR_OPCOES_VOLTAR, s0, s1, 0xC7FF, 0)

        jal PROC_DESENHAR

        j E_MM2_LOOP

E_MM2_MARCADOR_PERGAMINHO:

        lw t0, FASE_PERGAMINHO_NO_INICIO        # pega o marcador
        seqz t0, t0                             # inverte o marcador
        sw t0, FASE_PERGAMINHO_NO_INICIO, t1    # salva o marcador invertido
        j E_MM2_DRAW_CYCLE

E_MM2_MARCADOR_SAIDA_LIVRE:
        lw t0, FASE_SAIDA_LIVRE                 # pega o marcador
        seqz t0, t0                             # inverte o marcador
        sw t0, FASE_SAIDA_LIVRE, t1             # salva o marcador invertido
        j E_MM2_DRAW_CYCLE

E_MM2_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        addi sp, sp, 12
        ret