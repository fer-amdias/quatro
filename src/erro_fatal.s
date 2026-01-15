#################################################################
# ROTINA_ERRO_FATAL 					        #
# Mostra uma tela de erro                                       #
# 							     	#
# ARGUMENTOS:						     	#
#	a0 - string com o erro                                  #
# RETORNOS:                                                  	#
#       (nenhum)                                                #
#################################################################

.data

.text

ROTINA_ERRO_FATAL:

        mv s0, a0                       # sobrescreve s0 com o end. da string. nao vamos mais precisar dos registradores mesmo!
        li a0, 0xC0			# AZUL
	li a1, 1
	jal PROC_PREENCHER_TELA		# preenche a tela de azul

        imprimir_string(ERRO_FATAL_HEADER, 20, 20, 0xC7FF, 0)

        mv a0, s0
	li a1, 20
	li a2, 60
	li a3, 0xC7FF
	li a4, 1        # direto da memoria
	jal PROC_IMPRIMIR_STRING

        imprimir_string(ERRO_FATAL_TECLA, 20, 100, 0xC7FF, 0)

        jal PROC_DESENHAR

ROTINA_LOOP:
        sleep(20)                       # performance
	li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,ROTINA_LOOP	        # Se nao hah tecla pressionada entao nao checa tecla
  	lw t2,4(t1)  			# le o valor da tecla 

        li t0, '4'
        beq t2, t0, R_ET1_FIM

        j ROTINA_LOOP

R_ET1_FIM:
        fim