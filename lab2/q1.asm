MOV A, #03h
call convert
sjmp finish
convert:
MOV R0,A
ANL A,#00ah
MOV R3,A

MOV A,R0
ANL A,#0a0h
SWAP A
MOV R4,A

MOV A, R3
MOV B, A
CLR C
SUBB A, #0AH
JC less
MOV A,B
ADD A,#37H
less: MOV A,B
ADD A,#30H
MOV r1,A

MOV A, R4
MOV B, A
CLR C
SUBB A, #0AH
JC lessagain
MOV A,B
ADD A,#37H
lessagain: MOV A,B
ADD A,#30H
MOV r2,A
ret

finish:
end