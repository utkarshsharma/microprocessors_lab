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
LCALL DELAY 
CLR EN
RET



DATA_WRITE: 
ACALL LCD_READY
MOV P2, A
SETB RS
CLR RW
SETB EN
LCALL DELAY  ;WILL JUST HELP US SEE CHARACTERS BEING DISPLAYED ONE BY ONE. 
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


;---------------------------------------------------------------------------------------------
;------SPECIFY THE STRING IN THIS PART------------------------------------------------------------
MOV R0,#90H
MOV @R0,#' '
INC R0
MOV @R0,#' '
INC R0
MOV @R0,#'E'
INC R0
MOV @R0,#'E'
INC R0
MOV @R0,#' '
INC R0
MOV @R0,#'3'
INC R0
MOV @R0,#'3'
INC R0
MOV @R0,#'7'
INC R0
MOV @R0,#'-'
INC R0
MOV @R0,#' '
INC R0
MOV @R0,#'L'
INC R0
MOV @R0,#'a'
INC R0
MOV @R0,#'b'
INC R0
MOV @R0,#'2'
INC R0
MOV @R0,#' '
INC R0
MOV @R0,#' '


INC R0
MOV @R0,#' '
INC R0
MOV @R0,#'U'
INC R0
MOV @R0,#'T'
INC R0
MOV @R0,#'K'
INC R0
MOV @R0,#'A'
INC R0
MOV @R0,#'R'
INC R0
MOV @R0,#'S'
INC R0
MOV @R0,#'H'
INC R0
MOV @R0,#' '
INC R0
MOV @R0,#'S'
INC R0
MOV @R0,#'H'
INC R0
MOV @R0,#'A'
INC R0
MOV @R0,#'R'
INC R0
MOV @R0,#'M'
INC R0
MOV @R0,#'A'
INC R0
MOV @R0,#' '
MOV R0,#90H


LINE1:;LOOP FOR DISPLAY IN FIRST LINE OF LCD
MOV 0E0H,@R0
LCALL DATA_WRITE
INC R0;MOVE TO NEXT MEMORY LOCATION
CJNE R0,#0A0H,LINE1;CHECK IF 16 BYTES DONE

MOV A,#0C0H ;FOR MOVING TO NEXT LINE
LCALL CMD_WRITE

LINE2:;LOOP FOR DISPLAY IN SECOND LINE OF LCD
MOV 0E0H,@R0
LCALL DATA_WRITE
INC R0
CJNE R0,#0AFH,LINE2;

WAIT: SJMP WAIT ;KEEP WAITING HERE ONCE TASK DONE

END 