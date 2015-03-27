MOV r0,#81h
MOV r1,#82h
MOV @r0,#001h
MOV @r1,#002h

mov A,@r0
mov r2,A

mov A, @r1
mov r3, A

mov r4,#000h
mov r5,#000h

cjne r4,#000h,countup2
sjmp countup1

countup1:INC r5
mov A, r5
CJNE A,#0ffh,countup1
MOV r5,#000h
INC r4
mov A,r4
cjne A,0x02,countup1

countup2:INC r5
mov A,r5
cjne A,0x03,countup2

end


end
