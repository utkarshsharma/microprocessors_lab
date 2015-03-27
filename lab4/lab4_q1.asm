ORG 00H
USING 0
LJMP 	setup

ORG 1200H
speeds: DB 01H, 02H, 04H, 08H
speedsback: DB 08H, 04H, 02H, 01H

ORG 100H
setup:
	MOV TMOD, #001h
	SETB ET0			;ENABLE INTERRUPTS FOR T1 AND T0
	SETB EA
	
MAIN:	
	MOV R7, #00H		;R7 STORES SPEED 		
	MOV R2, #00H		;INITIALISING
	MOV P1, #0Fh		;Initializing (For Reading)
	MOV A, P1
	ANL A, #03H
	MOV B, R2			;OLD VALUE IN R2 MOVED TO B
	MOV R2, A			;R2 STORES OLD SWITCH INPUT
	SUBB A, B
	ADD A, #02D
	
	JNB ACC.0, not1or3	;Defined states. (If the difference between new and old values of switches + 2)=1 or 3, decrease speed
	LJMP dec_check				
not1or3:
	JNB ACC.1, not2		;Defined states. (If the difference between new and old values of switches + 2)=2, no change in speed
	LJMP run
not2:					;Defined states. (If the difference between new and old values of switches + 2)=0 or 4, increase speed
	LJMP inc_check


dec_check:
	CJNE R7, #-7D, decrease		;if already max backwd speed
	LJMP run
decrease:	
	DEC R7						;speed decreased/increased in backwd direction 
	LJMP run

inc_check:	
	CJNE R7, #7D, increase		;if already max fwd speed
	LJMP run
increase:
	INC R7						;speed increased/decreased in backwd directio 
	LJMP run
		
run:
	CJNE R7, #0D, nonzero		;if speed becomes zero
	LJMP zerospeed
nonzero:
	MOV A,  R7					;checking if speed is positive or negative,
	JB ACC.7, anticlock			;if speed(i.e. value stored in R7) is negative, then MSB will be high, and we will run the motor anticlockwise

clockws:
	MOV A,#00H
	MOV R3, #00H
clockws1:
	MOV A, R3
	MOV DPTR, #speeds
	MOVC A,@A+DPTR
	SWAP A
	MOV	P1, A
	LCALL runfwd
	INC R3
	CJNE R3, #04H, clockws1		;speed cycle complete
	LJMP MAIN

anticlock:
	MOV A,#00H
	MOV R3, #00H
anticlock1:
	MOV A, R3
	MOV DPTR, #speedsback
	MOVC A,@A+DPTR
	SWAP A
	MOV	P1, A
	LCALL runbckwd
	INC R3
	CJNE R3, #04H, anticlock1	;speed cycle complete
	LJMP MAIN

zerospeed:	
	MOV P1,#00h					;motor speed zero
	LCALL MAIN
	LJMP zerospeed

runbckwd:	
	MOV A, R7
	ADD A, #08D					;adjust for setting appropriate delay. Example -2=-FE. -FE+8=-2+8=6. i.e. 6*150ms of delay and anticlckws direction
	MOV R5, A					;no. of times 150ms delay has to be run
	keeprun:	LCALL hundfiftyms
	DJNZ R5, keeprun
	RET

runfwd:
	MOV A, R7 			
	MOV R5, A
	MOV A, #08D
	SUBB A, R5					;adjust for setting appropriate delay. Example R7=3. 8-3= 5. i.e. 5*150ms of delay and clckws direction
	MOV R5, A					;no. of times 150ms delay has to be run
	keeprun2:	LCALL hundfiftyms	
	DJNZ R5, keeprun2
	RET
	
ORG 1500H
hundfiftyms:
	PUSH AR1
	PUSH AR2
;MOVING 00 TO TH0 AND TL0
	MOV TH0, #00h	
	MOV TL0, #00h

	SETB TR0					;START TIMER1. STOPS ONLY WHEN 100ms ARE COMPLETED. THIS GIVES US ONE 100ms LOOP.
	MOV R2, #06h					;NO. OF TIMES WE HAVE TO RUN T0 FROM 00 TO FE FOR 100ms
set_t1_again:
	DJNZ R2, t1loop					;CHECKING IF 100ms ARE DONE
	sjmp hundfifms_done
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
hundfifms_done:
	CLR C
	MOV C, TR0
	JNC exit			;condition check for whether 100ms are up
	SJMP  hundfifms_done
exit:
	POP AR2
	POP AR1
	RET
	
	
	ORG 000BH		
ISR0:
	CLR TR0
	RETI
END