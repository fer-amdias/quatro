#################################################################
# PROC_MOVIMENTO_NPC_2  			       	     	#
# Calcula a direcao de movimento do NPC 2.                      #
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

.data

.eqv FUGIR_HITBOX_H 40
.eqv FUGIR_HITBOX_W 40
.eqv TEMPO_DE_FUGA_MS 2000

NPC_2_VETOR_DIRECAO: .space 4
NPC_2_VETOR_DIRECAO_TAMANHO: .byte 0

NPC_2_TIMESTAMP_FUGIR: .word 0
NPC_2_FUGINDO: .byte 0

.text

# A0 = DIRECAO FRENTE
# A1 = DIRECAO A SER CHECADA
SUBPROC_P_MN2_CHECAR_DIRECAO: 
                        addi sp, sp, -12
                        sw ra, (sp)
                        sw s0, 4(sp)
                        sw s3, 8(sp)

                        # guarda os argumentos em s0 e s3
                        mv s0, a1
                        seq(s3, a0, a1)         # OU SEJA, se estamos indo pra frente

                        ### agora temos que checar se a direcao eh andavel
                        li a0, 1        # modo 1 (checar por direcao)
                        mv a1, s1       # a1 = pos X
                        mv a2, s2       # a2 = pos Y
                        mv a3, s0       # a3 = direcao a ser checada
			jal PROC_TILE_ANDAVEL

                        beqz a0, S1_P_MN2_RET

S1_P_MN2_GUARDA_DIRECAO:
                        la t1, NPC_2_VETOR_DIRECAO
                        lb t0, NPC_2_VETOR_DIRECAO_TAMANHO
                        add t1, t0, t1                 # avanca TAMANHO casas no vetor

                        sb s0, (t1)
                        addi t0, t0, 1                 # incrementa em 1 o tamanho
                        sb t0, NPC_2_VETOR_DIRECAO_TAMANHO, t1

                        beqz s3, S1_P_MN2_RET       # se a direcao que checamos nao for a frente, retorna
                        # senao, adiciona a frente de novo
                        # isso dah pra gente um PESO 2 para a direcao da frente, pois ela vai ser contabilizada duplamente!

                        # seta s3 como 0 (para que esse loop soh se repita uma vez!!) e guarda a direcao DE NOVO.
                        mv s3, zero
                        j S1_P_MN2_GUARDA_DIRECAO

S1_P_MN2_RET:
                        lw ra, (sp)
                        lw s0, 4(sp)
                        lw s3, 8(sp)
                        addi sp, sp, 12
                        ret


PROC_MOVIMENTO_NPC_2:   

                        addi sp, sp, -24
		        sw ra, (sp)
                        sw s0, 4(sp)
                        sw s1, 8(sp)
                        sw s2, 12(sp)
                        sw s3, 16(sp)
                        sw s4, 20(sp)     

                        # se estamos fugindo, devemos aumentar a velocidade em 200%!
                        lb t0, NPC_2_FUGINDO
                        beqz t0, P_MN2_CONT

                        slli t1, a4, 1   # t1 = a4*2
                        add a4, a4, t1   # t1 = a4 + 2*a4  (300%*a4)

P_MN2_CONT:

                        # NAO podemos mover se a timestamp estah proibindo movimento.
                        # Isso depende de nossa velocidade.

                        # O periodo em ms eh igual a 3000/VELOCIDADE   
                        li t1, 3000    
                        div t0, t1, a4     # calcula o periodo em ms

                        lw t2, (a3)
                        add t2, t2, t0     # pega a ultima timestamp de movimento MAIS o periodo

                        mv t4, a0          # guarda o valor atual de a0
                        li a0, -1          # prepara pra retornar -1 caso necessario

                        csrr t3, time
                        bge t2, t3, P_MN2_FIM   # se (timestamp + periodo) > time, entao ainda nao passou PERIODO desde o ultimo movimento. retorna -1 (sem movimento.)
                        mv a0, t4          # retorna a0 que tinhamos guardado

                        mv s0, a0
                        mv s1, a1
                        mv s2, a2
                        mv s3, a3
                        mv s4, a4



                        # reseta o tamanho do vetor
                        sb x0, NPC_2_VETOR_DIRECAO_TAMANHO, t0
                        sw x0, NPC_2_VETOR_DIRECAO, t0              # reseta o vetor em si

                        # SEGUNDO, soh devemos mudar de direcao se:

                        # A. Estamos em uma posicao normalizada de tile, ou
                        # B. O tile atual nao eh mais andavel, contudo o tile de tras eh andavel

                        # senao, andamos na direcao que estamos indo.

                        ### agora temos que checar se o tile atual eh andavel
                        li a0, 0        # modo 1 (checar por direcao)
                                        # a1 = pos X
                                        # a2 = pos Y
			jal PROC_TILE_ANDAVEL

                        li a7, 0                # marca que foi o canto superior direito
                        beqz a0, P_MN2_TILE_ATUAL_NAO_ANDAVEL 

                        ### temos que checar todos os lados para garantir! Cada canto checa dois lados (e.g. superior esquerdo checa a esquerda e acima)

                        # canto inferior direito
                        mv a1, s1
                        mv a2, s2
                        addi a2, a2, TAMANHO_SPRITE
                        addi a2, a2, -1
                        addi a1, a1, TAMANHO_SPRITE
                        addi a1, a1, -1
                        li a0, 0        # modo 0 (checar por posicao)
                                        # a1 = pos X
                                        # a2 = pos Y
			jal PROC_TILE_ANDAVEL

                        li a7, 1              # marca que foi o canto superior esquerdo
                        beqz a0, P_MN2_TILE_ATUAL_NAO_ANDAVEL

                                                mv a1, s1
                        mv a2, s2                     

                        normalizar_posicao(a1, a2)
                        sub t1, a1, s1
                        seqz t1, t1    # t1 = (a1 == s1)
                        
                        sub t2, a2, s2
                        seqz t2, t2    # t2 = (a2 == s2)
                        

                        and t0, t1, t2 # t0 = (a1 == s1) & (s2 == s2) [OU SEJA, SE ESTAMOS EM UMA POSICAO NORMALIZADA]

                        beqz t0, P_MN2_VAI_PRA_FRENTE # se t0 == 0, nao estamos em uma posicao normalizada e devemos continuar indo pra frente.

                        lb t0, NPC_2_FUGINDO
                        bnez t0, P_MN2_CONTINUAR_FUGINDO

P_MN2_CHECAR_SE_DEVEMOS_FUGIR:

                        la t0, POSICAO_JOGADOR
                        lh t1, 0(t0)                    # t1 = jogador.x
                        lh t2, 2(t0)                    # t2 = jogador.y
                        lw t3, ALTURA_JOGADOR           # t3 = jogador.altura
                        lw t4, LARGURA_JOGADOR          # t4 = jogador.largura

                        #  se !(jogador.x < npc.x + npc.largura + HITBOX_W)     j SEM_COLISAO
                        addi t0, s1, TAMANHO_SPRITE
                        addi t0, t0, FUGIR_HITBOX_W
                        bge t1, t0, P_MN2_MOVIMENTO_NORMAL

                        # se !(jogador.x + jogador.largura + HITBOX_W > npc.x) j SEM_COLISAO
                        add t0, t1, t4
                        addi t0, t0, FUGIR_HITBOX_W
                        bge s1, t0, P_MN2_MOVIMENTO_NORMAL

                        # se !(jogador.y < npc.y + npc.altura + HITBOX_H)      j SEM_COLISAO
                        addi t0, s2, TAMANHO_SPRITE
                        addi t0, t0, FUGIR_HITBOX_H
                        bge t2, t0, P_MN2_MOVIMENTO_NORMAL

                        # se !(jogador.y + jogador.altura + HITBOX_H > npc.y)  j SEM_COLISAO
                        add t0, t2, t3
                        addi t0, t0, FUGIR_HITBOX_H
                        bge s2, t0, P_MN2_MOVIMENTO_NORMAL


P_MN2_FUGIR:
                        la t0, NPC_2_TIMESTAMP_FUGIR
                        csrr t1, time
                        addi t1, t1, TEMPO_DE_FUGA_MS
                        sw t1, (t0)
P_MN2_FUGINDO:
                        li t0, 1
                        sb t0, NPC_2_FUGINDO, t1

                        la t0, POSICAO_JOGADOR
                        lh t1, 0(t0)                    # t1 = jogador.x
                        lh t2, 2(t0)                    # t2 = jogador.y

                        # t1 = deltaX
                        # t2 = deltaY
                        sub t1, s1, t1
                        sub t2, s2, t2

        #                       se (deltaX > 0) {
        #                       se (deltaY > 0){
        #                               se (deltaX > deltaY) j MOVE_DIREITA 
        #                               senao j MOVE_BAIXO 
        #                       }senao{
        #                               deltaY = -deltaY
        #                               se (deltaX > deltaY) j MOVE_DIREITA
        #                               senao j MOVE_CIMA 
        #                       }
        #                       }senao{
        #                       se (deltaY > 0){
        #                               deltaX = -deltaX
        #                               se (deltaX > deltaY) j MOVE_ESQUERDA
        #                               senao j MOVE_BAIXO 
        #                       }senao{
        #                               se (deltaY > deltaX) j MOVE_ESQUERDA
        #                               senao j MOVE_CIMA
        #                       }
        #                       }     

                        sgtz t3, t1     # t3 = (deltaX > 0)
                        sgtz t4, t2     # t4 = (deltaY > 0)
                        and t5, t4, t3  # t5 = ((deltaX > 0) & (deltaY > 0))

                        # se (+DX e +DY), deltas positivos
                        bnez t5, P_MN2_DELTAS_POSITIVOS  

                        # se !(+DX e +DY) mas +DX, DX positivo e DY negativo
                        bnez t3, P_MN2_DELTAX_POSITIVO_DELTAY_NEGATIVO

                        # se !(+DX e +DY) mas +DY, DX negativo e DY positivo
                        bnez t4, P_MN2_DELTAX_NEGATIVO_DELTAY_POSITIVO

                        # se nenhum, DX negativo e DY negativo
P_MN2_DELTAS_NEGATIVOS:
                        ble t1, t2, P_MN2_TENTA_IR_PRA_ESQUERDA
                        j P_MN2_TENTA_IR_PRA_CIMA
P_MN2_DELTAX_NEGATIVO_DELTAY_POSITIVO:
                        neg t1, t1
                        bgt t1, t2, P_MN2_TENTA_IR_PRA_ESQUERDA
                        j P_MN2_TENTA_IR_PRA_BAIXO
P_MN2_DELTAX_POSITIVO_DELTAY_NEGATIVO:
                        neg t2, t2
                        bgt t1, t2 P_MN2_TENTA_IR_PRA_DIREITA
                        j P_MN2_TENTA_IR_PRA_CIMA
P_MN2_DELTAS_POSITIVOS:
                        bgt t1, t2, P_MN2_TENTA_IR_PRA_DIREITA
                        #j P_MN2_TENTA_IR_PRA_BAIXO eh desnecessario


        # escolhe a direcao de movimento
P_MN2_TENTA_IR_PRA_BAIXO:
                        li t6, 0                # BAIXO
                        j P_MN2_FUGIR_CONT
P_MN2_TENTA_IR_PRA_DIREITA:
                        li t6, 1                # DIREITA
                        j P_MN2_FUGIR_CONT
P_MN2_TENTA_IR_PRA_CIMA:
                        li t6, 2                # CIMA
                        j P_MN2_FUGIR_CONT
P_MN2_TENTA_IR_PRA_ESQUERDA:
                        li t6, 3                # ESQUERDA
                        j P_MN2_FUGIR_CONT

P_MN2_FUGIR_CONT:
                        # primeiro temos que saber se podemos ir pro tile que queremos ir
                        # guardamos a direcao e alguns registradores salvos que vamos utilizar
                        addi sp, sp, -20
                        sw t6, 0(sp)
                        sw s3, 4(sp)
                        sw s4, 8(sp)
                        sw s5, 12(sp)
                        sw s6, 16(sp)

                        # s3 = t6 + 90 graus
                        mv s3, t6
                        virar_90_graus_no_sentido_horario(s3)

                        # s4 = t6 - 90 graus
                        mv s4, t6
                        virar_90_graus_no_sentido_antihorario(s4)

                        li a0, 1                # modo 1 (checar por direcao)
                        mv a1, s1               # a1 = pos X
                        mv a2, s2               # a2 = pos Y
                        lw a3, 0(sp)            # a3 = direcao
                        jal PROC_TILE_ANDAVEL
                        # se nao podemos ir em direcao ah D, entao vamos pra outra direcao.
                        beqz a0, P_MN2_FUGIR_PRA_OUTRA_DIRECAO

                        # caso contrario, vamos pra D.
                        lw a0, 0(sp)
                        j P_MN2_FUGIR_FIM

P_MN2_FUGIR_PRA_OUTRA_DIRECAO:

                        li a0, 1                # modo 1 (checar por direcao)
                        mv a1, s1               # a1 = pos X
                        mv a2, s2               # a2 = pos Y
                        mv a3, s3               # a3 = direcao
                        jal PROC_TILE_ANDAVEL
                        mv s5, a0               # s5 = se eh possivel ir pra s3

                        li a0, 1                # modo 1 (checar por direcao)
                        mv a1, s1               # a1 = pos X
                        mv a2, s2               # a2 = pos Y
                        mv a3, s4               # a3 = direcao
                        jal PROC_TILE_ANDAVEL
                        mv s6, a0               # s6 = se eh possivel ir pra s4

                        li t0, 1
                        sub t1, t0, s5          # t1 = !s5
                        sub t2, t0, s6          # t2 = !s6
                        and t3, t1, t2          # t3 = (!s5 * !s6)
                        bnez t3, P_MN2_FUGIR_FICA_PARADO
                        bnez t2, P_MN2_FUGIR_MOVE_S3
                        bnez t1, P_MN2_FUGIR_MOVE_S4
P_MN2_FUGIR_MOVE_S3_OU_S4:
                        # prefeririamos continuar indo pra direcao que escolhemos previamente, entao checamos se algum eh igual
                        beq s3, s0, P_MN2_FUGIR_MOVE_S3
                        beq s4, s0, P_MN2_FUGIR_MOVE_S4

                        csrr t0, cycle
                        csrr t1, time
                        add t0, t0, t1

                        # se time + cycle for par, vai pra s4. senao, vai pra s3.
                        andi t0, t0, 0x01
                        beqz t0, P_MN2_FUGIR_MOVE_S4
P_MN2_FUGIR_MOVE_S3:
                        mv a0, s3
                        j P_MN2_FUGIR_FIM
P_MN2_FUGIR_MOVE_S4:
                        mv a0, s4
                        j P_MN2_FUGIR_FIM
P_MN2_FUGIR_FICA_PARADO:
                        li a0, -1
P_MN2_FUGIR_FIM:
                        lw t6, 0(sp)
                        lw s3, 4(sp)
                        lw s4, 8(sp)
                        lw s5, 12(sp)
                        lw s6, 16(sp)
                        addi sp, sp, 20
                        j P_MN2_FIM

P_MN2_CONTINUAR_FUGINDO:
                        lw t0, NPC_2_TIMESTAMP_FUGIR
                        csrr t1, time
                        bge t0, t1, P_MN2_FUGINDO       # se o tempo ainda nao acabou, continua fugindo

                        sb x0, NPC_2_FUGINDO, t0        # senao, guarda que nao estamos fugindo mais
                        # e continua movimento normal

P_MN2_MOVIMENTO_NORMAL:
P_MN2_ESCOLHER_NOVA_DIRECAO:

			# s0 = direcao NPC, [s1, s2] = pos NPC, [s3, s4] = pos jogador
                        mv a0, s0
                        mv a1, s0
                        jal SUBPROC_P_MN2_CHECAR_DIRECAO        # checa a frente
                        
                        mv a0, s0
                        mv a1, s0
                        virar_90_graus_no_sentido_antihorario(a1)# checa a esquerda

                        jal SUBPROC_P_MN2_CHECAR_DIRECAO        

                        mv a0, s0
                        mv a1, s0
                        virar_90_graus_no_sentido_horario(a1)
                        jal SUBPROC_P_MN2_CHECAR_DIRECAO        # checa a direita
                        
                        # seta a seed aleatoria como o ciclo atual e o index como o time
			csrr a1, cycle
			csrr a0, time
			li a7, 40
			ecall				        # coloca a seed

                        # agora vamos sortear um numero N entre 0 e o tamanho do vetor menos um. Vamos pegar o Nesimo elemento do vetor, e andar nessa direcao.
                        # primeiro, sorteamos um numero entre 0 e tamanho-1.



                        lb t0, NPC_2_VETOR_DIRECAO_TAMANHO
                        mv t1, t0                               # guarda o tamanho
                        beqz t0, P_MN2_CHECA_ATRAS

P_MN2_ESCOLHER:
                        csrr a0, time			        # index do gerador
			mv a1, t0                               # tamanho-1
			li a7, 42                               # RandIntRange
			ecall                                   # chama RandIntRange [0, tamanho[ 

                        # importante dizer que a syscall RandIntRange funciona diferente no RARS e no FPGRARS
                        # no RARS, ela sorteia entre 0 e a1. No FPGRARS, sorteia entre 0 e a1-1. Portanto, precisamos
                        # garantir que nunca vamos avancar demais no vetor, caso estivermos rodando no RARS!

                        # se nao sorteamos TAMANHO, continua
                        bne a0, t1, P_MN2_ESCOLHER_NOVA_DIRECAO_CONT

                        # caso contrario, precisamos fazer isso de novo, mas com tamanho-1 para garantir um resultado valido.
                        # isso soh vai acontecer se estivermos no RARS.

                        addi t0, t0, -1                         # tamanho-1
                        j P_MN2_ESCOLHER

P_MN2_ESCOLHER_NOVA_DIRECAO_CONT:

                        la t0, NPC_2_VETOR_DIRECAO              # pega o vetor
                        add t0, t0, a0                          # avanca para o indice vetor[N]
                        lb a0, (t0)                             # pega o elemento no indice N

                        j P_MN2_FIM


P_MN2_TILE_ATUAL_NAO_ANDAVEL: 

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
                        bge s0, t0, P_MN2_TILE_ATUAL_NAO_ANDAVEL_CONT2

                        # caso contrario...

                        li t0, TAMANHO_SPRITE
                        addi t0, t0, -1

                        # adiciona TAMANHO_SPRITE - 1
                        add t1, t1, t0
                        add t2, t2, t0

P_MN2_TILE_ATUAL_NAO_ANDAVEL_CONT2:
                        # agora checa o canto.
                        li a0, 0        # modo 0 (checar por posicao)
                        mv a1, t1       # a1 = pos X
                        mv a2, t2       # a2 = pos Y
			jal PROC_TILE_ANDAVEL

                        mv t4, a0     # guarda o resultado           
                        mv a0, s0
                        bnez t4, P_MN2_FIM    # se estamos indo na direcao certa (para LONGE do tile nao andavel), continua indo nela

                        # senao, precisamos checar se podemos ir pra tras!
                        # para isso, basta checar o OUTRO canto. agr a logica inverte.
                        # se estivermos indo para CIMA ou para a ESQUERDA, seria o inferior direito
                        # se estivermos indo para BAIXO ou para a DIREITA, seria o superior esquerdo

                        mv t1, s1
                        mv t2, s2               

                        # Se a direcao for 1 ou 0, nao precisamos fazer mais nada para pegar o canto.
                        li t0, 2
                        blt s0, t0, P_MN2_TILE_ATUAL_NAO_ANDAVEL_CONT3     

                        # caso contrario...

                        li t0, TAMANHO_SPRITE
                        addi t0, t0, -1

                        # adiciona TAMANHO_SPRITE - 1
                        add t1, t1, t0
                        add t2, t2, t0

P_MN2_TILE_ATUAL_NAO_ANDAVEL_CONT3:

                        # agora checa o OUTRO canto
                        li a0, 0        # modo 0 (checar por posicao)
                        mv a1, t1       # a1 = pos X
                        mv a2, t2       # a2 = pos Y
			jal PROC_TILE_ANDAVEL

                        mv t4, a0     # guarda o resultado           
                        mv a0, s0

                        virar_90_graus_no_sentido_antihorario(a0)
                        virar_90_graus_no_sentido_antihorario(a0)

                        bnez t4, P_MN2_FIM    # se estamos indo na direcao errada (para o tile nao andavel) E podemos ir pra tras, vai pra tras

                        # senao, fica parado
                        j P_MN2_FICA_PARADO
P_MN2_CHECA_ATRAS:
                        # se chegamos aqui, nao tem nenhuma direcao andavel...
                        # mas e se pudermos voltar de onde viermos?


                        li a0, 1        # modo 1 (checar por direcao)
                        mv a1, s1       # a1 = pos X
                        mv a2, s2       # a2 = pos Y

                        mv a3, s0       

                        # coloca pra tras
                        virar_90_graus_no_sentido_antihorario(a3)
                        virar_90_graus_no_sentido_antihorario(a3)

			jal PROC_TILE_ANDAVEL

                        beqz a0, P_MN2_FICA_PARADO      # CASO 0, nao conseguimos

                        # CASO 1, anda pra tras
                        mv a0, s0
                        virar_90_graus_no_sentido_antihorario(a0)
                        virar_90_graus_no_sentido_antihorario(a0)
                        j P_MN2_FIM
P_MN2_VAI_PRA_FRENTE:
                        mv a0, s0
                        j P_MN2_FIM
P_MN2_FICA_PARADO:
                        li a0, -1
P_MN2_FIM:
                        bltz a0, P_MN2_RET

                        # se chegamos aqui, a0 >= 0
                        # precisamos guardar a timestamp
                        csrr t0, time
                        sw t0, (s3)                     # salva a timestamp do movimento atual
P_MN2_RET:
                        lw ra, (sp)
                        lw s0, 4(sp)
                        lw s1, 8(sp)
                        lw s2, 12(sp)
                        lw s3, 16(sp)
                        lw s4, 20(sp)
                        addi sp, sp, 24
                        ret
