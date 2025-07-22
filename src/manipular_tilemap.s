#################################################################
# PROC_MANIPULAR_TILEMAP				       	#
# Lida com cada bomba presente na memoria, administrando	#
# countdowns e explosoes.		           		#
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : valor a ser escrito/somado	(ignorado no modo 2)	#
#	A1 : posicao X						#
#	A2 : posicao Y						#
#	A7 : modo 						#
#		( 0 = escrever, 1 = incrementar, 2 = ler)	#	# nao questione a ordem dos modos
# RETORNOS:                                                  	#
#       A0: valor do tile					#
#################################################################

# prefixo interno: P_MT1_

# mds haja arquivo
# ai o vei vai lah e bota 1000 include na main
# vai dar tanta linha no arquivo final que o rars vai infartar
# quem tentar rodar sem o fpgrars vai ter uma surpresa divertida
# (na vdd o que vai dar errado eh o frame rate de <1fps)
# (principalmente se nao der tempo de otimizar essa bagunca)

PROC_MANIPULAR_TILEMAP:

			# sanity check
			# eh essencial fazer isso pro jogo nao crashar quando a explosao sair pra fora do mapa
			
			la t2, POSICOES_MAPA
			lh t0, (t2)				# x do mapa
			lh t1, 2(t2)				# y do mapa
			
			# se x ou y estiverem fora do mapa
			blt a1, t0, P_MT1_SEM_TILE
			blt a2, t1, P_MT1_SEM_TILE
			
			li t2, 320				# largura vga
			sub t0, t2, t0				# x final do mapa = vga - x do mapa
			li t2, 240				# altura vga
			sub t1, t2, t1				# y final do mapa = vga - y do mapa
			
			# se x ou y estiverem fora do mapa
			bgt a1, t0, P_MT1_SEM_TILE
			bgt a2, t1, P_MT1_SEM_TILE
			
			j P_MT1_CONT
			
P_MT1_SEM_TILE:		li t1, -1				# nao existe esse tile rapaz
			j P_MT1_FIM

P_MT1_CONT:

			la t0, TILEMAP_BUFFER			# carrega o buffer
			
			### normaliza a posicao para corresponder ahs linhas e colunas que precisamos acessar
			la t2, POSICOES_MAPA
				
			lhu t3, (t2)				# t3 = pos_mapa_X; 
			lhu t4, 2(t2)				# t4 = pos_mapa_Y;
			
			sub a1, a1, t3				# pos_X -= pos_mapa_X; 
			sub a2, a2, t4				# pos_Y -= pos_mapa_Y;
			
			li t2, TAMANHO_SPRITE
			div a1, a1, t2				# N_coluna = pos_X / TAMANHO_SPRITE
			div a2, a2, t2				# N_linha = pos_Y / TAMANHO_SPRITE
			
			lw t1, 4(t0)				# carrega numero de colunas
			addi t0, t0, 8				# pula bytes de informacao
			
			mul t1, a2, t1				# t1 = idx = N_linha * n de colunas
			add t1, t1, a1				# idx += N_coluna
			
			add t0, t0, t1				# buffer += idx (pula pra posicao desejada)
			
			li t6, 1
			beq a7, t6, P_MT1_INCREMENTAR
			li t6, 2
			beq a7, t6, P_MT1_LER
			
P_MT1_ESCREVER:		sb a0, (t0)
			mv t1, a0
			j P_MT1_FIM
			
P_MT1_INCREMENTAR:	lbu t1, (t0)				# pega o tile
			add t1, t1, a0				# soma a0
	 		sb t1, (t0)				# bota de volta
	 		j P_MT1_FIM

P_MT1_LER:		lbu t1, (t0)				# soh pega o tile msm
P_MT1_FIM:	 	mv a0, t1
			ret
			
# argumentos:
#	a1 = pos X
#	a2 = pos Y
# eh isso mesmo. virtualproc. eh soh uma wrapper pra proc manipular tilemap.
VIRTUALPROC_COLOCAR_BOMBA_EM_TILEMAP:
			addi sp, sp, -4
			sw ra, (sp)

			li a0, 50
			li a7, 1
			jal PROC_MANIPULAR_TILEMAP
			
			lw ra, (sp)
			addi sp, sp, 4
			
			ret
			
			
# argumentos: 
#	a1 = pos X
#	a2 = pos Y
# prefixo interno: P_MT1_VP_ET_
VIRTUALPROC_EXPLODIR_TILE_EM_TILEMAP:
			addi sp, sp, -12
			sw ra, (sp)
			sw a1, 4(sp)
			sw a2, 8(sp)
				
			# le do tilemap
			li a7, 2
			jal PROC_MANIPULAR_TILEMAP
	
			lw a1, 4(sp)			# restaura pos X
			lw a2, 8(sp)			# restaura pos Y
			
			# se jah tem 100 no tile, abortar!!! jah estah explodindo!!!
			li t0, 100
			bge a0, t0, P_MT1_VP_ET_FIM
			
			# se o valor for maior que 50 (BOMBA), adiciona mais 50 (pra completar os 100 :))
			li t0, 50
			bge a0, t0, P_MT1_VP_ET_EXPLODIR_TILE_COM_BOMBA

P_MT1_VP_ET_EXPLODIR:	
			# soma 100 ao tile
			li a0, 100	
			li a7, 1
			jal PROC_MANIPULAR_TILEMAP
			j P_MT1_VP_ET_FIM

P_MT1_VP_ET_EXPLODIR_TILE_COM_BOMBA:
			# soma soh 50 ao tile
			li a0, 50
			li a7, 1
			jal PROC_MANIPULAR_TILEMAP

P_MT1_VP_ET_FIM:	# retorna tudo

			lw ra, (sp)
			# nao precisa restaurar argumentos
			addi sp, sp, 12
			
			ret


# acabei de perceber que eu escrevi um procedimento que eh soh uma versao tilemap de calcular_tile_atual, soh que com write e increment
# po
# n precisava
