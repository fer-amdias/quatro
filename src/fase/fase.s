.macro FASE(%fase, %capitulo, %nome_mapa, %label_de_morte)
	la a0, %nome_mapa
	li a1, %fase
	li a2, %capitulo
	jal PROC_FASE
	beqz a0, %label_de_morte	
.end_macro


#################################################################
# PROC_FASE							#
# Carrega uma fase e coloca ela para o jogador.			#
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : Nome do arquivo do mapa da fase			#
#	A1 : Numero da fase					#
#	A2 : Numero do capitulo					#
# RETORNOS:                                                  	#
#       A0: Se o jogador estah vivo ou nao			#
#################################################################
.data

# onde vamos guardar a musica tocando atualmente.
# vamos usar isso para so tocar uma nova musica quando mudarmos de soundtrack
SOUNDTRACK_ATUAL: .space TAMANHO_STRING_METADATA

.text

.eqv $NOME_MAPA 		s0
.eqv $TEMPO_LIMITE 		s1
.eqv $FASE 			s2
.eqv $CAPITULO 			s3
.eqv $ENDERECO_PERGAMINHO	s4


PROC_FASE:
	addi sp, sp, -24
	sw   s0, 0(sp)
	sw   s1, 4(sp)
	sw   s2, 8(sp)
	sw   s3, 12(sp)
	sw   s4, 16(sp)
	sw   ra,  20(sp)
	
	mv $NOME_MAPA, 			a0		
	mv $FASE, 			a1
	mv $CAPITULO, 			a2	
	

P_F1_ADICIONAR_VIDA:
	la t0, VIDAS_RESTANTES
	lb t1, (t0)
	li t2, MAX_VIDAS
	bge t1, t2, P_F1_FASE_INICIO	# se vidas >= MAX_VIDAS, nao incrementa
	addi t1, t1, 1
	sb t1, (t0)
	
P_F1_FASE_INICIO:			
	# carrega a fase, primeiro de tudo
	mv a0, $NOME_MAPA
	jal PROC_CARREGAR_FASE

	# retorna que o jogador "venceu" a fase se ela nao existir
	bltz a0, P_F1_VITORIA

	# pega o texto do pergaminho e salva ele
	la a0, FASE_TEXTO_PERGAMINHO
	jal PROC_OBTER_TRADUCAO
	mv $ENDERECO_PERGAMINHO, a0
	
	# reseta algumas variaveis
	sb zero, FASE_DESLOCAMENTO_X, t0
        sb zero, FASE_DESLOCAMENTO_Y, t0
	sb x0, NPC_2_FUGINDO, t0	

	# carrega o limite de tempo
	lw $TEMPO_LIMITE, SEGUNDOS_RESTANTES

	la t0, FASE_AUDIO_SOUNDTRACK
	la t1, FASE_AUDIO_SOUNDTRACK

	la a0, TRACK1_ARQUIVO
	la a1, FASE_AUDIO_SOUNDTRACK
	jal PROC_COMPARAR_STRINGS

	# se as strings sao iguais, a0 = 0, ent...
	bnez a0, P_F1_TOCAR_MUSICA	# se a musica de fundo antiga eh diferente, toca a nova
	
	#senao
	lw t0, TRACK1_ATIVO			
	bnez t0, P_F1_PULAR_MUSICA	# se a track ta ativa, deixa a musica tocando

P_F1_TOCAR_MUSICA: 
	## tocar musica	
	li a0, 1			# modo (adicionar audio)
	la a1, FASE_AUDIO_SOUNDTRACK	# a musica da fase
	li a2, 1			# na track 1
	li a3, 1			# no modo de loop
	jal PROC_TOCAR_AUDIO   

P_F1_PULAR_MUSICA:

	setar_tempo($TEMPO_LIMITE)	# seta o tempo limite

	la a0, BUFFER_TEXTURA
	jal PROC_IMPRIMIR_TILEMAP_NO_FASE_BUFFER
	
	### PEGAR LARGURA E ALTURA DO JOGADOR ###
	la t0, BUFFER_TEXTURA_JOGADOR
	lw t1, (t0)		
	lw t2, 4(t0)
	
	# corrige a altura do jogador
	li t0, 6
	div t2, t2, t0
	
	# salva as dimensoes do jogador
	sw t1, LARGURA_JOGADOR,  t0
	sw t2, ALTURA_JOGADOR, t0

P_F1_LOOP:	
	lb t0, MODO_DEBUG
	beqz t0, P_F1_SEM_DEBUG
	jal ROTINA_DEBUG

P_F1_SEM_DEBUG:

	# imprime o padrao de fundo
	la a0, BUFFER_TEXTURA_DE_FUNDO
	jal PROC_IMPRIMIR_PADRAO_DE_FUNDO
					
	jal PROC_IMPRIMIR_BUFFER_DE_FASE
	
	li a0, 1			# modo (0 = mover sem checar paredes, 1 = modo mover, 2 = modo posicionar)
	la a1, BUFFER_TEXTURA_JOGADOR	# endereco da textura do jogador

	la a2, TILEMAP_BUFFER		# endereco do mapa (nesse caso o buffer mesmo)
	jal PROC_REGISTRAR_MOVIMENTO

	la a0, BUFFER_TEXTURA_NPCS
	jal PROC_NPCS_MANAGER	

	# efeito de explosao, se houver
	li a0, 1
	jal PROC_EFEITO_EXPLOSAO

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
	
	lw t0, FASE_PERGAMINHO_NO_INICIO
	bnez t0, P_F1_MOSTRAR_TUTORIAL	# se pergaminho_no_inicio = 1, mostra o pergaminho

	li t0, TILE_SAIDA
	beq a1, t0, P_F1_SAIDA_DA_FASE
	
	li t0, TILE_ELEVADOR
	beq a1, t0, P_F1_SAIDA_DA_FASE
	
	j P_F1_LOOP_CONT
	
P_F1_RECEBER_POWERUP_TAMANHO_BOMBA:	

	li a0, 1			# toca
	la a1, FASE_AUDIO_POWERUP	# o efeito de powerup
	li a2, 2			# no track 2
	li a3, 0			# sem loop
	jal PROC_TOCAR_AUDIO  

	li t0, 1
	sb t0, POWERUP_TAMANHO_BOMBA, t1

	j P_F1_LIMPAR_POWERUP
	
P_F1_RECEBER_POWERUP_QTD_BOMBAS:	
	li a0, 1			# toca
	la a1, FASE_AUDIO_POWERUP	# o efeito de powerup
	li a2, 2			# no track 2
	li a3, 0			# sem loop
	jal PROC_TOCAR_AUDIO  

	li t0, 1
	sb t0, POWERUP_QTD_BOMBAS, t1

P_F1_LIMPAR_POWERUP:
	
	# ARGUMENTOS DE PROC_MANIPULAR_TILEMAP
	li a0, 0		# coloca tile VAZIO (0)
	lhu a1, JOGADOR_X	# onde o jogador estah (x)
	lhu a2, JOGADOR_Y	# onde o jogador estah (y)
	li a7, 0		# modo [sobr]escrever

	# corrige a posicao para ser igual ah checagem em PROC_CHECAR_COLISOES
	lw t0, ALTURA_JOGADOR	
	srli t0, t0, 1		# divide por 2
	lw t1, LARGURA_JOGADOR
	srli t1, t1, 1		# divide por 2	
	addi t1, t1, -1		# fator corretivo
	add a1, a1, t1		# centraliza
	add a2, a2, t0		# centraliza

	# guarda a posicao corrigida
	addi sp, sp, -8
	sw a1, (sp)
	sw a2, 4(sp)
	jal PROC_MANIPULAR_TILEMAP

	# ARGUMENTOS DE PROC_IMPRIMIR_TEXTURA (precisamos apagar o tile)
	lw a1, (sp)			# x
	lw a2, 4(sp)			# y
	li a3, TAMANHO_SPRITE		# dimensoes
	li a4, TAMANHO_SPRITE		# dimensoes
	li a7, 1			# modo imprimir na fase buffer
	# correcao

	addi sp, sp, 8 # joga fora o espaco reservado que nao vamos mais precisar
	
	la a0, BUFFER_TEXTURA		# carrega a textura
	addi a0, a0, 8			# pula words de informacao
	
	normalizar_posicao(a1, a2)
	
	jal PROC_IMPRIMIR_TEXTURA

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
	la a1, FASE_AUDIO_PERGAMINHO
	li a2, 2
	li a3, 0
	jal PROC_TOCAR_AUDIO  
P_F1_MOSTRAR_PERGAMINHO:	
	#	A0 : endereco da textura de pergaminho			
	#	A1 : endereco do texto do pergaminho			
	#	A2 : endereco da textura do mapa	
	la a0, BUFFER_TEXTURA_PERGAMINHO
	mv a1, $ENDERECO_PERGAMINHO
	la a2, BUFFER_TEXTURA
	jal PROC_MOSTRAR_PERGAMINHO
P_F1_LOOP_CONT:
	lb t0, PERGAMINHO_NA_TELA
	beqz t0, P_F1_LOOP_CONT2
	
	# se o pergaminho estah na tela, devemos continuar a mostra-lo
	
	la a0, BUFFER_TEXTURA_PERGAMINHO
	mv a1, $ENDERECO_PERGAMINHO
	la a2, BUFFER_TEXTURA
	jal PROC_MOSTRAR_PERGAMINHO
	
	j P_F1_LOOP_CONT2
P_F1_MOSTRAR_TUTORIAL:
	la a0, BUFFER_TEXTURA_PERGAMINHO
	mv a1, $ENDERECO_PERGAMINHO
	la a2, BUFFER_TEXTURA
	jal PROC_MOSTRAR_PERGAMINHO
	
	lb t0, PERGAMINHO_NA_TELA
	bnez t0, P_F1_LOOP_CONT2

	sw zero, FASE_PERGAMINHO_NO_INICIO, t0		# desativa o pergaminho na tela
	sobrescrever_tile_atual(2, BUFFER_TEXTURA)	# desfaz a destruicao do tile atual pelo proc mostrar_pergaminho
	
P_F1_LOOP_CONT2:	
	lw t0, SEGUNDOS_RESTANTES
	bltz $TEMPO_LIMITE, P_F1_LOOP_CONT3	# se nao houver limite de tempo, nao checa ele
	
	bltz t0, P_F1_MORTE			# se houver, mata o jogador se ele chegar a 0 segundos

	atualizar_tempo				# atualiza a contagem de tempo

P_F1_LOOP_CONT3:
	la a0, explosivos
	la a1, BUFFER_TEXTURA
	la a2, MAPA_ORIGINAL_BUFFER
	jal PROC_BOMBA_MANAGER

	mv a0, $CAPITULO
	mv a1, $FASE
	li a2, 0x00FF
	jal PROC_IMPRIMIR_HUD

	lb t0, GRAYSCALE
	beqz t0, P_F1_SEM_GRAYSCALE
	jal SHADER_GRAYSCALE

P_F1_SEM_GRAYSCALE:

	jal PROC_DESENHAR
	
	li a0, 0			# soh toca o audio mesmo
	jal PROC_TOCAR_AUDIO
	
	j P_F1_LOOP				# repete o game loop	
P_F1_MORTE:		
	jal SHADER_GRAYSCALE
	jal PROC_DESENHAR	

	li a0, 1			# modo tocar
	la a1, FASE_AUDIO_MORTE
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
	lw   ra,  20(sp)
	addi sp, sp, 24
	
	ret
