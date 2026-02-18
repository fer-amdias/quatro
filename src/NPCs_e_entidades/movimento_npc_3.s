#################################################################
# PROC_MOVIMENTO_NPC_3  			       	     	#
# Calcula a direcao de movimento do NPC 3.                      #
# 							     	#
# ARGUMENTOS:						     	#
#       A0 = direcao do NPC                                     #
#       A1 = pos X do NPC                                       #
#       A2 = pos Y do NPC                                       #
#       A3 = endereco do timestamp de ultima atualizacao        #
#       A4 = velocidade do NPC                                  #
#								#
# RETORNOS:                                                  	#
#       A0 = direcao de movimento (-1, caso fique parado)	#
#################################################################

PROC_MOVIMENTO_NPC_3:   
                        addi sp, sp, -24
		        sw ra, (sp)
                        sw s0, 4(sp)
                        sw s1, 8(sp)
                        sw s2, 12(sp)
                        sw s3, 16(sp)
                        sw s4, 20(sp)

                        

                        # primeiramente, NAO podemos mover se a timestamp estah proibindo movimento.
                        # Isso depende de nossa velocidade.

                        # O periodo em ms eh igual a 3000/VELOCIDADE
                        li t1, 3000         
                        div t0, t1, a4     # calcula o periodo em ms

                        lw t2, (a3)
                        add t2, t2, t0     # pega a ultima timestamp de movimento MAIS o periodo

                        mv t4, a0          # guarda o valor atual de a0
                        li a0, -1          # prepara pra retornar -1 caso necessario

                        csrr t3, time
                        bge t2, t3, P_MN3_FIM   # se (timestamp + periodo) > time, entao ainda nao passou PERIODO desde o ultimo movimento. retorna -1 (sem movimento.)
                        mv a0, t4          # retorna a0

                        mv s0, a0
                        mv s1, a1
                        mv s2, a2
                        mv s3, a3
                        mv s4, a4

                        # soh devemos mudar de direcao se:

                        # A. Estamos em uma posicao normalizada de tile E o tile ah frente nao pode ser andavel.
                        # B. O tile atual nao eh mais andavel, contudo o tile de tras eh andavel

                        # primeiro vemos se estamos em um tile andavel.

                        li a0, 0        # modo 0 (checar por posicao)
                                        # a1 = pos X
                                        # a2 = pos Y
			jal PROC_TILE_ANDAVEL

                        li a7, 0                # marca que foi o canto superior esquerdo
                        beqz a0, P_MN3_TILE_ATUAL_NAO_ANDAVEL 

                        ### temos que checar todos os lados para garantir! Cada canto checa dois lados (e.g. superior esquerdo checa a esquerda e acima)

                        # canto inferior direito
                        mv a1, s1
                        mv a2, s2
                        addi a2, a2, TAMANHO_SPRITE
                        addi a2, a2, -1
                        addi a1, a1, TAMANHO_SPRITE
                        addi a1, a1, -1
                        li a0, 0        # modo 1 (checar por direcao)
                                        # a1 = pos X
                                        # a2 = pos Y
			jal PROC_TILE_ANDAVEL

                        li a7, 1              # marca que foi o canto inferior direito
                        beqz a0, P_MN3_TILE_ATUAL_NAO_ANDAVEL

                                                mv a1, s1
                        mv a2, s2                     

                        normalizar_posicao(a1, a2)
                        sub t1, a1, s1
                        seqz t1, t1    # t1 = (a1 == s1)
                        
                        sub t2, a2, s2
                        seqz t2, t2    # t2 = (a2 == s2)
                        

                        and t0, t1, t2 # t0 = (a1 == s1) & (s2 == s2) [OU SEJA, SE ESTAMOS EM UMA POSICAO NORMALIZADA]

                        bnez t0, P_MN3_ESCOLHER_NOVA_DIRECAO    # se t0 == 1, podemos escolher uma nova direcao

                        # senao, continua indo pra frente
                        mv a0, s0
                        j P_MN3_FIM

P_MN3_ESCOLHER_NOVA_DIRECAO:

                        # a logica de movimento funciona da seguinte forma:
                        # 1. se podemos ir pra frente, vamos pra frente.
                        # 2. se nao podemos ir pra frente mas podemos ir pra tras, vamos pra tras.
                        # 3. se nao podemos ir pra frente nem pra tras, vamos pra esquerda.
                        # 4. se soh podemos ir pra direita, vamos ah direita.
                        # 5. se nao podemos nos mover, morremos.

                        li a0, 1        # modo 1 (checar por direcao)
                        mv a1, s1       # a1 = pos X
                        mv a2, s2       # a2 = pos Y
                        mv a3, s0       # direcao (frente)
			jal PROC_TILE_ANDAVEL
                        bnez a0, P_MN3_IR_PRA_FRENTE

                        li a0, 1        # modo 1 (checar por direcao)
                        mv a1, s1       # a1 = pos X
                        mv a2, s2       # a2 = pos Y
                        mv a3, s0       
                        virar_90_graus_no_sentido_horario(a3)
                        virar_90_graus_no_sentido_horario(a3) # direcao (atras)
			jal PROC_TILE_ANDAVEL
                        bnez a0, P_MN3_IR_PRA_TRAS

                        li a0, 1
                        mv a1, s1
                        mv a2, s2
                        mv a3, s0
                        virar_90_graus_no_sentido_antihorario(a3) # esquerda
                        jal PROC_TILE_ANDAVEL
                        bnez a0, P_MN3_IR_PRA_ESQUERDA

                        li a0, 1
                        mv a1, s1
                        mv a2, s2
                        mv a3, s0
                        virar_90_graus_no_sentido_horario(a3) # direita
                        jal PROC_TILE_ANDAVEL
                        bnez a0, P_MN3_IR_PRA_DIREITA

                        j P_MN3_MORRE
                        
P_MN3_TILE_ATUAL_NAO_ANDAVEL: 
                        # devemos checar se estamos andando pra longe do tile atual (para um tile andavel)
                        # podemos checar nosso canto mais a frente (superior esquerdo ou inferior direito) para ver se ele eh andavel
                        # se estivermos indo para CIMA ou para a ESQUERDA, seria o superior esquerdo
                        # se estivermos indo para BAIXO ou para a DIREITA, seria o inferior direito

                        # 0 = PARA BAIXO
			# 1 = PARA A DIREITA
			# 2 = PARA CIMA
			# 3 = PARA A ESQUERDA

                        mv t1, s1
                        mv t2, s2

                        # Se a direcao for 2 ou 3, nao precisamos fazer mais nada para pegar o canto.
                        li t0, 2
                        bge s0, t0, P_MN3_TILE_ATUAL_NAO_ANDAVEL_CONT2

                        # caso contrario...

                        li t0, TAMANHO_SPRITE
                        addi t0, t0, -1

                        # adiciona TAMANHO_SPRITE - 1
                        add t1, t1, t0
                        add t2, t2, t0

P_MN3_TILE_ATUAL_NAO_ANDAVEL_CONT2:
                        # agora checa o canto.
                        li a0, 0        # modo 0 (checar por posicao)
                        mv a1, t1       # a1 = pos X
                        mv a2, t2       # a2 = pos Y
			jal PROC_TILE_ANDAVEL

                        mv t4, a0     # guarda o resultado           
                        mv a0, s0
                        bnez t4, P_MN3_FIM    # se estamos indo na direcao certa (para LONGE do tile nao andavel), continua indo nela

                        # senao, precisamos checar se podemos ir pra tras!
                        # para isso, basta checar o OUTRO canto. agr a logica inverte.
                        # se estivermos indo para CIMA ou para a ESQUERDA, seria o inferior direito
                        # se estivermos indo para BAIXO ou para a DIREITA, seria o superior esquerdo

                        mv t1, s1
                        mv t2, s2               

                        # Se a direcao for 1 ou 0, nao precisamos fazer mais nada para pegar o canto.
                        li t0, 2
                        blt s0, t0, P_MN3_TILE_ATUAL_NAO_ANDAVEL_CONT3     

                        # caso contrario...

                        li t0, TAMANHO_SPRITE
                        addi t0, t0, -1

                        # adiciona TAMANHO_SPRITE - 1
                        add t1, t1, t0
                        add t2, t2, t0

P_MN3_TILE_ATUAL_NAO_ANDAVEL_CONT3:

                        # agora checa o OUTRO canto
                        li a0, 0        # modo 0 (checar por posicao)
                        mv a1, t1       # a1 = pos X
                        mv a2, t2       # a2 = pos Y
			jal PROC_TILE_ANDAVEL

                        mv t4, a0     # guarda o resultado           
                        mv a0, s0

                        virar_90_graus_no_sentido_antihorario(a0)
                        virar_90_graus_no_sentido_antihorario(a0)

                        bnez t4, P_MN3_FIM    # se estamos indo na direcao errada (para o tile nao andavel) E podemos ir pra tras, vai pra tras

                        # senao, fica parado
                        j P_MN3_FICA_PARADO

P_MN3_IR_PRA_FRENTE:
                        mv a0, s0
                        j P_MN3_FIM
P_MN3_IR_PRA_TRAS:
                        mv a0, s0
                        virar_90_graus_no_sentido_horario(a0)
                        virar_90_graus_no_sentido_horario(a0)
                        j P_MN3_FIM
P_MN3_IR_PRA_ESQUERDA:
                        mv a0, s0
                        virar_90_graus_no_sentido_antihorario(a0)
                        j P_MN3_FIM
P_MN3_IR_PRA_DIREITA:
                        mv a0, s0
                        virar_90_graus_no_sentido_horario(a0)
                        j P_MN3_FIM
P_MN3_FICA_PARADO:
                        li a0, -1
                        j P_MN3_RET
P_MN3_MORRE:   
                        li a0, 4
                        j P_MN3_RET
P_MN3_FIM:
                        bltz a0, P_MN3_RET

                        # se chegamos aqui, a0 >= 0
                        # precisamos guardar a timestamp
                        csrr t0, time
                        sw t0, (s3)                     # salva a timestamp do movimento atual
P_MN3_RET:
                        lw ra, (sp)
                        lw s0, 4(sp)
                        lw s1, 8(sp)
                        lw s2, 12(sp)
                        lw s3, 16(sp)
                        lw s4, 20(sp)
                        addi sp, sp, 24
                        ret