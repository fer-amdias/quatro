#################################################################
# ROTINA_MENU_PRINCIPAL 					#
# Mostra o menu principal do jogo.				#
# 							     	#
# ARGUMENTOS:						     	#
#	(nenhum)						#
# RETORNOS:                                                  	#
#       (nenhum)                                             	#
#################################################################

.data

# utilizado pros creditos poderem rolar pra cima
CREDITOS_TIMESTAMP: .word 0

# PREFIXO INTERNO: MP_

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
	
MENU:	li a0, 0x00			# preto
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
	
	la a0, MENU_OPCAO1
	li a1, 100
	li a2, 134
	li a3, 0x00FF
	mv a4, zero			# imprime do arquivo de localisacao
	jal PROC_IMPRIMIR_STRING
	
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
	
MP_LOOP:

	li t1,0xFF200000		# carrega o endere�o de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,MP_LOOP_CONT	# Se nao hah tecla pressionada entao nao checa tecla
  	lw t2,4(t1)  			# le o valor da tecla 
  	
  	li t0, '1'
	beq t2, t0, MP_JOGAR
	li t0, '2'
	beq t2, t0, MP_CONFIG
	li t0, '3'
	beq t2, t0, MP_CREDITOS
	li t0, '4'
	bne t2, t0, MP_LOOP_CONT # se NAO for 4, continua

	# se for, encerra o programa
	fim
MP_LOOP_CONT:
	li a0, 0
	jal PROC_TOCAR_AUDIO	
	j MP_LOOP

MP_JOGAR:

	li a0, 0x00			# preto
	li a1, 1
	jal PROC_PREENCHER_TELA		# preenche a tela de preto

	la a0, JOGAR_TITULO
	li a1, 70
	li a2, 105
	li a3, 0x00FF
	mv a4, zero
	jal PROC_IMPRIMIR_STRING

	la a0, JOGAR_OPCAO0
	li a1, 50
	li a2, 120
	li a3, 0x00FF
	mv a4, zero
	jal PROC_IMPRIMIR_STRING
	
	la a0, JOGAR_OPCAO1
	li a1, 50
	li a2, 130
	li a3, 0x00FF
	mv a4, zero
	jal PROC_IMPRIMIR_STRING
	
	la a0, JOGAR_OPCAO2
	li a1, 50
	li a2, 140
	li a3, 0x00FF
	mv a4, zero
	jal PROC_IMPRIMIR_STRING
	
	la a0, JOGAR_OPCAO3
	li a1, 50
	li a2, 150
	li a3, 0x00FF
	mv a4, zero
	jal PROC_IMPRIMIR_STRING
	
	la a0, JOGAR_OPCAO4
	li a1, 50
	li a2, 160
	li a3, 0x00FF
	mv a4, zero
	jal PROC_IMPRIMIR_STRING
	
	la a0, JOGAR_OPCAO5
	li a1, 50
	li a2, 180
	li a3, 0x00FF
	mv a4, zero
	jal PROC_IMPRIMIR_STRING

	jal PROC_DESENHAR	

MP_JOGAR_LOOP:

	li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,MP_JOGAR_LOOP_CONT	# Se nao hah tecla pressionada entao nao checa tecla
  	lw t2,4(t1)  			# le o valor da tecla 
  	
  	li t0, '0'
	beq t2, t0, MP_CAP0
  	li t0, '1'
	beq t2, t0, MP_CAP1
	#li t0, '2'
	#beq t2, t0, MP_CAP2
	#li t0, '3'
	#beq t2, t0, MP_CAP3
	#li t0, '4'
	#beq t2, t0, MP_CAP4
	
	li t0, '9'
	beq t2, t0, MENU
	li t0, 8		# TAMBEM VOLTA PRA BACKSPACE!!!
	beq t2, t0, MENU

MP_JOGAR_LOOP_CONT:
	li a0, 0
	jal PROC_TOCAR_AUDIO	
	j MP_JOGAR_LOOP
	
MP_CONFIG:
	li a0, 0x00			# preto
	li a1, 1
	jal PROC_PREENCHER_TELA		# preenche a tela de preto
	
	la a0, CONFIG_VOLTAR
	li a1, 0
	li a2, 20
	li a3, 0x00FF
	mv a4, zero
	jal PROC_IMPRIMIR_STRING # "pressione 9 pra voltar ao menu principal"
	
	la a0, CONFIG_IDIOMA
	li a1, 100
	li a2, 100
	li a3, 0x00FF
	mv a4, zero
	jal PROC_IMPRIMIR_STRING # "Escolha o idioma: "

	la a0, CONFIG_PT
	li a1, 100
	li a2, 120
	li a3, 0x00FF
	mv a4, zero
	jal PROC_IMPRIMIR_STRING # "1. Portugues"

	la a0, CONFIG_EN
	li a1, 100
	li a2, 130
	li a3, 0x00FF
	mv a4, zero			
	jal PROC_IMPRIMIR_STRING # "2. English"


MP_CONFIG_LOOP:
	li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,MP_CONFIG_LOOP_CONT	# Se nao hah tecla pressionada entao nao checa tecla
  	lw t2,4(t1)  			# le o valor da tecla 

SWITCH9:
	li t0 '9'
        beq t2, t0, MENU
SWITCH1:
        li t0, '1'
        bne t2, t0, SWITCH2
        li t0, PT_BR
        sb t0, lingua_atual, t1
       
	# precisamos atualizar o frame com as strings da lingua selecionada!
	jal PROC_DESENHAR
	li a0, 0
	jal PROC_TOCAR_AUDIO
	j MP_CONFIG 
SWITCH2:
        li t0, '2'
        bne t2, t0, SWITCH_BACKSPACE
        li t0, EN_US
        sb t0, lingua_atual, t1

	# precisamos atualizar o frame com as strings da lingua selecionada!
	jal PROC_DESENHAR
	li a0, 0
	jal PROC_TOCAR_AUDIO
	j MP_CONFIG 
SWITCH_BACKSPACE:
	li t0, 8		# TAMBEM VOLTA PRA BACKSPACE!!!
	bne t2, t0, SWITCH_FIM
	j MENU
SWITCH_FIM:  	

MP_CONFIG_LOOP_CONT:
	
	jal PROC_DESENHAR
	
	li a0, 0
	jal PROC_TOCAR_AUDIO

	j MP_CONFIG_LOOP






MP_CREDITOS:

	

	csrr t0, time
	sw t0, CREDITOS_TIMESTAMP, t1
	
CREDITOS_LOOP:

	li a0, 0x00			# preto
	li a1, 1
	jal PROC_PREENCHER_TELA		# preenche a tela de preto

	la a0, CREDITOS_VOLTAR
	li a1, 0
	li a2, 20
	li a3, 0x00FF
	mv a4, zero
	jal PROC_IMPRIMIR_STRING # "pressione 9 pra voltar"

	lw t0, CREDITOS_TIMESTAMP
	csrr t1, time
	sub s0, t1, t0				# s0 = DELTA_T
	
	srai s0, s0, 7				# divide DELTA_T por 32 (modifique para alterar a velocidade)
	
	# sim sim eu sei
	# dava pra fazer isso bem melhor
	# mas por enquanto fica assim mesmo
	# quando der tempo a gente arruma
	
	la a0, CREDITOS_1
	li a1, 20				
	jal MP_SUBPROC_MOSTRAR_CREDITO
			
	la a0, CREDITOS_FERNANDO
	li a1, 30				
	jal MP_SUBPROC_MOSTRAR_CREDITO	
	
	la a0, CREDITOS_2
	li a1, 60				
	jal MP_SUBPROC_MOSTRAR_CREDITO
			
	la a0, CREDITOS_FERNANDO
	li a1, 70				
	jal MP_SUBPROC_MOSTRAR_CREDITO	
	
	la a0, CREDITOS_3
	li a1, 100				
	jal MP_SUBPROC_MOSTRAR_CREDITO
	
	la a0, CREDITOS_AS21
	li a1, 120				
	jal MP_SUBPROC_MOSTRAR_CREDITO	
	
	la a0, CREDITOS_AS22
	li a1, 130				
	jal MP_SUBPROC_MOSTRAR_CREDITO
	
	la a0, CREDITOS_AS23
	li a1, 140		
	jal MP_SUBPROC_MOSTRAR_CREDITO
	
	la a0, CREDITOS_AS31
	li a1, 150				
	jal MP_SUBPROC_MOSTRAR_CREDITO
	
	la a0, CREDITOS_AS32
	li a1, 160				
	jal MP_SUBPROC_MOSTRAR_CREDITO
	
	la a0, CREDITOS_AS33
	li a1, 170				
	jal MP_SUBPROC_MOSTRAR_CREDITO
	
	la a0, CREDITOS_AS34
	li a1, 180				
	jal MP_SUBPROC_MOSTRAR_CREDITO	
	
	la a0, CREDITOS_AS11
	li a1, 190				
	jal MP_SUBPROC_MOSTRAR_CREDITO	
	
	la a0, CREDITOS_AS12
	li a1, 200		
	jal MP_SUBPROC_MOSTRAR_CREDITO	
	
	la a0, CREDITOS_AS13
	li a1, 210		
	jal MP_SUBPROC_MOSTRAR_CREDITO	
	
	la a0, CREDITOS_FIM1
	li a1, 270				
	jal MP_SUBPROC_MOSTRAR_CREDITO
	
	la a0, CREDITOS_FIM2
	li a1, 300				
	jal MP_SUBPROC_MOSTRAR_CREDITO
	
	la a0, CREDITOS_FIM3
	li a1, 400				
	jal MP_SUBPROC_MOSTRAR_CREDITO
	
	la a0, CREDITOS_FIM4
	li a1, 600				
	jal MP_SUBPROC_MOSTRAR_CREDITO
	
	la a0, CREDITOS_FIM5
	li a1, 800	
	jal MP_SUBPROC_MOSTRAR_CREDITO
	
	la a0, CREDITOS_FIM6
	li a1, 900	
	jal MP_SUBPROC_MOSTRAR_CREDITO
	
	la a0, CREDITOS_FIM7
	li a1, 930	
	jal MP_SUBPROC_MOSTRAR_CREDITO
	
	la a0, CREDITOS_FIM0
	li a1, 940
	jal MP_SUBPROC_MOSTRAR_CREDITO
	
	la a0, CREDITOS_FIM8
	li a1, 950
	jal MP_SUBPROC_MOSTRAR_CREDITO
	
	la a0, CREDITOS_FIM9
	li a1, 960
	jal MP_SUBPROC_MOSTRAR_CREDITO
	
	la a0, CREDITOS_FIM10
	li a1, 970
	jal MP_SUBPROC_MOSTRAR_CREDITO
	
	la a0, CREDITOS_FIM11
	li a1, 1050
	jal MP_SUBPROC_MOSTRAR_CREDITO
	
	la a0, CREDITOS_FIM12
	li a1, 1130
	jal MP_SUBPROC_MOSTRAR_CREDITO
	
	la a0, CREDITOS_FIM13
	li a1, 1200
	jal MP_SUBPROC_MOSTRAR_CREDITO
	
	li t1,0xFF200000		# carrega o endere�o de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,CREDITOS_LOOP_CONT	# Se nao hah tecla pressionada entao nao checa tecla
  	lw t2,4(t1)  			# le o valor da tecla
  	
  	li t0, '9'
  	beq t2, t0,  MENU		# se apertar 9 (voltar), leva de volta pro menu
	li t0, 8
  	beq t2, t0,  MENU		# se apertar backspace, leva de volta pro menu
  	
CREDITOS_LOOP_CONT:
	
	jal PROC_DESENHAR
	
	li a0, 0
	jal PROC_TOCAR_AUDIO


	j CREDITOS_LOOP


#a0 = endereco da string
#a1 = offset Y
MP_SUBPROC_MOSTRAR_CREDITO:
	addi sp, sp, -4
	sw ra, (sp)
	
	addi a1, a1, 155		# pra dar tempo de tudo aparecer
	
	sub a1, a1, s0	# a1 = offset - DELTA_T
	bltz a1, MP_SMC_FIM	# nao mostra se Y for negativo (o credito ja passou)
	
	addi a1, a1, 50	# offset para compensar o texto de voltar
	
	li t0, 220
	bgt a1, t0, MP_SMC_FIM	# nao mostra se Y for maior que 240 (o credito ainda nao ta na hora de passar)

	mv a2, a1
	li a1, 20
	li a3, 0x00FF
	mv a4, zero
	jal PROC_IMPRIMIR_STRING
	
MP_SMC_FIM:
	lw ra, (sp)
	addi sp, sp, 4
	ret


MP_CAP0:
	li a0, 0		# retorna tutorial
	j MP_FIM
MP_CAP1:
	li a0, 1		# retorna cap1
	j MP_FIM
MP_CAP2:
	li a0, 2		# retorna cap2
	j MP_FIM
MP_CAP3:
	li a0, 3		# retorna cap3
	j MP_FIM
MP_CAP4:
	li a0, 4		# retorna cap4
	j MP_FIM

MP_FIM:
	lw ra, (sp)
	addi sp, sp, 4
	ret
