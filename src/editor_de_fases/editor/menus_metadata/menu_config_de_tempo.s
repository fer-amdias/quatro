# EDITOR_MENU_CONFIG_DE_TEMPO
# Mostra o menu de selecao de texto pro pergaminho

.eqv MENU_CONFIG_DE_TEMPO_X 0
.eqv MENU_CONFIG_DE_TEMPO_Y 77

.data

MT3_DATA_STR_CARACTERES_DIGITADOS: .byte 0
MT3_DATA_STR_TERMINAL: .asciz "countdown: "
MT3_TEMPO: .space 5

.text


EDITOR_MENU_CONFIG_DE_TEMPO:
        addi sp, sp, -12
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)

        lw a0, FASE_LIMITE_DE_TEMPO     # a0 - inteiro
        la a1, MT3_TEMPO                # a1 - string destino
        jal PROC_INTEIRO_PARA_STRING    # copia a chave original para o nosso buffer de path para podermos modificalo sem alterar o valor do original

        la a0, MT3_TEMPO
        jal PROC_TAMANHO_STRING
        sb a0, MT3_DATA_STR_CARACTERES_DIGITADOS, t0  # salva a quantidade de caracteres digitados como o tamanho da string

        j E_MT3_DRAW_CYCLE

E_MT3_IDLE:
        sleep(10)
E_MT3_LOOP:
	li a0, 0
        jal PROC_TOCAR_AUDIO	
        
        li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,E_MT3_IDLE          # Se nao hah tecla pressionada entao nao faz NADA
  	lw t2,4(t1)  			# le o valor da tecla 

        li t0, 27       # ESC
        beq t2, t0, E_MT3_RET
	li t0, 8		
	beq t2, t0, E_MT3_REMOVE_CARACTERE
	li t0, '\n'
	beq t2, t0, E_MT3_ENTER

E_MT3_ADD_CARACTERE:
	la t0, MT3_TEMPO
	lbu t1, MT3_DATA_STR_CARACTERES_DIGITADOS

	li t3, 4
	bge t1, t3, E_MT3_IDLE	# cancela se chegamos no final do buffer

        # cancela se nao for um digito
        li t3, '0'
        blt t2, t3, E_MT3_IDLE  
        li t3, '9'
        bgt t2, t3, E_MT3_IDLE

	add t0, t0, t1	# vai ate o caractere a ser digitado

	sb t2, (t0)	# adiciona o caractere
	sb zero, 1(t0)	# coloca um \0 no caractere seguinte para marcar fim da string

	# incrementa os caracteres digitados
	addi t1, t1, 1
	sb t1, MT3_DATA_STR_CARACTERES_DIGITADOS, t0

        j E_MT3_DRAW_CYCLE

E_MT3_REMOVE_CARACTERE:
	la t0, MT3_TEMPO
	lbu t1, MT3_DATA_STR_CARACTERES_DIGITADOS
	beqz t1, E_MT3_IDLE	# nao tira nada se nao tiver caracteres
	addi t1, t1, -1		# volta um caractere
	add t0, t0, t1
	sb zero, (t0)	# substitui o ultimo caractere digitado por zero
	sb t1, MT3_DATA_STR_CARACTERES_DIGITADOS, t0	# decrementa a qtd de caracteres digitados

	j E_MT3_DRAW_CYCLE

E_MT3_ENTER:
        la a0, MT3_TEMPO                        
        jal PROC_STRING_PARA_INTEIRO

        sw a0, FASE_LIMITE_DE_TEMPO, t0         # salva o tempo limite

        j E_MT3_RET
E_MT3_DRAW_CYCLE:
        jal SHADER_OBSCURECER_TELA

        li a0, 0xA0
        li a1, MENU_CONFIG_DE_TEMPO_X
        li a2, MENU_CONFIG_DE_TEMPO_Y
        li a3, LARGURA_VGA
        sub a3, a3, a1
        addi a3, a3, -1
        li a4, ALTURA_VGA
        sub a4, a4, a2
        addi a4, a4, -1
        li a7, 0
        jal PROC_IMPRIMIR_RETANGULO

        li a0, 0xFF
        li a1, MENU_CONFIG_DE_TEMPO_X
        addi a1, a1, 5
        li a2, MENU_CONFIG_DE_TEMPO_Y
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
        li s0, MENU_CONFIG_DE_TEMPO_X
        li s1, MENU_CONFIG_DE_TEMPO_Y
        addi s0, s0, 9                 # x
        addi s1, s1, 9                 # y

        imprimir_string_reg(EDITOR_MENU_LIMITE_DE_TEMPO_PROMPT, s0, s1, 0xC7FF, 0)
        addi s1, s1, 10
        imprimir_string_reg(EDITOR_MENU_LIMITE_DE_TEMPO_AVISO, s0, s1, 0xC7FF, 0)
        addi s1, s1, 20
        imprimir_string_reg(MT3_DATA_STR_TERMINAL, s0, s1, 0xC7FF, 1)
        addi s0, s0, 88
        imprimir_string_reg(MT3_TEMPO, s0, s1, 0xC7FF, 1)
        addi s0, s0, -88
        addi s1, s1, 20
        imprimir_string_reg(EDITOR_MENU_CONFIRMAR, s0, s1,0xC7FF, 0)
        addi s1, s1, 10
        imprimir_string_reg(EDITOR_OPCOES_VOLTAR, s0, s1, 0xC7FF, 0)

        jal PROC_DESENHAR
        j E_MT3_LOOP

E_MT3_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        addi sp, sp, 12
        ret