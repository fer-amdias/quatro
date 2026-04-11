#################################################################
# PROC_REDIMENSIONAR_STRUCT_TILE				#
# Redimensiona os tiles de um buffer de tilemap para conterem a #
# quantidade de bytes desejados cada um.                        #
# 							     	#
# ARGUMENTOS:						     	#
#	A0 : Endereco do tilemap                                #
#	A1 : Tamanho original de cada tile                      #
#	A2 : Novo tamanho de cada tile                          #	
# RETORNOS:                                                  	#
#       (nenhum)                                                #
#################################################################

# Prefixo interno: P_RS1_

.data

RS1_TEMP_TILEMAP_BUFFER: .space TAMANHO_MAX_TILEMAP
RS1_ERRO_MSG:            .string "TILEMAP_REDIMENSIONADO_GRANDE_DEMAIS"

.text

PROC_REDIMENSIONAR_STRUCT_TILE:
        addi sp, sp, -4
        sw ra, (sp)

        # pega as dimensoes do mapa
        lw t0, (a0)
        lw t1, 4(a0)

        # salva em t0 a quantidade de tiles
        mul t0, t1, t0

        # garante que o novo tilemap nao vai dar buffer overflow
        mul t5, t0, a2
        li t6, TAMANHO_MAX_TILEMAP
        blt t6, t5, P_RS1_GRANDE_DEMAIS

        

        # salva em 
        addi t5, a0, 8  

        # salva em t6 o endereco atual do tilemap
        la t6, RS1_TEMP_TILEMAP_BUFFER

        # t0 = contador de tiles restantes
        # t5 = endereco atual do buffer de tilemap origem
        # t6 = endereco atual do buffer de tilemap temporario

P_RS1_LOOP:
        mv t1, a1                       # contador de quantos bytes faltam copiar (por tile)
        mv t2, a2                       # contador de quantos bytes faltam ser escritos (por tile)
        mv t3, t5                       # endereco inicial do tile
P_RS1_COPIAR_TILE_LOOP:
        blez t2, P_RS1_LOOP_CONT        # se ja escrevemos todos os bytes que deveriamos, paramos de copiar
        blez t1, P_RS1_TILE_LOOP_SALVAR_ZERO # se ainda falta algum byte para escrever, mas ja chegamos no final do tile original, coloca 0 no restante

        # transfere o tile
        lb t4, (t3)
        sb t4, (t6)
        addi t1, t1, -1                 # reduz o contador
        addi t2, t2, -1                 # reduz o contador
        
        # avanca para o proximo byte
        addi t3, t3, 1
        addi t6, t6, 1
        j P_RS1_COPIAR_TILE_LOOP        # continua o loop
P_RS1_TILE_LOOP_SALVAR_ZERO:
        sb zero, (t6)                   # coloca 0 no byte do buffer atual
        addi t6, t6, 1                  # avanca o endereco
        addi t2, t2, -1                 # reduz o contador
        bgtz t2, P_RS1_TILE_LOOP_SALVAR_ZERO # se o contador NAO chegou em 0, continua
P_RS1_LOOP_CONT:
        add t5, t5, a1                  # pula a quantidade original de tiles
        addi t0, t0, -1                 # decresce em 1 tile a quantidade que falta copiar
        bgtz t0, P_RS1_LOOP             # continua se ainda hah tiles para copiar
P_RS1_LOOP_FIM:

        mv a1, a0                       # destino (tilemap original)
        addi a1, a1, 8                  # apos as 2 words de dimensao
        la a0, RS1_TEMP_TILEMAP_BUFFER  # origem  (tilemap temporario)
        li a2, TAMANHO_MAX_TILEMAP      
        srli a2, a2, 2                  # copia todo o tilemap (qtd de bytes / 4 == qtd de words)
        jal PROC_COPIAR_BUFFER_WORD

        lw ra, (sp)
        addi sp, sp, 4
        ret                             # retorna

P_RS1_GRANDE_DEMAIS:

        la a0, RS1_ERRO_MSG
        j ROTINA_ERRO_FATAL               # j, nao jal, jah que o caminho para a ROTINA_ERRO_FATAL eh sempre so de ida e terminal.