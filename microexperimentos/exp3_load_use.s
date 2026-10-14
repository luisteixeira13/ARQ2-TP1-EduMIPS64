; Experimento 3 - Dependencia imediata apos load
; LD produz R1, imediatamente consumido por DADD.
.data
valor: .word 7
.code
DADDI R2, R0, valor
LD    R1, 0(R2)
DADD  R3, R1, R4
SYSCALL 0
