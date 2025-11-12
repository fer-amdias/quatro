#################################################################
# ROTINA_MENU_PRINCIPAL 					#
# Mostra o menu principal do jogo.				#
# 							     	#
# ARGUMENTOS:						     	#
#	(nenhum)						#
# RETORNOS:                                                  	#
#       a0 = capitulo escolhido                                 #
#################################################################

.data

# PREFIXO INTERNO: R_MP1_

.text
ROTINA_MENU_PRINCIPAL:
	

	addi sp, sp, -4
	sw ra, (sp)
	
	li a0, 1
	la a1, intro_tune
	li a2, 1
	li a3, 1
	jal PROC_TOCAR_AUDIO
	
	#	A0 : ENDERECO DA TEXTURA A SER IMPRESSA              #
	# 	A1 : POSICAO X                                       #
	#       A2 : POSICAO Y                                       #
	#       A3 : NUMERO DE LINHAS DA TEXTURA (ALTURA)            #
	#       A4 : NUMERO DE COLUNAS DA TEXTURA (LARGURA)          #
	#	A7 : MODO DE IMPRESSAO 				     #
	#			(0: FRAME_BUFFER, 1: FASE_BUFFER)    #
	
R_MP1_MENU:	
	li a0, 0x00			# preto
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

	#imprimir_string(%stringkey, %x, %y, %cor, %modo)
	imprimir_string(MENU_OPCAO1, 100, 134, 0x00FF, 0)
	imprimir_string(MENU_OPCAO2, 100, 144, 0x00FF, 0)
	imprimir_string(MENU_OPCAO3, 100, 154, 0x00FF, 0)
	imprimir_string(MENU_OPCAO4, 100, 164, 0x00FF, 0)
	
	la a0, MENU_OPCAO2
	li a1, 100
	li a2, 144
	li a3, 0x00FF
	mv a4, zero
	jal PROC_IMPRIMIR_STRING
	
	la a0, MENU_OPCAO3
	li a1, 100
	li a2, 154
	li a3, 0x00FF
	mv a4, zero
	jal PROC_IMPRIMIR_STRING
	
	la a0, MENU_OPCAO4
	li a1, 100
	li a2, 164
	li a3, 0x00FF
	mv a4, zero
	jal PROC_IMPRIMIR_STRING
	
	jal PROC_DESENHAR	
	
R_MP1_LOOP:

	li t1,0xFF200000		# carrega o endere�o de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,R_MP1_LOOP_CONT	# Se nao hah tecla pressionada entao nao checa tecla
  	lw t2,4(t1)  			# le o valor da tecla 
  	
  	li t0, '1'
	beq t2, t0, R_MP1_JOGAR
	li t0, '2'
	beq t2, t0, R_MP1_CONFIG
	li t0, '3'
	beq t2, t0, R_MP1_CREDITOS
	li t0, '4'
	bne t2, t0, R_MP1_LOOP_CONT # se NAO for 4, continua

	# se for, encerra o programa
	fim
R_MP1_LOOP_CONT:
	li a0, 0
	jal PROC_TOCAR_AUDIO	
	j R_MP1_LOOP

R_MP1_JOGAR:
	jal ROTINA_MENU_JOGAR
	bgez a0, R_MP1_FIM	# se o retorno for positivo, um capitulo foi selecionado. retorna esse capitulo pra main.
	j R_MP1_MENU
	
R_MP1_CONFIG:
	jal ROTINA_MENU_CONFIG
	j R_MP1_MENU

R_MP1_CREDITOS:
	jal ROTINA_MENU_CREDITOS
	j R_MP1_MENU

R_MP1_FIM:
	lw ra, (sp)
	addi sp, sp, 4
	ret
