# EDITOR_MENU_CONFIG

# Rotina que mostra o menu de configuracoes do editor.

EDITOR_MENU_CONFIG:

	addi sp, sp, -4
	sw ra, (sp)

E_MC1_MENU:

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

        imprimir_string(EDITOR_MENU_ESCOLHA, 100, 134, 0xC7FF, 0)

        imprimir_string(EDITOR_MENU_CONFIG_OPCAO_1, 100, 149, 0xC7FF, 0)

        lb t0, MUTADO
        bnez t0, E_MC1_PRINT_DESMUTAR


E_MC1_PRINT_MUTAR:
        imprimir_string(EDITOR_MENU_CONFIG_OPCAO_2_MUTAR, 100, 159, 0xC7FF, 0)
        j E_MC1_MENU_CONT
E_MC1_PRINT_DESMUTAR:
        imprimir_string(EDITOR_MENU_CONFIG_OPCAO_2_DESMUTAR, 100, 159, 0xC7FF, 0)
E_MC1_MENU_CONT:

        imprimir_string(EDITOR_MENU_OPCAO_9, 100, 169, 0xC7FF, 0)

        jal PROC_DESENHAR

E_MC1_LOOP:
	li a0, 0
        jal PROC_TOCAR_AUDIO	

	sleep(4) # performance

	li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,E_MC1_LOOP		# Se nao hah tecla pressionada entao nao checa tecla
  	lw t2,4(t1)  			# le o valor da tecla 
  	
  	li t0, '1'
	beq t2, t0, E_ME_MENU_IDIOMA
	li t0, '2'
	beq t2, t0, E_ME_MUTAR_DESMUTAR
	li t0, '9'
	beq t2, t0, E_MC1_VOLTAR
	li t0, 8		# TAMBEM VOLTA PRA BACKSPACE!!!
	beq t2, t0, E_MC1_VOLTAR

        j E_MC1_LOOP

E_MC1_VOLTAR:

	lw ra, (sp)
	addi sp, sp, 4
	ret

E_ME_MENU_IDIOMA:
        jal EDITOR_MENU_IDIOMA
        j E_MC1_MENU

E_ME_MUTAR_DESMUTAR:
        lb t0, MUTADO
        seqz t0, t0
        sb t0, MUTADO, t1
        j E_MC1_MENU
        




