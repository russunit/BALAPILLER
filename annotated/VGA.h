//
// automatically generated by spin2cpp v1.06 on Mon Mar 30 22:52:48 2015
// spin2cpp --ccode VGA.spin 
//

#ifndef VGA_Class_Defined__
#define VGA_Class_Defined__

#include <stdint.h>

#define Paramcount (21)
#define Colortable (384)

typedef struct VGA {
  int32_t	Cog;
  char dummy__;
} VGA;

  int32_t	VGA_Start(int32_t Vgaptr);
  int32_t	VGA_Stop(void);
#endif
