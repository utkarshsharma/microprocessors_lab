#include <AT89C5131.h>
//*******DECLARING VARIABLES**********************************

	sbit RS = P0^0;
	sbit RW = P0^1;
	sbit EN = P0^2;
	unsigned char displaychar;
	unsigned int displaychar1;
	
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
	
		
//*******DECLARING FUNCTIONS**********************************			
	void LCD_READY();
	void msdelay(unsigned int time);
	void tenmsdelay(unsigned int time);
	void lcdInit();
	void CMD_WRITE(unsigned char command);
	unsigned char ascii(unsigned char character);
	void byte_to_hex_display(unsigned char a);
	void DATA_WRITE(unsigned char character);
	void Displayloop(unsigned char, unsigned char, unsigned char, unsigned int);		
		
//*******MAIN LOOP**********************************
void main()
{
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
		
		if(octave == 0x01)
		{
			half_value = half_value/2 ;
		}
		if(octave == 0x02)
		{
			half_value = half_value*2 ;
		}
		if(octave > 0x02) 
		{
			half_value = 0xFFFF ;
		}
		
	Displayloop ( note_index, duration_value, octave, half_value);
	tenmsdelay(2);
	}

	while(1);

}

//*******DEFINING FUNCTIONS**********************************

//*******LCD INITIALIZATION**********************************

void lcd_init()
	{
		unsigned char a;
		a = 0x38;
		CMD_WRITE(a);    //2 LINE DISPLAY WITH 5x7 FONT ON AN 8BIT INTERFACE
		
		a = 0x0E;
		CMD_WRITE(a);		//TURN ON DISPLAY, CURSOR NOT BLINKING
	
		a = 0x06;				//INCREMENTING THE CURSOR POSITION
		CMD_WRITE(a);	

		
		a = 0x01;				//CLEAR SCREEN
		CMD_WRITE(a);
	}


//*******ONE MILLISECOND DELAY**********************************
void msdelay(unsigned int time)
{
	unsigned int i,j;
	for(i=0;i<time;i++)
	for(j=0;j<1275;j++);
}

//*******TEN MILLISECOND DELAY**********************************
void tenmsdelay(unsigned int time){
	unsigned int i;
	for(i=0;i<time;i++)
	{
		msdelay(10);
	}
}

//*******WRITING A COMMAND TO THE LCD**********************************
void CMD_WRITE(unsigned char command)
{	
	LCD_READY();
	tenmsdelay(10);
	P2 = command;
	RS = 0;
	RW = 0;
	EN = 1;
	msdelay(1);
	EN = 0;	
	msdelay(1);
}

//*******WRITING DATA TO THE LCD**********************************
void DATA_WRITE(unsigned char character)
{
	LCD_READY();
	tenmsdelay(1);
	P2 = character;
	RS = 1;
	RW = 0;
	EN = 1;
	msdelay(1);
	EN = 0;
	msdelay(1);
}

//*******CONVERT LOWER FOUR BITS TO ASCII**********************************
unsigned char ascii(unsigned char character)
{
	if (character>9) return (character - 9 + 0x40); 
	else return (character + 0x30);								
}

//*******CONVERT ONE BYTE TO ASCII AND DISPLAY ON LCD**********************************
void byte_to_hex_display(unsigned char a)
{ 
	unsigned char c= a>>4 & 0x0F;			//Higher nibble
	unsigned char b= ascii (c);
	DATA_WRITE(b);

	c= a & 0x0F;											//Lower nibble
	b= ascii (c);
	DATA_WRITE(b);
}

//*******WHATEVER IS TO BE DISPLAYED ON THE LCD**********************************
void Displayloop (unsigned char noteindex, unsigned char duration, unsigned char octave, unsigned int halfperiod)
{

	lcd_init();
	displaychar = 'N';
	DATA_WRITE(displaychar);
	displaychar = 'o';
	DATA_WRITE(displaychar);
	displaychar = 't';
	DATA_WRITE(displaychar);
	displaychar = 'e';
	DATA_WRITE(displaychar);		
	displaychar = '=';
	DATA_WRITE(displaychar);
	displaychar = ' ';
	DATA_WRITE(displaychar);
	
	byte_to_hex_display(noteindex);

	displaychar = ' ';
	DATA_WRITE(displaychar);
	displaychar = 'D';
	DATA_WRITE(displaychar);
	displaychar = '=';
	DATA_WRITE(displaychar);
	
	byte_to_hex_display(duration);
	
	displaychar = 0XC0;		      // NEXT LINE
	CMD_WRITE(displaychar);

	displaychar = 'O';
	DATA_WRITE(displaychar);
	displaychar = 'c';
	DATA_WRITE(displaychar);
	displaychar = 't';
	DATA_WRITE(displaychar);
	displaychar = '=';
	DATA_WRITE(displaychar);
	
	byte_to_hex_display(octave);
	
	displaychar = ' ';
	DATA_WRITE(displaychar);
	displaychar = 'H';
	DATA_WRITE(displaychar);
	displaychar = 'P';
	DATA_WRITE(displaychar);
	displaychar = '=';
	DATA_WRITE(displaychar);
	displaychar = ' ';
	DATA_WRITE(displaychar);
	
  displaychar = halfperiod>>8 & 0x00FF;
	byte_to_hex_display(displaychar);
	
	displaychar = ' ';
	DATA_WRITE(displaychar);
  
	displaychar = halfperiod & 0x00FF;
	byte_to_hex_display(displaychar);
	
}

void LCD_READY()
	{
			int i,j;
			unsigned char a = 0xff;
			P2 = 0xFF;            
			RS = 0;								
			RW = 1;								
			for( i=0; i<=75 ; i++)
		{
			for (j=0; j<=10 ; j++);
			}
			
			EN = 0;
		}