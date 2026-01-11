# EDITOR_NOVA_FASE
# cria uma nova fase padrao.

.data

.text

EDITOR_NOVA_FASE:
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
        ret
        