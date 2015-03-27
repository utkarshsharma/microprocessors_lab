MOV r0,#81h
MOV r1,#82h
MOV @r0,#0feh
MOV @r1,#0ffh

mov A,@r0
mov r2,A

mov A, @r1
mov r3, A

lcall delay
sjmp fart
delay:INC r2
c1: DJNZ r3,c1
MOV r3,#0FFh
DJNZ r2,c1
ret
fart:
end