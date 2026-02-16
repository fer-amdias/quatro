#################################################################
# ROTINA_MENU_AUDIO					        #
# Mostra o menu de configuracoes de audio.                      #
# 							     	#
# ARGUMENTOS:						     	#
#	(nenhum)						#
# RETORNOS:                                                  	#
#       (nenhum)                                                #
#################################################################

# prefixo interno: R_MA1_

ROTINA_MENU_AUDIO:
        addi sp, sp, -4
        sw ra, (sp)

R_MA1_AUDIO:

	li a0, 0x00			# preto
	li a1, 1
	jal PROC_PREENCHER_TELA		# preenche a tela de preto

        #imprimir_string(%stringkey, %x, %y, %cor, %modo) 

R_MA1_TEXTO_MUSICA:
        lb t0, MUTADO
        bnez t0, R_MA1_TEXTO_DESMUTAR_MUSICA

R_MA1_TEXTO_MUTAR_MUSICA:
        imprimir_string(AUDIO_MUTAR_MUSICA, 80, 134, 0x00FF, 0) # "1. Mutar musica"
        j R_MA1_TEXTO_EXPLOSOES

R_MA1_TEXTO_DESMUTAR_MUSICA:
        imprimir_string(AUDIO_DESMUTAR_MUSICA, 80, 134, 0x00FF, 0) # "1. Desmutar musica"


R_MA1_TEXTO_EXPLOSOES:
        lb t0, EXPLOSOES_MUTADAS
        bnez t0, R_MA1_TEXTO_DESMUTAR_EXPLOSOES

R_MA1_TEXTO_MUTAR_EXPLOSOES:
        imprimir_string(AUDIO_MUTAR_EXPLOSOES, 80, 144, 0x00FF, 0) # "2. Mutar explosoes"
        j R_MA1_TEXTO_OPCAO_9

R_MA1_TEXTO_DESMUTAR_EXPLOSOES:
        imprimir_string(AUDIO_DESMUTAR_EXPLOSOES, 80, 144, 0x00FF, 0) # "2. Mutar explosoes"


R_MA1_TEXTO_OPCAO_9:
        imprimir_string(MENU_OPCAO9, 80, 154, 0x00FF, 0) # "9. Voltar"


	jal PROC_DESENHAR
R_MA1_AUDIO_LOOP:
        sleep(10)                       # performance

	li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,R_MA1_AUDIO_LOOP_CONT	# Se nao hah tecla pressionada entao nao checa tecla
  	lw t2,4(t1)  			# le o valor da tecla 

R_MA1_SWITCH9:
	li t0 '9'
        beq t2, t0, R_MA1_FIM
R_MA1_SWITCH1:
        li t0, '1'
        bne t2, t0, R_MA1_SWITCH2
        lb t0, MUTADO
        seqz t0, t0
        sb t0, MUTADO, t1
	j R_MA1_AUDIO # (atualiza a pagina)
R_MA1_SWITCH2:
        li t0, '2'
        bne t2, t0, R_MA1_SWITCH_BACKSPACE
        lb t0, EXPLOSOES_MUTADAS
        seqz t0, t0
        sb t0, EXPLOSOES_MUTADAS, t1
	j R_MA1_AUDIO # (atualiza a pagina)
R_MA1_SWITCH_BACKSPACE:
	li t0, 8		# TAMBEM VOLTA PRA BACKSPACE!!!
	bne t2, t0, R_MA1_SWITCH_FIM
	j R_MA1_FIM
R_MA1_SWITCH_FIM:  	

R_MA1_AUDIO_LOOP_CONT:
	li a0, 0
	jal PROC_TOCAR_AUDIO

	j R_MA1_AUDIO_LOOP

R_MA1_FIM:
        lw ra, (sp)
        addi sp, sp, 4
        ret