#################################################################
# SHADER_OBSCURECER_TELA 				       	#
# Transforma o buffer e a tela em uma versao obscurecida do que #
# estah sendo exibido atualmente.                               #
# 							     	#
# ARGUMENTOS:						     	#
#	(nenhum)                                                #
# RETORNOS:                                                  	#
#       (nenhum)                                             	#
#################################################################

SHADER_OBSCURECER_TELA:
        # agora vamos sobrescrever a tela: frame 0 se o buffer for frame 1, frame 1 se o buffer for frame 0
        li t0, FRAME_0
        lw t1, FRAME_BUFFER_PTR		# carrega o endereco do frame buffer
        bgt t1, t0, S_OT1_FRAME_0
        li t1, FRAME_1
        li t2, FRAME_1_FIM
        j S_OT1_MAIN		

S_OT1_FRAME_0:
        li t1, FRAME_0
        li t2, FRAME_0_FIM
S_OT1_MAIN: 		
        mv t0, zero                     # marcador = 0
        mv t3, t1                       # usaremos o t3 como pointer de endereco a ser incrementado
        mv t4, zero                     # X = 0
        li t6, LARGURA_VGA

# t0 = marcador de obscurecimento de pixel. falso se o proximo pixel deve ser pulado, verdadeiro se nao.
# t1 = endereco inicial
# t2 = Pm = endereco limite
# t3 = P  = endereco do pixel vga atual
# t4 = X  = X atual
# t6 = Xm = LARGURA VGA
        j S_OT1_LOOP
        
S_OT1_PROXIMA_LINHA:    
        mv t4, zero                     # reseta o X
        seqz t0, t0                      # inverte o marcador
        # SE P >= Pm sai do loop
        bge t3, t2, S_OT1_CONT
        
S_OT1_LOOP:		
        beqz t0, S_OT1_PULA_PIXEL	# SE ( marcador = falso ), ENTAO PULA O PIXEL
                                        # SENAO:
        sb zero, (t3)			# 	obscurece o pixel
S_OT1_PULA_PIXEL:	
        seqz t0, t0                      # inverte o marcador

        addi t4, t4, 1			# X++ 
        addi t3, t3, 1			# P++ 

        # SE X = Xm, VAI PARA A PROXIMA LINHA
        beq t4, t6, S_OT1_PROXIMA_LINHA

        j S_OT1_LOOP			# continua o loop		

S_OT1_CONT:
        lw t3, FRAME_BUFFER_PTR		# carrega o endereco do frame buffer

S_OT1_COPIAR_PARA_FRAME_BUFFER:
        # agora devemos pegar o que estah em t1 e colocar em FRAME_BUFFER
        beq t1,t2,S_OT1_FIM		# se for o ultimo endereco ent sai do loop
        lw t4,0(t1)                     # pega uma word da tela
        sw t4,0(t3)			# salva a word no buffer
        addi t3,t3,4			# pula uma word
        addi t1,t1,4                    # pula uma word
        j S_OT1_COPIAR_PARA_FRAME_BUFFER			# volta a verificar

S_OT1_FIM:
        ret