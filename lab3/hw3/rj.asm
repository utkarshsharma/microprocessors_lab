MOV R0,#81H
MOV R1,#82H

MOV @R0,#0FFH   ;R0 MSB
MOV @R1,#0FFH	;R1 LSB

MOV A,@R0
MOV R3,A			;R3 MSB

MOV A,@R1
MOV R4,A			;R4 LSB

LCALL TWOS_COMPLEMENT


MOV TMOD,#01H
MOV TH0,R3
MOV TL0,R4

SETB P1.4
CLR P1.5
SETB P1.6
CLR P1.7

REPEAT:

CPL P1.4
CPL P1.5
CPL P1.6
CPL P1.7

MOV R3,#42

BACK:
LCALL DELAY
DJNZ R3,BACK

SJMP REPEAT




ORG 2000

DELAY:
SETB TR0
AGAIN: JNB TF0,AGAIN
CLR TR0
CLR TF0
RET


TWOS_COMPLEMENT:   ;INPUT IS R3-MSB,R4-LSB
MOV A,R4
CPL A
CLR C
ADD A,#1
MOV R4,A
MOV A,R3
CPL A 

JC NEXT
MOV R3,A
RET

NEXT:
ADD A,#1
MOV R3,A
RET
END