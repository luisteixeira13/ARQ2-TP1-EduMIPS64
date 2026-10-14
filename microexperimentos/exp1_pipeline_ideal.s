; Experimento 1 - Pipeline sem dependencias
; Quatro instrucoes independentes: cada uma escreve em um registrador diferente.
.code
DADDI R1, R0, 10
DADDI R2, R0, 20
DADDI R3, R0, 30
DADDI R4, R0, 40
SYSCALL 0
