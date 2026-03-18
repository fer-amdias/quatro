# EDITOR_CARREGAR_FASE			       	
# Carrega os metadados em FASE_METADATA para a memória
# ARGUMENTOS:						     	
#	(nenhum)                     
# RETORNOS:                                                  
#       (nenhum)

EDITOR_CARREGAR_METADADOS:
        addi sp, sp, -4
        sw ra, (sp)

        la a0, FASE_TEXTURA
        la a1, TEXTURA_BUFFER
        jal EDITOR_CARREGAR_TEXTURA

        la a0, FASE_TEXTURA_NPCS
        la a1, TEXTURA_NPCS_BUFFER
        jal EDITOR_CARREGAR_TEXTURA

        la a0, FASE_TEXTURA_DE_FUNDO
        la a1, TEXTURA_FUNDO_BUFFER
        jal EDITOR_CARREGAR_TEXTURA

        li a0, 1                        # modo 1: tocar novo audio
        la a1, FASE_AUDIO_SOUNDTRACK    # soundtrack da fase
        li a2, 1                        # track 1, de musica
        li a3, 1                        # COM loop
        jal PROC_TOCAR_AUDIO

        lw ra, (sp)
        addi sp, sp, 4
        ret