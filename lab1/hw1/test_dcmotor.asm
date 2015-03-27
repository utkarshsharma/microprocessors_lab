	ORG 0000H
	USING 0
	LJMP setup

	ORG 1000H	
setup:
	MOV TMOD, #001h
	SETB ET0			;ENABLE INTERRUPTS FOR T1 AND T0
	SETB EA
	MOV TH1, #00h
	MOV TL1, #00h
	SETB TR1
	MOV R5, #00h
	
MAIN:
	CJNE R5,#00h, S2
	MOV A, #0BH
	SJMP S3	;READ
S2:	MOV A, #02H
S3:	ANL A, #0FH
	MOV R0, A			;R0-->Time for which LED should be ON
	MOV A, #14h
	SUBB A, R0
	SETB P1.7

on:
	LCALL hundredms
	DJNZ R0, on

	MOV R1, A				;R1-->Time for which LED should be OFF
	CLR P1.7
		
		
off:	
	LCALL hundredms
	DJNZ R1, off	
	JNB TF1, JUMP
	CLR TR1
	MOV A, R5
	CPL A
	MOV R5,A
	MOV TH1, #00h
	MOV TL1, #00h
	SETB TR1
JUMP:
	LJMP MAIN

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

END