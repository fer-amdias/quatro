#################################################################
# 		  REGISTRO DE MEMORIA DO JOGO 		 	#
#################################################################
#								#
#  Aqui, tudo que precisa ser acessado "globalmente" serah	#
#  registrado e guardado, como vetores "globais". Tudo serah	#
#  visivel para todo e qualquer codigo do programa.		#
#								#
#  Nao guarde informacao aqui acessada apenas por um		#
#  procedimento, nem informacao utilizada somente na MAIN.	#
#								#
#  Tome cuidado com as labels que utilizar aqui, pois elas nao  #
#  podem ser redeclaradas nem sobrescritas em lugar nenhum.	#
#								#
# 								#
#  COMO USO ESSE MODULO?					#
#  Basta dar um .include "./memoria.asm" no inicio do		#
#  da main. 							#
#								#
#################################################################

.text

.include "./macros.asm"

.data

POSICOES_MAPA: .byte 0, 0
POSICAO_JOGADOR: .half 0, 0
FASE_ATUAL: .byte 0

INIMIGOS:         .byte 0 		# alihamento do vetor
	          .space 31 		# cada inimigo vai ser salvo em um byte, dando um total de 32 inimigos nesse vetor
INIMIGOS_POSICAO: .half 0 		# alinhamento do vetor
	          .space 127		# cada inimigo vai ter uma posicao de half-word (x) e half-word (y).
INIMIGOS_DIRECAO: .byte 0 		# alinhamento do vetor
		  .space 31		# cada inimigo vai ter uma direcao salvo em um byte.														