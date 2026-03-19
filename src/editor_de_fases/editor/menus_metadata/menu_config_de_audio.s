# EDITOR_MENU_CONFIG_DE_AUDIO
# Mostra o menu de selecao de metadata


.eqv MENU_CONFIG_DE_AUDIO_X 45
.eqv MENU_CONFIG_DE_AUDIO_Y 54

EDITOR_MENU_CONFIG_DE_AUDIO:
        addi sp, sp, -12
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)

        j E_MA1_DRAW_CYCLE

E_MA1_IDLE:
        sleep(10)
E_MA1_LOOP:
	li a0, 0
        jal PROC_TOCAR_AUDIO	
        
        li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,E_MA1_IDLE          # Se nao hah tecla pressionada entao nao faz NADA
  	lw t2,4(t1)  			# le o valor da tecla 

        li t0, 27       # ESC
        beq t2, t0, E_MA1_RET
        li t0, 8        # BACKSPACE
        beq t2, t0, E_MA1_RET
        li t0, '1'
        beq t2, t0, E_MA1_MENU_SOUNDTRACK
        li t0, '2'
        beq t2, t0, E_MA1_MENU_POWERUP
        li t0, '3'
        beq t2, t0, E_MA1_MENU_MORTE
        li t0, '4'
        beq t2, t0, E_MA1_MENU_PERGAMINHO

        j E_MA1_IDLE    # se nao for uma tecla valida, nao faz nada

E_MA1_DRAW_CYCLE:
        jal SHADER_OBSCURECER_TELA

        li a0, 0xA0
        li a1, MENU_CONFIG_DE_AUDIO_X
        li a2, MENU_CONFIG_DE_AUDIO_Y
        li a3, LARGURA_VGA
        sub a3, a3, a1
        li a4, ALTURA_VGA
        sub a4, a4, a2
        li a7, 0
        jal PROC_IMPRIMIR_RETANGULO

        li a0, 0xFF
        li a1, MENU_CONFIG_DE_AUDIO_X
        addi a1, a1, 5
        li a2, MENU_CONFIG_DE_AUDIO_Y
        addi a2, a2, 5
        li a3, LARGURA_VGA
        sub a3, a3, a1
        li a4, ALTURA_VGA
        sub a4, a4, a2
        li a5, 1
        li a7, 0
        jal PROC_IMPRIMIR_OUTLINE

        # coordenadas em que imprimiremos as strings
        li s0, MENU_CONFIG_DE_AUDIO_X
        li s1, MENU_CONFIG_DE_AUDIO_Y
        addi s0, s0, 10                 # x
        addi s1, s1, 10                 # y

        imprimir_string_reg(locale_EDITOR_MENU_AUDIO, s0, s1, 0xC7FF, 0)
        addi s1, s1, 30
        imprimir_string_reg(locale_EDITOR_MENU_AUDIO_SOUNDTRACK, s0, s1, 0xC7FF, 0)
        addi s1, s1, 15
        imprimir_string_reg(locale_EDITOR_MENU_AUDIO_POWERUP, s0, s1, 0xC7FF, 0)
        addi s1, s1, 15
        imprimir_string_reg(locale_EDITOR_MENU_AUDIO_MORTE, s0, s1, 0xC7FF, 0)
        addi s1, s1, 15
        imprimir_string_reg(locale_EDITOR_MENU_AUDIO_PERGAMINHO, s0, s1, 0xC7FF, 0)
        addi s1, s1, 30
        imprimir_string_reg(locale_EDITOR_OPCOES_VOLTAR, s0, s1, 0xC7FF, 0)

        jal PROC_DESENHAR

        j E_MA1_LOOP

E_MA1_MENU_SOUNDTRACK:
        la a0, FASE_AUDIO_SOUNDTRACK            # queremos carregar a soundtrack
        li a1, 1                                # na track 1
        li a2, 1                                # *com* loop
        jal EDITOR_CRIAR_MENU_CARREGAR_AUDIO
        j E_MA1_DRAW_CYCLE

E_MA1_MENU_POWERUP:
        la a0, FASE_AUDIO_POWERUP               # queremos carregar o som de powerup
        li a1, 2                                # na track 2
        mv a2, zero                             # *sem* loop
        jal EDITOR_CRIAR_MENU_CARREGAR_AUDIO
        j E_MA1_DRAW_CYCLE

E_MA1_MENU_MORTE:
        la a0, FASE_AUDIO_MORTE                 # queremos carregar o som de morte
        li a1, 2                                # na track 2
        mv a2, zero                             # *sem* loop
        jal EDITOR_CRIAR_MENU_CARREGAR_AUDIO
        j E_MA1_DRAW_CYCLE

E_MA1_MENU_PERGAMINHO:
        la a0, FASE_AUDIO_PERGAMINHO            # queremos carregar o som de abrir pergaminho
        li a1, 2                                # na track 2
        mv a2, zero                             # *sem* loop
        jal EDITOR_CRIAR_MENU_CARREGAR_AUDIO
        j E_MA1_DRAW_CYCLE

E_MA1_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        addi sp, sp, 12
        ret