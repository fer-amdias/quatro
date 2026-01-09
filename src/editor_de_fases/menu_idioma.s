# EDITOR_MENU_IDIOMA

# Rotina que mostra o menu de alterar o idioma atual.

EDITOR_MENU_IDIOMA:

	addi sp, sp, -4
	sw ra, (sp)

E_MI1_MENU:

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

        imprimir_string(EDITOR_MENU_IDIOMA_PROMPT, 100, 134, 0xC7FF, 0)
        imprimir_string(EDITOR_MENU_IDIOMA_PT, 100, 149, 0xC7FF, 0)
        imprimir_string(EDITOR_MENU_IDIOMA_EN, 100, 159, 0xC7FF, 0)
        imprimir_string(EDITOR_MENU_IDIOMA_BOAT, 100, 169, 0xC7FF, 0)
        imprimir_string(EDITOR_MENU_OPCAO_9, 100, 179, 0xC7FF, 0)

        jal PROC_DESENHAR

E_MI1_LOOP:

	li a0, 0
        lb t0, MUTADO
        bnez t0, E_MI1_LOOP_SEM_AUDIO
        jal PROC_TOCAR_AUDIO	
E_MI1_LOOP_SEM_AUDIO:

	li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,E_MI1_LOOP		# Se nao hah tecla pressionada entao nao checa tecla
  	lw t2,4(t1)  			# le o valor da tecla 
  	
  	li t0, '1'
	beq t2, t0, E_MI1_PT
	li t0, '2'
	beq t2, t0, E_MI1_EN
        li t0, '3'
	beq t2, t0, E_MI1_BOAT
	li t0, '9'
	beq t2, t0, E_MI1_VOLTAR
	li t0, 8		# TAMBEM VOLTA PRA BACKSPACE!!!
	beq t2, t0, E_MI1_VOLTAR

        j E_MI1_LOOP

E_MI1_VOLTAR:

	lw ra, (sp)
	addi sp, sp, 4
	ret

E_MI1_PT:
        li t0, PT_BR
        sb t0, lingua_atual, t1
j E_MI1_MENU

E_MI1_EN:
        li t0, EN_US
        sb t0, lingua_atual, t1
j E_MI1_MENU

E_MI1_BOAT:
        li t0, BOAT_
        sb t0, lingua_atual, t1
j E_MI1_MENU




