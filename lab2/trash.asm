LCALL convertandwrite
MOV A, #' '
LCALL DATA_WRITE
MOV A, B
LCALL convert
MOV A, #' '
LCALL DATA_WRITE
MOV A, PSW
LCALL convertandwirte
MOV A, #' '
LCALL DATA_WRITE


convertandwrite:
MOV 71H,A
ANL A,#00ah
MOV 72H,A

MOV A,71H
ANL A,#0a0h
SWAP A
MOV 73H,A

MOV A, 72H
MOV B, A
CLR C
SUBB A, #0AH
JC less
MOV A,B
ADD A,#37H
less: MOV A,B
ADD A,#30H
MOV 74H,A

MOV A, 73H
MOV B, A
CLR C
SUBB A, #0AH
JC lessagain
MOV A,B
ADD A,#37H
lessagain: MOV A,B
ADD A,#30H
MOV 75H,A
MOV A, 74H
LCALL DATA_WRITE
MOV A, 75H
LCALL DATA_WRITE
ret