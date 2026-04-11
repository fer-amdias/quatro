# EDITOR_NOVA_FASE
# cria uma nova fase padrao.

.data

TEXTURA_INICIAL:                        .asciz "../assets/texturas/ch0.bin"
TEXTURA_NPCS_INICIAL:                   .asciz "../assets/texturas/inimigos.bin"
TEXTURA_JOGADOR_INICIAL:                .asciz "../assets/texturas/jogador.bin"
TEXTURA_FUNDO_INICIAL:                  .asciz "../assets/texturas/"
TEXTURA_PERGAMINHO_INICIAL:             .asciz "../assets/texturas/pergaminho.bin"

AUDIO_SOUNDTRACK_INICIAL:               .asciz "../assets/musicas/"
AUDIO_POWERUP_INICIAL:                  .asciz "../assets/audioefeitos/"
AUDIO_MORTE_INICIAL:                    .asciz "../assets/audioefeitos/"
AUDIO_PERGAMINHO_INICIAL:               .asciz "../assets/audioefeitos/"


.text

EDITOR_NOVA_FASE:
        addi sp, sp, -4
        sw ra, (sp)

        # CARREGA OS DADOS PADRAO
        copiar_string(TEXTURA_INICIAL, FASE_TEXTURA)
        copiar_string(TEXTURA_NPCS_INICIAL, FASE_TEXTURA_NPCS)
        copiar_string(TEXTURA_JOGADOR_INICIAL, FASE_TEXTURA_JOGADOR)
        copiar_string(TEXTURA_FUNDO_INICIAL, FASE_TEXTURA_DE_FUNDO)
        copiar_string(TEXTURA_PERGAMINHO_INICIAL, FASE_TEXTURA_PERGAMINHO)
        copiar_string(AUDIO_SOUNDTRACK_INICIAL, FASE_AUDIO_SOUNDTRACK)
        copiar_string(AUDIO_POWERUP_INICIAL, FASE_AUDIO_POWERUP)
        copiar_string(AUDIO_MORTE_INICIAL, FASE_AUDIO_MORTE)
        copiar_string(AUDIO_PERGAMINHO_INICIAL, FASE_AUDIO_PERGAMINHO)

        sw zero, FASE_LIMITE_DE_TEMPO, t1
        sw zero, FASE_PERGAMINHO_NO_INICIO, t1
        sw zero, FASE_SAIDA_LIVRE, t1

        li t0, 2
        sw t0, TAMANHO_STRUCT_TILE, t1

        # remove o texto do pergaminho
        sb zero, FASE_TEXTO_PERGAMINHO, t1

        jal EDITOR_CARREGAR_METADADOS

        mv t0, zero     # t0 sera o nosso contador de bytes alocados

        la t1, FASE_TEMPLATE
        la t2, TILEMAP_BUFFER
        lw t3, (t1)
        sw t3, (t2)
        
        mv t4, t3       # salva uma das dimensoes

        lw t3, 4(t1)
        sw t3, 4(t2)

        mul t4, t4, t3  # pega uma dimensao vezes a outra
        addi t0, t0, 8

        lw t5, TAMANHO_STRUCT_TILE
        mul t4, t4, t5  # ..vezes a quantidade de bytes por tile

        # avanca 8 bytes
        add t1, t1, t0
        add t2, t2, t0
        addi t4, t4, 8

        # t0 contara quantos bytes devemos ir
        # t4 sera o limite de bytes
        # quanto t0 = t4, chegamos no byte final e devemos parar.

E_NF1_LOOP:
        lb t3, (t1)
        sb t3, (t2)
        addi t0, t0, 1          # marca que registramos outro byte
        addi t1, t1, 1          # avanca uma unidade
        addi t2, t2, 1          # avanca uma unidade
        blt t0, t4, E_NF1_LOOP  # continua se t0 < t4
 
E_NF1_RET:
        lw ra, (sp)
        addi sp, sp, 4
        ret
        