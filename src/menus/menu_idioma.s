#################################################################
# ROTINA_MENU_IDIOMA 					        #
# Mostra o menu de alterar idioma.                              #
# 							     	#
# ARGUMENTOS:						     	#
#	(nenhum)						#
# RETORNOS:                                                  	#
#       (nenhum)                                                #
#################################################################

# prefixo interno: R_MI1_

ROTINA_MENU_IDIOMA:
        addi sp, sp, -4
        sw ra, (sp)

R_MI1_IDIOMA:

	li a0, 0x00			# preto
	li a1, 1
	jal PROC_PREENCHER_TELA		# preenche a tela de preto

        #imprimir_string(%stringkey, %x, %y, %cor, %modo)  
        imprimir_string(IDIOMA_PROMPT, 80, 124, 0x00FF, 0) # "Escolha o idioma:"
        imprimir_string(IDIOMA_PT, 80, 134, 0x00FF, 0)     # "1. Portugues (BR)"
        imprimir_string(IDIOMA_EN, 80, 144, 0x00FF, 0)     # "2. English (US)"
        imprimir_string(MENU_OPCAO9, 80, 154, 0x00FF, 0)     # "9. Voltar"

	jal PROC_DESENHAR

R_MI1_IDIOMA_LOOP:
        sleep(10)                       # performance

	li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,R_MI1_IDIOMA_LOOP_CONT	# Se nao hah tecla pressionada entao nao checa tecla
  	lw t2,4(t1)  			# le o valor da tecla 

SWITCH9:
	li t0 '9'
        beq t2, t0, R_MI1_FIM
SWITCH1:
        li t0, '1'
        bne t2, t0, SWITCH2
        li t0, PT_BR
        sb t0, lingua_atual, t1
	j R_MI1_IDIOMA # (atualiza a pagina)
SWITCH2:
        li t0, '2'
        bne t2, t0, SWITCH_BACKSPACE
        li t0, EN_US
        sb t0, lingua_atual, t1
	j R_MI1_IDIOMA # (atualiza a pagina)
SWITCH_BACKSPACE:
	li t0, 8		# TAMBEM VOLTA PRA BACKSPACE!!!
	bne t2, t0, SWITCH_FIM
	j R_MI1_FIM
SWITCH_FIM:  	

R_MI1_IDIOMA_LOOP_CONT:
	li a0, 0
	jal PROC_TOCAR_AUDIO

	j R_MI1_IDIOMA_LOOP

R_MI1_FIM:
        lw ra, (sp)
        addi sp, sp, 4
        ret