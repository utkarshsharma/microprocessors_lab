ORG 0H
LJMP setup


ORG 400H
setup:
	MOV SCON, #0C0H  	;serial port mode 3, receiver enabled
	MOV TMOD, #21H      ;configure timer 1 in auto-reload mode for 1200 baud  ; TIMER 0 AS 16 BIT COUNTER
	MOV TH1, #0CCH      ;reload value for 1200 baud	
	MOV P1,#00H         ;USE LED

	SETB EA
	SETB ES      		;ENABLE SERIAL INTERRUPT
	CLR ET1       		;DISABLE TIMER1 INTERRUPT
	MOV R6,#00H         ;GLOBAL COUNTER
	SETB TR1            ;start timer
	SETB TI
	
MAIN:
	CJNE R6, #50, MAIN        
		MOV R6, #00H
	CPL P1.7       		;TOGGLE LED
	LJMP MAIN
	
	
ORG 200H	
tenmsdelay:      		;10 MS DELAY	
	MOV R7, #10
LOOP:
		MOV TH0, #0FFH
		MOV TL0, #40H
		SETB TR0
		comeagain: JNB TF0,comeagain
		CLR TR0
		CLR TF0
		DJNZ R7, LOOP	
RET

ORG 0023H
SERIAL_ISR:
	INC R6  
	ACALL tenmsdelay
	CLR TI
	MOV A, #'A'
	ADDC A, #00H
	MOV C, PSW.0
	MOV TB8, C          ;MOVE PARITY BIT TO TB8
	MOV SBUF, A         ;START SENDING CHARACTER   
RETI	

END