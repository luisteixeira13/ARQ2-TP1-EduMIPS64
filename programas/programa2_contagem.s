; Programa 2 - Conta quantas vezes um valor aparece no vetor
; Entrada: vetor = [4,7,4,2,4,9], alvo = 4, N = 6
; Saida: resultado = 3 na memoria e em R6
; R1: endereco atual; R2: elementos restantes; R3: alvo
; R4: endereco auxiliar; R5: elemento lido; R6: contador
.data
vetor: .word 4, 7, 4, 2, 4, 9
N: .word 6
alvo: .word 4
resultado: .word 0
.code
DADDI R1, R0, vetor
DADDI R4, R0, N
LD R2, 0(R4)
DADDI R4, R0, alvo
LD R3, 0(R4)
DADDI R6, R0, 0
BEQ R2, R0, Fim
Loop:
LD R5, 0(R1)        ; le o elemento atual
BNE R5, R3, Proximo ; se nao for igual ao alvo, nao conta
DADDI R6, R6, 1
Proximo:
DADDI R1, R1, 8
DADDI R2, R2, -1
BNE R2, R0, Loop
Fim:
DADDI R4, R0, resultado
SD R6, 0(R4)
SYSCALL 0
