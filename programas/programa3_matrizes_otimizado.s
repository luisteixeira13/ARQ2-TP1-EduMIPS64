; Programa 3 - Multiplicacao de matrizes (VERSAO OTIMIZADA)
; Entrada: A[2][3], B[3][2]; saida: C[2][2] em ordem por linhas
; Mesmo problema e mesmos dados do programa3_matrizes_original.s
;
; Melhorias:
; - ponteiro da linha de A calculado uma vez por linha
; - ponteiros de A e B avancam em vez de recalcular indices a cada k
; - cursor de C avanca 8 bytes a cada resultado
; - instrucoes independentes separam loads e o consumo dos produtos
;
; R1/R2: bases de A/B; R3: ponteiro do proximo elemento de C
; R4/R5/R6: i/j/k; R7/R8: ponteiros correntes de A/B
; R9/R10: valores carregados; R11: produto; R12: acumulador
; R13: inicio da linha atual de A; R14=2; R15=3
.data
A: .word 1, 2, 3, 4, 5, 6
B: .word 7, 8, 9, 10, 11, 12
C: .space 32
.code
DADDI R1, R0, A
DADDI R2, R0, B
DADDI R3, R0, C
DADDI R14, R0, 2
DADDI R15, R0, 3
DADDI R4, R0, 0
Linha:
DMUL R13, R4, R15     ; calcula (i*3) antes do laco de colunas
DSLL R13, R13, 3      ; transforma indice em deslocamento de bytes
DADD R13, R1, R13     ; inicio da linha A[i][0]
DADDI R5, R0, 0
Coluna:
DADD R7, R13, R0      ; recomeca A[i][0] para cada j
DSLL R8, R5, 3        ; deslocamento j*8 na primeira linha de B
DADD R8, R2, R8      ; comeca em B[0][j]
DADDI R12, R0, 0      ; acumulador de C[i][j]
DADDI R6, R0, 0       ; indice k
Produto:
LD R9, 0(R7)          ; A[i][k]
LD R10, 0(R8)         ; B[k][j]
DADDI R7, R7, 8       ; proxima coluna da mesma linha de A
DADDI R8, R8, 16      ; proxima linha de B: 2 colunas * 8 bytes
DMUL R11, R9, R10     ; calculo do produto
DADDI R6, R6, 1       ; incremento independente do resultado da DMUL
DADD R12, R12, R11    ; acumula o produto
BNE R6, R15, Produto
SD R12, 0(R3)         ; grava C[i][j] no proximo elemento da saida
DADDI R3, R3, 8       ; avanca cursor de C
DADDI R5, R5, 1
BNE R5, R14, Coluna
DADDI R4, R4, 1
BNE R4, R14, Linha
SYSCALL 0
