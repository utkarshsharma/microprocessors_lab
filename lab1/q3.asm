mov r2,#0ah
mov r0,#81h

readagain:
	call read
	djnz r2,readagain

xor:
mov r0,#81h
mov r1,#82h
mov a,@r0
mov r3,a
mov a,@r1
xrl a,r3
mov r3,a
mov a,r0

add a,#10h
mov r0,a
mov a,r3
mov @r0,a
mov a,r0

subb a,#0fh
mov r0,a

inc r1
cjne r1,#91h,xor


mov r1,#81h
mov a,@r0
mov r3,a
mov a,@r1
xrl a,r3
mov r3,a
mov a,r0
add a,#10h
mov r0,a
mov a,r3
mov @r0,a


mov a, p1
anl a,#00fh
mov b,#009h
subb a,b

jc ledsoff

inc b
mov r1,b

poploop:
pop 81h
mov a,81h
djnz r1, poploop
finalled:
mov p1,a
lcall delay
swap a
lcall delay
sjmp finalled

ledsoff:

mov p1,#000h
swap a
sjmp ledsoff

delay:
mov r6,#0ffh
mov r7,#0ffh
c1: DJNZ r6,c1
MOV r6,#0FFh
DJNZ r7,c1
ret

end
