# EDITOR_MENU_SALVAR_FASE_COMO
# Mostra o menu de salvamento.

.eqv MENU_SALVAR_FASE_X 0
.eqv MENU_SALVAR_FASE_Y 74

.data

SF1_DATA_STR_TERMINAL: .asciz "assets/fases/"
SF1_DATA_STR_CARACTERES_DIGITADOS: .byte 0
SF1_DATA_NOME_INVALIDO: .byte 0
                                
SF1_STR_PATH: .asciz "../assets/fases"
SF1_NOME_ARQUIVO: .space 256     # buffer para o nome do arquivo

.text

EDITOR_MENU_SALVAR_FASE_COMO:
        addi sp, sp, -12
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)

        la t0, SF1_STR_PATH
	li t1, '/'
	sb t1, 15(t0)	# correcao de erro: substitui o null-terminated character de SF1_STR_PATH por uma barra.
	# isso eh estritamente necessario: na versao 1.13 do FPGRARS, nao tem como declarar uma non-null-terminated string.
	# portanto, devemos destruir o \0 substituindo-o no codigo pelo que queremos no lugar, fazendo uma non-null-terminated
	# string na pratica.

        # coloca o nome do arquivo, se houver, no buffer
        la a0, STR_NOME_ARQUIVO
        la a1, SF1_NOME_ARQUIVO
        mv a2, zero                     # copia ateh o final
        jal PROC_COPIAR_STRING

        la a0, SF1_NOME_ARQUIVO
        jal PROC_TAMANHO_STRING
        sb a0, SF1_DATA_STR_CARACTERES_DIGITADOS, t0  # salva a quantidade de caracteres digitados como o tamanho da string

        sb zero, SF1_DATA_NOME_INVALIDO, t0 # reseta o estado da flag

E_SF1_OBSCURECER_TELA:
        jal SHADER_OBSCURECER_TELA
        j E_SF1_DRAW_CYCLE

E_SF1_IDLE:
        sleep(10)
E_SF1_LOOP:
        li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,E_SF1_IDLE          # Se nao hah tecla pressionada entao nao faz NADA
  	lw t2,4(t1)  			# le o valor da tecla 

        li t0, 27       # ESC
        beq t2, t0, E_SF1_RET
	li t0, 8		
	beq t2, t0, E_SF1_REMOVE_CARACTERE
	li t0, '\n'
	beq t2, t0, E_SF1_ENTER

E_SF1_ADD_CARACTERE:
	la t0, SF1_NOME_ARQUIVO
	lbu t1, SF1_DATA_STR_CARACTERES_DIGITADOS

	li t3, 255
	bge t1, t3, E_SF1_IDLE	# cancela se chegamos no final do buffer

	add t0, t0, t1	# vai ate o caractere a ser digitado

	sb t2, (t0)	# adiciona o caractere
	sb zero, 1(t0)	# coloca um \0 no caractere seguinte para marcar fim da string

	# incrementa os caracteres digitados
	addi t1, t1, 1
	sb t1, SF1_DATA_STR_CARACTERES_DIGITADOS, t0

        j E_SF1_DRAW_CYCLE

E_SF1_REMOVE_CARACTERE:
	la t0, SF1_NOME_ARQUIVO
	lbu t1, SF1_DATA_STR_CARACTERES_DIGITADOS
	beqz t1, E_SF1_IDLE	# nao tira nada se nao tiver caracteres
	addi t1, t1, -1		# volta um caractere
	add t0, t0, t1
	sb zero, (t0)	# substitui o ultimo caractere digitado por zero
	sb t1, SF1_DATA_STR_CARACTERES_DIGITADOS, t0	# decrementa a qtd de caracteres digitados

	j E_SF1_DRAW_CYCLE

E_SF1_ENTER:
        la a0, SF1_STR_PATH
	jal EDITOR_SALVAR_FASE
        bgtz a0, E_SF1_SALVAR_FIM    # se conseguimos escrever mais de 0 bytes, finalize. Senao, grite com o usuario.

	li t0, 1
	sb t0, SF1_DATA_NOME_INVALIDO, t1

	# reseta a string
	sb zero, SF1_DATA_STR_CARACTERES_DIGITADOS, t0
	sb zero, SF1_NOME_ARQUIVO, t0

	j E_SF1_DRAW_CYCLE

E_SF1_DRAW_CYCLE:

        li a0, 0xA0
        li a1, MENU_SALVAR_FASE_X
        li a2, MENU_SALVAR_FASE_Y
        li a3, LARGURA_VGA
        sub a3, a3, a1
        addi a3, a3, -1
        li a4, ALTURA_VGA
        sub a4, a4, a2
        addi a4, a4, -1
        li a7, 0
        jal PROC_IMPRIMIR_RETANGULO

        li a0, 0xFF
        li a1, MENU_SALVAR_FASE_X
        addi a1, a1, 5
        li a2, MENU_SALVAR_FASE_Y
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
        li s0, MENU_SALVAR_FASE_X
        li s1, MENU_SALVAR_FASE_Y
        addi s0, s0, 9                 # x
        addi s1, s1, 9                 # y

        imprimir_string_reg(EDITOR_MENU_CARREGAR_PROMPT, s0, s1, 0xC7FF, 0)
        addi s1, s1, 20
        imprimir_string_reg(SF1_DATA_STR_TERMINAL, s0, s1, 0xC7FF, 1)
        addi s0, s0, 104
        imprimir_string_reg(SF1_NOME_ARQUIVO, s0, s1, 0xC7FF, 1)
        addi s0, s0, -104
        addi s1, s1, 46
        imprimir_string_reg(EDITOR_OPCOES_VOLTAR, s0, s1, 0xC7FF, 0)

        lb t0, SF1_DATA_NOME_INVALIDO
        beqz t0, E_SF1_DRAW_CYCLE_CONT

E_SF1_ARQUIVO_NAO_ENCONTRADO:
        addi s1, s1, -10
        imprimir_string_reg(EDITOR_MENU_SALVAR_NOME_INVALIDO, s0, s1, 0xC737, 0)

E_SF1_DRAW_CYCLE_CONT:

        jal PROC_DESENHAR

        j E_SF1_LOOP

E_SF1_SALVAR_FIM:
        # salva o novo path
        la a0, SF1_STR_PATH
        la a1, ARQUIVO_STR_PATH
        mv a2, zero                     # ateh o final da string origem
        jal PROC_COPIAR_STRING

        mv a0, zero             # status: sucesso
        jal EDITOR_MENU_FASE_SALVA

E_SF1_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        addi sp, sp, 12
        ret