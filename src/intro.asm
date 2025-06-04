
.data
.include "..\cutscenes\intro\strip.data"


.text

j MAIN

SLEEP_1_SEC:	li a0, 1000		# define 1000ms como o tempo de dormir
SLEEP: 		li a7, 32       	# syscall 32 = sleep
		ecall
		ret


# Preenche a tela de preto
MAIN:		li t1,0xFF000000	# endereco inicial da Memoria VGA - Frame 0
		li t2,0xFF012C00	# endereco final 
		li t3,0x01010101	# cor preto|preto|preto|preto
LOOP: 		beq t1,t2,INICIO	# Se for o �ltimo endere�o ent�o sai do loop
		sw t3,0(t1)		# escreve a word na mem�ria VGA
		addi t1,t1,4		# soma 4 ao endere�o
		j LOOP			# volta a verificar
	

LOOP1:		li a0, 3000	
		jal SLEEP		# atrasa o programa por 3 segundos
		j LOOP1_1

# Carrega a strip
INICIO:		la s1,strip		# endere�o dos dados da tela na memoria
		addi s1,s1,8		# primeiro pixels depois das informa��es de nlin ncol
		li s0,-1		# inicia o frame da strip como -1 (nenhum frame)
		addi t0,t0,7		# define 7 como o ultimo frame 

LOOP1_1:	addi s0,s0,1		# adiciona 1 ao indicador de frame		
		beq s0,t0,FIM           # finaliza se passamos do ultimo frame
		li t1,0xFF000000	# endereco inicial da Memoria VGA - Frame 0
		li t2,0xFF012C00	# endereco final 
		
LOOP_FRAME: 	beq t1,t2,LOOP1		# Se for o �ltimo endere�o ent�o volta pro loop principal
		lw t3,0(s1)		# le um conjunto de 4 pixels : word
		sw t3,0(t1)		# escreve a word na mem�ria VGA
		addi t1,t1,4		# soma 4 ao endere�o
		addi s1,s1,4
		j LOOP_FRAME		# volta a verificar

# devolve o controle ao sistema operacional
FIM:	li a7,10		# syscall de exit
	ecall