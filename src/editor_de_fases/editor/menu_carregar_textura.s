# EDITOR_MENU_CARREGAR_TEXTURA
# Carrega uma textura fornecida pelo usuario.

.eqv MENU_CARREGAR_TEXTURA_X 0
.eqv MENU_CARREGAR_TEXTURA_Y 74

.data

MC3_DATA_STR_TERMINAL: .asciz "assets/texturas/"
MC3_DATA_STR_CARACTERES_DIGITADOS: .byte 0
MC3_DATA_ARQUIVO_NAO_ENCONTRADO: .byte 0
                                
MC3_STR_PATH: .asciz "../assets/texturas"
MC3_NOME_ARQUIVO: .space 256     # buffer para o nome do arquivo

.text

EDITOR_MENU_CARREGAR_TEXTURA:
        addi sp, sp, -4
        sw ra, (sp)

        la t0, MC3_STR_PATH
	li t1, '/'
	sb t1, 18(t0)	# correcao de erro: substitui o null-terminated character de MC3_STR_PATH por uma barra.
	# isso eh estritamente necessario: na versao 1.13 do FPGRARS, nao tem como declarar uma non-null-terminated string.
	# portanto, devemos destruir o \0 substituindo-o no codigo pelo que queremos no lugar, fazendo uma non-null-terminated
	# string na pratica.

        sb zero, MC3_DATA_ARQUIVO_NAO_ENCONTRADO, t0 # reseta o estado da flag

E_MC3_OBSCURECER_TELA:
        jal SHADER_OBSCURECER_TELA
        j E_MC3_DRAW_CYCLE

E_MC3_IDLE:
        sleep(10)
E_MC3_LOOP:
        li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,E_MC3_IDLE          # Se nao hah tecla pressionada entao nao faz NADA
  	lw t2,4(t1)  			# le o valor da tecla 

        li t0, 27       # ESC
        beq t2, t0, E_MC3_RET
	li t0, 8		
	beq t2, t0, E_MC3_REMOVE_CARACTERE
	li t0, '\n'
	beq t2, t0, E_MC3_ENTER

E_MC3_ADD_CARACTERE:
	la t0, MC3_NOME_ARQUIVO
	lbu t1, MC3_DATA_STR_CARACTERES_DIGITADOS

	li t3, 255
	bge t1, t3, E_MC3_IDLE	# cancela se chegamos no final do buffer

	add t0, t0, t1	# vai ate o caractere a ser digitado

	sb t2, (t0)	# adiciona o caractere
	sb zero, 1(t0)	# coloca um \0 no caractere seguinte para marcar fim da string

	# incrementa os caracteres digitados
	addi t1, t1, 1
	sb t1, MC3_DATA_STR_CARACTERES_DIGITADOS, t0

        j E_MC3_DRAW_CYCLE

E_MC3_REMOVE_CARACTERE:
	la t0, MC3_NOME_ARQUIVO
	lbu t1, MC3_DATA_STR_CARACTERES_DIGITADOS
	beqz t1, E_MC3_IDLE	# nao tira nada se nao tiver caracteres
	addi t1, t1, -1		# volta um caractere
	add t0, t0, t1
	sb zero, (t0)	# substitui o ultimo caractere digitado por zero
	sb t1, MC3_DATA_STR_CARACTERES_DIGITADOS, t0	# decrementa a qtd de caracteres digitados

	j E_MC3_DRAW_CYCLE

E_MC3_ENTER:
	la a0, MC3_STR_PATH
	li a1, 0	# read-only
	li a7, 1024
	ecall

	bgez a0, E_MC3_CARREGAR_TEXTURA
	# se a0 < 0, entao nao foi possivel abrir a fase!

	li t0, 1
	sb t0, MC3_DATA_ARQUIVO_NAO_ENCONTRADO, t1

	# reseta a string
	sb zero, MC3_DATA_STR_CARACTERES_DIGITADOS, t0
	sb zero, MC3_NOME_ARQUIVO, t0

	j E_MC3_DRAW_CYCLE

E_MC3_CARREGAR_TEXTURA:
        la a0, MC3_STR_PATH
	jal EDITOR_CARREGAR_TEXTURA
        j E_MC3_RET

E_MC3_DRAW_CYCLE:

        li a0, 0xA0
        li a1, MENU_CARREGAR_TEXTURA_X
        li a2, MENU_CARREGAR_TEXTURA_Y
        li a3, LARGURA_VGA
        sub a3, a3, a1
        addi a3, a3, -1
        li a4, ALTURA_VGA
        sub a4, a4, a2
        addi a4, a4, -1
        li a7, 0
        jal PROC_IMPRIMIR_RETANGULO

        li a0, 0xFF
        li a1, MENU_CARREGAR_TEXTURA_X
        addi a1, a1, 5
        li a2, MENU_CARREGAR_TEXTURA_Y
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
        li s0, MENU_CARREGAR_TEXTURA_X
        li s1, MENU_CARREGAR_TEXTURA_Y
        addi s0, s0, 9                 # x
        addi s1, s1, 9                 # y

        imprimir_string_reg(EDITOR_MENU_CARREGAR_PROMPT, s0, s1, 0xC7FF, 0)
        addi s1, s1, 20
        imprimir_string_reg(MC3_DATA_STR_TERMINAL, s0, s1, 0xC7FF, 1)
        addi s0, s0, 128
        imprimir_string_reg(MC3_NOME_ARQUIVO, s0, s1, 0xC7FF, 1)
        addi s0, s0, -128
        addi s1, s1, 46
        imprimir_string_reg(EDITOR_OPCOES_VOLTAR, s0, s1, 0xC7FF, 0)

        lb t0, MC3_DATA_ARQUIVO_NAO_ENCONTRADO
        beqz t0, E_MC3_DRAW_CYCLE_CONT

E_MC3_ARQUIVO_NAO_ENCONTRADO:
        addi s1, s1, -10
        imprimir_string_reg(EDITOR_MENU_CARREGAR_NAO_ENCONTRADO, s0, s1, 0xC737, 0)

E_MC3_DRAW_CYCLE_CONT:

        jal PROC_DESENHAR

        j E_MC3_LOOP

E_MC3_RET:
        lw ra, (sp)
        addi sp, sp, 4
        ret