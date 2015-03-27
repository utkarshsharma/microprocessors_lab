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

byte_to_hex:
mov b,a
anl a,#0f0h
swap a
cjne a,#0ah,neq
jmp character

next:
mov 70h,a
mov a,b
anl a,#0fh
cjne a,#0ah,neq1
jmp character1

next1:
mov b,a
mov a,70h
jmp exitlabel


character1:
add a,#37h
jmp next1
ret

neq1:
jc number1
jmp character1
ret

number1:
add a,#30h
jmp next1
ret

neq:
jc numb
jmp character
ret

numb:
add a,#30h
jmp next
ret

character:
add a,#37h
jmp next
ret

exitlabel:
ret


WRITE_BYTE:
LCALL BYTE_TO_HEX
LCALL DATA_WRITE
MOV A,B
LCALL DATA_WRITE
RET


delay5:    ;~5 seconds
	mov r5,#4ch
	lP1:
		mov r6,#0ffh
		lP2:
			mov r7,#0ffh
			djnz r7,$
			djnz r6,lP2
			djnz r5,lP1
ret

WRITE_8:
MOV R
MOV A,@R0
LCALL WRITE_BYTE
MOV A,#' '
LCALL DATA_WRITE

INC R0

MOV A,@R0
LCALL WRITE_BYTE
MOV A,#' '
LCALL DATA_WRITE

INC R0

MOV A,@R0
LCALL WRITE_BYTE
MOV A,#' '
LCALL DATA_WRITE

INC R0

MOV A,@R0
LCALL WRITE_BYTE
MOV A,#' '
LCALL DATA_WRITE

MOV A,#0C0H
LCALL CMD_WRITE
INC R0

MOV A,@R0
LCALL WRITE_BYTE
MOV A,#' '
LCALL DATA_WRITE

INC R0


MOV A,@R0
LCALL WRITE_BYTE
MOV A,#' '
LCALL DATA_WRITE

INC R0

MOV A,@R0
LCALL WRITE_BYTE
MOV A,#' '
LCALL DATA_WRITE

INC R0

MOV A,@R0
LCALL WRITE_BYTE
MOV A,#' '
LCALL DATA_WRITE

INC R0
RET


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

ORG 200H
MAIN:  

LCALL INIT_LCD  ;INIT_LCD SUB-ROUTINE TO CONFIGURE LCD BEFORE USE

;-------------------------------------------------------------------------------------------------
;DATA CAN BE DISPLAYED ON LCD BY PLACING IT IN ACC AND CALLING THE SUB-ROUTINE "DATA_WRITE"
;-------------------------------------------------------------------------------------------------
MOV P1,#0F0H
LCALL DELAY5
MOV A,#01H
LCALL CMD_WRITE
MOV A,#80H
LCALL CMD_WRITE

MOV P1,#0FH
MOV A,P1
SWAP A
MOV R0,A
LCALL DELAY5
MOV P1,#0FH
MOV A,P1
SWAP A
SUBB A,R0
CJNE A,#0H,MAIN

LCALL WRITE_8
LCALL DELAY5
MOV A,#01H
LCALL CMD_WRITE
MOV A,#80H
LCALL CMD_WRITE

LCALL WRITE_8
LCALL DELAY5
MOV A,#01H
LCALL CMD_WRITE
MOV A,#80H
LCALL CMD_WRITE

LJMP MAIN
;WAIT: SJMP WAIT ;KEEP WAITING HERE ONCE TASK DONE

END 