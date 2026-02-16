#################################################################
# ROTINA_MENU_JOGAR 					        #
# Mostra o menu de selecao de fase.				#
# 							     	#
# ARGUMENTOS:						     	#
#	(nenhum)						#
# RETORNOS:                                                  	#
#       a0 = capitulo escolhido                                 #
#################################################################

# prefixo interno: R_MJ1_

ROTINA_MENU_JOGAR:
        addi sp, sp, -4
        sw ra, (sp)

R_MJ1_JOGAR:

	li a0, 0x00			# preto
	li a1, 1
	jal PROC_PREENCHER_TELA		# preenche a tela de preto

        #imprimir_string(%stringkey, %x, %y, %cor, %modo)
        imprimir_string(JOGAR_TITULO, 70, 105, 0x00FF, 0)
        imprimir_string(JOGAR_OPCAO0, 50, 120, 0x00FF, 0)
        imprimir_string(JOGAR_OPCAO1, 50, 130, 0x00FF, 0)
        imprimir_string(JOGAR_OPCAO2, 50, 140, 0x00FF, 0)
        imprimir_string(JOGAR_OPCAO3, 50, 150, 0x00FF, 0)
        imprimir_string(JOGAR_OPCAO4, 50, 160, 0x00FF, 0)
        imprimir_string(JOGAR_OPCAO5, 50, 180, 0x00FF, 0)

	jal PROC_DESENHAR	

R_MJ1_JOGAR_LOOP:
        sleep(10)                       # performance

	li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,R_MJ1_JOGAR_LOOP_CONT	# Se nao hah tecla pressionada entao nao checa tecla
  	lw t2,4(t1)  			# le o valor da tecla 
  	
  	li t0, '0'
	beq t2, t0, R_MJ1_CAP0
  	li t0, '1'
	beq t2, t0, R_MJ1_CAP1
	li t0, '2'
	beq t2, t0, R_MJ1_CAP2
	#li t0, '3'
	#beq t2, t0, R_MJ1_CAP3
	#li t0, '4'
	#beq t2, t0, R_MJ1_CAP4
	
	li t0, '9'
	beq t2, t0, R_MJ1_VOLTAR
	li t0, 8		# TAMBEM VOLTA PRA BACKSPACE!!!
	beq t2, t0, R_MJ1_VOLTAR

R_MJ1_JOGAR_LOOP_CONT:
	li a0, 0
	jal PROC_TOCAR_AUDIO	
	j R_MJ1_JOGAR_LOOP

R_MJ1_CAP0:
	li a0, 0		# retorna tutorial
	j R_MJ1_SELECIONAR_CAPITULO
R_MJ1_CAP1:
	li a0, 1		# retorna cap1
	j R_MJ1_SELECIONAR_CAPITULO
R_MJ1_CAP2:
	li a0, 2		# retorna cap2
	j R_MJ1_SELECIONAR_CAPITULO
R_MJ1_CAP3:
	li a0, 3		# retorna cap3
	j R_MJ1_SELECIONAR_CAPITULO
R_MJ1_CAP4:
	li a0, 4		# retorna cap4
	j R_MJ1_SELECIONAR_CAPITULO

R_MJ1_VOLTAR:
        li a0, -1
R_MJ1_SELECIONAR_CAPITULO:
        lw ra, (sp)
        addi sp, sp, 4
        ret


