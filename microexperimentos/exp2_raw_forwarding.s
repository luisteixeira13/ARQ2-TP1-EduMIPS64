; Experimento 2 - Cadeia RAW
; Compare esta mesma sequencia com Forwarding OFF e ON.
.code
DADDI R1, R0, 10
DADD  R2, R1, R0
DADD  R3, R2, R0
DADD  R4, R3, R0
SYSCALL 0
