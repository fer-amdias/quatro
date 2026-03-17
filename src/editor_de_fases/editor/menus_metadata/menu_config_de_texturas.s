# EDITOR_MENU_CONFIG_DE_TEXTURAS
# Mostra o menu de selecao de metadata


.eqv MENU_CONFIG_DE_TEXTURAS_X 45
.eqv MENU_CONFIG_DE_TEXTURAS_Y 54

EDITOR_MENU_CONFIG_DE_TEXTURAS:
        addi sp, sp, -12
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)

        j E_MT1_DRAW_CYCLE

E_MT1_IDLE:
        sleep(10)
E_MT1_LOOP:
	li a0, 0
        jal PROC_TOCAR_AUDIO	
        
        li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,E_MT1_IDLE          # Se nao hah tecla pressionada entao nao faz NADA
  	lw t2,4(t1)  			# le o valor da tecla 

        li t0, 27       # ESC
        beq t2, t0, E_MT1_RET
        li t0, 8        # BACKSPACE
        beq t2, t0, E_MT1_RET
        li t0, '1'
        beq t2, t0, E_MT1_TEXTURA_MAPA
        li t0, '2'
        beq t2, t0, E_MT1_TEXTURA_NPCS
        li t0, '3'
        beq t2, t0, E_MT1_TEXTURA_JOGADOR
        li t0, '4'
        beq t2, t0, E_MT1_TEXTURA_DE_FUNDO

        j E_MT1_IDLE    # se nao for uma tecla valida, nao faz nada

E_MT1_DRAW_CYCLE:
        jal SHADER_OBSCURECER_TELA

        li a0, 0xA0
        li a1, MENU_CONFIG_DE_TEXTURAS_X
        li a2, MENU_CONFIG_DE_TEXTURAS_Y
        li a3, LARGURA_VGA
        sub a3, a3, a1
        li a4, ALTURA_VGA
        sub a4, a4, a2
        li a7, 0
        jal PROC_IMPRIMIR_RETANGULO

        li a0, 0xFF
        li a1, MENU_CONFIG_DE_TEXTURAS_X
        addi a1, a1, 5
        li a2, MENU_CONFIG_DE_TEXTURAS_Y
        addi a2, a2, 5
        li a3, LARGURA_VGA
        sub a3, a3, a1
        li a4, ALTURA_VGA
        sub a4, a4, a2
        li a5, 1
        li a7, 0
        jal PROC_IMPRIMIR_OUTLINE

        # coordenadas em que imprimiremos as strings
        li s0, MENU_CONFIG_DE_TEXTURAS_X
        li s1, MENU_CONFIG_DE_TEXTURAS_Y
        addi s0, s0, 10                 # x
        addi s1, s1, 10                 # y

        imprimir_string_reg(EDITOR_MENU_TEXTURAS, s0, s1, 0xC7FF, 0)
        addi s1, s1, 30
        imprimir_string_reg(EDITOR_MENU_TEXTURA_MAPA, s0, s1, 0xC7FF, 0)
        addi s1, s1, 15
        imprimir_string_reg(EDITOR_MENU_TEXTURA_NPCS, s0, s1, 0xC7FF, 0)
        addi s1, s1, 15
        imprimir_string_reg(EDITOR_MENU_TEXTURA_JOGADOR, s0, s1, 0xC7FF, 0)
        addi s1, s1, 15
        imprimir_string_reg(EDITOR_MENU_TEXTURA_DE_FUNDO, s0, s1, 0xC7FF, 0)
        addi s1, s1, 30
        imprimir_string_reg(EDITOR_OPCOES_VOLTAR, s0, s1, 0xC7FF, 0)

        jal PROC_DESENHAR

        j E_MT1_LOOP

E_MT1_TEXTURA_MAPA:
        la a0, FASE_TEXTURA                     # menu de carregar textura do mapa
        la a1, TEXTURA_BUFFER                   # carregar para o buffer de textura
        jal EDITOR_CRIAR_MENU_CARREGAR_TEXTURA
        j E_MT1_DRAW_CYCLE

E_MT1_TEXTURA_NPCS:
        la a0, FASE_TEXTURA_NPCS                # menu de carregar textura dos NPCs
        la a1, TEXTURA_NPCS_BUFFER          # carregar para o buffer de textura dos NPCs
        jal EDITOR_CRIAR_MENU_CARREGAR_TEXTURA
        j E_MT1_DRAW_CYCLE

E_MT1_TEXTURA_JOGADOR:
        la a0, FASE_TEXTURA_JOGADOR             # menu de carregar textura do jogador
        mv a1, zero                             # nenhum buffer de textura associado
        jal EDITOR_CRIAR_MENU_CARREGAR_TEXTURA
        j E_MT1_DRAW_CYCLE

E_MT1_TEXTURA_DE_FUNDO:
        jal EDITOR_MENU_CARREGAR_PADRAO_DE_FUNDO
        j E_MT1_DRAW_CYCLE

E_MT1_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        addi sp, sp, 12
        ret