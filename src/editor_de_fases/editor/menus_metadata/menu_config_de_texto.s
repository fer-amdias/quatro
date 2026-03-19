# EDITOR_MENU_CONFIG_DE_TEXTO
# Mostra o menu de selecao de texto pro pergaminho

.eqv MENU_CONFIG_DE_TEXTO_X 0
.eqv MENU_CONFIG_DE_TEXTO_Y 74

.data

MT2_DATA_STR_CARACTERES_DIGITADOS: .byte 0
MT2_DATA_CHAVE_N_ENCONTRADA: .byte 0
MT2_DATA_STR_TERMINAL: .asciz "key: "
MT2_CHAVE: .space TAMANHO_STRING_METADATA

.text


EDITOR_MENU_CONFIG_DE_TEXTO:
        addi sp, sp, -12
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)

        la a0, FASE_TEXTO_PERGAMINHO    # a0 - string origem
        la a1, MT2_CHAVE                # a1 - string destino
        mv a2, zero                     # a2 - quantidade de bytes (0 = ateh o final) 
        jal PROC_COPIAR_STRING          # copia a chave original para o nosso buffer de path para podermos modificalo sem alterar o valor do original

        la a0, MT2_CHAVE
        jal PROC_TAMANHO_STRING
        sb a0, MT2_DATA_STR_CARACTERES_DIGITADOS, t0  # salva a quantidade de caracteres digitados como o tamanho da string

        sb zero, MT2_DATA_CHAVE_N_ENCONTRADA, t0 # reseta o estado da flag

        j E_MT2_DRAW_CYCLE

E_MT2_IDLE:
        sleep(10)
E_MT2_LOOP:
	li a0, 0
        jal PROC_TOCAR_AUDIO	
        
        li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,E_MT2_IDLE          # Se nao hah tecla pressionada entao nao faz NADA
  	lw t2,4(t1)  			# le o valor da tecla 

        li t0, 27       # ESC
        beq t2, t0, E_MT2_RET
	li t0, 8		
	beq t2, t0, E_MT2_REMOVE_CARACTERE
	li t0, '\n'
	beq t2, t0, E_MT2_ENTER

E_MT2_ADD_CARACTERE:
	la t0, MT2_CHAVE
	lbu t1, MT2_DATA_STR_CARACTERES_DIGITADOS

	li t3, TAMANHO_STRING_METADATA
        addi t3, t3, -1
	bge t1, t3, E_MT2_IDLE	# cancela se chegamos no final do buffer

	add t0, t0, t1	# vai ate o caractere a ser digitado

	sb t2, (t0)	# adiciona o caractere
	sb zero, 1(t0)	# coloca um \0 no caractere seguinte para marcar fim da string

	# incrementa os caracteres digitados
	addi t1, t1, 1
	sb t1, MT2_DATA_STR_CARACTERES_DIGITADOS, t0

        j E_MT2_DRAW_CYCLE

E_MT2_REMOVE_CARACTERE:
	la t0, MT2_CHAVE
	lbu t1, MT2_DATA_STR_CARACTERES_DIGITADOS
	beqz t1, E_MT2_IDLE	# nao tira nada se nao tiver caracteres
	addi t1, t1, -1		# volta um caractere
	add t0, t0, t1
	sb zero, (t0)	# substitui o ultimo caractere digitado por zero
	sb t1, MT2_DATA_STR_CARACTERES_DIGITADOS, t0	# decrementa a qtd de caracteres digitados

	j E_MT2_DRAW_CYCLE

E_MT2_ENTER:
        la a0, MT2_CHAVE
	jal PROC_OBTER_TRADUCAO

	bnez a1, E_MT2_SALVAR_CHAVE
	# se a1 = 0, entao nao foi possivel encontrar a traducao!

	li t0, 1
	sb t0, MT2_DATA_CHAVE_N_ENCONTRADA, t1

	# reseta a string
	sb zero, MT2_DATA_STR_CARACTERES_DIGITADOS, t0
	sb zero, MT2_CHAVE, t0

	j E_MT2_DRAW_CYCLE

E_MT2_SALVAR_CHAVE:
        la a0, MT2_CHAVE                # copiar da string digitada (que corresponde a uma chave valida!)
        la a1, FASE_TEXTO_PERGAMINHO    # colar no buffer com o nome da chave de texto, atualizando-o
        mv a2, zero                     # copiar ate chegarmos em um /0
        jal PROC_COPIAR_STRING
        j E_MT2_RET

E_MT2_DRAW_CYCLE:
        jal SHADER_OBSCURECER_TELA

        li a0, 0xA0
        li a1, MENU_CONFIG_DE_TEXTO_X
        li a2, MENU_CONFIG_DE_TEXTO_Y
        li a3, LARGURA_VGA
        sub a3, a3, a1
        addi a3, a3, -1
        li a4, ALTURA_VGA
        sub a4, a4, a2
        addi a4, a4, -1
        li a7, 0
        jal PROC_IMPRIMIR_RETANGULO

        li a0, 0xFF
        li a1, MENU_CONFIG_DE_TEXTO_X
        addi a1, a1, 5
        li a2, MENU_CONFIG_DE_TEXTO_Y
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
        li s0, MENU_CONFIG_DE_TEXTO_X
        li s1, MENU_CONFIG_DE_TEXTO_Y
        addi s0, s0, 9                 # x
        addi s1, s1, 9                 # y

        imprimir_string_reg(locale_EDITOR_MENU_TEXTO_PROMPT, s0, s1, 0xC7FF, 0)
        addi s1, s1, 20
        imprimir_string_reg(MT2_DATA_STR_TERMINAL, s0, s1, 0xC7FF, 1)
        addi s0, s0, 40
        imprimir_string_reg(MT2_CHAVE, s0, s1, 0xC7FF, 1)
        addi s0, s0, -40
        addi s1, s1, 36
        imprimir_string_reg(locale_EDITOR_MENU_CONFIRMAR, s0, s1,0xC7FF, 0)
        addi s1, s1, 10
        imprimir_string_reg(locale_EDITOR_OPCOES_VOLTAR_AO_EDITOR, s0, s1, 0xC7FF, 0)

        lb t0, MT2_DATA_CHAVE_N_ENCONTRADA
        beqz t0, E_MT2_DRAW_CYCLE_CONT

E_MT2_CHAVE_NAO_ENCONTRADA:
        addi s1, s1, -20
        imprimir_string_reg(locale_EDITOR_MENU_CHAVE_NAO_ENCONTRADA, s0, s1, 0xC737, 0)

E_MT2_DRAW_CYCLE_CONT:

        jal PROC_DESENHAR
        j E_MT2_LOOP

E_MT2_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        addi sp, sp, 12
        ret