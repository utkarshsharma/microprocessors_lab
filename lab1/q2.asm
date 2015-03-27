mov sp, #020h
mov r0, #00ah

fivesec:
mov a,p1


mov r1,#064h
again:
lcall delay
djnz r1,again

swap a
mov p1,a
mov r5,a

mov r1,#064h
comeagain:
lcall delay
djnz r1,comeagain
mov a,p1
swap a
mov p1,a
swap a

anl a,#0f0h
mov r4, a
mov a, r5
anl a,#00fh
add a,r4

mov p1, a
mov 81h,a
push 81h
djnz r0, fivesec


mov r0,#064h
yetagain:
lcall delay
djnz r0,yetagain

mov a,p1
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