; Experimento 3 - Load-use com uma instrucao independente entre load e uso
; DADDI R5 pode executar enquanto o dado de R1 e carregado.
.data
valor: .word 7
.code
DADDI R2, R0, valor
LD    R1, 0(R2)
DADDI R5, R0, 100
DADD  R3, R1, R4
SYSCALL 0
