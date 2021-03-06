//
// automatically generated by spin2cpp v1.06 on Thu Mar 26 03:46:33 2015
// spin2cpp BALAPILLER.spin 
//

#ifndef BALAPILLER_Class_Defined__
#define BALAPILLER_Class_Defined__

#include <stdint.h>
#include "VGA64_PIXEngine.h"
#include "FullDuplexSerial.h"
#include "Synth.h"

class BALAPILLER {
public:
  static const int _Clkmode = 1032;
  static const int _Xinfreq = 5000000;
  static const int _Rx = 31;
  static const int _Tx = 30;
  static const int Not_at_boundary = 0;
  static const int Tw = 1;
  static const int Lw = 2;
  static const int Bw = 3;
  static const int Rw = 4;
  static const int Nwc = 5;
  static const int Swc = 6;
  static const int Nec = 7;
  static const int Sec = 8;
  static const int Pad = 9;
  static const int _Up = 0;
  static const int _Dn = 1;
  static const int _Lt = 2;
  static const int _Rt = 3;
  static const int Upchar = 56;
  static const int Dnchar = 50;
  static const int Dnchr2 = 53;
  static const int Ltchar = 52;
  static const int Rtchar = 54;
  static const int Up = 1;
  static const int Down = 2;
  static const int Left = 3;
  static const int Right = 4;
  static const int Pen_erase = 0;
  static const int Pen_draw = 1;
  static const int Screenwidth = 160;
  static const int Screenheight = 120;
  static const int Ball_back_in_play_delay = 3;
  static const int Ball_out_of_play = 0;
  static const int Ball_in_play = 1;
  static const int Ballsize = 3;
  static const int Ballspeed = 192;
  static const int Ballratio = 16;
  static const int Screen_top_offset = 0;
  static const int Screen_bottom_offset = 1;
  static const int Screen_left_offset = 0;
  static const int Screen_right_offset = 1;
  static const int Screenminx = 0;
  static const int Screenmaxx = 159;
  static const int Screenminy = 0;
  static const int Screenmaxy = 119;
  static const int Min_x_coordinate = 3;
  static const int Max_x_coordinate = 156;
  static const int Min_y_coordinate = 3;
  static const int Max_y_coordinate = 116;
  static const int _Pingroup = 2;
  static const int _Switchrate = 5;
  static const int Good = 1;
  static const int Bad = 2;
  static const int Win = 3;
  VGA64_PIXEngine	Screen;
  FullDuplexSerial	Sport;
  SynthSpin	Synth;
  int32_t	Main(void);
  int32_t	Atboundary(void);
  int32_t	Plotball(int32_t X, int32_t Y, int32_t K);
  int32_t	Plotapple(int32_t X, int32_t Y, int32_t K, int32_t Num);
  int32_t	Getkeypressed(void);
  int32_t	Getnewdirection(int32_t Whichkey, int32_t Olddirection);
  int32_t	Moveball(void);
  int32_t	Updatesnake(void);
  int32_t	Drawsnake(void);
  int32_t	Erasesnake(void);
  int32_t	Redrawborder(void);
  int32_t	Checkcollision(void);
  int32_t	Placeapples(void);
  int32_t	Checkapples(void);
  int32_t	Makesound(int32_t Command);
private:
  int32_t	Xball, Yball, Dirball;
  int32_t	Xpaddle, Ypaddle;
  int32_t	Bound, Peroff, Peron;
  int32_t	Deadballtime;
  int32_t	Ballinplay;
  int32_t	Xnewball, Ynewball, Xeraseball, Yeraseball;
  int32_t	Balls;
  int32_t	Xsnake[500];
  int32_t	Ysnake[500];
  int32_t	Xoldball, Yoldball;
  int32_t	Ballinc;
  int32_t	Apple[100], Xapple[100], Yapple[100];
  int32_t	Apples, Applelevel;
  int32_t	Soundcommand, Stack[32], Stack2[32], Acolor[7];
};

#endif
