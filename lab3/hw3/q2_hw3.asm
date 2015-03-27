MOV R0,#081h
MOV R1,#082h

MOV @R0,#0ffh   	;MSB
MOV @R1,#0ffh		;LSB

LCALL twoscomp

MOV TH0,@R0
MOV TL0,@R1

MOV TMOD,#001h		;16 bit counter mode

MOV P1,#0f0h

blinky:
MOV A,P1
CPL A
ANL A,#0f0h
MOV P1,A

MOV R2,#01ch

comeagain:
LCALL delay
DJNZ R2,comeagain

SJMP blinky

delay:
SETB TR0
loop: JNB TF0,loop
CLR TR0
CLR TF0
RET

twoscomp:			;take bit-by-bitcomplement and add 1
MOV A,@R1			;LSB
CPL A
CLR C
ADD A,#1
MOV @R1,A
MOV A,@R0			;MSB
CPL A 

JC carry			;if carry from LSB, jump to carry
MOV @R0,A			;otherwise, take complement directly
RET

carry:
ADD A,#1			;adding carry 1 to complement
MOV @R0,A
RET
END