# EDITOR_MENU_SOBRESCREVER_POPUP
# Mostra um prompt perguntando ao usuario
# se deseja sobrescrever o arquivo existente
# na pasta destino. Para ser usando em
# conjuncao com o salvar_com.
#
# RETORNO
# a0 - Se o usuario decidiu sobrescrever (1) ou cancelar (0)

.eqv MENU_SOBRESCREVER_POPUP_X 2
.eqv MENU_SOBRESCREVER_POPUP_Y 81

EDITOR_MENU_SOBRESCREVER_POPUP:
        addi sp, sp, -12
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)

        j E_SP1_DRAW_CYCLE

E_SP1_IDLE:
        sleep(10)
E_SP1_LOOP:
	li a0, 0
        jal PROC_TOCAR_AUDIO	
        
        li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,E_SP1_IDLE          # Se nao hah tecla pressionada entao nao faz NADA
        lw t0,4(t1)  			# le o valor da tecla 

        li t1, '1'
        beq t1, t0, E_SP1_SOBRESCREVER

        li t1, '2'
        beq t1, t0, E_SP1_CANCELAR

        # cancela para BACKSP e ESC
        li t1, 8
        beq t1, t0, E_SP1_CANCELAR
        li t1, 27
        beq t1, t0, E_SP1_CANCELAR

        j E_SP1_IDLE

E_SP1_DRAW_CYCLE:
        jal SHADER_OBSCURECER_TELA

        li a0, 0xA0
        li a1, MENU_SOBRESCREVER_POPUP_X
        li a2, MENU_SOBRESCREVER_POPUP_Y
        li a3, LARGURA_VGA
        sub a3, a3, a1
        addi a3, a3, -1
        li a4, ALTURA_VGA
        sub a4, a4, a2
        addi a4, a4, -1
        li a7, 0
        jal PROC_IMPRIMIR_RETANGULO

        li a0, 0xFF
        li a1, MENU_SOBRESCREVER_POPUP_X
        addi a1, a1, 5
        li a2, MENU_SOBRESCREVER_POPUP_Y
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
        li s0, MENU_SOBRESCREVER_POPUP_X
        li s1, MENU_SOBRESCREVER_POPUP_Y
        addi s0, s0, 10                 # x
        addi s1, s1, 10                 # y

        imprimir_string_reg(locale_SOBRESCREVER_PROMPT, s0, s1, 0xC7FF, 0)
        addi s1, s1, 40                 # pula 4 linhas

        imprimir_string_reg(locale_SOBRESCREVER_SIM, s0, s1, 0xC7FF, 0)
        addi s1, s1, 10
        imprimir_string_reg(locale_SOBRESCREVER_NAO, s0, s1, 0xC7FF, 0)

        jal PROC_DESENHAR
        j E_SP1_LOOP

E_SP1_SOBRESCREVER:
        li a0, 1                # retorna SOBRESCREVER
        j E_SP1_RET

E_SP1_CANCELAR:
        li a0, 0                # retorna CANCELAR

E_SP1_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        addi sp, sp, 12
        ret