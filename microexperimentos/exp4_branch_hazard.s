; Experimento 4 - Hazard de controle
; O contador executa dez iteracoes; BNE e uma instrucao MIPS64 padrao.
.code
DADDI R1, R0, 10
DADDI R2, R0, 0
Loop:
DADDI R2, R2, 1
DADDI R1, R1, -1
BNE   R1, R0, Loop
SYSCALL 0
