# EDITOR_REDIMENSIONAR_MODELO
# Redimensiona o mockup de redimensionamento para ter as dimensoes escolhidas.
#
# ARGUMENTOS:
# a0 - diferencial da largura (quanto adicionar/remover ah largura)
# a1 - diferencial da altura (quanto adicionar/remover ah altura)

.eqv MODELO_LARGURA_MINIMA 3
.eqv MODELO_ALTURA_MINIMA 3
.eqv MODELO_LARGURA_MAXIMA 11
.eqv MODELO_ALTURA_MAXIMA 11

EDITOR_REDIMENSIONAR_MODELO:
        addi sp, sp, -4
        sw ra, (sp)

        lb t0, MODELO_DE_REDIMENSIONAMENTO_LARGURA
        add t0, t0, a0          # pega L + dL
        li t2, MODELO_LARGURA_MINIMA
        blt t0, t2, E_RM2_RET   # retorna se L + dL < L minimo
        li t2, MODELO_LARGURA_MAXIMA
        bgt t0, t2, E_RM2_RET   # retorna se L + dL > L maximo
        
        lb t1, MODELO_DE_REDIMENSIONAMENTO_ALTURA
        add t1, t1, a1          # pega H + dH
        li t2, MODELO_ALTURA_MINIMA
        blt t1, t2, E_RM2_RET   # retorna se H + dH < H minimo
        li t2, MODELO_ALTURA_MAXIMA
        bgt t1, t2, E_RM2_RET   # retorna se H + dH > H maximo

        # salva os novos valores
        sb t0, MODELO_DE_REDIMENSIONAMENTO_LARGURA, t2
        sb t1, MODELO_DE_REDIMENSIONAMENTO_ALTURA, t2

E_RM2_RET:
        lw ra, (sp)
        addi sp, sp, 4
        ret