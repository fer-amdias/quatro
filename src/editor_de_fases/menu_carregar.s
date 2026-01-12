# EDITOR_MENU_CARREGAR

# Rotina que mostra o menu de selecao de arquivo

.data

MENU_CARREGAR_STR_TERMINAL: .asciz "assets/fases/"
MENU_CARREGAR_STR_CARACTERES_DIGITADOS: .byte 0
MENU_CARREGAR_ARQUIVO_NAO_ENCONTRADO: .byte 0

.text

EDITOR_MENU_CARREGAR:

	addi sp, sp, -4
	sw ra, (sp)

	la t0, ARQUIVO_STR_PATH
	li t1, '/'
	sb t1, 15(t0)	# correcao de erro: substitui o null-terminated character de ARQUIVO_STR_PATH por uma barra.
	# isso eh estritamente necessario: na versao 1.13 do FPGRARS, nao tem como declarar uma non-null-terminated string.
	# portanto, devemos destruir o \0 substituindo-o no codigo pelo que queremos no lugar, fazendo uma non-null-terminated
	# string na pratica.

	sb zero, MENU_CARREGAR_ARQUIVO_NAO_ENCONTRADO, t0 # reseta o estado da flag

E_MC2_MENU:

        li a0, 0xA0			# ciano
	li a1, 1
	jal PROC_PREENCHER_TELA		# preenche a tela de preto
	
	la a0, logoquatro
	li a1, 59
	li a2, 30
	lw a3, 4(a0)
	lw a4, (a0)
	addi a0, a0, 8			# pula os bytes de informacao
	li a7, 0
	jal PROC_IMPRIMIR_TEXTURA

        imprimir_string(EDITOR_MENU_CARREGAR_PROMPT, 100, 134, 0xC7FF, 0)
        imprimir_string(MENU_CARREGAR_STR_TERMINAL, 10, 149, 0xC7FF, 1)
        imprimir_string(STR_NOME_ARQUIVO, 114, 149, 0xC7FF, 1)
        imprimir_string(EDITOR_MENU_OPCAO_9, 100, 164, 0xC7FF, 0)
	# TODO: use ESC instead of 9 in case user file contains the letter 9 lmao
	# why didnt i foresee this problem earlier

	lb t0, MENU_CARREGAR_ARQUIVO_NAO_ENCONTRADO
	beqz t0, E_MC2_MENU_CONT

	# se o arquivo nao foi encontrado

	imprimir_string(EDITOR_MENU_CARREGAR_NAO_ENCONTRADO, 100, 189, 0xC737, 0)
	
E_MC2_MENU_CONT:
	jal PROC_DESENHAR

E_MC2_LOOP:

	li a0, 0
        jal PROC_TOCAR_AUDIO	

	sleep(4) # performance

	li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,E_MC2_LOOP		# Se nao hah tecla pressionada entao nao checa tecla
  	lw t2,4(t1)  			# le o valor da tecla 
  	
	li t0, '9'
	beq t2, t0, E_MC2_VOLTAR
	li t0, 8		
	beq t2, t0, E_MC2_REMOVE_CARACTERE
	li t0, '\n'
	beq t2, t0, E_MC2_ENTER

E_MC2_ADD_CARACTERE:
	la t0, STR_NOME_ARQUIVO
	lbu t1, MENU_CARREGAR_STR_CARACTERES_DIGITADOS

	li t3, 255
	bge t1, t3, E_MC2_MENU	# cancela se chegamos no final do buffer

	add t0, t0, t1	# vai ate o caractere a ser digitado

	sb t2, (t0)	# adiciona o caractere
	sb zero, 1(t0)	# coloca um \0 no caractere seguinte para marcar fim da string

	# incrementa os caracteres digitados
	addi t1, t1, 1
	sb t1, MENU_CARREGAR_STR_CARACTERES_DIGITADOS, t0

        j E_MC2_MENU

E_MC2_REMOVE_CARACTERE:
	la t0, STR_NOME_ARQUIVO
	lbu t1, MENU_CARREGAR_STR_CARACTERES_DIGITADOS
	beqz t1, E_MC2_MENU	# nao tira nada se nao tiver caracteres
	addi t1, t1, -1		# volta um caractere
	add t0, t0, t1
	sb zero, (t0)	# substitui o ultimo caractere digitado por zero
	sb t1, MENU_CARREGAR_STR_CARACTERES_DIGITADOS, t0	# decrementa a qtd de caracteres digitados
	j E_MC2_MENU


E_MC2_VOLTAR:
	sb zero, MENU_CARREGAR_STR_CARACTERES_DIGITADOS, t0
	sb zero, STR_NOME_ARQUIVO, t0
	lw ra, (sp)
	addi sp, sp, 4
	ret

E_MC2_ENTER:
	la a0, ARQUIVO_STR_PATH
	li a1, 0	# read-only
	li a7, 1024
	ecall

	bgtz a0, E_MC2_CARREGAR_FASE
	# se a0 < 0, entao nao foi possivel abrir a fase!

	li t0, 1
	sb t0, MENU_CARREGAR_ARQUIVO_NAO_ENCONTRADO, t1

	# reseta a string
	sb zero, MENU_CARREGAR_STR_CARACTERES_DIGITADOS, t0
	sb zero, STR_NOME_ARQUIVO, t0

	j E_MC2_MENU

E_MC2_CARREGAR_FASE:

	# jal EDITOR_CARREGAR_FASE

	li a7, 10
	ecall
	# finaliza, placeholder


