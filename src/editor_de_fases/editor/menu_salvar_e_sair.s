# EDITOR_MENU_SAIR_E_SALVAR_PROMPT
# Mostra o menu que fala se a fase foi salva ou nao.
#
# RETORNO
# a0:  STATUS
#          0 = Nao Sair
#          1 = Sair

.eqv MENU_SALVAR_E_SAIR_PROMPT_X 30
.eqv MENU_SALVAR_E_SAIR_PROMPT_Y 86

EDITOR_MENU_SALVAR_E_SAIR_PROMPT:
        addi sp, sp, -12
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)
        j E_SS1_DRAW_CYCLE

E_SS1_IDLE:
        sleep(10)
E_SS1_LOOP:
	li a0, 0
        jal PROC_TOCAR_AUDIO	
        
        li t1,0xFF200000		# carrega o endereco de controle do KDMMIO
	lw t0,0(t1)			# Le bit de Controle Teclado
	andi t0,t0,0x0001		# mascara o bit menos significativo
   	beq t0,zero,E_SS1_IDLE          # Se nao hah tecla pressionada entao nao faz NADA
        lw t0,4(t1)  			# le o valor da tecla 

        li t1, '1'
        beq t0, t1, E_SS1_SALVAR

        li t1, '2'
        beq t0, t1, E_SS1_SAIR

        li t1, 27 # ESC
        beq t0, t1, E_SS1_NAO_SAIR      # cancela se ESC apertado

        li t1, '3'
        beq t0, t1, E_SS1_NAO_SAIR

        j E_SS1_IDLE

E_SS1_DRAW_CYCLE:
        jal SHADER_OBSCURECER_TELA

        li a0, 0xA0
        li a1, MENU_SALVAR_E_SAIR_PROMPT_X
        li a2, MENU_SALVAR_E_SAIR_PROMPT_Y
        li a3, LARGURA_VGA
        sub a3, a3, a1
        addi a3, a3, -1
        li a4, ALTURA_VGA
        sub a4, a4, a2
        addi a4, a4, -1
        li a7, 0
        jal PROC_IMPRIMIR_RETANGULO

        li a0, 0xFF
        li a1, MENU_SALVAR_E_SAIR_PROMPT_X
        addi a1, a1, 5
        li a2, MENU_SALVAR_E_SAIR_PROMPT_Y
        addi a2, a2, 5
        li a3, LARGURA_VGA
        sub a3, a3, a1
        addi a3, a3, -1
        li a4, ALTURA_VGA
        sub a4, a4, a2
        addi a4, a4, -1
        li a5, 1
        li a7, 0
        jal PROC_IMPRIMIR_OUTLINE

        # coordenadas em que imprimiremos as strings
        li s0, MENU_SALVAR_E_SAIR_PROMPT_X
        li s1, MENU_SALVAR_E_SAIR_PROMPT_Y
        addi s0, s0, 10                 # x
        addi s1, s1, 10                 # y

        imprimir_string_reg(locale_EDITOR_MENU_SAIR_PROMPT, s0, s1, 0xC7FF, 0)

        addi s1, s1, 20                 # pula 2 linhas

        imprimir_string_reg(locale_EDITOR_MENU_SAIR_PROMPT_OPCAO1, s0, s1, 0xC7FF, 0)
        addi s1, s1, 10
        imprimir_string_reg(locale_EDITOR_MENU_SAIR_PROMPT_OPCAO2, s0, s1, 0xC7FF, 0)
        addi s1, s1, 10
        imprimir_string_reg(locale_EDITOR_MENU_SAIR_PROMPT_OPCAO3, s0, s1, 0xC7FF, 0)

        jal PROC_DESENHAR
        j E_SS1_LOOP

E_SS1_SALVAR:
        lb t0, STR_NOME_ARQUIVO # pega o primeiro caractere do nome do arquivo
        beqz t0, E_SS1_SALVAR_COMO # se for vazio, o arquivo ainda nao tem nome!

        la a0, ARQUIVO_STR_PATH
	jal EDITOR_SALVAR_FASE
        # retorno: quantos bytes foram lidos, -1 se houve um erro
        # passamos pro menu de fase salva
        blez a0, E_SS1_SALVAR_FALHA

        # se chegamos aqui, tudo deu certo!
        jal EDITOR_MENU_FASE_SALVA
        j E_SS1_SAIR

E_SS1_SALVAR_FALHA:
        # se deu algo de errado, mostra o menu de falha e volta ao prompt
        li a0, -1
        jal EDITOR_MENU_FASE_SALVA
        j E_SS1_DRAW_CYCLE

E_SS1_SALVAR_COMO:
        jal EDITOR_MENU_SALVAR_FASE_COMO
        blez a0, E_SS1_DRAW_CYCLE # Nao sai se nao conseguimos salvar ainda
        # senao, pode sair mesmo

E_SS1_SAIR:
        li a0, 1                # retorna 1: Sair
        j E_SS1_RET

E_SS1_NAO_SAIR:
        mv a0, zero             # retorna 0: Nao Sair

E_SS1_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        addi sp, sp, 12
        ret