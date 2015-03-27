#include <AT89C5131.h>
//*******DECLARING VARIABLES**********************************

	
	unsigned char ii=0;
	unsigned char jj=0;
	sbit out = P1^7;
	bit enablebit=1;
	unsigned char higherHT;
	unsigned char lowerHT;

	unsigned char note_index;
	unsigned char duration_value;
	unsigned char note_value;
	unsigned int half_value;
	unsigned char half_index;
	unsigned char octave;
	unsigned int octave1;
	
	unsigned int Halfperiod [12]= { 3900, 3681, 3476, 3279, 3096, 2925, 2757, 2600, 2456, 2319, 2189, 2066 };
	unsigned char Notes [18]= {0, 2, 4, 5, 7, 9, 11, 16, 64, 16, 11, 9, 7, 5, 4, 2, 0, 0 };
	unsigned char Durations[18]= {200, 100, 100, 100, 200, 100, 100, 200, 100, 200, 100, 100, 200, 100, 100, 100, 200, 00};
	void tenmsdelay();
	
void serial_int (void) interrupt 1
{	
	if (enablebit==1)
	{
		out=~out;
	}
	TH0=higherHT;
	TL0=lowerHT;
}	

	
void main()
{		TMOD=0x11;
		ET0=1;
		EA=1;

	for( note_index=0; note_index < 18; note_index++)
	{
		duration_value = Durations[note_index];
		if (duration_value == 0){break;}
		note_value = Notes[note_index];
		octave1 = note_value & 0xF0;
		octave1= octave1>>4 & 0x0F;
		octave= octave1;
		half_index = note_value & 0x0F;
		
		half_value = Halfperiod[half_index];
		enablebit=1;
		if(octave == 0x01)
		{
			enablebit=1;
			half_value = half_value/2 ;
		}
		if(octave == 0x02)
		{	
			enablebit=1;
			half_value = half_value*2 ;
		}
		if(octave > 0x02) 
		{
			enablebit=0;
			half_value = 0xFFFF ;
		}
		half_value=0x00-half_value;
		higherHT=half_value>>8 & 0x00FF;
		TH0=higherHT;
		lowerHT=half_value & 0x00FF;
		TL0=lowerHT;
		TR0=1;
		
		for (jj=0; jj<duration_value; jj++)
		tenmsdelay();
	}	
		out = 0;
}

void tenmsdelay()
{
			for (ii=0; ii<5; ii++)
			{
				TH1=0x0c;
				TL1=0x30;
				TR1=1;
				while(1)
				{
					if(TF1==1)
					{
						TF1=0;
						TR1=0;
						break;
					}
				}
			}
}