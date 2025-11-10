#################################################################
# PROC_MOVIMENTO_NPC_1  			       	     	#
# Calcula a direcao de movimento do NPC 1.                      #
# 							     	#
# ARGUMENTOS:						     	#
#       A0 = direcao do NPC                                     #
#       A1 = pos X do NPC                                       #
#       A2 = pos Y do NPC                                       #
#       A3 = endereco do timestamp de ultima atualizacao        #
#								#
# RETORNOS:                                                  	#
#       A0 = direcao de movimento (-1, caso fique parado)	#
#################################################################

.data
.word 0 0 0 0 0 0 0 0 0 0 0 0 0 0
NPC_1_TIMESTAMP: .word 0

NPC_1_VETOR_DIRECAO: .space 4
NPC_1_VETOR_DIRECAO_TAMANHO: .byte 0

.text

# A0 = DIRECAO FRENTE
# A1 = DIRECAO A SER CHECADA
SUBPROC_P_MN1_CHECAR_DIRECAO: 
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

                        beqz a0, S1_P_MN1_RET

S1_P_MN1_GUARDA_DIRECAO:
                        la t1, NPC_1_VETOR_DIRECAO
                        lb t0, NPC_1_VETOR_DIRECAO_TAMANHO
                        add t1, t0, t1                 # avanca TAMANHO casas no vetor

                        sb s0, (t1)
                        addi t0, t0, 1                 # incrementa em 1 o tamanho
                        sb t0, NPC_1_VETOR_DIRECAO_TAMANHO, t1

                        beqz s3, S1_P_MN1_RET       # se a direcao que checamos nao for a frente, retorna
                        # senao, adiciona a frente de novo
                        # isso dah pra gente um PESO 2 para a direcao da frente, pois ela vai ser contabilizada duplamente!

                        # seta s3 como 0 (para que esse loop soh se repita uma vez!!) e guarda a direcao DE NOVO.
                        mv s3, zero
                        j S1_P_MN1_GUARDA_DIRECAO

S1_P_MN1_RET:
                        lw ra, (sp)
                        lw s0, 4(sp)
                        lw s3, 8(sp)
                        addi sp, sp, 12
                        ret


PROC_MOVIMENTO_NPC_1:   

                        addi sp, sp, -24
		        sw ra, (sp)
                        sw s0, 4(sp)
                        sw s1, 8(sp)
                        sw s2, 12(sp)
                        sw s3, 16(sp)
                        sw s4, 20(sp)

                        

                        # primeiramente, NAO podemos mover se a timestamp estah proibindo movimento.
                        # Isso depende de nossa velocidade.

                        # O periodo em ms eh igual a 2000/VELOCIDADE

                        lb t0, STRUCT_NPCS # carrega o primeiro atributo do primeiro NPC: velocidade
                        li t1, 3000         
                        div t0, t1, t0     # calcula o periodo em ms

                        lw t2, (a3)
                        add t2, t2, t0     # pega a ultima timestamp de movimento MAIS o periodo

                        mv t4, a0          # guarda o valor atual de a0
                        li a0, -1          # prepara pra retornar -1 caso necessario

                        csrr t3, time
                        bge t2, t3, P_MN1_FIM   # se (timestamp + periodo) > time, entao ainda nao passou PERIODO desde o ultimo movimento. retorna -1 (sem movimento.)
                        mv a0, t4          # retorna a0

                        mv s0, a0
                        mv s1, a1
                        mv s2, a2
                        mv s3, a3
                        mv s4, a4

                        # reseta o tamanho do vetor
                        sb x0, NPC_1_VETOR_DIRECAO_TAMANHO, t0
                        sw x0, NPC_1_VETOR_DIRECAO, t0              # reseta o vetor em si

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
                        beqz a0, P_MN1_TILE_ATUAL_NAO_ANDAVEL 

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

                        li a7, 1              # marca que foi o canto superior esquerdo
                        beqz a0, P_MN1_TILE_ATUAL_NAO_ANDAVEL


                        mv a1, s1
                        mv a2, s2                     

                        normalizar_posicao(a1, a2)
                        sub t1, a1, s1
                        seqz t1, t1    # t1 = (a1 == s1)
                        
                        sub t2, a2, s2
                        seqz t2, t2    # t2 = (a2 == s2)
                        

                        and t0, t1, t2 # t0 = (a1 == s1) & (s2 == s2) [OU SEJA, SE ESTAMOS EM UMA POSICAO NORMALIZADA]

                        bnez t0, P_MN1_ESCOLHER_NOVA_DIRECAO    # se t0 == 1, podemos escolher uma nova direcao

                        # senao, continua indo pra frente
                        mv a0, s0
                        j P_MN1_FIM

P_MN1_ESCOLHER_NOVA_DIRECAO:

			# s0 = direcao NPC, [s1, s2] = pos NPC, [s3, s4] = pos jogador
                        mv a0, s0
                        mv a1, s0
                        jal SUBPROC_P_MN1_CHECAR_DIRECAO        # checa a frente
                        
                        mv a0, s0
                        mv a1, s0
                        virar_90_graus_no_sentido_antihorario(a1)# checa a esquerda

                        jal SUBPROC_P_MN1_CHECAR_DIRECAO        

                        mv a0, s0
                        mv a1, s0
                        virar_90_graus_no_sentido_horario(a1)
                        jal SUBPROC_P_MN1_CHECAR_DIRECAO        # checa a direita
                        
                        # seta a seed aleatoria como o ciclo atual e o index como o time
			csrr a1, cycle
			csrr a0, time
			li a7, 40
			ecall				        # coloca a seed

                        # agora vamos sortear um numero N entre 0 e o tamanho do vetor menos um. Vamos pegar o Nesimo elemento do vetor, e andar nessa direcao.
                        # primeiro, sorteamos um numero entre 0 e tamanho-1.



                        lb t0, NPC_1_VETOR_DIRECAO_TAMANHO
                        mv t1, t0                               # guarda o tamanho
                        beqz t0, P_MN1_CHECA_ATRAS

P_MN1_ESCOLHER:
                        csrr a0, time			        # index do gerador
			mv a1, t0                               # tamanho-1
			li a7, 42                               # RandIntRange
			ecall                                   # chama RandIntRange [0, tamanho[ 

                        # importante dizer que a syscall RandIntRange funciona diferente no RARS e no FPGRARS
                        # no RARS, ela sorteia entre 0 e a1. No FPGRARS, sorteia entre 0 e a1-1. Portanto, precisamos
                        # garantir que nunca vamos avancar demais no vetor, caso estivermos rodando no RARS!

                        # se nao sorteamos TAMANHO, continua
                        bne a0, t1, P_MN1_ESCOLHER_NOVA_DIRECAO_CONT

                        # caso contrario, precisamos fazer isso de novo, mas com tamanho-1 para garantir um resultado valido.
                        # isso soh vai acontecer se estivermos no RARS.

                        addi t0, t0, -1                         # tamanho-1
                        j P_MN1_ESCOLHER

P_MN1_ESCOLHER_NOVA_DIRECAO_CONT:

                        la t0, NPC_1_VETOR_DIRECAO              # pega o vetor
                        add t0, t0, a0                          # avanca para o indice vetor[N]
                        lb a0, (t0)                             # pega o elemento no indice N

                        j P_MN1_FIM


P_MN1_TILE_ATUAL_NAO_ANDAVEL: 

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
                        bge s0, t0, P_MN1_TILE_ATUAL_NAO_ANDAVEL_CONT2

                        # caso contrario...

                        li t0, TAMANHO_SPRITE
                        addi t0, t0, -1

                        # adiciona TAMANHO_SPRITE - 1
                        add t1, t1, t0
                        add t2, t2, t0

P_MN1_TILE_ATUAL_NAO_ANDAVEL_CONT2:
                        # agora checa o canto.
                        li a0, 0        # modo 0 (checar por posicao)
                        mv a1, t1       # a1 = pos X
                        mv a2, t2       # a2 = pos Y
			jal PROC_TILE_ANDAVEL

                        mv t4, a0     # guarda o resultado           
                        mv a0, s0
                        bnez t4, P_MN1_FIM    # se estamos indo na direcao certa (para LONGE do tile nao andavel), continua indo nela

                        # senao, precisamos checar se podemos ir pra tras!
                        # para isso, basta checar o OUTRO canto. agr a logica inverte.
                        # se estivermos indo para CIMA ou para a ESQUERDA, seria o inferior direito
                        # se estivermos indo para BAIXO ou para a DIREITA, seria o superior esquerdo

                        mv t1, s1
                        mv t2, s2               

                        # Se a direcao for 1 ou 0, nao precisamos fazer mais nada para pegar o canto.
                        li t0, 2
                        blt s0, t0, P_MN1_TILE_ATUAL_NAO_ANDAVEL_CONT3     

                        # caso contrario...

                        li t0, TAMANHO_SPRITE
                        addi t0, t0, -1

                        # adiciona TAMANHO_SPRITE - 1
                        add t1, t1, t0
                        add t2, t2, t0

P_MN1_TILE_ATUAL_NAO_ANDAVEL_CONT3:

                        # agora checa o OUTRO canto
                        li a0, 0        # modo 0 (checar por posicao)
                        mv a1, t1       # a1 = pos X
                        mv a2, t2       # a2 = pos Y
			jal PROC_TILE_ANDAVEL

                        mv t4, a0     # guarda o resultado           
                        mv a0, s0

                        virar_90_graus_no_sentido_antihorario(a0)
                        virar_90_graus_no_sentido_antihorario(a0)

                        bnez t4, P_MN1_FIM    # se estamos indo na direcao errada (para o tile nao andavel) E podemos ir pra tras, vai pra tras

                        # senao, fica parado
                        j P_MN1_FICA_PARADO
P_MN1_CHECA_ATRAS:
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

                        beqz a0, P_MN1_FICA_PARADO      # CASO 0, nao conseguimos

                        # CASO 1, anda pra tras
                        mv a0, s0
                        virar_90_graus_no_sentido_antihorario(a0)
                        virar_90_graus_no_sentido_antihorario(a0)
                        j P_MN1_FIM
P_MN1_FICA_PARADO:
                        li a0, -1
P_MN1_FIM:
                        bltz a0, P_MN1_RET

                        # se chegamos aqui, a0 >= 0
                        # precisamos guardar a timestamp
                        csrr t0, time
                        sw t0, (s3)                     # salva a timestamp do movimento atual
P_MN1_RET:
                        lw ra, (sp)
                        lw s0, 4(sp)
                        lw s1, 8(sp)
                        lw s2, 12(sp)
                        lw s3, 16(sp)
                        lw s4, 20(sp)
                        addi sp, sp, 24
                        ret
