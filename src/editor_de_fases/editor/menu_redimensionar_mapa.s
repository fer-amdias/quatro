# EDITOR_MENU_REDIMENSIONAR_MAPA
# Mostra o menu de redimensionamento de mapa.

.eqv MENU_REDIMENSIONAR_MAPA_X 40
.eqv MENU_REDIMENSIONAR_MAPA_Y 28

.data

.text
EDITOR_MENU_REDIMENSIONAR_MAPA:
        addi sp, sp, -12
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)

E_RM1_OBSCURECER_TELA:
        jal SHADER_OBSCURECER_TELA
        j E_RM1_DRAW_CYCLE

E_RM1_IDLE:
        sleep(10)
E_RM1_LOOP:
        li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,E_RM1_IDLE          # Se nao hah tecla pressionada entao nao faz NADA
  	lw t2,4(t1)  			# le o valor da tecla 

        li t0, 27       # ESC
        beq t2, t0, E_RM1_RET
        li t0, 8        # BACKSPACE
        beq t2, t0, E_RM1_RET
        li t0, 'W'
        beq t2, t0, E_RM1_W
        li t0, 'A'
        beq t2, t0, E_RM1_A
        li t0, 'S'
        beq t2, t0, E_RM1_S
        li t0, 'D'
        beq t2, t0, E_RM1_D
        li t0, 'w'
        beq t2, t0, E_RM1_W
        li t0, 'a'
        beq t2, t0, E_RM1_A
        li t0, 's'
        beq t2, t0, E_RM1_S
        li t0, 'd'
        beq t2, t0, E_RM1_D

        li t0, '\n'
        beq t2, t0, E_RM1_REDIMENSIONAR

        j E_RM1_IDLE    # se nao for uma tecla valida, nao faz nada

E_RM1_W:
        li a0, 0
        li a1, -1 
        j E_RM1_REDIMENSIONAR_MODELO
E_RM1_A:
        li a0, -1
        li a1, 0
        j E_RM1_REDIMENSIONAR_MODELO
E_RM1_S:
        li a0, 0
        li a1, 1
        j E_RM1_REDIMENSIONAR_MODELO
E_RM1_D:
        li a0, 1
        li a1, 0
        j E_RM1_REDIMENSIONAR_MODELO

E_RM1_REDIMENSIONAR_MODELO:
        jal EDITOR_REDIMENSIONAR_MODELO # redimensiona para LARGURA+a0 e ALTURA+a1
        j E_RM1_DRAW_CYCLE

E_RM1_REDIMENSIONAR:
        lb a0, MODELO_DE_REDIMENSIONAMENTO_LARGURA
        lb a1, MODELO_DE_REDIMENSIONAMENTO_ALTURA
        jal EDITOR_REDIMENSIONAR_MAPA  # aplica as novas dimensoes 
        j E_RM1_RET

E_RM1_DRAW_CYCLE:

        li a0, 0xA0
        li a1, MENU_REDIMENSIONAR_MAPA_X
        li a2, MENU_REDIMENSIONAR_MAPA_Y
        li a3, LARGURA_VGA
        sub a3, a3, a1
        li a4, ALTURA_VGA
        sub a4, a4, a2
        li a7, 0
        jal PROC_IMPRIMIR_RETANGULO

        li a0, 0xFF
        li a1, MENU_REDIMENSIONAR_MAPA_X
        addi a1, a1, 5
        li a2, MENU_REDIMENSIONAR_MAPA_Y
        addi a2, a2, 5
        li a3, LARGURA_VGA
        sub a3, a3, a1
        li a4, ALTURA_VGA
        sub a4, a4, a2
        li a5, 1
        li a7, 0
        jal PROC_IMPRIMIR_OUTLINE

        # coordenadas em que imprimiremos as strings
        li s0, MENU_REDIMENSIONAR_MAPA_X
        li s1, MENU_REDIMENSIONAR_MAPA_Y
        addi s0, s0, 10                 # x
        addi s1, s1, 10                 # y
        jal EDITOR_IMPRIMIR_MODELO

        imprimir_string_reg(EDITOR_MENU_TITULO, s0, s1, 0xC7FF, 0)
        addi s1, s1, 10
        imprimir_string_reg(EDITOR_MENU_REDIMENSIONAR_CONTROLES, s0, s1, 0xC7FF, 0)
        addi s1, s1, 140
        imprimir_string_reg(EDITOR_MENU_CONFIRMAR, s0, s1, 0xC7FF, 0)
        addi s1, s1, 10      
        imprimir_string_reg(EDITOR_OPCOES_VOLTAR, s0, s1, 0xC7FF, 0)

        jal PROC_DESENHAR

        j E_RM1_LOOP

E_RM1_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        addi sp, sp, 12
        ret