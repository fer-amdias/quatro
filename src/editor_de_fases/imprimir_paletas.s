# EDITOR_IMPRIMIR_PALETAS
# Imprime a paleta de tiles e de NPCs.
#
# ARGUMENTOS:
# a0 - textura dos tiles
# a1 - textura dos NPCs

EDITOR_IMPRIMIR_PALETAS:

addi sp, sp, -44
sw ra, (sp)
sw s0, 4(sp)    
sw s1, 8(sp)
sw s2, 12(sp)
sw s3, 16(sp)
sw s4, 20(sp)
sw s5, 24(sp)
sw s6, 28(sp)
sw s7, 32(sp)  
sw s8, 36(sp)
sw s9, 40(sp)

# PALETA DE TILES

# tile 0+Y -> print at yval
# tile 1+Y -> print at yval+22
# tile 2+Y -> print at yval+44
# ...
# tile n+Y -> print at yval+22n

# stop once n>7 or n>VALOR_MAXIMO

lb s1, PALETA_DE_TILES_Y
lb s2, PALETA_DE_TILES_VALOR_MAXIMO

li s3, PALETAS_X                         
li s4, PALETAS_Y                         

li s5, 6                                # imprime de 0 a 6

li s6, 0                                # n

addi a0, a0, 8                          # pula as words de informacao
li t0, AREA_SPRITE
mul t5, t0, s1
add a0, a0, t5                          # vai pro tile 0+Y
mv s0, a0                               # guarda a textura

mv s7, a1                               # guarda a textura dos NPCs

mv s8, zero                             # primeira passagem

li s9, AREA_SPRITE                      # tamanho do passo (1 tile por tile)
E_IP1_WHILE_LOOP:

        # 	a0 = endereco da textura (.data)
        # 	a1 = pos X
        # 	a2 = pos Y
        # 	a3 = n de linhas da textura
        # 	a4 = n de colunas da textura
        
        mv a0, s0
        mv a1, s3			# aX = X
        mv a2, s4			# aY = Y
        li a3, TAMANHO_SPRITE		# aL = L
        li a4, TAMANHO_SPRITE		# aC = C
        li a7, 0			# printa na tela
        
        jal PROC_IMPRIMIR_TEXTURA	

add t5, s6, s1
bge t5, s2, E_IP1_BREAK
bge s6, s5, E_IP1_BREAK
addi s6, s6, 1

# espacamento entre itens
addi s4, s4, TAMANHO_SPRITE
addi s4, s4, 2

add s0, s0, s9 
j E_IP1_WHILE_LOOP

E_IP1_BREAK:

bnez s8, E_IP1_RET # se s8 = 1, ja imprimimos os dois tiles
# senao, temos que imprimir a PALETA DE NPCs

lb s1, PALETA_DE_NPCS_Y
lb s2, PALETA_DE_NPCS_VALOR_MAXIMO

li t0, BYTE_NPC_0
sub s2, s2, t0                          # coloca relativo ao NPC 0

li s3, PALETAS_X                         
li s4, PALETAS_Y      

# espacamento entre paletas
addi s3, s3, DISTANCIA_ENTRE_PALETAS            
addi s3, s3, TAMANHO_SPRITE   

li s6, 0                                # n

addi s7, s7, 8                          # pula as words de informacao
li t0, AREA_SPRITE
mul t5, t0, s1
li t0, 5
mul t5, t5, t0                          # 5 tiles por NPC
add s7, s7, t5                          # vai pro NPC 0+Y
mv s0, s7                               # coloca a textura certa no registrador de textura

li s8, 1                                # marca que nao eh nossa primeira passagem aqui

li s9, AREA_SPRITE                      
li t0, 5
mul s9, s9, t0                          # tamanho do passo (5 tiles por NPC)
j E_IP1_WHILE_LOOP

E_IP1_RET:

lw ra, (sp)
lw s0, 4(sp)    
lw s1, 8(sp)
lw s2, 12(sp)
lw s3, 16(sp)
lw s4, 20(sp)
lw s5, 24(sp)
lw s6, 28(sp)
lw s7, 32(sp)  
lw s8, 36(sp) 
lw s9, 40(sp)
addi sp, sp, 44
ret