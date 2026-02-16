#################################################################
# ROTINA_MENU_CONFIG_ADICIONAIS 		                #
# Mostra o menu de configuracoes adicionais. O jogador pode     #
# alterar aqui coisas como o grayscale, o efeito de explosao e  #
# o modo debug.                 				#
# 							     	#
# ARGUMENTOS:						     	#
#	(nenhum)						#
# RETORNOS:                                                  	#
#       (nenhum)                                                #
#################################################################

# prefixo interno: R_CA1_

ROTINA_MENU_CONFIG_ADICIONAIS:
        addi sp, sp, -4
        sw ra, (sp)

R_CA1_CONFIG_ADICIONAIS:

	li a0, 0x00			# preto
	li a1, 1
	jal PROC_PREENCHER_TELA		# preenche a tela de preto

        #imprimir_string(%stringkey, %x, %y, %cor, %modo) 

R_CA1_DRAW:
                imprimir_string(ADICIONAIS_TITULO, 70, 124, 0x00FF, 0) # "Outras configuracoes"

        # imprime ativar/desativar grayscale
        R_CA1_TEXTO_GRAYSCALE:
                lb t0, GRAYSCALE
                bnez t0, R_CA1_TEXTO_DESATIVAR_GRAYSCALE

        R_CA1_TEXTO_ATIVAR_GRAYSCALE:
                imprimir_string(ADICIONAIS_ATIVAR_GRAYSCALE, 70, 134, 0x00FF, 0) # "1. Ativar grayscale"
                j R_CA1_TEXTO_EFEITO_DE_EXPLOSAO

        R_CA1_TEXTO_DESATIVAR_GRAYSCALE:
                imprimir_string(ADICIONAIS_DESATIVAR_GRAYSCALE, 70, 134, 0x00FF, 0) # "1. Destivar grayscale"

        # imprime ativar/desativar efeito de explosao
        R_CA1_TEXTO_EFEITO_DE_EXPLOSAO:
                lb t0, EFEITO_EXPLOSAO
                bnez t0, R_CA1_TEXTO_DESATIVAR_EFEITO_DE_EXPLOSAO

        R_CA1_TEXTO_ATIVAR_EFEITO_DE_EXPLOSAO:
                imprimir_string(ADICIONAIS_ATIVAR_EFEITO_DE_EXPLOSAO, 70, 144, 0x00FF, 0) # "2. Ativar efeito de explosao"
                j R_CA1_TEXTO_MODO_DEBUG

        R_CA1_TEXTO_DESATIVAR_EFEITO_DE_EXPLOSAO:
                imprimir_string(ADICIONAIS_DESATIVAR_EFEITO_DE_EXPLOSAO, 70, 144, 0x00FF, 0) # "2. Desativar efeito de explosao"

        # imprime ativar/desativar modo debug
        R_CA1_TEXTO_MODO_DEBUG:
                lb t0, MODO_DEBUG
                bnez t0, R_CA1_TEXTO_DESATIVAR_MODO_DEBUG

        R_CA1_TEXTO_ATIVAR_MODO_DEBUG:
                imprimir_string(ADICIONAIS_ATIVAR_MODO_DEBUG, 70, 154, 0x00FF, 0) # "3. Ativar modo debug"
                j R_CA1_TEXTO_OPCAO_9

        R_CA1_TEXTO_DESATIVAR_MODO_DEBUG:
                imprimir_string(ADICIONAIS_DESATIVAR_MODO_DEBUG, 70, 154, 0x00FF, 0) # "3. Desativar modo debug"


        R_CA1_TEXTO_OPCAO_9:
                imprimir_string(MENU_OPCAO9, 70, 164, 0x00FF, 0) # "9. Voltar"


	jal PROC_DESENHAR
R_CA1_CONFIG_ADICIONAIS_LOOP:
        sleep(10)                       # performance

	li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,R_CA1_CONFIG_ADICIONAIS_LOOP_CONT	# Se nao hah tecla pressionada entao nao checa tecla
  	lw t2,4(t1)  			# le o valor da tecla 

R_CA1_SWITCH9:
	li t0 '9'
        beq t2, t0, R_CA1_FIM
R_CA1_SWITCH1:
        li t0, '1'
        bne t2, t0, R_CA1_SWITCH2
        lb t0, GRAYSCALE
        seqz t0, t0
        sb t0, GRAYSCALE, t1
	j R_CA1_CONFIG_ADICIONAIS # (atualiza a pagina)
R_CA1_SWITCH2:
        li t0, '2'
        bne t2, t0, R_CA1_SWITCH3
        lb t0, EFEITO_EXPLOSAO
        seqz t0, t0
        sb t0, EFEITO_EXPLOSAO, t1
	j R_CA1_CONFIG_ADICIONAIS # (atualiza a pagina)
R_CA1_SWITCH3:
        li t0, '3'
        bne t2, t0, R_CA1_SWITCH_BACKSPACE
        lb t0, MODO_DEBUG
        seqz t0, t0
        sb t0, MODO_DEBUG, t1
        j R_CA1_CONFIG_ADICIONAIS # (atualiza a pagina)
R_CA1_SWITCH_BACKSPACE:
	li t0, 8		# TAMBEM VOLTA PRA BACKSPACE!!!
	bne t2, t0, R_CA1_SWITCH_FIM
	j R_CA1_FIM
R_CA1_SWITCH_FIM:  	

R_CA1_CONFIG_ADICIONAIS_LOOP_CONT:
	li a0, 0
	jal PROC_TOCAR_AUDIO

	j R_CA1_CONFIG_ADICIONAIS_LOOP

R_CA1_FIM:
        lw ra, (sp)
        addi sp, sp, 4
        ret