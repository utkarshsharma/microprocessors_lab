MOV r0,#81h
MOV r1,#82h
MOV @r0,#001h
MOV @r1,#002h

mov A,@r0
mov r2,A

mov A, @r1
mov r3, A

INC r2
c1: DJNZ r3,c1
MOV r3,#0FFh
DJNZ r2,c1
end