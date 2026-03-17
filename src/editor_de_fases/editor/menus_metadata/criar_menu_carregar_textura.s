# EDITOR_CRIAR_MENU_CARREGAR_TEXTURA
# Mostra um menu de carregar textura de acordo com os parametros fornecidos.
#
# a0 - buffer de nome do arquivo a ser alterado
# a1 - buffer para carregar a textura (0 para nao carregar em lugar nenhum)

.eqv CRIAR_MENU_CARREGAR_TEXTURA_X 0
.eqv CRIAR_MENU_CARREGAR_TEXTURA_Y 69

.data

CM1_DATA_STR_TERMINAL: .asciz "src/"
CM1_DATA_STR_CARACTERES_DIGITADOS: .byte 0
CM1_DATA_ARQUIVO_NAO_ENCONTRADO: .byte 0

CM1_STR_PATH: .space TAMANHO_STRING_METADATA    # onde vamos guardar o que o usuario esta digitando

.text

EDITOR_CRIAR_MENU_CARREGAR_TEXTURA:
        addi sp, sp, -20
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)
        sw s2, 12(sp)
        sw s3, 16(sp)

        mv s2, a0                       # s2 = string com nome de arquivo
        mv s3, a1                       # s3 = buffer para qual vamos carregar a textura

#       mv a0, a0                       # a0 - string origem, ja colocada
        la a1, CM1_STR_PATH             # a1 - string destino
        mv a2, zero                     # a2 - quantidade de bytes (0 = ateh o final) 
        jal PROC_COPIAR_STRING          # copia a chave original para o nosso buffer de path para podermos modificalo sem alterar o valor do original

        la a0, CM1_STR_PATH
        jal PROC_TAMANHO_STRING
        sb a0, CM1_DATA_STR_CARACTERES_DIGITADOS, t0  # salva a quantidade de caracteres digitados como o tamanho da string

        sb zero, CM1_DATA_ARQUIVO_NAO_ENCONTRADO, t0 # reseta o estado da flag

        j E_CM1_DRAW_CYCLE

E_CM1_IDLE:
        sleep(10)
E_CM1_LOOP:
	li a0, 0
        jal PROC_TOCAR_AUDIO	
        
        li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,E_CM1_IDLE          # Se nao hah tecla pressionada entao nao faz NADA
  	lw t2,4(t1)  			# le o valor da tecla 

        li t0, 27       # ESC
        beq t2, t0, E_CM1_RET
	li t0, 8		
	beq t2, t0, E_CM1_REMOVE_CARACTERE
	li t0, '\n'
	beq t2, t0, E_CM1_ENTER

E_CM1_ADD_CARACTERE:
	lbu t1, CM1_DATA_STR_CARACTERES_DIGITADOS

	li t3, TAMANHO_STRING_METADATA
        addi t3, t3, -1
	bge t1, t3, E_CM1_IDLE	# cancela se chegamos no final do buffer

	la t0, CM1_STR_PATH
	add t0, t0, t1	# vai ate o caractere a ser digitado

	sb t2, (t0)	# adiciona o caractere
	sb zero, 1(t0)	# coloca um \0 no caractere seguinte para marcar fim da string

	# incrementa os caracteres digitados
	addi t1, t1, 1
	sb t1, CM1_DATA_STR_CARACTERES_DIGITADOS, t0

        j E_CM1_DRAW_CYCLE

E_CM1_REMOVE_CARACTERE:
	la t0, CM1_STR_PATH
	lbu t1, CM1_DATA_STR_CARACTERES_DIGITADOS
	beqz t1, E_CM1_IDLE	# nao tira nada se nao tiver caracteres
	addi t1, t1, -1		# volta um caractere
	add t0, t0, t1
	sb zero, (t0)	# substitui o ultimo caractere digitado por zero
	sb t1, CM1_DATA_STR_CARACTERES_DIGITADOS, t0	# decrementa a qtd de caracteres digitados

	j E_CM1_DRAW_CYCLE

E_CM1_ENTER:
        beqz s3, E_CM1_VALIDAR_SEM_CARREGAR    # SE o buffer de carregar textura nao foi fornecido, verifica que o arquivo existe sem carrega-lo

        la a0, CM1_STR_PATH             # a0 - string para carregar
        mv a1, s3                       # a1 - buffer para onde carregar
	jal EDITOR_CARREGAR_TEXTURA

	bgtz a0, E_CM1_SUCESSO
	# se a0 <= 0, entao nao foi possivel carregar a textura!

E_CM1_ENTER_FALHA:
	li t0, 1
	sb t0, CM1_DATA_ARQUIVO_NAO_ENCONTRADO, t1

	# reseta a string
	sb zero, CM1_DATA_STR_CARACTERES_DIGITADOS, t0
	sb zero, CM1_STR_PATH, t0

	#j E_CM1_DRAW_CYCLE
E_CM1_DRAW_CYCLE:
        jal SHADER_OBSCURECER_TELA

        li a0, 0xA0
        li a1, CRIAR_MENU_CARREGAR_TEXTURA_X
        li a2, CRIAR_MENU_CARREGAR_TEXTURA_Y
        li a3, LARGURA_VGA
        sub a3, a3, a1
        addi a3, a3, -1
        li a4, ALTURA_VGA
        sub a4, a4, a2
        addi a4, a4, -1
        li a7, 0
        jal PROC_IMPRIMIR_RETANGULO

        li a0, 0xFF
        li a1, CRIAR_MENU_CARREGAR_TEXTURA_X
        addi a1, a1, 5
        li a2, CRIAR_MENU_CARREGAR_TEXTURA_Y
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
        li s0, CRIAR_MENU_CARREGAR_TEXTURA_X
        li s1, CRIAR_MENU_CARREGAR_TEXTURA_Y
        addi s0, s0, 9                 # x
        addi s1, s1, 9                 # y

        imprimir_string_reg(EDITOR_MENU_CARREGAR_PROMPT, s0, s1, 0xC7FF, 0)
        addi s1, s1, 20
        imprimir_string_reg(CM1_DATA_STR_TERMINAL, s0, s1, 0xC7FF, 1)
        addi s0, s0, 32
        imprimir_string_reg(CM1_STR_PATH, s0, s1, 0xC7FF, 1)
        addi s0, s0, -32
        addi s1, s1, 46
        imprimir_string_reg(EDITOR_MENU_CONFIRMAR, s0, s1,0xC7FF, 0)
        addi s1, s1, 10
        imprimir_string_reg(EDITOR_OPCOES_VOLTAR, s0, s1, 0xC7FF, 0)

        lb t0, CM1_DATA_ARQUIVO_NAO_ENCONTRADO
        beqz t0, E_CM1_DRAW_CYCLE_CONT

E_CM1_ARQUIVO_NAO_ENCONTRADO:
        addi s1, s1, -20
        imprimir_string_reg(EDITOR_MENU_CARREGAR_NAO_ENCONTRADO, s0, s1, 0xC737, 0)

E_CM1_DRAW_CYCLE_CONT:
        jal PROC_DESENHAR
        j E_CM1_LOOP

E_CM1_VALIDAR_SEM_CARREGAR:
        la a0, CM1_STR_PATH             # arquivo digitado
	li a1, 0	                # read-only
	li a7, 1024                     # abrir arquivo
	ecall

        bltz a0, E_CM1_ENTER_FALHA      # volta e marca como falha se nao conseguimos abrir o arquivo

        # a0 carregado
        li a7, 57       # fechar arquivo
        ecall                           # fecha o arquivo antes de continuarmos

        # se chegamos ate aqui, o arquivo existe -- portanto, a validacao foi bem-sucedida!

E_CM1_SUCESSO:
        la a0, CM1_STR_PATH             # copiar da string digitada (que corresponde a um arquivo valido!)
        mv a1, s2                       # colar no buffer com nome da chave da textura, atualizando-o
        mv a2, zero                     # copiar ate chegarmos em um /0
        jal PROC_COPIAR_STRING

E_CM1_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        lw s2, 12(sp)
        lw s3, 16(sp)
        addi sp, sp, 20
        ret