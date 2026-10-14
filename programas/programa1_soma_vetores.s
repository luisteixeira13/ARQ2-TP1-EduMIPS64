; Programa 1 - Soma de dois vetores inteiros de 64 bits
; Entrada: A = [1,2,3,4,5], B = [10,20,30,40,50], N = 5
; Saida: C = [11,22,33,44,55], gravada na memoria
; R1/R2/R3: enderecos atuais de A/B/C; R4: elementos restantes
; R5/R6: valores lidos; R7: soma; R8: endereco de N
.data
A: .word 1, 2, 3, 4, 5
B: .word 10, 20, 30, 40, 50
C: .space 40
N: .word 5
.code
DADDI R1, R0, A
DADDI R2, R0, B
DADDI R3, R0, C
DADDI R8, R0, N
LD R4, 0(R8)
BEQ R4, R0, Fim
Loop:
LD R5, 0(R1)       ; le A[i]
LD R6, 0(R2)       ; le B[i]
DADD R7, R5, R6    ; calcula A[i] + B[i]
SD R7, 0(R3)       ; grava C[i]
DADDI R1, R1, 8    ; proximo elemento de 64 bits
DADDI R2, R2, 8
DADDI R3, R3, 8
DADDI R4, R4, -1
BNE R4, R0, Loop
Fim:
SYSCALL 0
