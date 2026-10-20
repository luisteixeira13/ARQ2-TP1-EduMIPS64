; Experimento de escala: soma de vetores, N = 5
; Baseado no mesmo algoritmo do programa1_soma_vetores.s.
; Esperado: C[i] = A[i] + B[i] = 11*(i+1).
; R1/R2/R3: ponteiros; R4: restantes; R5/R6: entradas
; R7: soma; R8: endereco de N.
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
LD R5, 0(R1)
LD R6, 0(R2)
DADD R7, R5, R6
SD R7, 0(R3)
DADDI R1, R1, 8
DADDI R2, R2, 8
DADDI R3, R3, 8
DADDI R4, R4, -1
BNE R4, R0, Loop
Fim:
SYSCALL 0
