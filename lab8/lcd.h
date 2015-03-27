#ifndef _LCD_H
#define _LCD_H

void lcdInit(void);
void lcdReset(void);
void lcdx16(unsigned int);
void lcdx8(unsigned char);
void lcdCmd(char);
void lcdChar(char);
void lcdClear();
void lcdXY(char, char);
void lcdString(char *);
unsigned char ascii(unsigned char);
void lcdInt99(unsigned int);
void lcdTime(char, char, char);
void lcdDate(char, char, char);

#endif