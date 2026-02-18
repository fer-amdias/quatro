#################################################################
# PROC_IMPRIMIR_PADRAO_DE_FUNDO 				#
# Imprime um padrao para ficar no fundo de uma fase             #
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : endereco da textura do padrao                      #
# RETORNOS:                                                  	#
#       (nenhum)                                             	#
#################################################################

# eh importante notar que apenas dimensoes divisoras de LARGURA_VGA (x) e ALTURA_VGA (y) funcionarao bem aqui

# Prefixo interno: P_IP1_

PROC_IMPRIMIR_PADRAO_DE_FUNDO:
                addi sp, sp, -32
                sw ra, (sp)
                sw s0, 4(sp)
                sw s1, 8(sp)
                sw s2, 12(sp)
                sw s3, 16(sp)
                sw s4, 20(sp)
                sw s5, 24(sp)
                sw s6, 28(sp)

                la t0, NULL
                beq a0, t0, P_IP1_PREENCHER_TELA

                lw s0, (a0)     # largura    
                lw s1, 4(a0)    # altura
                addi a0, a0, 8

                li s2, 0        # X
                li s3, 0        # Y

                li s4, LARGURA_VGA
                li s5, ALTURA_VGA

                mv s6, a0
                j P_IP1_LOOP

P_IP1_PREENCHER_TELA:
# PROC_PREENCHER_TELA 				       	     	
# Muda cada pixel do frame fornecido para ter a cor fornecida 	
# 							     	
# ARGUMENTOS:						     	
#	A0 : COR DE PREENCHIMENTO                            	
#	A1 : MODO : 0 = tela, 1 = buffer                   	

                mv a0, zero
                li a1, 1
                jal PROC_PREENCHER_TELA
                j P_IP1_FIM                                          	
P_IP1_LOOP:

#       PROC_IMPRIMIR_TEXTURA				             
#	A0 : ENDERECO DA TEXTURA A SER IMPRESSA              
# 	A1 : POSICAO X                                     
#       A2 : POSICAO Y                                      
#       A3 : NUMERO DE LINHAS DA TEXTURA (ALTURA)            
#       A4 : NUMERO DE COLUNAS DA TEXTURA (LARGURA)          
#	A7 : MODO DE IMPRESSAO 				     
#			(0: FRAME_BUFFER, 1: FASE_BUFFER)                                  

                mv a0, s6       # endereco da textura
                mv a1, s2       # x
                mv a2, s3       # y
                mv a3, s1       # altura
                mv a4, s0       # largura
                mv a7, zero     # imprimir no frame_buffer

                jal PROC_IMPRIMIR_TEXTURA

                add s2, s2, s0  # avanca LARGURA colunas pra frente
                blt s2, s4, P_IP1_LOOP  # continua se ainda podemos imprimir nessa linha

P_IP1_PROXIMA_LINHA:
                mv s2, zero     # linha 0
                add s3, s3, s1  # avanca ALTURA linhas para baixo
                blt s3, s5, P_IP1_LOOP  # continua se ainda nao chegamos ao final

P_IP1_FIM:
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



