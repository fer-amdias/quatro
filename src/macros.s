#################################################
#		REGISTRO DE MACROS		#
#################################################
# Aqui define-se as macros a serem utilizadas   #
# no jogo.					#
# 						#
# Como esse arquivo estah incluido em 		#
# memoria.s, pode ser acessado por todos os	#
# arquivos .s do programa.			#
#################################################

.data 
MACRO_DATA_QUEBRA_DE_LINHA: .string "\n"

.macro print(%string_address)
	.text
	li a7, 4
	la a0, %string_address
	ecall
.end_macro

# ATENCAO: ISSO NAO FUNCIONA NO FPGRARS
# soh no rars... por algum motivo.
.macro print_literal(%str)
	.data
	var: .string %str
	
	.text
	li a7, 4
	la a0, var
	ecall
.end_macro
	

.macro print_int(%int)
	.text
	li a7, 36
	mv a0, %int
	ecall
.end_macro

.macro quebra_de_linha
	.text
	li a7, 4
	la a0, MACRO_DATA_QUEBRA_DE_LINHA
	ecall
.end_macro

.macro print_int_ln(%int)
	.text
	li a7, 36
	mv a0, %int
	ecall
	
	quebra_de_linha
.end_macro

.macro safe_print_int_ln(%int)
	.text
	addi sp, sp, -8
	sw a0, (sp)
	sw a7, 4(sp)

	mv a0, %int
	li a7, 36
	ecall

	quebra_de_linha

	lw a0, (sp)
	lw a7, 4(sp)
	addi sp, sp, 8
.end_macro

.macro print_literal_ln(%str)
	.data
	var: .string %str
	
	.text
	li a7, 4
	la a0, var
	ecall
	
	li a7, 4
	la a0, MACRO_DATA_QUEBRA_DE_LINHA
	ecall
.end_macro

.macro print_hex(%int)
	.text
	li a7, 34
	mv a0, %int
	ecall
.end_macro

.macro print_hex_ln(%int)
	.text
	li a7, 34
	mv a0, %int
	ecall
	
	li a7, 4
	la a0, MACRO_DATA_QUEBRA_DE_LINHA
	ecall
.end_macro

.macro fim
	.text
	li a7, 10
	ecall
.end_macro

# rg x, rg y
.macro normalizar_posicao(%x, %y)
	la t0, POSICOES_MAPA          # t0 -> word com X e Y do mapa
	lhu t1, 0(t0)                 # t1 = POSICAO_MAPA_X
	lhu t2, 2(t0)                 # t2 = POSICAO_MAPA_Y
	
	li  t0, TAMANHO_SPRITE

	sub t3, %x, t1                # t3 = X relativo ao mapa

	rem t4, t3, t0                # t4 = X % TAMANHO_SPRITE

	sub %x, %x, t4                # x -= resto

	sub t3, %y, t2                # t3 = Y relativo ao mapa
	rem t4, t3, t0                # t4 = Y % TAMANHO_SPRITE
	sub %y, %y, t4                # y -= resto
.end_macro

# rg x, rg y, int valor, rg reg_textura_mapa
.macro sobrescrever_tilemap_rg(%x, %y, %valor, %reg_textura_mapa)
	mv t0, %reg_textura_mapa
	
	li t1, AREA_SPRITE
	li t2, %valor
	mul t1, t1, t2
	add t0, t1, t0			# pula pro endereco do tile TEXTURAS + (TILE * AREA_SPRITE)
	

	addi sp, sp, -12
	sw %x, (sp)
	sw %y, 4(sp)
	sw t0, 8(sp)
	
	li a0, %valor
	mv a1, %x
	mv a2, %y
	li a7, 0			# modo escrever
	jal PROC_MANIPULAR_TILEMAP

	lw a0, 8(sp)		# endereco da textura
	addi a0, a0, 8			# pula words de informacao
	lw a1, (sp)			# x
	lw a2, 4(sp)			# y
	li a3, TAMANHO_SPRITE		# dimensoes
	li a4, TAMANHO_SPRITE		# dimensoes
	li a7, 1			# modo imprimir na fase buffer
	
	normalizar_posicao(a1, a2)
	
	jal PROC_IMPRIMIR_TEXTURA
	
	# joga fora a1 e a2 e reg_textura_mapa
	addi sp, sp, 12
.end_macro

# rg x, rg y, int valor, label textura_mapa
.macro sobrescrever_tilemap(%x, %y, %valor, %textura_mapa)
	la t0, %textura_mapa
	sobrescrever_tilemap_rg(%x, %y, %valor, t0)
.end_macro

# int valor, rg textura_mapa
.macro sobrescrever_tile_atual_rg(%valor, %reg_textura_mapa)
	mv t6, %reg_textura_mapa
	
	li t0, AREA_SPRITE
	li t1, %valor
	mul t0, t0, t1
	add t6, t6, t0			# pula pro endereco do tile TEXTURAS + (TILE * AREA_SPRITE)

	addi sp, sp, -4
	sw t6, (sp)

	la a0, POSICAO_JOGADOR
	lhu a1, (a0)
	lhu a2, 2(a0)
	li a0, %valor
	li a7, 0			# modo escrever
	jal PROC_MANIPULAR_TILEMAP

	la a0, POSICAO_JOGADOR		# temp
	lhu a1, (a0)			# x
	lhu a2, 2(a0)			# y
	li a3, TAMANHO_SPRITE		# dimensoes
	li a4, TAMANHO_SPRITE		# dimensoes
	li a7, 1			# modo imprimir na fase buffer
	lw a0, (sp)			# carrega a textura
	addi a0, a0, 8			# pula words de informacao
	
	normalizar_posicao(a1, a2)
	
	jal PROC_IMPRIMIR_TEXTURA
	
	addi sp, sp, 4
.end_macro

# rg x, rg y, int valor, label textura_mapa
.macro sobrescrever_tile_atual(%valor, %textura_mapa)
	la t0, %textura_mapa
	sobrescrever_tile_atual_rg(%valor, t0)
.end_macro

.macro selecionar_texto_rg(%reg, %temp_reg, %temp_reg2, %rg_id)
        # pega o offset de acordo com o idioma atual
        mv %temp_reg, %rg_id                       # pega o ID na tabela de offsets
        lbu %temp_reg2, lingua_atual            # pega a lingua (COLUNA NA TABELA) atual
        slli %temp_reg2, %temp_reg2, 2          # converte a lingua para multiplo de 4 (para podermos pular N words)
        add %temp_reg, %temp_reg, %temp_reg2    # pulamos até a enésima word da linha (a correspondente a lingua atual)

        # id = id1;   
        # lingua = 2;
        # lingua *= 4;
        # id += lingua;

        #                        pega esse
        #                           VVV
        # offsets:       l0   l1    l2      l3
        # id1:   .word   0    595   20394   1023919
        # id2:   ...

        # carrega o bloco de strings
        la %reg, strblock

        # carrega o offset da tabela
        lw %temp_reg, 0(%temp_reg)

        # aplica o offset
        add %reg, %reg, %temp_reg

        #terminamos! %reg contem o endereço de str_block + offset.
        # "return %reg"
.end_macro

.macro selecionar_texto(%reg, %temp_reg, %temp_reg2, %id)
        la %temp_reg2, %id              # passa o registrador temporario como o registrador com o ID
        selecionar_texto_rg(%reg, %temp_reg, %temp_reg2, %temp_reg2)
.end_macro

.macro setar_tempo(%reg_tempo)
	mv a0, x0
	mv a1, %reg_tempo
	jal PROC_TEMPO_MANAGER
.end_macro

.macro atualizar_tempo
	li a0, 1
	jal PROC_TEMPO_MANAGER
.end_macro

.macro incrementar_direcao(%reg_direcao)
	addi %reg_direcao, %reg_direcao, 1
	li t1, 4
	slt t0, %reg_direcao, t1
	mul %reg_direcao, %reg_direcao, t0	# se a direcao for 4 ou maior, multiplica por 0 
.end_macro

.macro decrementar_direcao(%reg_direcao)
	addi %reg_direcao, %reg_direcao, -1
	li t1, 4
	sltz t0, %reg_direcao
	mul t0, t0, t1				
	add %reg_direcao, %reg_direcao, t0					# se a direcao for -1 ou menor, adiciona 4
.end_macro

# alias para incrementar_direcao(%reg_direcao)
.macro virar_90_graus_no_sentido_antihorario(%reg_direcao)
	incrementar_direcao(%reg_direcao)
.end_macro

# alias para decrementar_direcao(%reg_direcao)
.macro virar_90_graus_no_sentido_horario(%reg_direcao)
	decrementar_direcao(%reg_direcao)
.end_macro

# seta %reg para 1 se os dois argumentos forem iguais, senao seta para 0
.macro seq(%reg, %arg1, %arg2)
	sub %reg, %arg1, %arg2		# pega arg1 - arg2
	seqz %reg, %reg			# se arg1 - arg2 = 0, eles sao iguais.
.end_macro

# imprime uma string arg[0] em x = arg[1] e y = arg[2] com cor arg[3]. se arg[4] = 0, trata arg[0] como chave em locale.s. senao, como endereco.
.macro imprimir_string(%stringkey, %x, %y, %cor, %modo)
	la a0, %stringkey
	li a1, %x
	li a2, %y
	li a3, %cor
	li a4, %modo
	jal PROC_IMPRIMIR_STRING
.end_macro

# imprime uma string arg[0] em x = arg[1] e y = arg[2] com cor arg[3]. se arg[4] = 0, trata arg[0] como chave em locale.s. senao, como endereco.
.macro imprimir_string_reg(%stringkey, %x, %y, %cor, %modo)
	la a0, %stringkey
	mv a1, %x
	mv a2, %y
	li a3, %cor
	li a4, %modo
	jal PROC_IMPRIMIR_STRING
.end_macro

.macro sleep(%seg)
	.text
	li a0, %seg
	li a7, 32
	ecall
.end_macro

.macro safe_sleep(%seg)
	.text
	addi sp, sp, -8
	sw a0, (sp)
	sw a7, 4(sp)

	li a0, %seg
	li a7, 32
	ecall

	lw a0, (sp)
	lw a7, 4(sp)
	addi sp, sp, 8
.end_macro