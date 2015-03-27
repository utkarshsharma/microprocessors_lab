;---------------------------------------------------------------------------------
;TITLE  : SUB-ROUTINE FOR DISPLAY OF CHARACTER ON LCD (WITH LCD_READY)
;AUTHOR : AKASH SUBHASH PACHARNE (WADHWANI ELECTRONICS LAB)
;*NOTE* : STUDENTS SHOULD GO THROUGH "LCD control made easy" DOCUMENT POSTED ON 
;         MOODLE BEFORE USING THIS SUB-ROUTINE
;---------------------------------------------------------------------------------

;---------------------------------------------------------------------------------
; EQUATE: (Assembler Directive)
; Usage: symbol EQU expression
; Description:	
; EQU statement creates a new symbol named symbol with the value of the expression
;----------------------------------------------------------------------------------
RS EQU P0.0
RW EQU P0.1
EN EQU P0.2
;---------------------------------------------------------------------------------
; ORG: (Assembler Directive)
; Usage: ORG expression
; Description: ORG directive changes the assembler's location counter to the value in 
; the expression. ORG defines where your program is to be located in the various sections
; of ROM. ***NOTE: Using ORG, it is possible to overwrite existing code or data.
;----------------------------------------------------------------------------------
ORG 00H
LJMP MAIN

ORG 50H

DELAY: 	
MOV R1, #0FFH
MOV R2, #0FFH
L1: 
NOP 
DJNZ R1, L1
DJNZ R2, L1
RET

CMD_WRITE:  
ACALL LCD_READY
MOV P2, A
CLR RS
CLR RW
SETB EN
;LCALL DELAY 
CLR EN
RET

DATA_WRITE: 
ACALL LCD_READY
MOV P2, A
SETB RS
CLR RW
SETB EN
;LCALL DELAY  ;WILL JUST HELP US SEE CHARACTERS BEING DISPLAYED ONE BY ONE. 
              ;ALSO, IT MAY ELIMINATE THE NEED FOR LCD_READY/BUSY CHECK!
			  ;BUT IT IS RECOMMENDED TO ALWAYS CHECK FOR LCD_BUSY.
			  ;UNCOMMENT THE CALL TO DELAY ROUTINE IF U WANT TO SEE INDIVIDUAL CHAR
			  ;BEING WRITTEN SLOWLY ON LCD
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

;-----------------------------------------------------------------------------------------------
;LCD CHAR DISPLAY SUB-ROUTINE ENDS HERE. THE MAIN DEMONSTRATES THE USAGE OF THE SUB-ROUTINE
;-----------------------------------------------------------------------------------------------

ORG 100H
MAIN:  

LCALL INIT_LCD  ;INIT_LCD SUB-ROUTINE TO CONFIGURE LCD BEFORE USE

;-------------------------------------------------------------------------------------------------
;DATA CAN BE DISPLAYED ON LCD BY PLACING IT IN ACC AND CALLING THE SUB-ROUTINE "DATA_WRITE"
;-------------------------------------------------------------------------------------------------
;MOV R1, #030H
;init:
;MOV @R1, #023h
;inc R1
;cjne R1, #040h, init

MOV R1, #0e0H
init:
MOV @R1, #045h
inc R1
cjne R1, #0f0h, init

readagain:

MOV A,#01H			;clear screen
LCALL CMD_WRITE
MOV A,#80H
LCALL CMD_WRITE

MOV P1,#00FH		;clearing first 4 bits in advance to make last 4 bits of memory location 0
;LCALL delay1
MOV A,P1
SWAP A
MOV R0,A
LCALL delay5
MOV P1,#00FH
;LCALL delay1
MOV A,P1
SWAP A
SUBB A,R0			; check if both values read are equal
CJNE A,#000H,readagain

LCALL display8bytes;subroutine to display 8 bytes
LCALL delay5
MOV A,#01H
LCALL CMD_WRITE
MOV A,#80H
LCALL CMD_WRITE

LCALL display8bytes;next 8 bytes
LCALL delay5

ljmp readagain


SJMP WAIT

display8bytes:
MOV R7, #002H
line2:
MOV R6,#004H	; for 4 bytes
comeagain:
MOV A,@R0
LCALL convertandwrite
MOV A,#' '
LCALL DATA_WRITE
INC R0
DJNZ R6,comeagain	;for 4 bytes
MOV A,#0C0H			;to next line on lcd
LCALL CMD_WRITE
DJNZ R7, line2
ret

convertandwrite:
MOV R5,A
ANL A,#00fh		;taking only the last 4 bits
MOV R3,A

MOV A,R5
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
MOV A,R2		;displaying first nibble
LCALL DATA_WRITE
MOV A, R1		;displaying second nibble
LCALL DATA_WRITE
ret


WAIT: SJMP WAIT ;KEEP WAITING HERE ONCE TASK DONE
sjmp fart

delay5:
mov r5,#045h
del:
LCALL delay1
djnz r5, del
ret

delay1:
MOV R6, #0FFH
MOV R7, #0FFH
c1: DJNZ r7,c1
MOV r7,#0FFh
DJNZ r6,c1
ret

fart:
END 