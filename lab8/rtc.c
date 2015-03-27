#include "rtc.h"
#include "i2c.h"
#include "delay.h"

void rtcInit()
{
   	i2cStart();            // Start I2C communication (pull SDA down)

	rtcWrite(0xD0);   // Connect to DS1307 by sending its ID on I2c Bus
	rtcWrite(0x07);     // Select the Ds1307 ControlRegister to configure Ds1307
	rtcWrite(0x00);        // Write 0x00 to Control register to disable SQW-Out, not needed

	i2cStop();             // Stop I2C communication after initilizing DS1307 (pull SDA up)
}

void rtcWrite(unsigned char dat)
{
	i2cWrite(dat);   // Connect to DS1307 by sending its ID on I2c Bus
	i2cClock();
}

unsigned char rtcRead()
{
	return i2cRead();   
}

void rtcSetTime(unsigned char hh, unsigned char mm, unsigned char ss)
{
	i2cStart();            // Start I2C communication

	rtcWrite(rtcID);	// connect to DS1307 by sending its ID on I2c Bus
	rtcWrite(SEC_ADDRESS); // Select the SEC RAM address
	
	rtcWrite(ss);			// Write sec on RAM address 00H
	rtcWrite(mm);			// Write min on RAM address 01H
	rtcWrite(hh);			// Write hour on RAM address 02H

	i2cStop();           	// Stop I2C communication after Setting the Time
}

void rtcSetDate(unsigned char day, unsigned char dd, unsigned char mm, unsigned char yy)
{
	i2cStart();            // Start I2C communication

	rtcWrite(rtcID);	// connect to DS1307 by sending its ID on I2c Bus
	rtcWrite(DATE_ADDRESS);		// Request DAY RAM address at 04H
	
	rtcWrite(day);		// Write day on RAM address 03H
	rtcWrite(dd);			// Write date on RAM address 04H
	rtcWrite(mm);			// Write month on RAM address 05H
	rtcWrite(yy);			// Write year on RAM address 06h

	i2cStop();				// Stop I2C communication after Setting the Date
}

void rtcGetTime(unsigned char *h_ptr, unsigned char *m_ptr, unsigned char *s_ptr)
{
	i2cStart();           // Start I2C communication

	rtcWrite(rtcID);	// connect to DS1307 by sending its ID on I2c Bus
	rtcWrite(SEC_ADDRESS);		    // Request Sec RAM address at 00H

	i2cStop();			// Stop I2C communication after selecting Sec Register

	i2cStart();		        // Start I2C communication
	rtcWrite(0xD1);	        // connect to DS1307( under Read mode)
	//by sending its ID on I2c Bus

	*s_ptr = rtcRead();  i2cAck();     // read second and return Positive ACK
	*m_ptr = rtcRead();  i2cAck();	   // read minute and return Positive ACK
	*h_ptr = rtcRead();  i2cNAck();   // read hour and return Negative/No ACK

	i2cStop();		        // Stop I2C communication after reading the Time
}

void rtcGetDate(unsigned char *day_ptr, unsigned char *d_ptr, unsigned char *m_ptr, unsigned char *y_ptr)
{
	i2cStart();            // Start I2C communication

	rtcWrite(rtcID);	// connect to DS1307 by sending its ID on I2c Bus
	rtcWrite(DATE_ADDRESS);		// Request DAY RAM address at 04H

	i2cStop();			    // Stop I2C communication after selecting DAY Register


	i2cStart();		        // Start I2C communication
	rtcWrite(0xD1);	        // connect to DS1307( under Read mode)
	// by sending its ID on I2c Bus
	
	*day_ptr = rtcRead(); i2cAck();	//read week day and return Positive ACK
	*d_ptr = rtcRead(); i2cAck();	 // read Day and return Positive ACK
	*m_ptr = rtcRead(); i2cAck(); 	 // read Month and return Positive ACK
	*y_ptr = rtcRead(); i2cNAck();	 // read Year and return Negative/No ACK

	i2cStop();		  // Stop I2C communication after reading the Time
}
