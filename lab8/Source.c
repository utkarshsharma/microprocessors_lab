#include<AT89C5131.h>
#include<delay.h>
#include<i2c.h>
#include<rtc.h>
#include<lcd.h>

void main(){
	char *dayNames[7] = { "MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN" };
	char *monthName[12] = { "JAN", "FEB", "MAR", "APR", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC" };
	unsigned char sec, min, hour, day, date, month, year;
	
	lcdReset();
	lcdInit();
	
	rtcInit();
	
	rtcSetTime(0x11,0x59,0x0);
	rtcSetDate(0x3,0x26,0x8,0x14);
	
	
	while(1){
	rtcGetTime(&hour, &min, &sec);
	rtcGetDate(&day, &date, &month, &year);
	lcdString(" ");
	lcdString(dayNames[day]);
	lcdString(" ");
	lcdx8(date);
	lcdString(" ");
	lcdString(monthName[month]);
	lcdString(" 20");
	lcdx8(year);
	lcdXY(1,0);
	lcdString("    ");
	lcdx8(hour);
	lcdString(":");
	lcdx8(min);
	lcdString(":");
	lcdx8(sec);
	lcdString("    ");
	
	delay_sec(1);
	lcdClear();
}
	
}
