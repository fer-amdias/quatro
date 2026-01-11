#################################################################
# 	        DEFINICOES DE ARQUIVOS DE FASES 	        #
#################################################################
#								#
#  Aqui, se guarda as definicoes do funcionamento interno dos   #
#  arquivos de fases.
#								#
#  COMO USO ESSE MODULO?					#
#  Basta dar um .include no inicio de memoria.s.	        #
#								#
#################################################################

# essas definicoes sao a respeito das informacoes nos arquivos de fase.
# os tiles sao de numero 0 a BYTE_NPC_0 - 1.
# os NPCs sao de numero BYTE_NPC_0 a 127.
.eqv BYTE_NPC_0 32