MOV 81H,#000h
MOV 82H,#002h
MOV r1,81H
MOV r0,82H
lcall label


label:INC r1
decR1: DJNZ r0,decR1
MOV r0,#0FFh
DJNZ r1,decR1
ret
end
