USING 0

DATA1: DB 1AH, 11H, 24H, 10H, 3CH, 0FH, 61H, 0EH, 93H, 0DH, 0CFH, 0CH, 17H, 0CH, 6AH, 0BH, 0C6H, 0AH, 2BH, 0AH, 99H, 09H, 0FH, 09H, 8DH, 08H, 12H, 08H, 9EH, 07H, 31H, 07H

MOV TMOD,#001h		;16 bit counter mode
SETB P1.7

LCALL read
MOV DPTR, #DATA1

loop:
MOV A,R7
MOVC A, @A+DPTR
MOV R4,A
MOV A, R7
INC A
INC R7
MOVC A, @A+DPTR
MOV R3,A
LCALL twoscomp
sq_wave:
LCALL delay
CPL P1.7
SJMP sq_wave
DEC R7
SJMP loop


read:
PUSH AR0
PUSH ACC
MOV P1,#00FH		;clearing first 4 bits in advance to make last 4 bits of memory location 0
MOV A,P1
MOV R0,A
LCALL delay
MOV A,P1
SUBB A,R0			; check if both values read are equal
CJNE A,#000H,read

;NEXT PART OF CODE DOUBLES THE INDEX READ FROM THE SWITCH
MOV B,#002H
MOV A,R0
MUL AB
MOV R7,A
POP ACC
POP AR0
RET

twoscomp:			;take bit-by-bitcomplement and add 1
PUSH ACC
MOV A,R4			;LSB
CPL A
CLR C
ADD A,#1
MOV R4,A
MOV A,R3			;MSB
CPL A 

JC carry			;if carry from LSB, jump to carry
MOV R3,A			;otherwise, take complement directly
RET

carry:
ADD A,#1			;adding carry 1 to complement
MOV R3,A
POP ACC
RET


delay:
MOV TH0,R3
MOV TL0,R4

SETB TR0
loop1: JNB TF0,loop1
CLR TR0
CLR TF0
RET

END