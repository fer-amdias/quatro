#################################################################
# PROC_IMPRIMIR_SPRING				       	     	#
# Imprime uma string no FRAME BUFFER.				#
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : endereco da string					#
#	A1 : X							#
#	A2 : Y							#
#	A3 : cores (0x0000bbff)					#
#	A4 : modo de impressao 					#
#		(0 = da tabela de offset, 1 = da memoria)	#
# RETORNOS:                                                  	#
#       (nenhum)						#
#################################################################

# Prefixo interno: P_IS1_

# CODIGO ADAPTADO DE SYSTEMv24.s

.data
# Tabela de caracteres desenhados segundo a fonte 8x8 pixels do ZX-Spectrum
LabelTabChar:
.word 	0x00000000, 0x00000000, 0x10101010, 0x00100010, 0x00002828, 0x00000000, 0x28FE2828, 0x002828FE, 
	0x38503C10, 0x00107814, 0x10686400, 0x00004C2C, 0x28102818, 0x003A4446, 0x00001010, 0x00000000, 
	0x20201008, 0x00081020, 0x08081020, 0x00201008, 0x38549210, 0x00109254, 0xFE101010, 0x00101010, 
	0x00000000, 0x10081818, 0xFE000000, 0x00000000, 0x00000000, 0x18180000, 0x10080402, 0x00804020, 
	0x54444438, 0x00384444, 0x10103010, 0x00381010, 0x08044438, 0x007C2010, 0x18044438, 0x00384404, 
	0x7C482818, 0x001C0808, 0x7840407C, 0x00384404, 0x78404438, 0x00384444, 0x1008047C, 0x00202020, 
	0x38444438, 0x00384444, 0x3C444438, 0x00384404, 0x00181800, 0x00001818, 0x00181800, 0x10081818, 
	0x20100804, 0x00040810, 0x00FE0000, 0x000000FE, 0x04081020, 0x00201008, 0x08044438, 0x00100010, 
	0x545C4438, 0x0038405C, 0x7C444438, 0x00444444, 0x78444478, 0x00784444, 0x40404438, 0x00384440,
	0x44444478, 0x00784444, 0x7840407C, 0x007C4040, 0x7C40407C, 0x00404040, 0x5C404438, 0x00384444, 
	0x7C444444, 0x00444444, 0x10101038, 0x00381010, 0x0808081C, 0x00304848, 0x70484444, 0x00444448, 
	0x20202020, 0x003C2020, 0x92AAC682, 0x00828282, 0x54546444, 0x0044444C, 0x44444438, 0x00384444, 
	0x38242438, 0x00202020, 0x44444438, 0x0C384444, 0x78444478, 0x00444850, 0x38404438, 0x00384404, 
	0x1010107C, 0x00101010, 0x44444444, 0x00384444, 0x28444444, 0x00101028, 0x54828282, 0x00282854, 
	0x10284444, 0x00444428, 0x10284444, 0x00101010, 0x1008047C, 0x007C4020, 0x20202038, 0x00382020, 
	0x10204080, 0x00020408, 0x08080838, 0x00380808, 0x00442810, 0x00000000, 0x00000000, 0xFE000000, 
	0x00000810, 0x00000000, 0x3C043800, 0x003A4444, 0x24382020, 0x00582424, 0x201C0000, 0x001C2020, 
	0x48380808, 0x00344848, 0x44380000, 0x0038407C, 0x70202418, 0x00202020, 0x443A0000, 0x38043C44, 
	0x64584040, 0x00444444, 0x10001000, 0x00101010, 0x10001000, 0x60101010, 0x28242020, 0x00242830, 
	0x08080818, 0x00080808, 0x49B60000, 0x00414149, 0x24580000, 0x00242424, 0x44380000, 0x00384444, 
	0x24580000, 0x20203824, 0x48340000, 0x08083848, 0x302C0000, 0x00202020, 0x201C0000, 0x00380418, 
	0x10381000, 0x00101010, 0x48480000, 0x00344848, 0x44440000, 0x00102844, 0x82820000, 0x0044AA92, 
	0x28440000, 0x00442810, 0x24240000, 0x38041C24, 0x043C0000, 0x003C1008, 0x2010100C, 0x000C1010, 
	0x10101010, 0x00101010, 0x04080830, 0x00300808, 0x92600000, 0x0000000C, 0x243C1818, 0xA55A7E3C, 
	0x99FF5A81, 0x99663CFF, 0x10280000, 0x00000028, 0x10081020, 0x00081020
	
.text
	

PROC_IMPRIMIR_STRING:

			addi	sp, sp, -12			# aloca espaco
	    		sw	ra, 0(sp)			# salva ra
	    		sw	s0, 4(sp)			# salva s0
	    		sw 	s1, 8(sp)			# pos x (para podermos indentar o texto corretamente)
			mv 	s1, a1				# salva a pos x

			bnez a4, P_IS1_STRING_DA_MEMORIA

			# STRING DA TABELA DE OFFSET:
			selecionar_texto_rg(s0, t0, t1, a0)	# carrega a string a ser impressa
			j P_IS1_LOOP	

P_IS1_STRING_DA_MEMORIA:
			mv s0, a0				# coloca o endereco da string em s0

P_IS1_LOOP:		lb	a0, 0(s0)                 	# le em a0 o caracter a ser impresso
	
	    		beq     a0, zero, P_IS1_LOOP_FIM	# string ASCIIZ termina com NULL
	    		
	    		li 	t0, '\n'
	    		beq	a0, t0, P_IS1_PulaLinha		# se o caractere for enter, pula linha
	
	    		jal     SUBPROC_IMPRIMIR_CARACTERE 	# imprime char
	    		
			addi    a1, a1, 8                 	# incrementa a coluna
			li 	t6, LARGURA_VGA
			addi 	t6, t6, -7		
			bge	a1, t6, P_IS1_PulaLinha		# se nao tiver lugar na linha
			
			j 	P_IS1_NaoPulaLinha		# por padrao, nao pula linha
			
P_IS1_PulaLinha:	    	addi    a2, a2, 10                 	# incrementa a linha (+2 de spacing)
	    		mv    	a1, s1				# volta a coluna zero

P_IS1_NaoPulaLinha:	addi    s0, s0, 1			# proximo caractere
    			j       P_IS1_LOOP       		# volta ao loop

P_IS1_LOOP_FIM:		lw      ra, 0(sp)    			# recupera ra
			lw 	s0, 4(sp)			# recupera s0 original
			lw	s1, 8(sp)
    			addi    sp, sp, 12			# libera espaco
			ret      	    			# retorna


#########################################################
#  SUBPROC_IMPRIMIR_CARACTERE                            #
#  a0 = char(ASCII)                                     #
#  a1 = x                                               #
#  a2 = y                                               #
#  a3 = cores (0x0000bbff) 	b = fundo, f = frente	#
#########################################################
#   t0 = i                                              #
#   t1 = j                                              #
#   t2 = endereco do char na memoria                    #
#   t3 = metade do char (2a e depois 1a)                #
#   t4 = endereco para impressao                        #
#   t5 = background color                               # 
#   t6 = foreground color                               #
#########################################################

# Prefixo interno: SP_IC1_

#	t9 foi convertido para s9 pois nao ha registradores temporarios sobrando dentro deste procedimento

SUBPROC_IMPRIMIR_CARACTERE:
		addi sp, sp, -4
		sw s9, (sp)
		li 	t4, 0xFF	# t4 temporario
		slli 	t4, t4, 8	# t4 = 0x0000FF00 (no RARS, nao podemos fazer diretamente "andi rd, rs1, 0xFF00")
		and    	t5, a3, t4   	# t5 obtem cor de fundo
    		srli	t5, t5, 8	# numero da cor de fundo
		andi   	t6, a3, 0xFF    # t6 obtem cor de frente

		li 	tp, ' '
		blt 	a0, tp, SP_IC1_.NAOIMPRIMIVEL	# ascii menor que 32 nao eh imprimivel
		li 	tp, '~'
		bgt	a0, tp, SP_IC1_.NAOIMPRIMIVEL	# ascii Maior que 126  nao eh imprimivel
    		j       SP_IC1_.IMPRIMIVEL
    
SP_IC1_.NAOIMPRIMIVEL: li      a0, 32		# Imprime espaco

SP_IC1_.IMPRIMIVEL:	li	tp, LARGURA_VGA			# Num colunas 320
SP_IC1_.mul1:		mul     t4, tp, a2			# multiplica a2x320  t4 = coordenada y
SP_IC1_.mul1d:	add     t4, t4, a1               		# t4 = 320*y + x
			addi    t4, t4, 7                 	# t4 = 320*y + (x+7)
			lw      tp, FRAME_BUFFER_PTR          	# pointer de frame
			add     t4, t4, tp               	# t4 = endereco de impressao do ultimo pixel da primeira linha do char
			addi    t2, a0, -32               	# indice do char na memoria
			slli    t2, t2, 3                 	# offset em bytes em relacao ao endereco inicial
			la      t3, LabelTabChar		# endereco dos caracteres na memoria
			add     t2, t2, t3               	# endereco do caractere na memoria
			lw      t3, 0(t2)                 	# carrega a primeira word do char
			li 	t0, 4				# i=4

SP_IC1_.forChar1I:	beq     t0, zero, SP_IC1_.endForChar1I # if(i == 0) end for i
    			addi    t1, zero, 8               	# j = 8

SP_IC1_.forChar1J:	beq     t1, zero, SP_IC1_.endForChar1J # if(j == 0) end for j
        		andi    s9, t3, 0x001			# primeiro bit do caracter
        		srli    t3, t3, 1             		# retira o primeiro bit
        		beq     s9, zero, SP_IC1_.SP_IC1_Pixelbg1	# pixel eh fundo?
        		sb      t6, 0(t4)             		# imprime pixel com cor de frente
        		j       SP_IC1_.endCharPixel1
SP_IC1_.SP_IC1_Pixelbg1:	
			li	s9, COR_TRANSPARENTE
			beq	t5, s9, SP_IC1_.endCharPixel1	# se cor eh transparente, nao imprime aqui
			sb      t5, 0(t4)                # imprime pixel com cor de fundo
SP_IC1_.endCharPixel1: addi    t1, t1, -1                	# j--
    			addi    t4, t4, -1                	# t4 aponta um pixel para a esquerda
    			j       SP_IC1_.forChar1J		# vollta novo pixel

SP_IC1_.endForChar1J: addi    t0, t0, -1 		# i--
    			addi    t4, t4, LARGURA_VGA
			addi    t4, t4, 8
    			j       SP_IC1_.forChar1I	# volta ao loop

SP_IC1_.endForChar1I:	lw      t3, 4(t2)           	# carrega a segunda word do char
			li 	t0, 4			# i = 4
SP_IC1_.forChar2I:    beq     t0, zero, SP_IC1_.endForChar2I  # if(i == 0) end for i
    			addi    t1, zero, 8             # j = 8

SP_IC1_.forChar2J:	beq	t1, zero, SP_IC1_.endForChar2J # if(j == 0) end for j
        		andi    s9, t3, 0x001	    		# pixel a ser impresso
        		srli    t3, t3, 1                 	# desloca para o proximo
        		beq     s9, zero, SP_IC1_.SP_IC1_Pixelbg2 # pixel eh fundo?
        		sb      t6, 0(t4)			# imprime cor frente
        		j       SP_IC1_.endCharPixel2		# volta ao loop

SP_IC1_.SP_IC1_Pixelbg2:	
			li	s9, COR_TRANSPARENTE
			beq	t5, s9, SP_IC1_.endCharPixel2	# se cor eh transparente, nao imprime aqui
			sb      t5, 0(t4)		# imprime cor de fundo

SP_IC1_.endCharPixel2:	addi    t1, t1, -1		# j--
    				addi    t4, t4, -1              # t4 aponta um pixel para a esquerda
    				j       SP_IC1_.forChar2J

SP_IC1_.endForChar2J:	addi	t0, t0, -1 		# i--
    			addi    t4, t4, LARGURA_VGA
			addi    t4, t4, 8
    			j       SP_IC1_.forChar2I	# volta ao loop

SP_IC1_.endForChar2I:	
			lw s9, (sp)
			addi sp, sp, 4
			ret				# retorna
