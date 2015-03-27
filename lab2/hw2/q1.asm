MOV A, #03h
call convert
sjmp finish
convert:
MOV R0,A
ANL A,#00fh		;taking only the last 4 bits
MOV R3,A

MOV A,R0
ANL A,#0f0h		;taking only the first 4 bits
SWAP A
MOV R4,A

;next part of code is for converting the lower 4 bits to hex
MOV A, R3
MOV B, A
CLR C
SUBB A, #0AH	;to check if letter or number
JC less
MOV A,B
ADD A,#37H		;if it is letter, a to f
MOV R1,A
SJMP out
less: MOV A,B	;if it is number, 0 to 9
ADD A,#30H
MOV r1,A

out:
;next part of code is for converting the upper 4 bits to hex
MOV A, R4
MOV B, A
CLR C
SUBB A, #0AH
JC lessagain
MOV A,B
ADD A,#37H
MOV R2,A
sjmp out1
lessagain: MOV A,B
ADD A,#30H
MOV r2,A

out1:
end