##############################################################
# PROC_TILE_ANDAVEL     			             #
# Retorna se o tile a ser checado eh andavel.                #
# 							     #
# ARGUMENTOS:						     #
#	A0 : MODO (0 = checar a posicao)                     #
#                 (1 = tile na direcao A3 da posicao dada    #
#               A1 : pos X                                   #
#               A2 : pos Y                                   #
#               A3 : direcao (caso modo 1)                   #
# RETORNOS:                                                  #
#       A0 : Se eh andavel ou nao.                           #
##############################################################

# Prefixo interno: P_TA2_

.text

PROC_TILE_ANDAVEL:
                addi sp, sp, -4
                sw ra, (sp)

                beqz a0, P_TA2_CALCULAR_TILE    # se o modo for 0, nao precisamos calcular qual tile eh.


P_TA2_SWITCH:
                li t1, TAMANHO_SPRITE

                # SWITCH STATEMENT para a direcao atual (a3)
                beqz a3, P_TA2_D0
                li t0, 1
                beq a3, t0, P_TA2_D1
                li t0, 2
                beq a3, t0, P_TA2_D2
                li t0, 3
                beq a3, t0, P_TA2_D3

                # default: faz remainder e checa de novo
                li t0, 4
                rem a3, a3, t0
                j P_TA2_SWITCH


                
P_TA2_D0:
                add a2, a2, t1
                j P_TA2_CALCULAR_TILE
P_TA2_D1:
                add a1, a1, t1
                j P_TA2_CALCULAR_TILE
P_TA2_D2:
                sub a2, a2, t1
                j P_TA2_CALCULAR_TILE
P_TA2_D3:
                sub a1, a1, t1

P_TA2_CALCULAR_TILE:
                # PROC_CALCULAR_TILE_ATUAL			             
                # Calcula o tile atual de uma coordenada X e Y e retorna a   
                # informacao, linha, coluna, x e y.			     
                # 							     
                # ARGUMENTOS:						     
                #	A0 : ENDERECO DO MAPA (.data)			     
                # 	A1 : POSICAO X                                       
                #       A2 : POSICAO Y                                       
                # RETORNOS INTERESSANTES:                                                  
                #       A0 : INFORMACAO DO TILE ATUAL (0-255)		     
  
                la a0, TILEMAP_BUFFER
                # a1 e a2 jah posicionados
                jal PROC_CALCULAR_TILE_ATUAL

                # retorna ZERO se eh parede, parede quebravel, ou bomba. retorna UM se eh explosao. retorna UM, caso nenhum dos anteriores.
                li t0, 1
                beq t0, a0, P_TA2_RETORNA_ZERO
                li t0, 4
                beq t0, a0, P_TA2_RETORNA_ZERO
                li t0, 100
                bge a0, t0, P_TA2_RETORNA_UM
                li t0, 50
                bge a0, t0, P_TA2_RETORNA_ZERO

                j P_TA2_RETORNA_UM
P_TA2_RETORNA_UM:
                li a0, 1
                j P_TA2_FIM
P_TA2_RETORNA_ZERO:
                mv a0, zero
P_TA2_FIM:
                lw ra, (sp)
                addi sp, sp, 4
                ret
