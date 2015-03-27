#include<AT89C5131.h>
#include<stdio.h>
#include<i2c.h>
#include<ds1307.h>

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

	