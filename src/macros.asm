#################################################
#		REGISTRO DE MACROS		#
#################################################
# Aqui define-se as macros ah serem utilizadas   #
# no jogo.					#
# 						#
# Como esse arquivo estah incluido em 		#
# memoria.asm, pode ser acessado por todos os	#
# arquivos .asm.				#
#################################################

.macro print (%string_address)
li a7, 4
la a0, %string_address
ecall
.end_macro
