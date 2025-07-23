#################################################################
# PROC_IMPRIMIR_INTEIRO				       	     	#
# Imprime um inteiro na tela.					#
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : inteiro						#
#	A1 : X							#
#	A2 : Y							#
#	A3 : cores (0x0000bbff)					#
# RETORNOS:                                                  	#
#       (nenhum)						#
#################################################################

# Prefixo interno: P_II1_

# CODIGO ADAPTADO DE SYSTEMv24.s

.data

TempBuffer: .space 72					# buffer para 8 caracteres (+ 1 null) no maximo

.text

PROC_IMPRIMIR_INTEIRO:
		addi 	sp, sp, -4			# Aloca espaco
		sw 	ra, 0(sp)			# salva ra
		la 	t0, TempBuffer			# carrega o Endereco do Buffer da String
		
		bge 	a0, zero, P_II1_POSITIVO	# Se eh positvo
		li 	t1, '-'				# carrega o sinal -
		sb 	t1, 0(t0)			# coloca no buffer
		addi 	t0, t0, 1			# incrementa endereco do buffer
		sub 	a0, zero, a0			# torna o numero positivo
		
P_II1_POSITIVO: li 	t2, 10				# carrega numero 10
		li 	t1, 0				# carrega numero de digitos com 0
		
P_II1_LOOP1:	
		div 	t4, a0, t2			# divide por 10 (quociente)
		rem 	t3, a0, t2			# resto
		addi 	sp, sp, -4			# aloca espaco na pilha
		sw 	t3, 0(sp)			# coloca resto na pilha
		mv 	a0, t4				# atualiza o numero com o quociente
		addi 	t1, t1, 1			# incrementa o contador de digitos
		bne 	a0, zero, P_II1_LOOP1		# verifica se o numero eh zero
				
P_II1_LOOP2:	lw 	t2, 0(sp)			# le digito da pilha
		addi 	sp, sp, 4			# libera espaco
		addi 	t2, t2, 48			# converte o digito para ascii
		sb 	t2, 0(t0)			# coloca caractere no buffer
		addi 	t0, t0, 1			# incrementa endereco do buffer
		addi 	t1, t1, -1			# decrementa contador de digitos
		bne 	t1, zero, P_II1_LOOP2		# eh o ultimo?
		sb 	zero, 0(t0)			# insere \NULL na string
		
		la 	a0, TempBuffer			# Endereco do buffer da srting
		jal 	PROC_IMPRIMIR_STRING		# chama o imprimir string
				
		lw 	ra, 0(sp)			# recupera ra
		addi 	sp, sp, 4			# libera espaco
fimprintInt:	ret					# retorna