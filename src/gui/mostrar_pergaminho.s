#################################################################
# PROC_MOSTRAR_PERGAMINHO				       	#
# Mostra o pergaminho da fase na tela.				#
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : endereco da textura de pergaminho			#
#	A1 : endereco do texto do pergaminho			#
#	A2 : endereco da textura do mapa			#
# RETORNOS:                                                  	#
#       (nenhum)						#
#################################################################

# Prefixo interno: P_MP1_
# acho legal que ateh agora nenhum prefixo interno se coincidiu, tornando o numero no prefixo completamente inutil
# se eu nao tivesse incluido, aposto que ele seria completamente necessario por algum motivo
# edit (10 Novembro 2025): foi util por causa do tile andavel e o tocar audio

.text

PROC_MOSTRAR_PERGAMINHO:
			addi sp, sp, -4
			sw ra, (sp)

			lb t0, PERGAMINHO_NA_TELA
			bnez t0, P_MP1_CHECAR_COOLDOWN
			
			la t0, PERGAMINHO_NA_TELA
			
			li t1, 1
			sb t1, (t0)			# guarda que hah um pergaminho na tela
			sb t1, JOGO_PAUSADO, t0		# guarda que o jogo estah pausado
			
			csrr t0, time
			addi t0, t0, 500		# adiciona 500ms
			sw t0, ENTER_COOLDOWN, t1	# guarda o cooldown
			
			j P_MP1_CONT	
P_MP1_CHECAR_COOLDOWN:
			csrr t0, time
			lw t1, ENTER_COOLDOWN
			ble t0, t1, P_MP1_CONT		# se timenow < enter_cooldown, sair

			li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
			lw t0,0(t1)			# Le bit de Controle Teclado
			andi t0,t0,0x0001		# mascara o bit menos significativo
		   	beqz t0, P_MP1_CONT		# Se nao hah tecla pressionada entao pula
		  	lw t2,4(t1)  			# le o valor da tecla 
		  	
		  	# se enter ou espaco estiverem pressionados, destroi o pergaminho
		  	li t0, '\n'
		  	beq t2, t0, P_MP1_DESTRUIR_PERGAMINHO
		  	li t0, ' '
		  	beq t2, t0, P_MP1_DESTRUIR_PERGAMINHO
		  	li t0, 8		# backspace
		  	bne t2, t0, P_MP1_CONT  # continua se nao for backspace

			# guarda que o pergaminho NAO ESTAH MAIS NA TELA antes de ir pro menu :)
			la t0, PERGAMINHO_NA_TELA
			sb x0, (t0)

			# despausa o jogo. muito importante tbm. senao o jogo congela eternamente.
			la t0, JOGO_PAUSADO				
			sb x0, (t0)					
		  	j MENU			# que monstruosidade. eu corrigiria isso se eu soubesse de uma maneira elegante de faze-lo.
		  	 	
P_MP1_DESTRUIR_PERGAMINHO:  	
			addi sp, sp, -4
			sw a2, (sp)		# salva endereco do mapa


			# ARGUMENTOS DE PROC_MANIPULAR_TILEMAP
			li a0, 0		# coloca tile VAZIO (0)
			lhu a1, JOGADOR_X	# onde o jogador estah (x)
			lhu a2, JOGADOR_Y	# onde o jogador estah (y)
			li a7, 0		# modo [sobr]escrever

			# corrige a posicao para ser igual ah checagem em PROC_CHECAR_COLISOES
			lw t0, ALTURA_JOGADOR	
			srli t0, t0, 1		# divide por 2
			lw t1, LARGURA_JOGADOR
			srli t1, t1, 1		# divide por 2	
			addi t1, t1, -1		# fator corretivo
			add a1, a1, t1		# centraliza
			add a2, a2, t0		# centraliza
			jal PROC_MANIPULAR_TILEMAP

			# ARGUMENTOS DE PROC_IMPRIMIR_TEXTURA (precisamos apagar o pergaminho)
			la t0, POSICAO_JOGADOR		# posicao do jogador
			lhu a1, (t0)			# x
			lhu a2, 2(t0)			# y
			li a3, TAMANHO_SPRITE		# dimensoes
			li a4, TAMANHO_SPRITE		# dimensoes
			li a7, 1			# modo imprimir na fase buffer

			# correcao
			lw t0, ALTURA_JOGADOR	
			srli t0, t0, 1		# divide por 2
			lw t1, LARGURA_JOGADOR
			srli t1, t1, 1		# divide por 2	
			addi t1, t1, -1		# fator corretivo
			add a1, a1, t1		# centraliza
			add a2, a2, t0		# centraliza
			
			lw a0, (sp)			# carrega a textura
			addi a0, a0, 8			# pula words de informacao
			
			normalizar_posicao(a1, a2)
			
			jal PROC_IMPRIMIR_TEXTURA


			la t0, PERGAMINHO_NA_TELA			
			sb x0, (t0)					# marca que nao precisamos mais mostrar o pergaminho
			la t0, JOGO_PAUSADO				
			sb x0, (t0)					# despausa o jogo

			addi sp, sp, 4				

			csrr t0, time
			addi t0, t0, 250		# adiciona 250ms
			sw t0, ENTER_COOLDOWN, t1	# guarda o cooldown
			
			j P_MP1_FIM					# para de mostrar o pergaminho
		  	
P_MP1_CONT:		addi sp, sp, -4		
			sw a1, (sp)		# salva o texto do pergaminho
	
			
			
			# a0 jah posicionado
			
			# a textura ocupa a tela toda
			li a1, 0		# X = 0
			li a2, 0		# Y = 0
			li a3, ALTURA_VGA	# dimensoes = VGA
			li a4, LARGURA_VGA	# dimensoes = VGA
			addi a0, a0, 8		# pula as words de informacao
			li a7, 0		# imprimir no frame buffer
			
			jal PROC_IMPRIMIR_TEXTURA
			
			lw a0, (sp)
			li a1, 40
			li a2, 38
			li a3, 0x0000C700
			mv a4, zero		# imprime do arquivo de localisacao	
			jal PROC_IMPRIMIR_STRING

			la a0, SCROLL_ENTER
			li a1, 40
			li a2, 178
			li a3, 0xC700
			mv a4, zero		# imprime do arquivo de localisacao
			jal PROC_IMPRIMIR_STRING
			
			addi sp, sp, 4

P_MP1_FIM:		lw ra, (sp)	
			addi sp, sp, 4
			ret
 

