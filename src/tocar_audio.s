#################################################################
# PROC_TOCAR_AUDIO				       	     	#
# Toca o audio presente nas tracks e adiciona audio ahs tracks.	#
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : MODO (0 = continuar tocando, 1 = tocar nova)	#
#	caso a0 = 1:						#
#		A1 = endereco onde estah o audio		#
#		A2 = track para sobrescrever (1, 2 ou 3)	#
#		A3 = modo de loop (0, 1)			#
# RETORNOS:                                                  	#
#       (nenhum)                                             	#
#################################################################

.data
.include "Musicas/teste2.data"

TRACK1:
	TRACK1_ATIVO: 		.word 0	# se estah tocando ou nao
	TRACK1_TIMESTAMP:	.word 0 # quando o track comecou
	TRACK1_INICIO_POINTER:	.word 0 # pointer pra primeira nota (em caso de loop)
	TRACK1_POINTER:		.word 0 # marca qual eh a proxima nota
	TRACK1_LOOP:		.word 0	# marca se o track estah loopando
	
TRACK2:
	TRACK2_ATIVO: 		.word 0	# se estah tocando ou nao
	TRACK2_TIMESTAMP:	.word 0 # quando o track comecou
	TRACK2_INICIO_POINTER:	.word 0 # pointer pra primeira nota (em caso de loop)
	TRACK2_POINTER:		.word 0 # marca qual eh a proxima nota
	TRACK2_LOOP:		.word 0	# marca se o track estah loopando
	
TRACK3:
	TRACK3_ATIVO: 		.word 0	# se estah tocando ou nao
	TRACK3_TIMESTAMP:	.word 0 # quando o track comecou
	TRACK3_INICIO_POINTER:	.word 0 # pointer pra primeira nota (em caso de loop)
	TRACK3_POINTER:		.word 0 # marca qual eh a proxima nota
	TRACK3_LOOP:		.word 0	# marca se o track estah loopando
	
#	Notas (struct){
#		byte pitch
#		byte instrument
#		byte volume
#		space 1
#		word duration
#		word start_ms
#	}

# PREFIXO INTERNO: P_TA1_

.text
.eqv pitch 0
.eqv instrument 1
.eqv volume 2
.eqv duration, 4
.eqv start_ms 8
.eqv tamanho_struct_nota 12

PROC_TOCAR_AUDIO:
		addi sp, sp, -4
		sw ra, (sp)
		beqz, a0, P_TA1_TOCAR_SEQUENCIAL	# apena toca as tracks se o modo for 0
		
		# senao, inicializa a track escolhida
P_TA1_SWITCH1:
		li t0, 1
		bne a2, t0, P_TA1_SWITCH2
		jal P_TA1_INICIAR_TRACK1		# inicia a track 1
		j P_TA1_SWITCH_FIM
P_TA1_SWITCH2:
		li t0, 2
		bne a2, t0, P_TA1_SWITCH3
		jal P_TA1_INICIAR_TRACK2		# inicia a track 2
		j P_TA1_SWITCH_FIM
P_TA1_SWITCH3:
		li t0, 3
		bne a2, t0, P_TA1_SWITCH_FIM
		jal P_TA1_INICIAR_TRACK3		# inicia a track 3
P_TA1_SWITCH_FIM:

P_TA1_TOCAR_SEQUENCIAL:
	jal P_TA1_TRACK1
	jal P_TA1_TRACK2
	jal P_TA1_TRACK3
	j P_TA1_FIM
	


P_TA1_INICIAR_TRACK1: 		
		sw a1, TRACK1_INICIO_POINTER, t1# salva o audio como o ponteiro de inicio
		sw a1, TRACK1_POINTER, t1	# salva o audio como o ponteiro atual tbm
       		li t0, 1
      		sw t0, TRACK1_ATIVO, t1		# ativa a track
      		csrr t0, time
      		sw t0, TRACK1_TIMESTAMP, t1	# salva o momento em que a track comecou
      		sw a3, TRACK1_LOOP, t1		# salva se o loop estah ligado ou nao
      		ret			
       		
P_TA1_TRACK1: 

		lw t0, TRACK1_ATIVO
		beqz t0, P_TA1_TRACK1_FIM2	# se o track nao estah ativo, volta para onde estavamos
		
		lw t0, TRACK1_TIMESTAMP
		csrr t1, time
		sub t2, t1, t0			# milisegundos desde o comeco do timestamp
		
		lw t0, TRACK1_POINTER
		lw t1, duration(t0)
		beqz t1, P_TA1_TRACK1_FIM1	# se duracao == 0, chegamos no fim e devemos voltar
		
		lw t1, start_ms(t0)		
		bgt t1, t2, P_TA1_TRACK1_FIM2	# se start_ms < ms_desde_timestamp: nao toca nada ainda, nao eh hora
		
		lb a0, pitch(t0)
		lw a1, duration(t0)
		lb a2, instrument(t0)
		lb a3, volume(t0)
		li a7, 31
		ecall
		
		addi t0, t0, tamanho_struct_nota
		sw t0, TRACK1_POINTER, t1	# vai pra proxima nota no arquivo
		
		j P_TA1_TRACK1			# checa se hah alguma nota que deveria tocar simultaneamente
		
P_TA1_TRACK1_FIM1:	
		lw t0, TRACK1_LOOP
		beqz t0, P_TA1_TRACK1_FIM1_CONT
		# se o loop estiver ligado, reinicia tudo
		
		lw t0, TRACK1_INICIO_POINTER
		sw t0, TRACK1_POINTER, t1	# coloca o ponteiro de nota de volta no comeco
		csrr t0, time
		sw t0, TRACK1_TIMESTAMP, t1	# reinicia a timestamp da track (pra ela tocar de novo)
		j P_TA1_TRACK1_FIM2		# continua com o resto do proc
		
P_TA1_TRACK1_FIM1_CONT:
		sw zero, TRACK1_POINTER, t0	# limpa o pointer de reproducao
		sw zero, TRACK1_ATIVO, t0	# termina a reproducao
P_TA1_TRACK1_FIM2:
       		ret
       		
       		
       		
       		
       		
       		
       		
P_TA1_INICIAR_TRACK2: 		
		sw a1, TRACK2_INICIO_POINTER, t1# salva o audio como o ponteiro de inicio
		sw a1, TRACK2_POINTER, t1	# salva o audio como o ponteiro atual tbm
       		li t0, 1
      		sw t0, TRACK2_ATIVO, t1		# ativa a track
      		csrr t0, time
      		sw t0, TRACK2_TIMESTAMP, t1	# salva o momento em que a track comecou
      		sw a3, TRACK2_LOOP, t1		# salva se o loop estah ligado ou nao
      		ret
       		
P_TA1_TRACK2: 

		lw t0, TRACK2_ATIVO
		beqz t0, P_TA1_TRACK2_FIM2	# se o track nao estah ativo, volta para onde estavamos
		
		lw t0, TRACK2_TIMESTAMP
		csrr t1, time
		sub t2, t1, t0			# milisegundos desde o comeco do timestamp
		
		lw t0, TRACK2_POINTER
		lw t1, duration(t0)
		beqz t1, P_TA1_TRACK2_FIM1	# se duracao == 0, chegamos no fim e devemos voltar
		
		lw t1, start_ms(t0)		
		bgt t1, t2, P_TA1_TRACK2_FIM2	# se start_ms < ms_desde_timestamp: nao toca nada ainda, nao eh hora
		
		lb a0, pitch(t0)
		lw a1, duration(t0)
		lb a2, instrument(t0)
		lb a3, volume(t0)
		li a7, 31
		ecall
		
		addi t0, t0, tamanho_struct_nota
		sw t0, TRACK2_POINTER, t1	# vai pra proxima nota no arquivo
		
		j P_TA1_TRACK2			# checa se hah alguma nota que deveria tocar simultaneamente
		
P_TA1_TRACK2_FIM1:	
		lw t0, TRACK2_LOOP
		beqz t0, P_TA1_TRACK2_FIM1_CONT
		# se o loop estiver ligado, reinicia tudo
		
		lw t0, TRACK2_INICIO_POINTER
		sw t0, TRACK2_POINTER, t1	# coloca o ponteiro de nota de volta no comeco
		csrr t0, time
		sw t0, TRACK2_TIMESTAMP, t1	# reinicia a timestamp da track (pra ela tocar de novo)
		j P_TA1_TRACK2_FIM2		# continua com o resto do proc
		
P_TA1_TRACK2_FIM1_CONT:
		sw zero, TRACK2_POINTER, t0	# limpa o pointer de reproducao
		sw zero, TRACK2_ATIVO, t0	# termina a reproducao
P_TA1_TRACK2_FIM2:
       		ret
       		
       		
       		
       		
       		
       		
       		
       		
       		
       		
P_TA1_INICIAR_TRACK3: 		
		sw a1, TRACK3_INICIO_POINTER, t1# salva o audio como o ponteiro de inicio
		sw a1, TRACK3_POINTER, t1	# salva o audio como o ponteiro atual tbm
       		li t0, 1
      		sw t0, TRACK3_ATIVO, t1		# ativa a track
      		csrr t0, time
      		sw t0, TRACK3_TIMESTAMP, t1	# salva o momento em que a track comecou
      		sw a3, TRACK3_LOOP, t1		# salva se o loop estah ligado ou nao
      		ret
       		
P_TA1_TRACK3: 

		lw t0, TRACK3_ATIVO
		beqz t0, P_TA1_TRACK3_FIM2	# se o track nao estah ativo, volta para onde estavamos
		
		lw t0, TRACK3_TIMESTAMP
		csrr t1, time
		sub t2, t1, t0			# milisegundos desde o comeco do timestamp
		
		lw t0, TRACK3_POINTER
		lw t1, duration(t0)
		beqz t1, P_TA1_TRACK3_FIM1	# se duracao == 0, chegamos no fim e devemos voltar
		
		lw t1, start_ms(t0)		
		bgt t1, t2, P_TA1_TRACK3_FIM2	# se start_ms < ms_desde_timestamp: nao toca nada ainda, nao eh hora
		
		lb a0, pitch(t0)
		lw a1, duration(t0)
		lb a2, instrument(t0)
		lb a3, volume(t0)
		li a7, 31
		ecall
		
		addi t0, t0, tamanho_struct_nota
		sw t0, TRACK3_POINTER, t1	# vai pra proxima nota no arquivo
		
		j P_TA1_TRACK3			# checa se hah alguma nota que deveria tocar simultaneamente
		
P_TA1_TRACK3_FIM1:	
		lw t0, TRACK3_LOOP
		beqz t0, P_TA1_TRACK3_FIM1_CONT
		# se o loop estiver ligado, reinicia tudo
		
		lw t0, TRACK3_INICIO_POINTER
		sw t0, TRACK3_POINTER, t1	# coloca o ponteiro de nota de volta no comeco
		csrr t0, time
		sw t0, TRACK3_TIMESTAMP, t1	# reinicia a timestamp da track (pra ela tocar de novo)
		j P_TA1_TRACK3_FIM2		# continua com o resto do proc
		
P_TA1_TRACK3_FIM1_CONT:
		sw zero, TRACK3_POINTER, t0	# limpa o pointer de reproducao
		sw zero, TRACK3_ATIVO, t0	# termina a reproducao
P_TA1_TRACK3_FIM2:
       		ret
       
       
P_TA1_FIM:
		lw ra, (sp)
		addi sp, sp, 4
		ret
       
       
       
