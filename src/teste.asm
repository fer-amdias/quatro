
.data
.include "strip.data"


.text

# Preenche a tela de vermelho
	li t1,0xFF000000	# endereco inicial da Memoria VGA - Frame 0
	li t2,0xFF012C00	# endereco final 
	li t3,0x07070707	# cor vermelho|vermelho|vermelhor|vermelho
LOOP: 	beq t1,t2,INICIO		# Se for o último endereço então sai do loop
	sw t3,0(t1)		# escreve a word na memória VGA
	addi t1,t1,4		# soma 4 ao endereço
	j LOOP			# volta a verificar
	
# Carrega a strip
INICIO:	la s1,strip		# endereço dos dados da tela na memoria
	addi s1,s1,8		# primeiro pixels depois das informações de nlin ncol
	li s0,-1		# inicia o frame da strip como -1 (nenhum frame)
	addi t0,t0,7		# define 7 como o ultimo frame 
FORA:	addi s0,s0,1		# adiciona 1 ao indicador de frame		
	beq s0,t0,FIM        # finaliza se passamos do ultimo frame
	li t1,0xFF000000	# endereco inicial da Memoria VGA - Frame 0
	li t2,0xFF012C00	# endereco final 
LOOP1: 	beq t1,t2,FORA		# Se for o último endereço então sai do loop
	lw t3,0(s1)		# le um conjunto de 4 pixels : word
	sw t3,0(t1)		# escreve a word na memória VGA
	addi t1,t1,4		# soma 4 ao endereço
	addi s1,s1,4
	j LOOP1			# volta a verificar

# devolve o controle ao sistema operacional
FIM:	li a7,10		# syscall de exit
	ecall