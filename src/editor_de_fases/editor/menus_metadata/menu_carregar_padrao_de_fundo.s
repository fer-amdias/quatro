# EDITOR_MENU_CARREGAR_PADRAO_DE_FUNDO
# Mostra o menu de carregar textura do padrao de fundo.

.eqv MENU_CARREGAR_PADRAO_DE_FUNDO_X 0
.eqv MENU_CARREGAR_PADRAO_DE_FUNDO_Y 64

.data

CP1_DATA_STR_TERMINAL: .asciz "src/"
CP1_DATA_STR_CARACTERES_DIGITADOS: .byte 0
CP1_DATA_ARQUIVO_NAO_ENCONTRADO: .byte 0

CP1_STR_PATH: .space TAMANHO_STRING_METADATA    # onde vamos guardar o que o usuario esta digitando

.text

EDITOR_MENU_CARREGAR_PADRAO_DE_FUNDO:
        addi sp, sp, -20
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)
        sw s2, 12(sp)
        sw s3, 16(sp)

        la s2, FASE_TEXTURA_DE_FUNDO    # s2 = string com o nome 
        la s3, TEXTURA_FUNDO_BUFFER     # s3 = buffer para qual vamos carregar a textura

        mv a0, s2                       # a0 - string origem
        la a1, CP1_STR_PATH             # a1 - string destino
        mv a2, zero                     # a2 - quantidade de bytes (0 = ateh o final) 
        jal PROC_COPIAR_STRING          # copia a chave original para o nosso buffer de path para podermos modificalo sem alterar o valor do original

        la a0, CP1_STR_PATH
        jal PROC_TAMANHO_STRING
        sb a0, CP1_DATA_STR_CARACTERES_DIGITADOS, t0  # salva a quantidade de caracteres digitados como o tamanho da string

        sb zero, CP1_DATA_ARQUIVO_NAO_ENCONTRADO, t0 # reseta o estado da flag

        j E_CP1_DRAW_CYCLE

E_CP1_IDLE:
        sleep(10)
E_CP1_LOOP:
	li a0, 0
        jal PROC_TOCAR_AUDIO	
        
        li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,E_CP1_IDLE          # Se nao hah tecla pressionada entao nao faz NADA
  	lw t2,4(t1)  			# le o valor da tecla 

        li t0, 27       # ESC
        beq t2, t0, E_CP1_RET
	li t0, 8		
	beq t2, t0, E_CP1_REMOVE_CARACTERE
	li t0, '\n'
	beq t2, t0, E_CP1_ENTER

E_CP1_ADD_CARACTERE:
	lbu t1, CP1_DATA_STR_CARACTERES_DIGITADOS

	li t3, TAMANHO_STRING_METADATA
        addi t3, t3, -1
	bge t1, t3, E_CP1_IDLE	# cancela se chegamos no final do buffer

	la t0, CP1_STR_PATH
	add t0, t0, t1	# vai ate o caractere a ser digitado

	sb t2, (t0)	# adiciona o caractere
	sb zero, 1(t0)	# coloca um \0 no caractere seguinte para marcar fim da string

	# incrementa os caracteres digitados
	addi t1, t1, 1
	sb t1, CP1_DATA_STR_CARACTERES_DIGITADOS, t0

        j E_CP1_DRAW_CYCLE

E_CP1_REMOVE_CARACTERE:
	la t0, CP1_STR_PATH
	lbu t1, CP1_DATA_STR_CARACTERES_DIGITADOS
	beqz t1, E_CP1_IDLE	# nao tira nada se nao tiver caracteres
	addi t1, t1, -1		# volta um caractere
	add t0, t0, t1
	sb zero, (t0)	# substitui o ultimo caractere digitado por zero
	sb t1, CP1_DATA_STR_CARACTERES_DIGITADOS, t0	# decrementa a qtd de caracteres digitados

	j E_CP1_DRAW_CYCLE

E_CP1_ENTER:
        lw t0, CP1_DATA_STR_CARACTERES_DIGITADOS
        beqz t0, E_CP1_REMOVER_TEXTURA  # se nao houver nenhum caractere digitado, remove a textura

        la a0, CP1_STR_PATH             # a0 - string para carregar
        mv a1, s3                       # a1 - buffer para onde carregar
	jal EDITOR_CARREGAR_TEXTURA

	bgtz a0, E_CP1_SUCESSO
	# se a0 <= 0, entao nao foi possivel carregar a textura!

E_CP1_ENTER_FALHA:
	li t0, 1
	sb t0, CP1_DATA_ARQUIVO_NAO_ENCONTRADO, t1

	# reseta a string
	sb zero, CP1_DATA_STR_CARACTERES_DIGITADOS, t0
	sb zero, CP1_STR_PATH, t0

	#j E_CP1_DRAW_CYCLE
E_CP1_DRAW_CYCLE:
        jal SHADER_OBSCURECER_TELA

        li a0, 0xA0
        li a1, MENU_CARREGAR_PADRAO_DE_FUNDO_X
        li a2, MENU_CARREGAR_PADRAO_DE_FUNDO_Y
        li a3, LARGURA_VGA
        sub a3, a3, a1
        addi a3, a3, -1
        li a4, ALTURA_VGA
        sub a4, a4, a2
        addi a4, a4, -1
        li a7, 0
        jal PROC_IMPRIMIR_RETANGULO

        li a0, 0xFF
        li a1, MENU_CARREGAR_PADRAO_DE_FUNDO_X
        addi a1, a1, 5
        li a2, MENU_CARREGAR_PADRAO_DE_FUNDO_Y
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
        li s0, MENU_CARREGAR_PADRAO_DE_FUNDO_X
        li s1, MENU_CARREGAR_PADRAO_DE_FUNDO_Y
        addi s0, s0, 9                 # x
        addi s1, s1, 9                 # y

        imprimir_string_reg(EDITOR_MENU_CARREGAR_PROMPT, s0, s1, 0xC7FF, 0)
        addi s1, s1, 10
        imprimir_string_reg(EDITOR_MENU_FUNDO_DICA, s0, s1, 0xC7FF, 0)
        addi s1, s1, 20
        imprimir_string_reg(CP1_DATA_STR_TERMINAL, s0, s1, 0xC7FF, 1)
        addi s0, s0, 32
        imprimir_string_reg(CP1_STR_PATH, s0, s1, 0xC7FF, 1)
        addi s0, s0, -32
        addi s1, s1, 46
        imprimir_string_reg(EDITOR_MENU_CONFIRMAR, s0, s1,0xC7FF, 0)
        addi s1, s1, 10
        imprimir_string_reg(EDITOR_OPCOES_VOLTAR, s0, s1, 0xC7FF, 0)

        lb t0, CP1_DATA_ARQUIVO_NAO_ENCONTRADO
        beqz t0, E_CP1_DRAW_CYCLE_CONT

E_CP1_ARQUIVO_NAO_ENCONTRADO:
        addi s1, s1, -20
        imprimir_string_reg(EDITOR_MENU_CARREGAR_NAO_ENCONTRADO, s0, s1, 0xC737, 0)

E_CP1_DRAW_CYCLE_CONT:
        jal PROC_DESENHAR
        j E_CP1_LOOP

E_CP1_REMOVER_TEXTURA:
        # nulifica as dimensoes da textura, efetivamente apagando-a por invalidez
        sw zero, (s3)
        sw zero, 4(s3)

E_CP1_SUCESSO:
        la a0, CP1_STR_PATH             # copiar da string digitada (que corresponde a um arquivo valido!)
        mv a1, s2                       # colar no buffer com nome da chave da textura, atualizando-o
        mv a2, zero                     # copiar ate chegarmos em um /0
        jal PROC_COPIAR_STRING

E_CP1_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        lw s2, 12(sp)
        lw s3, 16(sp)
        addi sp, sp, 20
        ret