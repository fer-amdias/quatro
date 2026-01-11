# EDITOR_DE_FASES
# eh aqui que temos o editor em si!!!

EDITOR_DE_FASES:

        addi sp, sp, -4
        sw ra, (sp)

        la a0, ch0
        jal EDITOR_IMPRIMIR_FASE_NO_FASE_BUFFER

E_DF1_LOOP:

        li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,E_DF1_DRAW_CYCLE    # Se nao hah tecla pressionada entao nao checa tecla
  	lw t2,4(t1)  			# le o valor da tecla 
  	
	li t0, '9'
	beq t2, t0, E_DF1_RET
        li t0, 8
	beq t2, t0, E_DF1_RET

        li t0, 'W'
        beq t2, t0, E_DF1_W
        li t0, 'A'
        beq t2, t0, E_DF1_A
        li t0, 'S'
        beq t2, t0, E_DF1_S
        li t0, 'D'
        beq t2, t0, E_DF1_D

E_DF1_W:
        li a0, 0
        li a1, -1
E_DF1_A:
        li a0, -1
        li a1, 0
E_DF1_S:
        li a0, 0
        li a1, 1
E_DF1_D: 
        li a0, 1
        li a1, 0

#       jal EDITOR_MOVER_SELETOR_DE_TILE

        j E_DF1_DRAW_CYCLE

E_DF1_DRAW_CYCLE:

        li a0, 0xA0 #ciano
        li a1, 1
        jal PROC_PREENCHER_TELA        

        li a0, 0x00
        li a1, 10
        li a2, 10
        li a3, 230
        li a4, 230
        li a7, 0
        jal PROC_IMPRIMIR_RETANGULO
        
        jal PROC_IMPRIMIR_BUFFER_DE_FASE

        jal EDITOR_IMPRIMIR_UI

        jal PROC_DESENHAR

        j E_DF1_LOOP

E_DF1_RET:

        lw ra, (sp)
        addi sp, sp, 4
        ret

