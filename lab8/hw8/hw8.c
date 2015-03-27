#include<AT89C5131.h>
#include<stdio.h>

//*******DECLARING VARIABLES**********************************

	sbit RS = P0^0;
	sbit RW = P0^1;
	sbit EN = P0^2;
	int displayvar[] = {15,22,59,1,29,9,14};

//*******DECLARING FUNCTIONS**********************************			
	void LCD_READY();
	void msdelay(unsigned int time);
	void init_lcd();
	void CMD_WRITE(unsigned char command);
	void DATA_WRITE(unsigned char character);
	void STRING_WRITE(char*);

//*******************MAIN LOOP**********************************

void main()
{
	init_lcd();
	msdelay(5);
	CMD_WRITE(0x80);
	msdelay(5);
	
	switch(displayvar[3])
			{
					case 1:		
							STRING_WRITE("MON ");
							break;
					case 2:		
							STRING_WRITE("TUE ");
							break;
					case 3:		
							STRING_WRITE("WED ");
							break;
					case 4:		
							STRING_WRITE("THU ");
							break;
					case 5:		
							STRING_WRITE("FRI ");
							break;
					case 6:		
							STRING_WRITE("SAT ");
							break;
					case 7:		
							STRING_WRITE("SUN ");
							break;
					default:
							break;
			}

		DATA_WRITE((displayvar[4]/10)+48);
		DATA_WRITE((displayvar[4]%10)+48);
		STRING_WRITE(" ");
		
		switch(displayvar[5])
			{
					case 1:		
							STRING_WRITE("JAN ");
							break;
					case 2:		
							STRING_WRITE("FEB ");
							break;
					case 3:		
							STRING_WRITE("MAR ");
							break;
					case 4:		
							STRING_WRITE("APR ");
							break;
					case 5:		
							STRING_WRITE("MAY ");
							break;
					case 6:		
							STRING_WRITE("JUN ");
							break;
					case 7:		
							STRING_WRITE("JUL ");
							break;
					case 8:		
							STRING_WRITE("AUG ");
							break;
					case 9:		
							STRING_WRITE("SEP ");
							break;
					case 10:		
							STRING_WRITE("OCT ");
							break;
					case 11:		
							STRING_WRITE("NOV ");
							break;
					case 12:		
							STRING_WRITE("DEC ");
							break;
					default:
							break;
			}

			DATA_WRITE(2+48);
			DATA_WRITE(0+48);
			DATA_WRITE((displayvar[6]/10)+48);
			DATA_WRITE((displayvar[6]%10)+48);
			
			CMD_WRITE(0xC0);
			
			STRING_WRITE("   ");
			DATA_WRITE((displayvar[0]/10)+48);
			DATA_WRITE((displayvar[0]%10)+48);
			STRING_WRITE(":");
			DATA_WRITE((displayvar[1]/10)+48);
			DATA_WRITE((displayvar[1]%10)+48);
			STRING_WRITE(":");
			DATA_WRITE((displayvar[2]/10)+48);
			DATA_WRITE((displayvar[2]%10)+48);
		
		while(1);
}




//*******DEFINING FUNCTIONS**********************************

//*******LCD INITIALIZATION**********************************

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

void init_lcd()
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

//*******WRITING A COMMAND TO THE LCD**********************************
void CMD_WRITE(unsigned char command)
{	
	LCD_READY();
	msdelay(100);
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
	msdelay(10);
	P2 = character;
	RS = 1;
	RW = 0;
	EN = 1;
	msdelay(1);
	EN = 0;
	msdelay(1);
}

void STRING_WRITE(char* str)				//Function to print string at once
{			
		int i = 0;
		while(str[i] != '\0')					//While null character of string is not reached
		{
				DATA_WRITE(str[i]);
				i++;
		}
}