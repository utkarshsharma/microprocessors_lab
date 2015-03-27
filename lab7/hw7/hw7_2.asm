
ORG 000h
SPCON equ 00C3h
SPSTA equ 0C4h
DATAREG equ 0C5h

JMP setup

ORG 0100h

setup:
	MOV SPCON,#00111111b		;Baud Rate = 3MHz
	ORL SPCON,#01000000b
	
MAIN:
	CLR P2.2					;Enable ADC
	MOV DATAREG,#01h  			;Start Bit
	
SPIF0:
	MOV B,SPSTA
	JNB B.7,SPIF0				;Wait for SPIF to be high
	
	MOV DATAREG,#10000000b		;Set ADC as single-ended and Channel as 0
	
SPIF1:
	MOV B,SPSTA
	JNB B.7,SPIF1				;Wait again for SPIF to be high

	MOV B,DATAREG				;Read ADC highest 2 bits	
	ANL B,#00000011b
	MOV A,B
	RL A
	RL A
	MOV 0020h,#00110000b		;Set Control bits
	ORL A,0020h
	MOV 0020h,A 				;Store first 6 bits to be sent to DAC in 20h

	MOV DATAREG,#00h 			;Send random bits to recover later 8 bits of ADC
	
SPIF2:
	MOV B,SPSTA
	JNB B.7,SPIF2 				;Wait for SPIF to be high

	MOV B,DATAREG 				;Read ADC lower 8 bits
	MOV A,B
	ANL A,#11000000b
	RL A
	RL A
	ORL A,0020h
	MOV 0020h,A   				;Store the next two bits in 20h

	MOV A,B
	RL A
	RL A
	MOV B,A
	CLR B.1
	CLR B.0
	MOV 0021h,B 			;Store later 6 bits of ADC and last two cits as 0

	SETB P2.2 				;Disable ADC
	CLR P2.0 				;Enable DAC
	MOV DATAREG,0020h 		;Send control bits and first 4 bits of ADC output to DAC
	
SPIF3:
	MOV B,SPSTA
	JNB B.7,SPIF3 			;Wait for SPIF to be high
	
	MOV DATAREG,0021h 		;Send next 8 bits
	
SPIF4:
	MOV B,SPSTA
	JNB B.7,SPIF4 			;Wait for SPIF to be high
	
	SETB P2.0				;Disable DAC
	LJMP MAIN 				;Transmit data continuously

endLoop:
	JMP endLoop

END