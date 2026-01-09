# EDITOR_MENU_PRINCIPAL

# Rotina que mostra o menu principal do editor.

EDITOR_MENU_PRINCIPAL:

	addi sp, sp, -4
	sw ra, (sp)

	li a0, 1
	la a1, intro_tune
	li a2, 1
	li a3, 1
	jal PROC_TOCAR_AUDIO

E_MP1_MENU:

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

	imprimir_string(EDITOR_MENU_PRINCIPAL_OPCAO_1, 100, 134, 0xC7FF, 0)
	imprimir_string(EDITOR_MENU_PRINCIPAL_OPCAO_2, 100, 144, 0xC7FF, 0)
	imprimir_string(EDITOR_MENU_PRINCIPAL_OPCAO_3, 100, 154, 0xC7FF, 0)
	imprimir_string(EDITOR_MENU_PRINCIPAL_OPCAO_4, 100, 164, 0xC7FF, 0)

        jal PROC_DESENHAR

E_MP1_LOOP:

	li a0, 0
        lb t0, MUTADO
        bnez t0, E_MP1_LOOP_SEM_AUDIO
        jal PROC_TOCAR_AUDIO	
E_MP1_LOOP_SEM_AUDIO:

	li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,E_MP1_LOOP		# Se nao hah tecla pressionada entao nao checa tecla
  	lw t2,4(t1)  			# le o valor da tecla 
  	
  	li t0, '1'
	beq t2, t0, E_MP1_MENU_EDITAR
	li t0, '2'
	beq t2, t0, E_MP1_MENU_CONFIG
	li t0, '3'
	beq t2, t0, E_MP1_MENU_CREDITOS
	li t0, '4'
	bne t2, t0, E_MP1_LOOP # se NAO for 4, continua

	lw ra, (sp)
	addi sp, sp, 4
	ret

E_MP1_MENU_EDITAR:
	jal EDITOR_MENU_EDITAR
	j E_MP1_MENU
	
E_MP1_MENU_CONFIG:
	jal EDITOR_MENU_CONFIG
	j E_MP1_MENU

E_MP1_MENU_CREDITOS:
	lb t0, MUTADO
	seqz t0, t0	# pega !MUTADO
	sw t0, TRACK1_ATIVO, t1	# salva !MUTADO no track ativo para impedir que a musica toque se estiver mutado!
	jal ROTINA_MENU_CREDITOS
	j E_MP1_MENU


