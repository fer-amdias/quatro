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
        imprimir_string(CONFIG_VOLTAR, 0, 20, 0x00FF, 0)    # "pressione 9 pra voltar ao menu principal"
        imprimir_string(CONFIG_IDIOMA, 100, 100, 0x00FF, 0) # "Escolha o idioma: "
        imprimir_string(CONFIG_PT, 100, 120, 0x00FF, 0)     # "1. Portugues"
        imprimir_string(CONFIG_EN, 100, 130, 0x00FF, 0)     # "2. English"

	jal PROC_DESENHAR

R_MC1_CONFIG_LOOP:
	li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,R_MC1_CONFIG_LOOP_CONT	# Se nao hah tecla pressionada entao nao checa tecla
  	lw t2,4(t1)  			# le o valor da tecla 

SWITCH9:
	li t0 '9'
        beq t2, t0, R_MC1_FIM
SWITCH1:
        li t0, '1'
        bne t2, t0, SWITCH2
        li t0, PT_BR
        sb t0, lingua_atual, t1
	j R_MC1_CONFIG # (atualiza a pagina)
SWITCH2:
        li t0, '2'
        bne t2, t0, SWITCH_BACKSPACE
        li t0, EN_US
        sb t0, lingua_atual, t1
	j R_MC1_CONFIG # (atualiza a pagina)
SWITCH_BACKSPACE:
	li t0, 8		# TAMBEM VOLTA PRA BACKSPACE!!!
	bne t2, t0, SWITCH_FIM
	j R_MC1_FIM
SWITCH_FIM:  	

R_MC1_CONFIG_LOOP_CONT:
	li a0, 0
	jal PROC_TOCAR_AUDIO

	j R_MC1_CONFIG_LOOP

R_MC1_FIM:
        lw ra, (sp)
        addi sp, sp, 4
        ret