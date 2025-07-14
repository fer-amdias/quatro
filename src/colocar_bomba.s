#################################################################
# PROC_COLOCAR_BOMBA				       	     	#
# Coloca uma bomba na posicao escolhida.            		#
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : posicao x						#
#	A1 : posicao y						#
# 	A2 : textura da bomba					#
# RETORNOS:                                                  	#
#       A0 : se a bomba foi colocada ou nao (0 ou 1)		#
#################################################################

# prefixo interno: P_CB1_

PROC_COLOCAR_BOMBA:


			addi sp, sp, -24
			sw ra, (sp)
			sw a3, 4(sp)
			sw a4, 8(sp)
			sw a5, 12(sp)
			sw a6, 16(sp)
			sw a7, 20(sp)


#### fazendo a posicao estar no canto superior esquerdo de um tile
			# primeira coisa eh normalizar a posicao
			la t0, POSICOES_MAPA
			
			lhu t1, (t0)			# t1 = pos_mapa_X; 
			lhu t2, 2(t0)			# t2 = pos_mapa_Y;
			
			sub a0, a0, t1			# pos_X -= pos_mapa_X; 
			sub a1, a1, t2			# pos_Y -= pos_mapa_Y;
			
			li t0, TAMANHO_SPRITE
			rem t3, a0, t0			# t3 = pos_X % TAMANHO_SPRITE
			rem t4, a1, t0			# t4 = pos_X % TAMANHO_SPRITE
			
			sub a0, a0, t3			# pos_X agora eh divisivel por TAMANHO_SPRITE
			sub a1, a1, t4			# pos_Y agora eh divisivel por TAMANHO_SPRITE
			
			# bota de volta as posicoes do mapa
			add a0, a0, t1
			add a1, a1, t2
		
#### checando se existe bomba no tile que queremos botar

			# LOOP de i = 0 a i = 3
			li t0, 0
			li t4, 4
			
			la t5, BOMBAS			# t5 = EB = endereco do array de struct de bombas
	
			
P_CB1_LOOP_1:		lb t3, 4(t5)			# t3 = bomba.existe
			beqz t3, P_CB1_LOOP_1_CONT	# se !bomba.existe, pula a checagem dessa bomba
			
			lh t1, (t5)			# t1 = bomba.posicao_x
			lh t2, 2(t5)			# t2 = bomba.posicao_y
			
			# se as posicoes forem diferentes, continua
			bne t1, a0, P_CB1_LOOP_1_CONT
			bne t2, a1, P_CB1_LOOP_1_CONT
			# senao, para
			j P_CB1_SEM_BOMBA
			
P_CB1_LOOP_1_CONT:	addi t5, t5, STRUCT_BOMBAS_OFFSET # desloca o array em uma posicao
			addi t0, t0, 1		# i++
			blt t0, t4, P_CB1_LOOP_1# se i < 4, continuar
			
#### cacando uma posicao disponivel

			# LOOP de i = 0 a 3
			li t0, 0
			li t4, 4
			la t5, BOMBAS			# t5 = EB = endereco do array de struct de bombas

P_CB1_LOOP_2:		lb t3, 4(t5)			# t3 = bomba.existe
			bnez t3, P_CB1_LOOP_2_CONT	# se bomba.existe, pula a checagem dessa bomba
			
			li t1, 1
			sh a0, (t5)			# salva a pos x da bomba
			sh a1, 2(t5)			# salva a pos y da bomba
			sb t1, 4(t5)			# salva que a bomba existe
			
			li t1, 3
			sb t1, 5(t5)			# salva a contagem regressiva como 3

			csrr t1, time
			addi t1, t1, 1000			# adiciona 1000 milisegundos
			sw t1, 8(t5)			# salva os milisegundos ateh a contagem regressiva abaixar em 1
			
			j P_CB1_IMPRIMIR_BOMBA

			
P_CB1_LOOP_2_CONT:	addi t5, t5, STRUCT_BOMBAS_OFFSET # desloca o array em uma posicao
			addi t0, t0, 1			# i++
			blt t0, t4, P_CB1_LOOP_2	# se i < 4, continuar
			j P_CB1_SEM_BOMBA		# caso contrario, nao achamos vaga disponivel e eh isso, nao botamos bomba ent
			
			
			#		PROC_IMPRIMIR_TEXTURA			     
P_CB1_IMPRIMIR_BOMBA:	#	A0 : ENDERECO DA TEXTURA A SER IMPRESSA              
			# 	A1 : POSICAO X                                      
			#       A2 : POSICAO Y                                       
			#       A3 : NUMERO DE LINHAS DA TEXTURA (ALTURA)            
			#       A4 : NUMERO DE COLUNAS DA TEXTURA (LARGURA)          
			#	A7 : MODO DE IMPRESSAO 				     
			#			(0: FRAME_BUFFER, 1: FASE_BUFFER)    
			
			
			mv t0, a2	# temp = textura
			mv a2, a1	# a2 = pos y
			mv a1, a0	# a1 = pos x
			mv a0, t0	# a0 = temp
			
			# carrega as dimensoes da textura
			li a3, TAMANHO_SPRITE
			li a4, TAMANHO_SPRITE
			addi a0, a0, 8			# pula as words de informacao de textura
			
			li a7, 1			# imprime no buffer de afse
			
			jal PROC_IMPRIMIR_TEXTURA
			
			li a0, 1
			j P_CB1_FIM
			
			
			# retorna 0 ----> bomba nao colocada
P_CB1_SEM_BOMBA:	li a0, 0

P_CB1_FIM:		lw ra, (sp)
			lw a3, 4(sp)
			lw a4, 8(sp)
			lw a5, 12(sp)
			lw a6, 16(sp)
			lw a7, 20(sp)
			addi sp, sp, 24
			print_int(a0)
			quebra_de_linha
			ret
			
			
			
			
			
			
			
			
			
			
