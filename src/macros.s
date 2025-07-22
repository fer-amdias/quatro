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

