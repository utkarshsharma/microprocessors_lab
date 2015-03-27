ORG 00H
LJMP 	MAIN

ORG 100H
MAIN:	MOV R7 , #00H		; R7 STORES SPEED 		
	
		MOV R2 , #00H		; INITIALISING
		SETB	P1.0		; To ready it for input
		SETB	P1.1
		SETB	P1.2
		SETB	P1.3
		MOV A , P1
		ANL A , #00000011B
		MOV B , R2			; OLD VALUE IN R2 MOVED TO B
		MOV R2 , A			; R2 STORES OLD SWITCH INPUT
		SUBB A , B
		ADD A , #02D
		
		CJNE A , #01D , LABX1	; TWO BIT INPUT OF SWITCH IS COMPARED TO ITS PREVIOUS VALUE
		LJMP DECR				
LABX1:	CJNE A , #03D , LABX2	; FOUR POSSIBLE CASES OF CHANGE, AND ONE FOR REMAINING SAME
		LJMP DECR
LABX2:	CJNE A , #00D , LABX3
		LJMP INCR
LABX3:	CJNE A , #04D , LABX4
		LJMP INCR
LABX4:	CJNE A , #02D , LABD1
LABD1:	LJMP RUN


DECR:	CJNE R7 , #-7D , DECI	; TO CHECK SATURATION
		LJMP RUN
DECI:	DEC R7					; DECREMENT SPEED HERE/ OR INCREASE IN NEGATIVE DIRECTION 
		LJMP RUN

INCR:	CJNE R7 , #7D , INCRI	;  TO CHECK SATURATION
		LJMP RUN
INCRI:	INC R7					; INCREASE SPEED HERE/ OR DECREASE IN NEGATIVE DIRECTION 
		LJMP RUN
		
RUN: 	CJNE R7 , #0D , LAZ		; CHECK FOR ZERO SPEED
		LJMP ZERO
LAZ:	CLR C
		MOV A , #0B0H			 
		SUBB A , R7				; NEGATIVE OR 2S COMPELEMENT IS GRATER THAN 0B0H,
		JC RUN_BACK				; HENCE C WILL BE ACTIVATED IF R7 IS NEGATIVE
		LJMP RUN_FORW

RUN_BACK:
		MOV		P1,		#8FH
		LCALL	DELAYB
		MOV		P1,		#4FH
		LCALL	DELAYB
		MOV		P1,		#2FH
		LCALL	DELAYB
		MOV 	P1,		#1FH
		LCALL	DELAYB
		LCALL 	MAINC1
		LJMP	RUN_BACK
		
RUN_FORW:
		MOV		P1,		#1FH
		LCALL	DELAYF
		MOV		P1,		#2FH
		LCALL	DELAYF
		MOV		P1,		#4FH
		LCALL	DELAYF
		MOV 	P1,		#8FH
		LCALL	DELAYF
		LCALL	MAINC1
		LJMP	RUN_FORW

ZERO:	SETB	P1.4		
		SETB	P1.5
		SETB	P1.6
		SETB	P1.7
		LCALL MAINC1
		LJMP ZERO

DELAYB:	
		MOV A , R7
		ADD A , #08D
		MOV B , #03D
		MUL AB
		MOV R5 , A
		LAX1:	LCALL DELAY	
		DJNZ R5 , LAX1
		RET

DELAYF:
		MOV A , R7 			
		MOV R5 , A
		MOV A , #08D
		SUBB A , R5
		MOV B , #03D
		MUL AB
		MOV R5 , A
		LAX2:	LCALL DELAY	
		DJNZ R5 , LAX2
		RET

DELAY:	MOV TH0 , #000H			; DELAY FUNCTION GENERATES 33 MILISEC OF DELAY 
		MOV TL0 , #000H
		MOV TMOD, #01H
		SETB TR0
		TLOOP: JNB TF0,TLOOP
		CLR TR0
		CLR TF0
		RET

MAINC1:	SETB	P1.0		; To ready it for input
		SETB	P1.1
		SETB	P1.2
		SETB	P1.3
		MOV A , P1
		ANL A , #00000011B
		MOV B , R2			; OLD VALUE IN R2 MOVED TO B
		MOV R2 , A			; R2 STORES OLD SWITCH INPUT
		SUBB A , B
		ADD A , #02D
		
		CJNE A , #01D , LABZ1
		LJMP DECR
LABZ1:	CJNE A , #03D , LABZ2
		LJMP DECR
LABZ2:	CJNE A , #00D , LABZ3
		LJMP INCR
LABZ3:	CJNE A , #04D , LABZ4
		LJMP INCR
LABZ4:	CJNE A , #02D , LABS1
LABS1:	RET

END