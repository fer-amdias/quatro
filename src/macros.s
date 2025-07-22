#################################################
#		REGISTRO DE MACROS		#
#################################################
# Aqui define-se as macros a serem utilizadas   #
# no jogo.					#
# 						#
# Como esse arquivo estah incluido em 		#
# memoria.s, pode ser acessado por todos os	#
# arquivos .s.					#
#################################################

.data 
MACRO_DATA_QUEBRA_DE_LINHA: .string "\n"

# ATENCAO: ISSO NAO FUNCIONA NO FPGRARS
# soh no rars... por algum motivo.
.macro print(%string_address)
	.text
	li a7, 4
	la a0, %string_address
	ecall
.end_macro

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

