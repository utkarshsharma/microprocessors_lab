#include<AT89C5131.h>
#include<stdio.h>


#define SEC   0x00
#define	MIN   0x01	
#define HOUR  0x02
#define DAY   0x03
#define DATE  0x04
#define MONTH 0x05
#define YEAR  0x06

//*******DECLARING VARIABLES**********************************

	sbit RS = P0^0;
	sbit RW = P0^1;
	sbit EN = P0^2;
	int displayvar[] = {15,22,59,1,29,9,14};

//*******DECLARING FUNCTIONS**********************************


	void LCD_READY();
	void msdelay(unsigned int time);
	void tenmsdelay(unsigned int time);
	void lcd_init();
	void CMD_WRITE(unsigned char command);
	void DATA_WRITE(unsigned char character);	
	void STRING_WRITE(unsigned char character);
	void send2lcd(unsigned char value);

	void I2C_clock();
	void I2C_start();
	void I2C_stop();
	unsigned char I2C_read(void);
	bit I2C_write(unsigned char dat);

	
	/************** DEFINING DS1307 FUCTION****************************************/




#define DS1307_ID 0xD0	

unsigned char DS1307_get(unsigned char addr)
{
	unsigned char ret;	

	I2C_start();            /* Start i2c bus */

	I2C_write(DS1307_ID);   /* Connect to DS1307 */
	I2C_write(addr);				/* Request RAM address on DS1307 */
	
	I2C_start();						/* Start i2c bus */

	I2C_write(DS1307_ID+1);	/* Connect to DS1307 for Read */
	ret = I2C_read();				/* Receive data */
	
	I2C_stop();							/* Stop i2c bus */

   return ret;			
}



/***************************** Main function *************************************/
void main()			
{
	unsigned int sec, min, hour, day, date, month, year;
		
		/* Get Date & Time */
		sec   = DS1307_get(SEC);	
		min   = DS1307_get(MIN);	
		hour  = DS1307_get(HOUR);
		day 	= DS1307_get (DAY);
		date  = DS1307_get(DATE);
		month = DS1307_get(MONTH);
		year  = DS1307_get(YEAR);
	
	lcd_init();
	
	while(1) 
	{
			switch(day)
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
			

		CMD_WRITE(0x86);
		
		send2lcd(date);		
		DATA_WRITE(' ');		
		send2lcd(month);
		DATA_WRITE(' ');			
		send2lcd(year);
	
		CMD_WRITE(0xC6);
			
		send2lcd(hour);
		DATA_WRITE(':');       
		send2lcd(min);
		DATA_WRITE(':');		
		send2lcd(sec);
	}	   
}







void send2lcd(unsigned char value)
{
	unsigned char buf = 0;	
	
	buf = value & 0xF0;				/* Filter for high byte */
	buf = (buf>>4)|(0x30);		/* Convert  to ascii code */

	DATA_WRITE(buf);						/* Show on LCD */

	buf = value & 0x0F;				/* Filter for low byte */
	buf = buf | 0x30;       	/* Convert to ascii code */

	DATA_WRITE(buf);						/* Show on LCD */
}	












/*********************** DEFINING I2C FUNCTIONS **********************************************************/



#define SDA P2_7
#define SCL P2_6

void I2C_clock()
{
	delay();
	SCL = 1;								/* Start clock */
	delay();    
	SCL = 0;								/* Clear SCL */
}

void I2C_start()
{
	if(SCL)
	SCL = 0;									/* Clear SCL */
	SDA = 1;        					/* Set SDA */
	SCL = 1;									/* Set SCL */
	delay(); 	
	SDA = 0;        					/* Clear SDA */
	delay(); 
	SCL = 0;       						 /* Clear SCL */
}

void I2C_stop()
{
	if(SCL)	
	SCL = 0;									/* Clear SCL */
	SDA = 0;									/* Clear SDA */
	delay();
	SCL = 1;									/* Set SCL */
	delay();
	SDA = 1;									/* Set SDA */
}

bit I2C_write(unsigned char dat)
{
	bit data_bit;		
	unsigned char i;	

	for(i=0;i<8;i++)						/* For loop 8 time(send data 1 byte) */
	{
		data_bit = dat & 0x80;		/* Filter MSB bit keep to data_bit */
		SDA = data_bit;						/* Send data_bit to SDA */
		I2C_clock();      				/* Call for send data to i2c bus */
		dat = dat<<1;  
	}
	SDA = 1;											/* Set SDA */
	delay();	
	SCL = 1;											/* Set SCL */
	delay();	
	data_bit = SDA;   						/* Check acknowledge */
	SCL = 0;											/* Clear SCL */
	delay();
	return data_bit;							/* If send_bit = 0 i2c is valid */		 	
}

unsigned char I2C_read()
{
	bit rd_bit;	
	unsigned char i, dat;
	dat = 0x00;	

	for(i=0;i<8;i++)								/* For loop read data 1 byte */
	{
		delay();
		SCL = 1;											/* Set SCL */
		delay(); 
		rd_bit = SDA;									/* Keep for check acknowledge	*/
		dat = dat<<1;		
		dat = dat | rd_bit;						/* Keep bit data in dat */
		SCL = 0;											/* Clear SCL */
	}
	return dat;
}


















//*******DEFINING LCD FUNCTIONS**********************************

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
		msdelay(10);
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
		
void STRING_WRITE(unsigned char *lcd_string)
{
	while (*lcd_string) 
	{
		DATA_WRITE(*lcd_string++);
	}
}