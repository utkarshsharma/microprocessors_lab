	ORG 0000H
	USING 0
	LJMP setup

	ORG 1000H	
setup:
	MOV P1, #0FH			;Initializing
	
MAIN:
	MOV A, P1				;READ
	ANL A, #0FH
	MOV R0, A				;R0-->Time for which LED should be ON
	MOV A, #14h
	SUBB A, R0
	SETB P1.7

on:
	LCALL onems
	DJNZ R0, on

	MOV R1, A				;R1-->Time for which LED should be OFF
	CLR P1.7
		
		
off:	
	LCALL onems
	DJNZ R1, off	

	LJMP MAIN

onems:						;THIS LOOP GENERATES A DELAY OF 1MS
	MOV R6, # 0EAH
	MOV R7, # 004D
notdone:
	DJNZ R6, $
	DJNZ R7, notdone
	RET

END