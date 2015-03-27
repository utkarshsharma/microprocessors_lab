#include<AT89C5131.h>
#include<ctype.h>
#include<string.h>
#include<delay.h>
#include<lcd.h>

//***********bit byte definations********************************
sbit RS = P0 ^ 0;     // Register Select line
sbit RW = P0 ^ 1;  		// Read/write line
sbit EN = P0 ^ 2; 		// Enable line
sbit busy = P2 ^ 7;
#define lcd P2			//lcd data port	

//*******LCD RESET ROUTINE**********************************
void lcdReset(){
	P0 = 0x00;
	P2 = 0x00;
	delay_ms(15); 				// wait for more than 15ms
	lcdCmd(0x30);
	delay_ms(4);  				// wait more than 4.1ms
	lcdCmd(0x30);
	delay_ms(1);  				// wait more than 100us
	lcdCmd(0x30);
	delay_ms(1);
	lcdCmd(0x02);		  // return to home
	delay_ms(1);
}

//********LCD INITIALIZATION*********************************
void lcdInit(){
	lcdCmd(0x38);				//8-bit, 2 Line, 5x7 Dots
	delay_ms(10);
	lcdCmd(0x0e);				//display cursor on
	delay_ms(10);
	lcdCmd(0x06);				//Entry mode, auto increment with no shift
	delay_ms(10);
	lcdCmd(0x01);				//clear lcd
	delay_ms(10);
}

//*********LCD COMMAND WRITE*********************************
void lcdCmd(unsigned char command){
	delay_ms(10);				//wait
	lcd = command;				//write data to port
	RS = 0;						//command mode
	RW = 0;
	EN = 1;
	delay_ms(10);				//enable pulse for 10ms more than enough
	EN = 0;
	delay_ms(10);
}


//********LCD DISPLAY LONG HEX 0XFFFF*********************** 
void lcdx16(unsigned int number){
	lcdx8((number >> 8)&(0x00ff));		//display upper two hex digits
	lcdx8((number)&(0x00ff));			//display lower two hex deigits
}


//********LCD DISPLAY SHORT HEX 0XFF************************
void lcdx8(unsigned char number){
	lcdChar(ascii((number >> 4)&(0x0f)));			//display MSB hex digit after converting it into ascii
	lcdChar(ascii((number)&(0x0f)));			//display LSB hex digit after converting it into ascii
}

//********LCD DISPLAY CHAR**********************************
void lcdChar(unsigned char character){
	delay_ms(1);								//wait
	lcd = character;							//write data to port
	RS = 1;										//data display mode
	RW = 0;
	EN = 1;
	delay_ms(1);									//en pulse of more than 1 ms
	EN = 0;
	delay_ms(1);
}

//***********COVERT HEX TO TO ASCII VALUE********************
//***********TAKES A 8BIT NUMBER REPRESENTING 4 BIT HEX******
unsigned char ascii(unsigned char character){
	if (character > 9)return (character - 9 + 0x40);				//A-F
	else return (character + 0x30);								//0-9
}

void lcdInt99(unsigned int num)
{
   lcdChar((num/10)+0x30);
   lcdChar((num%10)+0x30);
}

void lcdString(char *string_ptr)
{
	while (*string_ptr)
		lcdChar(*string_ptr++);
}

void lcdXY(char row, char col)
{
	char pos;

	if (row < 2)
	{
		pos = 0x80 | (row << 6); // take the line number
		//row0->pos=0x80  row1->pos=0xc0

		if (col < 16)
			pos = pos + col;            //take the char number
		//now pos points to the given XY pos

		lcdCmd(pos);	       // Move the Cursor specified Position
	}
}

void lcdClear()
{
	lcdCmd(0x01);	// Clear the LCD and go to First line First Position
}

void lcdDate(char day, char month, char year)
{
	lcdChar(((day >> 4) & 0x0f) + 0x30);
	lcdChar((day & 0x0f) + 0x30);
	lcdChar('/');

	lcdChar(((month >> 4) & 0x0f) + 0x30);
	lcdChar((month & 0x0f) + 0x30);
	lcdChar('/');

	lcdChar(((year >> 4) & 0x0f) + 0x30);
	lcdChar((year & 0x0f) + 0x30);
}

void lcdTime(char hour, char min, char sec)
{
	lcdChar(((hour >> 4) & 0x0f) + 0x30);
	lcdChar((hour & 0x0f) + 0x30);
	lcdChar(':');

	lcdChar(((min >> 4) & 0x0f) + 0x30);
	lcdChar((min & 0x0f) + 0x30);
	lcdChar(':');

	lcdChar(((sec >> 4) & 0x0f) + 0x30);
	lcdChar((sec & 0x0f) + 0x30);
}
