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
MACRO_DATA_QUEBRA_DE_LINHA: .ascii "\n\0"


.macro print(%string_address)
	.text
	li a7, 4
	la a0, %string_address
	ecall
.end_macro

.macro print_literal(%string_literal)
	.data
	var: .string %string_literal
	
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

.macro print_hex(%int)
	.text
	li a7, 34
	mv a0, %int
	ecall
.end_macro

