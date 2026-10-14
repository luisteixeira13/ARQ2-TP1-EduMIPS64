; Programa 3 - Multiplicacao de matrizes inteiras de 64 bits
; A: 2x3, B: 3x2, C: 2x2; armazenamento por linhas
; Entrada: A = [[1,2,3],[4,5,6]], B = [[7,8],[9,10],[11,12]]
; Saida: C = [[58,64],[139,154]], gravada na memoria
; R1/R2/R3: bases de A/B/C; R4/R5/R6: indices i/j/k
; R7/R8: enderecos; R9/R10: operandos; R11: produto
; R12: soma de C[i][j]; R14: 2; R15: 3
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
DADDI R5, R0, 0
Coluna:
DADDI R6, R0, 0
DADDI R12, R0, 0
Produto:
DMUL R7, R4, R15  ; indice de A[i][k]: i*3 + k
DADD R7, R7, R6
DSLL R7, R7, 3    ; converte indice em bytes: multiplica por 8
DADD R7, R1, R7
LD R9, 0(R7)
DSLL R8, R6, 1    ; indice de B[k][j]: k*2 + j
DADD R8, R8, R5
DSLL R8, R8, 3
DADD R8, R2, R8
LD R10, 0(R8)
DMUL R11, R9, R10
DADD R12, R12, R11
DADDI R6, R6, 1
BNE R6, R15, Produto
DSLL R7, R4, 1    ; indice de C[i][j]: i*2 + j
DADD R7, R7, R5
DSLL R7, R7, 3
DADD R7, R3, R7
SD R12, 0(R7)
DADDI R5, R5, 1
BNE R5, R14, Coluna
DADDI R4, R4, 1
BNE R4, R14, Linha
SYSCALL 0
