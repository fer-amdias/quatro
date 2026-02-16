#################################################################
# ROTINA_MENU_CONFIG 					        #
# Mostra o menu de configuracoes.				#
# 							     	#
# ARGUMENTOS:						     	#
#	(nenhum)						#
# RETORNOS:                                                  	#
#       (nenhum)                                                #
#################################################################

# prefixo interno: R_MC1_

ROTINA_MENU_CONFIG:
        addi sp, sp, -4
        sw ra, (sp)

R_MC1_CONFIG:

	li a0, 0x00			# preto
	li a1, 1
	jal PROC_PREENCHER_TELA		# preenche a tela de preto

        #imprimir_string(%stringkey, %x, %y, %cor, %modo)  
        imprimir_string(CONFIG_OPCAO_IDIOMA, 70, 134, 0x00FF, 0) # "1. Alterar idioma"
        imprimir_string(CONFIG_OPCAO_AUDIO, 70, 144, 0x00FF, 0)     # "2. Configuracoes de audio"
        imprimir_string(CONFIG_OPCAO_ADICIONAIS, 70, 154, 0x00FF, 0)     # "3. Outras configuracoes"
        imprimir_string(MENU_OPCAO9, 70, 164, 0x00FF, 0)     # "9. Voltar"

	jal PROC_DESENHAR

R_MC1_CONFIG_LOOP:
        sleep(10)                       # performance

	li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,R_MC1_CONFIG_LOOP_CONT	# Se nao hah tecla pressionada entao nao checa tecla
  	lw t2,4(t1)  			# le o valor da tecla 

R_MC1_SWITCH9:
	li t0 '9'
        beq t2, t0, R_MC1_FIM
R_MC1_SWITCH1:
        li t0, '1'
        bne t2, t0, R_MC1_SWITCH2
        jal ROTINA_MENU_IDIOMA
	j R_MC1_CONFIG 
R_MC1_SWITCH2:
        li t0, '2'
        bne t2, t0, R_MC1_SWITCH3
        jal ROTINA_MENU_AUDIO
	j R_MC1_CONFIG 
R_MC1_SWITCH3:
        li t0, '3'
        bne t2, t0, R_MC1_SWITCH_BACKSPACE
        jal ROTINA_MENU_CONFIG_ADICIONAIS
	j R_MC1_CONFIG 
R_MC1_SWITCH_BACKSPACE:
	li t0, 8		# TAMBEM VOLTA PRA BACKSPACE!!!
	bne t2, t0, R_MC1_SWITCH_FIM
	j R_MC1_FIM
R_MC1_SWITCH_FIM:  	

R_MC1_CONFIG_LOOP_CONT:
	li a0, 0
	jal PROC_TOCAR_AUDIO

	j R_MC1_CONFIG_LOOP

R_MC1_FIM:
        lw ra, (sp)
        addi sp, sp, 4
        ret