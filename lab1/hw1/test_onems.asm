	ORG 00H
	LJMP MAIN

	ORG 100H
MAIN:
	MOV TMOD, #01h
	SETB ET0
	SETB EA
onems:
;MOVING 00 TO TH0 AND TL0
	MOV TH0, #0f5h	
	MOV TL0, #0b5h
	SETB TR0					;START TIMER1. STOPS ONLY WHEN 100ms ARE COMPLETED. THIS GIVES US ONE 100ms LOOP.
onems_done:
	CLR C
	MOV C, TR0
	JNC exit					;condition check for whether 1ms are up
	SJMP  onems_done
exit:
	RET
	
ljmp onems	
	ORG 000BH		
ISR0:
	CLR TR0
	RETI
END