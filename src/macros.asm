#################################################
#		REGISTRO DE MACROS		#
#################################################
# Aqui define-se as macros a serem utilizadas   #
# no jogo.					#
# 						#
# Como esse arquivo estah incluido em 		#
# memoria.asm, pode ser acessado por todos os	#
# arquivos .asm.				#
#################################################


.data 
MACRO_DATA_QUEBRA_DE_LINHA: .ascii "\n\0"
.text

.macro print (%string_address)
	li a7, 4
	la a0, %string_address
	ecall
.end_macro

.macro print_int (%int)
	li a7, 1
	mv a0, %int
	ecall
.end_macro

.macro quebra_de_linha
	li a7, 4
	la a0, MACRO_DATA_QUEBRA_DE_LINHA
	ecall
.end_macro
