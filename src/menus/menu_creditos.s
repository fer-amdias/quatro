#################################################################
# ROTINA_MENU_CREDITOS 					        #
# Mostra o menu de creditos.    				#
# 							     	#
# ARGUMENTOS:						     	#
#	(nenhum)						#
# RETORNOS:                                                  	#
#       (nenhum)                                                #
#################################################################

# Prefixo interno: R_MC2_

.data

# utilizado pros creditos poderem rolar pra cima
CREDITOS_TIMESTAMP: .word 0

.text

.macro mostrar_creditos(%key, %delta_t)
        la a0, %key
        addi s1, s1, %delta_t
        mv a1, s1
        jal R_MC2_SUBPROC_MOSTRAR_CREDITOS
.end_macro

ROTINA_MENU_CREDITOS:
        addi sp, sp, -8
        sw ra, (sp)

	csrr t0, time
	sw t0, CREDITOS_TIMESTAMP, t1
	
R_MC2_LOOP:
        sleep(10)                       # performance

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
	sub s0, t1, t0				# s0 = T
	
	srai s0, s0, 7				# divide T por 32 (modifique para alterar a velocidade)

        mv s1, x0                               # s1 = delta_T (vai ser usaad na macro de mostrar_creditos)
	
        # mostrar_creditos(%key, %delta_t)
        mostrar_creditos(CREDITOS_1, 20)       
        mostrar_creditos(CREDITOS_FERNANDO, 10)
        mostrar_creditos(CREDITOS_2, 30)       
        mostrar_creditos(CREDITOS_FERNANDO, 10)
        mostrar_creditos(CREDITOS_3, 30)      
        mostrar_creditos(CREDITOS_AS21, 20)   
	mostrar_creditos(CREDITOS_AS22, 10)   
        mostrar_creditos(CREDITOS_AS23, 10)   
        mostrar_creditos(CREDITOS_AS31, 10)   
        mostrar_creditos(CREDITOS_AS32, 10)   
        mostrar_creditos(CREDITOS_AS33, 10)   
        mostrar_creditos(CREDITOS_AS34, 10)   
        mostrar_creditos(CREDITOS_AS11, 10)   
        mostrar_creditos(CREDITOS_AS12, 10)   
        mostrar_creditos(CREDITOS_AS13, 10)   
        mostrar_creditos(CREDITOS_FIM1, 60)   
        mostrar_creditos(CREDITOS_FIM2, 30)   
        mostrar_creditos(CREDITOS_FIM3, 100)   
        mostrar_creditos(CREDITOS_FIM4, 200)   
        mostrar_creditos(CREDITOS_FIM5, 200)   
        mostrar_creditos(CREDITOS_FIM6, 100)   
        mostrar_creditos(CREDITOS_FIM7, 30)   
        mostrar_creditos(CREDITOS_FIM0, 10)   
        mostrar_creditos(CREDITOS_FIM8, 10)   
        mostrar_creditos(CREDITOS_FIM9, 10)   
        mostrar_creditos(CREDITOS_FIM10, 10)  
        mostrar_creditos(CREDITOS_FIM11, 80) 
        mostrar_creditos(CREDITOS_FIM12, 80) 
        mostrar_creditos(CREDITOS_FIM13, 70) 
	
	li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,R_MC2_LOOP_CONT	# Se nao hah tecla pressionada entao nao checa tecla
  	lw t2,4(t1)  			# le o valor da tecla
  	
  	li t0, '9'
  	beq t2, t0,  R_MC2_FIM		# se apertar 9 (voltar), leva de volta pro menu
	li t0, 8
  	beq t2, t0,  R_MC2_FIM		# se apertar backspace, leva de volta pro menu
  	
R_MC2_LOOP_CONT:
	
	jal PROC_DESENHAR
	
	li a0, 0
	jal PROC_TOCAR_AUDIO


	j R_MC2_LOOP

R_MC2_FIM:
        lw ra, (sp)
	addi sp, sp, 8
	ret



#a0 = endereco da string
#a1 = offset Y
R_MC2_SUBPROC_MOSTRAR_CREDITOS:
	addi sp, sp, -4
	sw ra, (sp)
	
	addi a1, a1, 155		# pra dar tempo de tudo aparecer
	
	sub a1, a1, s0	# a1 = offset - T
	bltz a1, S1_R_MC2_FIM	# nao mostra se Y for negativo (o credito ja passou)
	
	addi a1, a1, 50	# offset para compensar o texto de voltar
	
	li t0, 220
	bgt a1, t0, S1_R_MC2_FIM	# nao mostra se Y for maior que 240 (o credito ainda nao ta na hora de passar)

	mv a2, a1
	li a1, 20
	li a3, 0x00FF
	mv a4, zero
	jal PROC_IMPRIMIR_STRING

S1_R_MC2_FIM:
	lw ra, (sp)
	addi sp, sp, 4
	ret