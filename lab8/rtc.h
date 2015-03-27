#ifndef _rtcH
#define _rtcH

void rtcInit();
void rtcWrite(unsigned char);
unsigned char rtcRead();
void rtcSetTime(unsigned char, unsigned char, unsigned char);
void rtcSetDate(unsigned char, unsigned char, unsigned char, unsigned char);
void rtcGetTime(unsigned char *, unsigned char *, unsigned char *);
void rtcGetDate(unsigned char *, unsigned char *, unsigned char *, unsigned char *);

#endif
