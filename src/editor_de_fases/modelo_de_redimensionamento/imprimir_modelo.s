# EDITOR_IMPRIMIR_MODELO
# Imprime o modelo de redimensionamento na tela.

.eqv MODELO_CENTRO_X 160
.eqv MODELO_CENTRO_Y 130

.eqv TAMANHO_BLOCO_MODELO 7

.eqv COR_BLOCO_BORDA 0xFF       # branco
.eqv COR_BLOCO_ESCURO 0x9B      # cinza
.eqv COR_BLOCO_CLARO 0x52       # cinza escuro

EDITOR_IMPRIMIR_MODELO:
        addi sp, sp, -32
        sw ra, (sp)
        sw s0, 4(sp)
        sw s1, 8(sp)
        sw s2, 12(sp)
        sw s3, 16(sp)
        sw s4, 20(sp)
        sw s5, 24(sp)
        sw s6, 28(sp)

        # devemos agora calcular a posicao X e Y que o modelo deve estar
        # primeiramente, devemos multiplicar o tamanho do modelo em blocos pelo tamanho de cada bloco
        li t0, TAMANHO_BLOCO_MODELO
        lb s1, MODELO_DE_REDIMENSIONAMENTO_LARGURA
        lb s2, MODELO_DE_REDIMENSIONAMENTO_ALTURA
        mul t1, s1, t0			# LB = L * TAMANHO_BLOCO_MODELO
        mul t2, s2, t0			# HB = H * TAMANHO_BLOCO_MODELO
        
        # agora devemos propriamente centralizar o modelo
        # a distancia do canto superor esquerdo pro centro eh LB/2 e CB/2
        # entao botamos X = MODELO_CENTRO_X - LB/2
        # igualmente, 	Y = MODELO_CENTRO_Y - HB/2

        srli s3, t1, 1     		# X = LB/2
        neg s3, s3			# X = -LB/2
        addi s3, s3, MODELO_CENTRO_X    # X = MODELO_CENTRO_Y - LB/2  

        srli s4, t2, 1     		# Y = HB/2
        neg s4, s4			# Y = -HB/2
        addi s4, s4, MODELO_CENTRO_Y    # Y = MODELO_CENTRO_X - HB/2  	 

        mv s0, zero
        
        j E_IM1_LOOP

        # s0 = M = marcador de tile claro
        # s1 = L = Largura
        # s2 = H = Altura
        # s3 = X
        # s4 = Y
        # s5 = CC (Contador de Colunas)
        # s6 = CL (Contador de Linhas)

E_IM1_PROXIMA_LINHA:
        li t0, TAMANHO_BLOCO_MODELO
        mul t0, t0, s1                  # largura em pixeis
        sub s3, s3, t0			# X -= L, voltando ele pra posicao inicial
        addi s4, s4, TAMANHO_BLOCO_MODELO# Y += TAMANHO_BLOCO_MODELO
        addi s6, s6, 1                  # CL++
        mv s5, zero			# CC = 0

        # SE CL = H: TERMINA A IMPRESSAO
        beq s6, s2, E_IM1_IMPRIMIR_DIMENSOES

E_IM1_LOOP:

        beqz s5, E_IM1_IMPRIMIR_TILE_BORDA      # tiles na coluna 0 sao borda
        beqz s6, E_IM1_IMPRIMIR_TILE_BORDA      # tiles na linha 0 sao borda
        addi t0, s5, 1
        beq t0, s1, E_IM1_IMPRIMIR_TILE_BORDA   # tiles na coluna L-1 sao borda
        addi t0, s6, 1
        beq t0, s2, E_IM1_IMPRIMIR_TILE_BORDA   # tiles na coluna L-1 sao borda

        add t0, s5, s6
        andi t0, t0, 0x0001                         # pega a paridade de CC+CL

        bnez t0, E_IM1_IMPRIMIR_TILE_ESCURO     # escuro se CL+CC = impar
        j E_IM1_IMPRIMIR_TILE_CLARO             # senao claro

E_IM1_IMPRIMIR_TILE_BORDA:
        li a0, COR_BLOCO_BORDA
        j E_IM1_IMPRIMIR

E_IM1_IMPRIMIR_TILE_CLARO:
        li a0, COR_BLOCO_CLARO
        j E_IM1_IMPRIMIR

E_IM1_IMPRIMIR_TILE_ESCURO:
        li a0, COR_BLOCO_ESCURO

E_IM1_IMPRIMIR:

        # imprime de X Y a X+TAMANHO_BLOCO-1 e Y+TAMANHO_BLOCO-1
        
        mv a1, s3
        mv a2, s4
        addi a3, a1, TAMANHO_BLOCO_MODELO
        addi a3, a3, -1
        addi a4, a2, TAMANHO_BLOCO_MODELO
        addi a4, a4, -1
        li a7, 0
        jal PROC_IMPRIMIR_RETANGULO

        addi s3, s3, TAMANHO_BLOCO_MODELO# X += TAMANHO_BLOCO_MODELO
        addi s5, s5, 1                   # CC++

        # SE CC = L, proxima linha!
        beq s5, s1, E_IM1_PROXIMA_LINHA

        j E_IM1_LOOP			# continua o loop	

E_IM1_IMPRIMIR_DIMENSOES:
        # A dimensao L tem que ser impressa em (MODELO_CENTRO_X, MODELO_CENTRO_Y  + 2 + HP/2)
        # A dimensao H tem que ser impressa em (MODELO_CENTRO_X + 2 + LP/2, MODELO_CENTRO_Y)

        lb a0, MODELO_DE_REDIMENSIONAMENTO_LARGURA
	li a1, MODELO_CENTRO_X
        addi a1, a1, -3         # compensa pelo tamanho do numero
	li a2, MODELO_CENTRO_Y
        addi a2, a2, 2  # + 2
        li t1, TAMANHO_BLOCO_MODELO    
        mul t0, s2, t1  # H em pixeis (HL)
        srli t0, t0, 1  # HL/2
        add a2, a2, t0  # + HL/2
	li a3, 0xC7FF

        li t0, 10
        blt a0, t0, E_IM1_IMPRIMIR_DIMENSOES_CONT

        addi a1, a1, -4

E_IM1_IMPRIMIR_DIMENSOES_CONT:

        jal PROC_IMPRIMIR_INTEIRO

        lb a0, MODELO_DE_REDIMENSIONAMENTO_ALTURA
	li a1, MODELO_CENTRO_X
        addi a1, a1, 2  # + 2
        li t1, TAMANHO_BLOCO_MODELO    
        mul t0, s1, t1  # L em pixeis (LL)
        srli t0, t0, 1  # LL/2
        add a1, a1, t0  # + LL/2
	li a2, MODELO_CENTRO_Y
        addi a2, a2, -3         # compensa pelo tamanho do numero
	li a3, 0xC7FF

	jal PROC_IMPRIMIR_INTEIRO

        

E_IM1_RET:
        lw ra, (sp)
        lw s0, 4(sp)
        lw s1, 8(sp)
        lw s2, 12(sp)
        lw s3, 16(sp)
        lw s4, 20(sp)
        lw s5, 24(sp)
        lw s6, 28(sp)
        addi sp, sp, 32
        ret



