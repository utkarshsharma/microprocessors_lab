ORG 00H
	LJMP setup
	
ORG 	0100H

setup:	
	MOV	TMOD,	#015H		; 16 bit timer mode for T1 and 16 bit counter mode for T0
	MOV	TH0,	#000H
	MOV	TL0,	#000H
	SETB EA 				; To enable interrupts
	SETB ET1
	
	SETB P3.4				;Configure T0 as a counter
	SETB TR0				;Start Counter
	MOV	R3, #031D			;Timer1 Interrupt has to be called this many times to make 1 second
	MOV	TH1, #000H
	MOV	TL1, #000H
	SETB TR1

MAIN:
	MOV P1, #08FH
	
	MOV A, P1				;Reading from the Switches
	ANL A, #0FH
	MOV R2, A				;R2-->Time for which LED should be ON
	SETB P3.0				;To DC Motor

	MOV A, #14h
	SUBB A, R2
	SETB P3.0
	MOV R1, A				;R1-->Time for which LED should be OFF


motoron:
	LCALL onems
	DJNZ R2, motoron

	CLR P3.0
		
motoroff:	
	LCALL onems
	DJNZ R1, motoroff	
	
	
	MOV R4, #0ffH
	lcall onems
	
	LJMP MAIN

onems:							;THIS LOOP GENERATES A DELAY OF 1MS
	MOV R6, # 0EAH
	MOV R7, # 004D
notdone:
	DJNZ R6, $
	DJNZ R7, notdone
	RET

ORG 001BH
ISR1:
	CLR		TR1
	CJNE	R3,	 #0000H, keepgoing
	CLR TR0
	MOV A, TL0
	JB ACC.7, sev_to_4
	JB ACC.6, six_to_3
	JB ACC.5, five_to_2
	JB ACC.4, four_to_1
	SWAP A
	sjmp display
four_to_1:
	RL A
five_to_2:
	RL A
six_to_3:
	RL A
sev_to_4:

display:
	MOV P1 , A
	MOV	R3, #031D
	SETB TR0
returni:
	SETB TR1
	RETI
	
keepgoing:
	MOV		TH1 , #00H
	MOV		TL1 , #00H
	DEC		R3
	sjmp returni

END