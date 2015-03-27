//
// automatically generated by spin2cpp v1.06 on Thu Mar 26 03:46:33 2015
// spin2cpp BALAPILLER.spin 
//

#ifndef VGA64_PIXEngine_Class_Defined__
#define VGA64_PIXEngine_Class_Defined__

#include <stdint.h>

class VGA64_PIXEngine {
public:
  static const int Light_grey = 252;
  static const int Grey = 168;
  static const int Dark_grey = 84;
  static const int Light_red = 192;
  static const int Red = 128;
  static const int Dark_red = 64;
  static const int Light_green = 48;
  static const int Green = 32;
  static const int Dark_green = 16;
  static const int Light_blue = 12;
  static const int Blue = 8;
  static const int Dark_blue = 4;
  static const int Light_orange = 240;
  static const int Orange = 160;
  static const int Dark_orange = 80;
  static const int Light_purple = 204;
  static const int Purple = 136;
  static const int Dark_purple = 68;
  static const int Light_teal = 60;
  static const int Teal = 40;
  static const int Dark_teal = 20;
  static const int White = 255;
  static const int Black = 0;
  static uint8_t dat[];
  int32_t	Plotbox(int32_t Color, int32_t Xpixelstart, int32_t Ypixelstart, int32_t Xpixelend, int32_t Ypixelend);
  int32_t	Plotpixel(int32_t Color, int32_t Xpixel, int32_t Ypixel);
  int32_t	Displayclear(void);
  int32_t	Displaypointer(void);
  int32_t	Displaystate(int32_t State);
  int32_t	Displayrate(int32_t Rate);
  int32_t	Displaywait(int32_t Frames);
  int32_t	Displaycolor(int32_t Redamount, int32_t Greenamount, int32_t Blueamount);
  int32_t	Pixenginestart(int32_t Pingroup);
  int32_t	Pixenginestop(void);
private:
};

#endif
