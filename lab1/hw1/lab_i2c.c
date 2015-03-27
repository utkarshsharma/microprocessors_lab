#include<AT89C5131.h>

sbit RS = P0^0;
sbit RW = P0^1;
sbit EN = P0^2;

sbit SCL=P2^6; //i2c clock pin
 
sbit SDA=P2^7; //i2c data pin

unsigned char *day[]={"SUN","MON","TUE","WED","THU","FRI","SAT"};

unsigned char *mon[]={"JAN", "FEB", "MAR", "APR", "MAY", "JUN", "AUG","SEP", "OCT", "NOV","DEC"};

unsigned char clock[]={32, 9, 19, 1, 41, 9, 20};

#define SCLHIGH  SCL=1;
 
#define SCLLOW   SCL=0;
 
#define SDAHIGH  SDA=1;
 
#define SDALOW   SDA=0;

unsigned char slave_ack,add=0,c,k,sas;
 
unsigned int num;

void delay_us(unsigned int us_count);
void delayms(unsigned int ms_count);
void lcdCmd(unsigned char command);
void lcdReset();
void lcdInit();
unsigned char ascii(unsigned char character);
void lcdChar(unsigned char character);
void lcdInt8(unsigned int number);
void lcdString(unsigned char* String);





void start(void) //starts i2c, if both SCK & SDA are idle
{ 
if(SCL==0) //check SCK. if SCK busy, return else SCK idle
return;
if(SDA==0) //check SDA. if SDA busy, return else SDA idle
return;
 
SDALOW //High to Low transition on data line SDA makes d start condition
delay_us(1);
 
SCLLOW  //clock low   
delay_us(1);
}

void stop(void) //stops i2c, releasing the bus
{        
SDALOW //data low
SCLHIGH //clock high
delay_us(1);
SDAHIGH //Low to High transition on data line SDA makes d stop condition
delay_us(1);
}
 

void send_byte(unsigned char c) //transmits one byte of data to i2c bus
{
unsigned mask=0x80;
do   //transmits 8 bits
{
if(c&mask) //set data line accordingly(0 or 1)
SDAHIGH //data high
else
SDALOW  //data low
 
//generate clock
SCLHIGH   //clock high
delay_us(1);
 
SCLLOW   //clock low
delay_us(1);
 
mask/=2;  //shift mask
}while(mask>0);
 
SDAHIGH  //release data line for acknowledge
SCLHIGH  //send clock for acknowledge
delay_us(1);
slave_ack=SDA; //read data pin for acknowledge
SCLLOW  //clock low
delay_us(1);
}

unsigned char receive_byte(unsigned char master_ack) //receives one byte of data from i2c bus
{
unsigned char c=0,mask=0x80;
do   //receive 8 bits
{
SCLHIGH //clock high
delay_us(1);
 
if(SDA==1) //read data
c|=mask;    //store data
   SCLLOW   //clock low
   delay_us(1);
   mask/=2; //shift mask
}while(mask>0);
 
if(master_ack==1)
SDAHIGH //don't acknowledge
else
SDALOW //acknowledge
 
    SCLHIGH //clock high
    delay_us(1);
   
    SCLLOW //clock low
    delay_us(1);
 
SDAHIGH //data high
 
return c;
}

unsigned char read_i2c(unsigned char device_id,unsigned char location)
//reads one byte of data(c) from slave device(device_id) at given address(location)
{
unsigned char c;
do
{
start();   //starts i2c bus  
send_byte(device_id); //select slave device
if(slave_ack==1) //if acknowledge not received, stop i2c bus
stop();
}while(slave_ack==1); //loop until acknowledge is received
 
send_byte(location);  //send address location     
stop(); //stop i2c bus
start(); //starts i2c bus  
send_byte(device_id+1); //select slave device in read mode
c=receive_byte(1); //receive data from i2c bus
stop(); //stop i2c bus
return c;
}

void write_i2c(unsigned char device_id,unsigned char location,unsigned char c)
//writes one byte of data(c) to slave device(device_id) at given address(location)
{
do
{
start();       //starts i2c bus
send_byte(device_id);   //select slave device
if(slave_ack==1)   //if acknowledge not received, stop i2c bus
stop();
}while(slave_ack==1); //loop until acknowledge is received
 
send_byte(location); //send address location
send_byte(c); //send data to i2c bus
stop(); //stop i2c bus
}


void init_rtc()
{
while(add<=6)   //update real time clock ic i.e. ds1307 with time
{
write_i2c(0xd0,add,clock[add]);
add++;
}
}


void main()
{
	lcdReset();
	lcdInit();
	delayms(5);
	
	init_rtc();
	
while(1)
{	
	lcdString(day[read_i2c(0xd0,0x03)]);//read day register and display 
	
	lcdString(" ");
	
	c=read_i2c(0xd0,0x04);//read date register and display on LCD
	
	lcdInt8(c);
	
	lcdString(" ");
	
	lcdString(mon[read_i2c(0xd0,0x05)]);//read month register and display on LCD
	
	lcdString(" 20");
	
	c=read_i2c(0xd0,0x06);//read year register and display on LCD
	
	lcdInt8(c);
	
	lcdCmd(0xc0);     //next line
	delayms(5);
	
	c=read_i2c(0xd0,0x02);//read hours register and display on LCD
	
	lcdInt8(c);
	
	lcdString(":");
	
	c=read_i2c(0xd0,0x01);//read minutes register and display on LCD
	
	lcdInt8(c);
	
	lcdString(":");
	
	c=read_i2c(0xd0,0x00);//read seconds register and display on LCD
	
	lcdInt8(c);
	
	delayms(100);
  lcdCmd(0x01); // Go to starting position of 1st line of LCD 

	}
}




//*********DELAY LOOPS*********************************

void delay_us(unsigned int us_count)
{
	while (us_count != 0)
	{
		us_count--;
	}
}


void delayms(unsigned int ms_count)
{
	while (ms_count != 0)
	{
		delay_us(50);	 //delay_us is called to generate 1ms delay
		ms_count--;
	}
}





//*********LCD COMMAND WRITE*********************************
void lcdCmd(unsigned char command){
	delayms(10);
	P2 = command;
	RS = 0;
	RW = 0;
	EN = 1;
	delayms(10);
	EN = 0;
	delayms(10);	
}

//*******LCD RESET ROUTINE**********************************
void lcdReset(){
	P0 = 0x00;
	P2 = 0x00;
	delayms(15); 				// wait for more than 15ms after supply rises to 4.5V
	lcdCmd(0x30);
	delayms(4);  				// wait more than 4.1ms
	lcdCmd(0x30);
	delayms(1);  				// wait more than 100us, but delayms(1) will provide 1ms
	lcdCmd(0x30);
	delayms(1);
	lcdCmd(0x02);		  // return to home
	delayms(1);	
}

//********LCD INITIALIZATION*********************************
void lcdInit(){
	lcdCmd(0x38);  //2 LINE DISPLAY WITH 5x7 FONT ON AN 8BIT INTERFACE
	delayms(10);
	lcdCmd(0x0e);   //TURN ON DISPLAY, CURSOR NOT BLINKING
	delayms(10);
	lcdCmd(0x06);     //INCREMENTING THE CURSOR POSITION
	delayms(10);
	lcdCmd(0x01);     //CLEAR SCREEN
	delayms(10);
}

//***********COVERT HEX TO TO ASCII VALUE********************
unsigned char ascii(unsigned char character){
	if (character>9)return (character - 9 + 0x40); //A-F
	else return (character + 0x30);								//0-9
}

//********LCD DISPLAY CHAR**********************************
void lcdChar(unsigned char character){
	delayms(10);				//wait for busy flag
	P2 = character;
	RS = 1;
	RW = 0;
	EN = 1;
	delayms(1);
	EN = 0;
	delayms(1);
}

//********LCD DISPLAY SHORT HEX 0XFF************************
void lcdInt8(unsigned char number){
	lcdChar(ascii((number>>4)&(0x0f)));
	lcdChar(ascii((number)&(0x0f)));
}

//*********LCD DISPLAY STRING********************************
void lcdString(unsigned char* String){
	unsigned char i=0, temp=0;
	while(String[i]!='\0'){				//TERMINATE WHEN END OF STRING
	 temp = String[i++];					//STORE AND INCREASE INDEX
	 lcdChar(temp);	 							//DISPLAY STORED VALUE
	}
}