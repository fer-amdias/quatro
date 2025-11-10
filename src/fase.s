#FASE         (1,       0,       ch0_fase1,      ch0,            MENOS_UM,              inimigos,              jogador,     internationale,          powerup,                  morte,           abertura_pergaminho,          ch0_fase1.scroll,      pergaminho,                    1,                       1)
.macro FASE(%fase, %capitulo, %arquivo_mapa, %textura_do_mapa, %tempo_limite, %textura_dos_npcs, %textura_do_jogador, %musica_de_fundo, %audioefeito_de_powerup, %audioefeito_de_morte, %audioefeito_de_pergaminho, %endereco_pergaminho, %textura_do_pergaminho, %mostrar_pergaminho_no_inicio, %modo_saida_livre)
	
	# se a saida estah coberta por um bloco quebravel ou nao
	li t0, %modo_saida_livre
	sw t0, MODO_SAIDA_LIVRE, t1
	
	# se hah pergaminho no inicio
	li t0, %mostrar_pergaminho_no_inicio
	sw t0, PERGAMINHO_NO_INICIO, t1
	
	la a0, %arquivo_mapa
	la a1, %musica_de_fundo
	li a2, %tempo_limite
	li a3, %fase
	li a4, %capitulo
	la a5, %endereco_pergaminho
	la a6, %audioefeito_de_powerup
	la a7, %audioefeito_de_morte
	
	la t0, P_F1_ARGUMENTOS_ADICIONAIS
	
	la t1, %audioefeito_de_pergaminho
	sw t1, 0(t0)
	la t1, %textura_dos_npcs
	sw t1, 4(t0)
	la t1, %textura_do_jogador
	sw t1, 8(t0)
	la t1, %textura_do_mapa
	sw t1, 12(t0)
	la t1, %textura_do_pergaminho
	sw t1, 16(t0)
	

	# se tempo limite < SEM_TEMPO_LIMITE, a2 = 1, senao a2 = 0
	slti a2, a2, SEM_LIMITE_DE_TEMPO		 
	li t0, %tempo_limite
	addi t0, t0, 1			
	mul t0, t0, a2		# multiplica a2 por tempo limite + 1
	addi a2, t0, -1		# tempo_limite = a2 - 1 (tempo_limite se tempo limite < SEM_TEMPO_LIMITE, -1 caso contrario)
	
	jal PROC_FASE
	
.end_macro


#################################################################
# PROC_CAPITULO_0				       	     	#
# Coloca uma bomba na posicao escolhida.            		#
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : Arquivo do mapa da fase				#
#	A1 : Musica de fundo					#
# 	A2 : Tempo limite					#
#	A3 : Numero da fase					#
#	A4 : Numero do capitulo					#
#	A5 : Endereco (na memoria) do pergaminho da fase	#
#		(pode ser omitido se nao houver)		#
#	A6 : Endereco do audioefeito de powerup			#
#	A7 : Endereco do audioefeito de morte			#
#								#
#	P_F1_ARGUMENTOS_ADICIONAIS - AA				#
#	0(AA) : Endereco do audioefeito de pergaminho		#
#	4(AA) : Endereco da textura de npcs			#
#	8(AA) : Endereco da textura do jogador			#
#	12(AA): Textura do mapa da fase				#
#	16(AA): Textura do pergaminho da fase			#
# RETORNOS:                                                  	#
#       A0: Se o jogador estah vivo ou nao			#
#################################################################
.data

	# argumentos adicionais que nao couberam nos registradores de argumento
	PERGAMINHO_NO_INICIO: .word 0
	P_F1_ARGUMENTOS_ADICIONAIS: .space 20
	

.text

.eqv $ARQUIVO_MAPA 		s0
.eqv $MUSICA_DE_FUNDO 		s1
.eqv $TEMPO_LIMITE 		s2
.eqv $FASE 			s3
.eqv $CAPITULO 			s4
.eqv $ENDERECO_PERGAMINHO	s5
.eqv $AUDIOEFEITO_DE_POWERUP	s6
.eqv $AUDIOEFEITO_DE_MORTE	s7
.eqv $AUDIOEFEITO_DE_PERGAMINHO s8
.eqv $TEXTURA_DOS_NPCS	s9
.eqv $TEXTURA_DO_JOGADOR	s10
.eqv $TEXTURA_DO_MAPA		s11
.eqv TEXTURA_PERGAMINHO		16


PROC_FASE:
				addi sp, sp, -52
				sw   s0, 0(sp)
				sw   s1, 4(sp)
				sw   s2, 8(sp)
				sw   s3, 12(sp)
				sw   s4, 16(sp)
				sw   s5, 20(sp)
				sw   s6, 24(sp)
				sw   s7, 28(sp)
				sw   s8, 32(sp)
				sw   s9, 36(sp)
				sw   s10, 40(sp)
				sw   s11, 44(sp)
				sw   ra,  48(sp)
				
				mv $ARQUIVO_MAPA, 		a0			
				mv $MUSICA_DE_FUNDO, 		a1			
				mv $TEMPO_LIMITE, 		a2
				mv $FASE, 			a3
				mv $CAPITULO, 			a4
				mv $ENDERECO_PERGAMINHO, 	a5
				mv $AUDIOEFEITO_DE_POWERUP, 	a6
				mv $AUDIOEFEITO_DE_MORTE, 	a7
				
				la t0, P_F1_ARGUMENTOS_ADICIONAIS
				
				lw $AUDIOEFEITO_DE_PERGAMINHO, 	0(t0)
				lw $TEXTURA_DOS_NPCS,       4(t0)
				lw $TEXTURA_DO_JOGADOR,		8(t0)
				lw $TEXTURA_DO_MAPA,		12(t0)
				
P_F1_FASE_INICIO:			
				sb x0, NPC_2_FUGINDO, t0	

				lw t1, TRACK1_INICIO_POINTER
				bne t1, $MUSICA_DE_FUNDO, P_F1_TOCAR_MUSICA	# se a musica de fundo antiga eh diferente, toca a nova
				
				#senao
				lw t0, TRACK1_ATIVO			
				bnez t0, P_F1_PULAR_MUSICA	# se a track ta ativa, deixa a musica tocando

P_F1_TOCAR_MUSICA: 
		## tocar musica	
		li a0, 1			# modo (adicionar audio)
		mv a1, $MUSICA_DE_FUNDO		# a musica da fase
		li a2, 1			# na track 1
		li a3, 1			# no modo de loop
		jal PROC_TOCAR_AUDIO   

P_F1_PULAR_MUSICA:
		# imprime a fase :)
		mv a0, $ARQUIVO_MAPA
		mv a1, $TEXTURA_DO_MAPA
		mv a2, $TEMPO_LIMITE	
		jal PROC_IMPRIMIR_FASE
		
		### PEGAR LARGURA E ALTURA DO JOGADOR ###
		mv t0, $TEXTURA_DO_JOGADOR
		lw t1, (t0)		
		lw t2, 4(t0)
		
		# corrige a altura do jogador
		li t0, 6
		div t2, t2, t0
		
		# salva as dimensoes do jogador
		sw t1, ALTURA_JOGADOR,  t0
		sw t2, LARGURA_JOGADOR, t0

P_F1_LOOP:	
		li a0, 0x00			# preto
		li a1, 1
		jal PROC_PREENCHER_TELA		# preenche a tela de preto
						
		jal PROC_IMPRIMIR_BUFFER_DE_FASE
		
		li a0, 1			# modo (0 = mover sem checar paredes, 1 = modo mover, 2 = modo posicionar)
		mv a1, $TEXTURA_DO_JOGADOR	# endereco da textura do jogador
		la a2, TILEMAP_BUFFER		# endereco do mapa (nesse caso o buffer mesmo)
		jal PROC_REGISTRAR_MOVIMENTO
		
		mv a0, $TEXTURA_DOS_NPCS
		jal PROC_NPCS_MANAGER	
		
		jal PROC_CHECAR_COLISOES
		# retorna a0 : se o jogador ainda estah vivo
		# 	  a1 : qual tile o jogador estah
		
		# se o jogador nao estah vivo
		beqz a0, P_F1_MORTE			# mata o jogador (claro)
		
		li t0, TILE_POWERUP_1
		beq a1, t0, P_F1_RECEBER_POWERUP_TAMANHO_BOMBA
		
		li t0, TILE_POWERUP_2
		beq a1, t0, P_F1_RECEBER_POWERUP_QTD_BOMBAS
		
		li t0, TILE_PERGAMINHO
		beq a1, t0, P_F1_CHECAR_PERGAMINHO
		
		li t0, 100
		bge a1, t0, P_F1_MORTE		# jogador esteve na explosao
		
		lw t0, PERGAMINHO_NO_INICIO
		bnez t0, P_F1_MOSTRAR_TUTORIAL	# se pergaminho_no_inicio = 1, mostra o pergaminho
		
		li t0, TILE_SAIDA
		beq a1, t0, P_F1_SAIDA_DA_FASE
		
		li t0, TILE_ELEVADOR
		beq a1, t0, P_F1_SAIDA_DA_FASE
		
		j P_F1_LOOP_CONT
		
P_F1_RECEBER_POWERUP_TAMANHO_BOMBA:	

		li a0, 1			# toca
		mv a1, $AUDIOEFEITO_DE_POWERUP	# o efeito de powerup
		li a2, 2			# no track 2
		li a3, 0			# sem loop
		jal PROC_TOCAR_AUDIO  

		li t0, 1
		sb t0, POWERUP_TAMANHO_BOMBA, t1
		sobrescrever_tile_atual_rg(0, $TEXTURA_DO_MAPA)	# marca o tile onde tava o powerup como vazio
		j P_F1_LOOP_CONT
		
P_F1_RECEBER_POWERUP_QTD_BOMBAS:	
		li a0, 1			# toca
		mv a1, $AUDIOEFEITO_DE_POWERUP	# o efeito de powerup
		li a2, 2			# no track 2
		li a3, 0			# sem loop
		jal PROC_TOCAR_AUDIO  

		li t0, 1
		sb t0, POWERUP_QTD_BOMBAS, t1
		sobrescrever_tile_atual_rg(0, $TEXTURA_DO_MAPA)	# marca o tile como vazio
		j P_F1_LOOP_CONT
		
P_F1_SAIDA_DA_FASE: 
		lb t0, CONTADOR_INIMIGOS
		bnez t0, P_F1_LOOP_CONT		# se ainda houver <<inimigos>>, nao deixa o jogador sair
		j P_F1_VITORIA			# se nao houver, vence a fase

P_F1_CHECAR_PERGAMINHO:	
		lb t0, PERGAMINHO_NA_TELA
		bnez t0, P_F1_MOSTRAR_PERGAMINHO
		# toca efeito sonoro de abertura de pergaminho
		li a0, 1
		mv a1, $AUDIOEFEITO_DE_PERGAMINHO
		li a2, 2
		li a3, 0
		jal PROC_TOCAR_AUDIO  
P_F1_MOSTRAR_PERGAMINHO:	
		#	A0 : endereco da textura de pergaminho			
		#	A1 : endereco do texto do pergaminho			
		#	A2 : endereco da textura do mapa	
		la t0, P_F1_ARGUMENTOS_ADICIONAIS		
		lw a0, TEXTURA_PERGAMINHO(t0)
		mv a1, $ENDERECO_PERGAMINHO
		mv a2, $TEXTURA_DO_MAPA
		jal PROC_MOSTRAR_PERGAMINHO
P_F1_LOOP_CONT:
		
		lb t0, PERGAMINHO_NA_TELA
		beqz t0, P_F1_LOOP_CONT2
		
		# se o pergaminho estah na tela, devemos continuar a mostra-lo
		
		la t0, P_F1_ARGUMENTOS_ADICIONAIS
		lw a0, TEXTURA_PERGAMINHO(t0)
		mv a1, $ENDERECO_PERGAMINHO
		mv a2, $TEXTURA_DO_MAPA
		jal PROC_MOSTRAR_PERGAMINHO
		
		j P_F1_LOOP_CONT2
P_F1_MOSTRAR_TUTORIAL:
		la t0, P_F1_ARGUMENTOS_ADICIONAIS
		lw a0, TEXTURA_PERGAMINHO(t0)
		mv a1, $ENDERECO_PERGAMINHO
		mv a2, $TEXTURA_DO_MAPA
		jal PROC_MOSTRAR_PERGAMINHO
		
		lb t0, PERGAMINHO_NA_TELA
		bnez t0, P_F1_LOOP_CONT2

		sw zero, PERGAMINHO_NO_INICIO, t0		# desativa o pergaminho na tela
		sobrescrever_tile_atual_rg(2, $TEXTURA_DO_MAPA)			# desfaz a destruicao do tile atual pelo proc mostrar_pergaminho
		
P_F1_LOOP_CONT2:	

		lw t0, SEGUNDOS_RESTANTES
		bltz $TEMPO_LIMITE, P_F1_LOOP_CONT3	# se nao houver limite de tempo, nao checa ele
		
		bltz t0, P_F1_MORTE			# se houver, mata o jogador se ele chegar a 0 segundos

		atualizar_tempo				# atualiza a contagem de tempo

P_F1_LOOP_CONT3:
		la a0, explosivos
		mv a1, $TEXTURA_DO_MAPA
		mv a2, $ARQUIVO_MAPA
		jal PROC_BOMBA_MANAGER

		mv a0, $CAPITULO
		mv a1, $FASE
		li a2, 0x00FF
		jal PROC_IMPRIMIR_HUD

		jal PROC_DESENHAR
		
		li a0, 0			# soh toca o audio mesmo
		jal PROC_TOCAR_AUDIO
		
		j P_F1_LOOP				# repete o game loop	
P_F1_MORTE:		
		jal PROC_DESENHAR	

		li a0, 1			# modo tocar
		mv a1, $AUDIOEFEITO_DE_MORTE
		li a2, 1		# track 1 pra sobrescrever a musica
		li a3, 0		# sem loop
		jal PROC_TOCAR_AUDIO 
		
		csrr t0, time
		sw t0, MORTE_TIMESTAMP, t1	# salva a timestamp da morte
P_F1_MORTE_LOOP:	
		mv a0, zero			# modo continuar tocando
		jal PROC_TOCAR_AUDIO 
		
		csrr t0, time
		li t1, 5000
		sub t0, t0, t1			# subtrai 5 segundos do tempo atual
		
		lw t1, MORTE_TIMESTAMP
		blt t0, t1, P_F1_MORTE_LOOP		# espera passar 5 segundos para continuar
		
		lb t0, VIDAS_RESTANTES
		addi t0, t0, -1 		# perde uma vida
		beqz t0, P_F1_DERROTA		# se vidas = 0, o jogador perdeu
		addi t0, t0, -1 		# subtrai outra vida para cancelar o ganho de PROC_IMPRIMIR_FASE
		sb t0, VIDAS_RESTANTES, t1	
		
		j P_F1_FASE_INICIO
P_F1_DERROTA:
		li a0, 0
		j P_F1_FIM
P_F1_VITORIA:
		li a0, 1
P_F1_FIM: 
				lw   s0, 0(sp)
				lw   s1, 4(sp)
				lw   s2, 8(sp)
				lw   s3, 12(sp)
				lw   s4, 16(sp)
				lw   s5, 20(sp)
				lw   s6, 24(sp)
				lw   s7, 28(sp)
				lw   s8, 32(sp)
				lw   s9, 36(sp)
				lw   s10, 40(sp)
				lw   s11, 44(sp)	
				lw   ra,  48(sp)
				addi sp, sp, 52
				
				ret
