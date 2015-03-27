#ifndef _i2cH
#define _i2cH

void i2cClock(void);
void i2cStart();
void i2cStop(void);
void i2cWrite(unsigned char );
unsigned char i2cRead(void);
void i2cAck();
void i2cNAck();

#endif