; Experimento de escala: soma de vetores, N = 50
; Baseado no mesmo algoritmo do programa1_soma_vetores.s.
; Esperado: C[i] = A[i] + B[i] = 11*(i+1).
; R1/R2/R3: ponteiros; R4: restantes; R5/R6: entradas
; R7: soma; R8: endereco de N.
.data
A: .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50
B: .word 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200, 210, 220, 230, 240, 250, 260, 270, 280, 290, 300, 310, 320, 330, 340, 350, 360, 370, 380, 390, 400, 410, 420, 430, 440, 450, 460, 470, 480, 490, 500
C: .space 400
N: .word 50
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
