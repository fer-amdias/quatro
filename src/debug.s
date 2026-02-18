#################################################################
# ROTINA_DEBUG           			       	     	#
# Mostra informacoes de debug                                   #
#################################################################

# prefixo_interno: R_D1_ 

.eqv PRINT_INTERVALO 500

.data

        ULTIMO_FRAME_TIMESTAMP: .word 0
        DEBUG_FRASE: .asciz "FPS: "

        PRINT_TIMESTAMP:        .word 0

.text

ROTINA_DEBUG:
        csrr t0, time
        lw t1, ULTIMO_FRAME_TIMESTAMP
        sw t0, ULTIMO_FRAME_TIMESTAMP, t2

        lw t2, PRINT_TIMESTAMP
        sub t2, t0, t2          # t2 = tempo desde PRINT_TIMESTAMP
        li t3, PRINT_INTERVALO
        sub t2, t2, t3          # t2 = tempo desde PRINT_TIMESTAMP - PRINT_INTERVALO
        bltz t2, ROTINA_DEBUG_RET       # se ainda nao se passaram PRINT_INTERVALO milissegundos, nao imprime

        sw t0, PRINT_TIMESTAMP, t2 # salva que printamos

        sub t0, t0, t1  # periodo = ms entre o frame atual e o frame passado

        seqz t3, t0
        add t0, t3, t0 # adiciona 1 se o frame atual e passado ocorreram no mesmo ms

        li t1, 1000     # 1 segundo = 1000 ms
        div t2, t1, t0  # F/S = 1000 * 1/periodo = 1000/periodo

        print(DEBUG_FRASE)
        safe_print_int_ln(t2)

ROTINA_DEBUG_RET:
        ret


