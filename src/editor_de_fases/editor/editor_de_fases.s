# EDITOR_DE_FASES
# eh aqui que temos o editor em si!!!

EDITOR_DE_FASES:

        addi sp, sp, -4
        sw ra, (sp)

E_DF1_RECARREGAR_EDITOR_DE_FASES:

        lw a0, TEXTURA_DO_MAPA
        la a1, inimigos
        jal EDITOR_IMPRIMIR_FASE_NO_FASE_BUFFER

        lw a0, TEXTURA_DO_MAPA
        jal EDITOR_CRIAR_PALETA_DE_TILES

        la a0, inimigos
        jal EDITOR_CRIAR_PALETA_DE_NPCS
        j E_DF1_DRAW_CYCLE

E_DF1_IDLE:
        sleep(10)                       # performance: enquanto nada acontece, nao faz nada lol

E_DF1_LOOP:

        li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,E_DF1_IDLE          # Se nao hah tecla pressionada entao nao faz NADA
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

        li t0, 'w'
        beq t2, t0, E_DF1_W
        li t0, 'a'
        beq t2, t0, E_DF1_A
        li t0, 's'
        beq t2, t0, E_DF1_S
        li t0, 'd'
        beq t2, t0, E_DF1_D
        li t0, '\n'
        beq t2, t0, E_DF1_ENTER

        li t0, 'I'
        beq t2, t0, E_DF1_I
        li t0, 'J'
        beq t2, t0, E_DF1_J
        li t0, 'K'
        beq t2, t0, E_DF1_K
        li t0, 'L'
        beq t2, t0, E_DF1_L

        li t0, 'i'
        beq t2, t0, E_DF1_I
        li t0, 'j'
        beq t2, t0, E_DF1_J
        li t0, 'k'
        beq t2, t0, E_DF1_K
        li t0, 'l'
        beq t2, t0, E_DF1_L
        li t0, '\n'
        beq t2, t0, E_DF1_ENTER

        li t0, 27
        beq t2, t0, E_DF1_ESC

        j E_DF1_DRAW_CYCLE

E_DF1_W:
        li a0, 0
        li a1, -1
        j E_DF1_MOVER_SELETOR
E_DF1_A:
        li a0, -1
        li a1, 0
        j E_DF1_MOVER_SELETOR
E_DF1_S:
        li a0, 0
        li a1, 1
        j E_DF1_MOVER_SELETOR
E_DF1_D: 
        li a0, 1
        li a1, 0
        j E_DF1_MOVER_SELETOR

E_DF1_I:
        li a0, 0
        li a1, -1
        j E_DF1_MOVER_SELETOR_DE_PALETA
E_DF1_J:
        li a0, -1
        li a1, 0
        j E_DF1_MOVER_SELETOR_DE_PALETA
E_DF1_K:
        li a0, 0
        li a1, 1
        j E_DF1_MOVER_SELETOR_DE_PALETA
E_DF1_L: 
        li a0, 1
        li a1, 0
        j E_DF1_MOVER_SELETOR_DE_PALETA

E_DF1_ENTER:

        jal EDITOR_VALOR_DO_SELETOR_DE_PALETA # retorna o valor em a0
        jal EDITOR_ALTERAR_TILE_SELECIONADO   # recebe o valor retornado acima

        lw a0, TEXTURA_DO_MAPA
        la a1, inimigos
        jal EDITOR_IMPRIMIR_FASE_NO_FASE_BUFFER
        j E_DF1_DRAW_CYCLE

E_DF1_MOVER_SELETOR:

        jal EDITOR_MOVER_SELETOR_DE_TILE
        j E_DF1_DRAW_CYCLE

E_DF1_MOVER_SELETOR_DE_PALETA:

        jal EDITOR_MOVER_SELETOR_DE_PALETA
        j E_DF1_DRAW_CYCLE

E_DF1_ESC:
        jal EDITOR_MENU_EDITOR_DE_FASES
        bnez a0, E_DF1_RET # se a flag de retorno nao for zero, retorna ao menu principal
        j E_DF1_RECARREGAR_EDITOR_DE_FASES      # recalcula o editor

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
        li a0, 0xFF
        li a1, 10
        li a2, 10
        li a3, 230
        li a4, 230
        li a5, 1
        li a7, 0
        jal PROC_IMPRIMIR_OUTLINE


        jal EDITOR_IMPRIMIR_UI

        jal PROC_DESENHAR               # imprime tudo no ciclo

        j E_DF1_LOOP

E_DF1_RET:

        lw ra, (sp)
        addi sp, sp, 4
        ret

