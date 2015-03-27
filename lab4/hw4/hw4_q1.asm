	ORG 0000H
	USING 0
	LJMP setup

	ORG 1000H	
setup:
	MOV TMOD, #001h
	SETB ET0			;ENABLE INTERRUPTS FOR T1 AND T0
	SETB EA

reset:
	MOV R1, #001h 		;R1 is dedicated to lighting LEDs. But LEDs are the upper 4 bits. We'll swap this later.
	
MAIN:
	MOV R0, P1			;Switches being read here
	MOV A, R0			;Check if we have to terminate
	ANL A,#0fh
	JZ terminate
	MOV R0,A			;R0 now has the value on switch
	
LEDs:
	MOV A, R1
	SWAP A				;LEDs are higher 4 bits of P1
	MOV P1, A
	MOV B, #002h
	MOV A, R1
	MUL AB				;Next input is always double of previous time
	MOV R1, A			;R1 being set for the next turn 
		
foursteps:	
	LCALL hundredms
	DJNZ R0, foursteps	;Delay = (value on switch)*100ms
	
	CJNE R1, #010h,MAIN ;Check if LEDs have completed their cycle
	LJMP reset



	ORG 1500H
hundredms:
	PUSH AR1
	PUSH AR2
;MOVING 00 TO TH0 AND TL0
	MOV TH0, #00h	
	MOV TL0, #00h

	SETB TR0					;START TIMER1. STOPS ONLY WHEN 100ms ARE COMPLETED. THIS GIVES US ONE 100ms LOOP.
	MOV R2, #04h					;NO. OF TIMES WE HAVE TO RUN T0 FROM 00 TO FE FOR 100ms
set_t1_again:
	DJNZ R2, t1loop					;CHECKING IF 100ms ARE DONE
	sjmp hundms_done
t1loop:
;RESET TH0 AND TL0 if 100ms NOT UP
	MOV TH0, #00h
	MOV TL0, #00h
;CHECK TH0 AND STOP IT FROM OVERFLOWING BECAUSE 100ms ARE NOT UP
check_th1:
	MOV R1, TH0
	CJNE R1, #0feh, check_th1
	SJMP set_t1_again
;NOW 100ms ALMOST DONE. WAIT FOR INTERRUPT0 TO BE CALLED. THAT IS, TR0 TO BECOME 0.
hundms_done:
	CLR C
	MOV C, TR0
	JNC exit			;condition check for whether 100ms are up
	SJMP  hundms_done
exit:
	POP AR2
	POP AR1
	RET
	
	
	ORG 000BH		
ISR0:
	CLR TR0
	RETI

	ORG 1050H
terminate:
	MOV P1,#000h
END