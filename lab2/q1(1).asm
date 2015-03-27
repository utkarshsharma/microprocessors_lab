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
MOV A, #01Eh
MOV B, #04Fh
MOV R0, #053h
MOV R1, #02ah
MOV R2, #04dh
MOV R3, #05ch
MOV R4, #025h
MOV R5, #0efh
MOV R6, #073h
MOV R7, #003h

MOV 70H,A			;storing value in registers to memory locations as registers will be used in the code
MOV 72H,R0
MOV 73H,R1
MOV 74H,R2
MOV 75H,R3
MOV 76H,R4
MOV 77H,R5
MOV 78H,R6
MOV 79H,R7
MOV 71H,B
MOV A,#000H
MOV R0, #000H		; is used as counter in LOOP
MOV DPTR, #ABPSW

LOOP:
MOVC A, @A+DPTR
LCALL DATA_WRITE
INC R0
MOV A,R0
CJNE A, #008H, LOOP

MOV A,70H					; value of A was stored in 70H earlier
LCALL convertandwrite
MOV A, #' '
LCALL DATA_WRITE
MOV A, 71H					; value of B was stored in 70H earlier
LCALL convertandwrite
MOV A, #' '
LCALL DATA_WRITE
MOV A, PSW
LCALL convertandwrite

MOV A,#0C0H ;FOR MOVING TO NEXT LINE
LCALL CMD_WRITE

MOV A,#000H
MOV R0, #000H
MOV DPTR, #R012

LOOP1:
MOVC A, @A+DPTR
LCALL DATA_WRITE
INC R0
MOV A,R0
CJNE A, #007H, LOOP1

MOV A,72H					; value of R0 was stored in 70H earlier
LCALL convertandwrite
MOV A, #' '
LCALL DATA_WRITE
MOV A, 73H					; value of R1 was stored in 70H earlier
LCALL convertandwrite
MOV A, #' '
LCALL DATA_WRITE
MOV A, 74H					; value of R2 was stored in 70H earlier
LCALL convertandwrite

mov r0,#045h
delay5:
ACALL delay1
djnz r0, delay5

MOV A, #01H
LCALL CMD_WRITE
MOV A, #80H
LCALL CMD_WRITE


MOV A,#000H
MOV R0, #000H
MOV DPTR, #R345

LOOP2:
MOVC A, @A+DPTR
LCALL DATA_WRITE
INC R0
MOV A,R0
CJNE A, #007H, LOOP2

MOV A,75H				;R3
LCALL convertandwrite
MOV A, #' '
LCALL DATA_WRITE
MOV A, 76H				;R4
LCALL convertandwrite
MOV A, #' '
LCALL DATA_WRITE
MOV A, 77H				;R5
LCALL convertandwrite

MOV A,#0C0H ;FOR MOVING TO NEXT LINE
LCALL CMD_WRITE

MOV A,#000H
MOV R0, #000H
MOV DPTR, #R67SP

LOOP3:
MOVC A, @A+DPTR
LCALL DATA_WRITE
INC R0
MOV A,R0
CJNE A, #008H, LOOP3

MOV A,78H				;R6
LCALL convertandwrite
MOV A, #' '
LCALL DATA_WRITE
MOV A, 79H				;R7
LCALL convertandwrite
MOV A, #' '
LCALL DATA_WRITE
MOV A, SP
LCALL convertandwrite

SJMP WAIT

convertandwrite:
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
MOV A,R2		;displaying first nibble
LCALL DATA_WRITE
MOV A, R1		;displaying second nibble
LCALL DATA_WRITE
ret

WAIT: SJMP WAIT ;KEEP WAITING HERE ONCE TASK DONE
sjmp fart
delay1:
MOV R2, #0FFH
MOV R3, #0FFH
c1: DJNZ r3,c1
MOV r3,#0FFh
DJNZ r2,c1
ret

fart:
ORG 500H
ABPSW:
DB 'ABPSW = '

ORG 600H
R012:
DB 'R012 = '

ORG 700H
R345:
DB 'R345 = '

ORG 800H
R67SP:
DB 'R67SP = '
END 