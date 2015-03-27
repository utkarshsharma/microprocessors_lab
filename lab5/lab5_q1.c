#include <AT89C5131.h>
//*******DECLARING VARIABLES**********************************


	
	sbit out = P0^0;
	bit enablebit=1;
	unsigned int HT=0xFFFF;
	
	void serial_int (void) interrupt 1
	{	
		if (enablebit==1)
		{
			TR0=0;
			TH0=HT>>8 & 0x00FF;
			TL0=HT & 0x00FF;
			TR0=1;
			out=~out;
		}
	}	
	
	void main(){
		ET0=1;
		ET1=1;
		EA=1;
		TR0=1;
		while(1);
	}