#include<reg51.h>
#include "delay.h"
#include "i2c.h"

sbit SCL=P0^2;		//SCL Connected to P3.6
sbit SDA=P0^1;	 	//SDA Connected to P3.7

void i2cClock(void)
{
	delay_us(1);	
	SCL = 1;

	/*  __________
	              |_______  SCL signal to generate clock
	*/

	delay_us(1);
	SCL = 0;
}

void i2cStart()
{
	/*             _____________________
	SCL : ________|                     |______
	      ___________________
	SDA : 	                 |__________
	*/
	SCL = 0;		// Pull SCL low
	SDA = 1;        // Pull SDA High
	delay_us(1);

	SCL = 1;		//Pull SCL high
	delay_us(1);

	SDA = 0;        //Now Pull SDA LOW, to generate the Start Condition
	delay_us(1);

	SCL = 0;        //Finally Clear the SCL to complete the cycle
}

void i2cStop(void)
{
	SCL = 0;			// Pull SCL low
	delay_us(1);

	SDA = 0;			// Pull SDA  low
	delay_us(1);

	SCL = 1;			// Pull SCL High
	delay_us(1);

	SDA = 1;			// Now Pull SDA High, to generate the Stop Condition
}

void i2cWrite(unsigned char dat)
{
	unsigned char i;

	for(i=0;i<8;i++)		 // loop 8 times to send 1-byte of data
	 {
		SDA = dat & 0x80;    // Send Bit by Bit on SDA line
		i2cClock();      	 // Generate Clock at SCL
		dat = dat<<1;
	  }
    	SDA = 1;			     // Set SDA at last

}

unsigned char i2cRead(void)
{
	unsigned char i, dat=0x00;

	   SDA=1;			    //Make SDA as I/P
	for(i=0;i<8;i++)		// loop 8times read 1-byte of data
	 {
		delay_us(1);
		SCL = 1;			// Pull SCL High
		delay_us(1);

		dat = dat<<1;		//dat is Shifted each time and
		dat = dat | SDA;	//ORed with the received bit to pack into byte

		SCL = 0;			// Clear SCL to complete the Clock
	   }
   return dat;		         // Finally return the received Byte*
}

void i2cAck()
{
	SDA = 0;		//Pull SDA low to indicate Positive ACK
	i2cClock();	//Generate the Clock
	SDA = 1;		// Pull SDA back to High(IDLE state)
}

void i2cNAck()
{
	SDA = 1;		//Pull SDA high to indicate Negative/NO ACK
   i2cClock();	    // Generate the Clock  
	SCL = 1;		// Set SCL */
}