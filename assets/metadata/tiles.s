#################################################################
# 		  DEFINICAO DE STRUCT TILES                     #
#################################################################
#								#
#  Aqui, se guarda as structs e definicoes sobre tiles,         #
#  especialmente suas propriedades e atributos em um tilemap.   #
#								#
#  COMO USO ESSE MODULO?					#
#  Basta dar um .include no inicio de memoria.s.	        #
#								#
#################################################################


.eqv TILE_STRUCT_TAMANHO 2

.eqv TILE_STRUCT_ATRIBUTO_TIPO     0
.eqv TILE_STRUCT_ATRIBUTO_EXPLOSAO 1

# struct tile { 
#       byte tipo;
#       byte explosao;
# }
#
# sizeof(tile) = 2;