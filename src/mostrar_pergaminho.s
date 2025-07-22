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

.data

ENTER_COOLDOWN: .word 0

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
		  	
		  	j P_MP1_CONT  	
P_MP1_DESTRUIR_PERGAMINHO:  	
			mv t0, a2
			sobrescrever_tile_atual_rg(0, t0)		# coloca um tile normal no lugar do pergaminho
			la t0, PERGAMINHO_NA_TELA			
			sb x0, (t0)					# marca que nao precisamos mais mostrar o pergaminho
			la t0, JOGO_PAUSADO				
			sb x0, (t0)					# despausa o jogo
			
			j P_MP1_FIM					# para de mostrar o pergaminho
		  	
P_MP1_CONT:		addi sp, sp, -4		
			sw a1, (sp)		# salva o texto do pergaminho
	
			
			
			# a0 jah posicionado
			
			# a textura ocupa a tela toda
			li a1, 0		# X = 0
			li a2, 0		# Y = 0
			li a3, 240		# dimensoes = VGA
			li a4, 320		# dimensoes = VGA
			addi a0, a0, 8		# pula as words de informacao
			li a7, 0		# imprimir no frame buffer
			
			jal PROC_IMPRIMIR_TEXTURA
			
			lw a0, (sp)
			li a1, 40
			li a2, 40
			li a3, 0x0000C7FF
			jal PROC_IMPRIMIR_STRING
			
			addi sp, sp, 4

P_MP1_FIM:		lw ra, (sp)	
			addi sp, sp, 4
			ret
 

