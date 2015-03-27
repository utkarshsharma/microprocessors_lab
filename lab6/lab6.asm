	ORG 0000H
	LJMP SETUP
	USING 0

	RS EQU P0.0
	RW EQU P0.1
	EN EQU P0.2


;***************************************      RECEIVE PART     **********************************************************************************

	ORG 0023H                ;SERIAL INTERRUPT ADDRESS
SERIAL_ISR:
	JB TI, EXIT
	JNB RI, EXIT
	CJNE R3, #0FH, RECEIVE
	MOV R3, #00H
	MOV A, #080H
	SETB C
	LCALL CMD_WRITE
	
RECEIVE:	
	INC R3  
	MOV A, SBUF; Save this character
	MOV @R1,A
	INC R1
	CLR RI ; clear receive interrupt flag
EXIT:
	RETI

;******************************     INITIAL SETUP      **********************************************************************
ORG 100h
setup:
	LCALL INIT_LCD      ;initialize lcd
	MOV SCON, #050H  	;serial port mode 3, receiver enabled
	MOV TMOD, #21H      ;configure timer 1 in auto-reload mode for 1200 baud  ; TIMER 0 AS 16 BIT COUNTER
	MOV TH1, #0CCH      ;reload value for 1200 baud
	MOV P1,#0FFH        ;USE SWITCHES AS INput

	SETB EA             ;Enable interrupts
	SETB ES      		;ENABLE SERIAL INTERRUPT
	MOV R1, #80H
	MOV R3,#00H         
	SETB TR1            ;start timer
	MOV A, P1
	ANL A, #0FH
	MOV R2, A	
	CLR RI
	CLR TI
	CLR C

;************************************       TRANSMIT  DISPLAY   PART      ******************************************************************************
MAIN:
	MOV A, #0C0H
	LCALL CMD_WRITE

TRANSMIT_DISPLAY:
	PUSH AR0
	MOV R0, #00H
DISPLAY_LOOP1:
	MOV A, R0
	MOV DPTR, #DATASTORE
	MOVC A,@A+DPTR
	LCALL DATA_WRITE
	INC R0
	CJNE R0, #10H, DISPLAY_LOOP1
	POP AR0
	
	
	
;*****************************************      MAIN SWITCH CHECKING PART      ************************************************************************************

READ_SWITCHES:
	MOV P1, #0FFH
	JNC GO_ON
	LJMP RECEIVE_DONE
GO_ON:
	MOV A, P1
	ANL A, #0FH
	MOV R6, #200D
DELAYLOOP:
	LCALL tenmsdelay
	DJNZ R6, DELAYLOOP
	CJNE A, 0X02, CHECK2         ;RECHECKING THE SWITCHES FOR BETTER RELIABILITY
	LJMP READ_SWITCHES
	
CHECK2:
	MOV P1,#0FFH
	MOV R4, A
	MOV A, P1
	ANL A, #0FH
	MOV R6, #200D
DELAYLOOP2:
	LCALL tenmsdelay
	DJNZ R6, DELAYLOOP2
	CJNE A, 0X04, READ_SWITCHES         ;IF DIFFERENT, GO BACK TO CHECK AGAIN





;******************************************       TRANSMIT DATA PART     **********************************************************************************
TRANSMIT:
	CLR TI
	CLR RI
	MOV R2, A
SEND_LOOP:
	PUSH AR0
	MOV R0, #00H
SEND_LOOP1:
	MOV A, R0
	MOV DPTR, #DATASTORE
	MOVC A,@A+DPTR
	MOV SBUF, A
wait: JNB TI, wait
	CLR TI
	INC R0
	CJNE R0, #10H, SEND_LOOP1
	POP AR0
	CLR C
	LJMP READ_SWITCHES





;*********************************    RECEIVE DISPLAY PART    ******************************************************************************************

RECEIVE_DONE:
	MOV A, #80H
	LCALL CMD_WRITE
	MOV R1, #80H
WRITE_RECEIVED:
	MOV A, @R1
	LCALL DATA_WRITE
	INC R1
	CJNE R1, #90H, WRITE_RECEIVED
	MOV R1, #080H
	
	MOV A, #80H
	LCALL CMD_WRITE
	CLR C
	LJMP READ_SWITCHES
	

;******************************************     LCD RELATED CODE    ****************************************************************************
	ORG 2000H

CMD_WRITE:  
	ACALL LCD_READY
	MOV P2, A
	CLR RS
	CLR RW
	SETB EN
	CLR EN
	RET

DATA_WRITE: 
	ACALL LCD_READY
	MOV P2, A
	SETB RS
	CLR RW
	SETB EN
	CLR EN
	RET

INIT_LCD:
	MOV A, #38H     ;2 LINE DISPLAY WITH 5x7 FONT ON AN 8BIT INTERFACE
	LCALL CMD_WRITE
	MOV A, #0EH     ;TURN ON DISPLAY, CURSOR NOT BLINKING
	LCALL CMD_WRITE
	MOV A, #06H     ;INCREMENTING THE CURSOR POSITION
	LCALL CMD_WRITE
	MOV A, #1H      ;CLEAR SCREEN
	LCALL CMD_WRITE
	RET

;FOLLOWING SUB-ROUTINE CHECKS BUSY_FLAG AND WAITS TILL LCD IS READY

LCD_READY:
	MOV P2,#0FFH    ;MAKE P2.7 AS INPUT
	CLR RS          ;SELECT COMMAND REGISTER
	SETB RW         ;TO READ FROM LCD
	CHECK: 	
	CLR EN
	SETB EN
	JB P2.7, CHECK  ;READ BUSY FLAG UNTIL IT BECOMES ZERO
	CLR EN
	RET

;***************************************    DELAY CODE      ***************************************************************************************
	
tenmsdelay:        ; 10 MS DELAY	
	MOV R5, #10
LOOP:
	MOV TH0, #0FFH
	MOV TL0, #40H
	SETB TR0
	comeagain: JNB TF0,comeagain
	CLR TR0
	CLR TF0
	DJNZ R5, LOOP	
	RET


;*******************************************************************************************************************************
	ORG 3000H
DATASTORE:
	DB '1','2','D','0','7','0','0','5','2','U','T','K','A','R','S','H'


END