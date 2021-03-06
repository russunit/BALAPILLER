{{
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// VGA64 6 Bits Per Pixel Engine
//
// Author: Kwabena W. Agyeman
// Updated: 11/17/2010
// Designed For: P8X32A
// Version: 1.0
//
// Copyright (c) 2010 Kwabena W. Agyeman
// See end of file for terms of use.
//
// Update History:
//
// v1.0 - Original release - 11/17/2009.
//
// For each included copy of this object only one spin interpreter should access it at a time.
//
// Nyamekye,
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

' AW NOTES: Majors questions
' what's f-porch, b-porch, h-sync?
' The assembly code is driving this on the cog
' Can we use multiple cogs to write to DisplayBuffer
' What happens if we drive two cogs to both output to VGA?
' What is the (repeat 32) loop in PIXEngineStart doing?

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Video Circuit:
//
//     0   1   2   3 Pin Group  ' determine the pin that the byte output starts on
//
//                     240OHM
// Pin 0,  8, 16, 24 ----R-------- Vertical Sync 'used for timing
//
//                     240OHM
// Pin 1,  9, 17, 25 ----R-------- Horizontal Sync 'used for timing
//
//                     470OHM
// Pin 2, 10, 18, 26 ----R-------- Blue Video ' controls blue intensity
//                            |
//                     240OHM |
// Pin 3, 11, 19, 27 ----R-----
//
//                     470OHM
// Pin 4, 12, 20, 28 ----R-------- Green Video 'intensity
//                            |
//                     240OHM |
// Pin 5, 13, 21, 29 ----R-----
//
//                     470OHM
// Pin 6, 14, 22, 30 ----R-------- Red Video ' intensity
//                            |
//                     240OHM |
// Pin 7, 15, 23, 31 ----R-----
//
//                            5V
//                            |
//                            --- 5V
//
//                            --- Vertical Sync Ground
//                            |
//                           GND
//
//                            --- Hoirzontal Sync Ground
//                            |
//                           GND
//
//                            --- Blue Return
//                            |
//                           GND
//
//                            --- Green Return
//                            |
//                           GND
//
//                            --- Red Return
//                            |
//                           GND
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}

CON

  #$FC, Light_Grey, #$A8, Grey, #$54, Dark_Grey
  #$C0, Light_Red, #$80, Red, #$40, Dark_Red
  #$30, Light_Green, #$20, Green, #$10, Dark_Green
  #$0C, Light_Blue, #$08, Blue, #$04, Dark_Blue
  #$F0, Light_Orange, #$A0, Orange, #$50, Dark_Orange
  #$CC, Light_Purple, #$88, Purple, #$44, Dark_Purple
  #$3C, Light_Teal, #$28, Teal, #$14, Dark_Teal
  #$FF, White, #$00, Black

PUB plotBox(color, xPixelStart, yPixelStart, xPixelEnd, yPixelEnd) '' 8 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Plots a one color box of pixels on screen.
'' //
'' // Color - The color of the box of pixels to display on screen. A color byte (%RR_GG_BB_xx).
'' // XPixelStart - The X cartesian pixel start coordinate. X between 0 and 159. Y between 0 and 119.
'' // YPixelStart - The Y cartesian pixel start coordinate. Note that this axis is inverted like on all other graphics drivers.
'' // XPixelEnd - The X cartesian pixel end coordinate. X between 0 and 159. Y between 0 and 119.
'' // YPixelEnd - The Y cartesian pixel end coordinate. Note that this axis is inverted like on all other graphics drivers.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  xPixelEnd := ((xPixelEnd <# 159) #> 0) ' <# limit max(signed) returns lowest value, 
																				 ' #> limit min(signed)
  yPixelEnd := (((yPixelEnd <# 119) #> 0) * 160)
  xPixelStart := ((xPixelStart <# xPixelEnd) #> 0)
  yPixelStart := (((yPixelStart * 160) <# yPixelEnd) #> 0)

  yPixelEnd += xPixelStart
  yPixelStart += xPixelStart
  xPixelEnd -= --xPixelStart

  repeat result from yPixelStart to yPixelEnd step 160
		' BYTEFILL (StartAddress, Value, Count) p. 57
		' (color | $3) fills in the first two bits, corresponding to vert and hor sync bits.
    bytefill(@displayBuffer + result, (color | $3), xPixelEnd)

PUB plotPixel(color, xPixel, yPixel) '' 6 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Plots a one color pixel on screen.
'' //
'' // Color - The color of the pixel to display on screen. A color byte (%RR_GG_BB_xx).
'' // XPixel - The X cartesian pixel coordinate. X between 0 and 159. Y between 0 and 119.
'' // YPixel - The Y cartesian pixel coordinate. Note that this axis is inverted like on all other graphics drivers.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  displayBuffer.byte[((xPixel <# 159) #> 0) + (160 * ((yPixel <# 119) #> 0))] := (color | $3)

PUB displayClear '' 3 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Clears the screen to black.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ' longfill(StartAddress, Value, Count), same as byte fill
  longfill(@displayBuffer, 0, constant((160 * 120) / 4))

PUB displayPointer '' 3 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Returns a pointer to the display buffer.
'' //
'' // The display buffer is an array of 160 by 120 bytes. Each byte represents a pixel on the screen.
'' //
'' // Each pixel is a color byte (%RR_GG_BB_xx). Where RR, GG, and BB are the two bit values of red, green, blue respectively.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  return @displayBuffer

PUB displayState(state) '' 4 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Enables or disables the PIX Driver's video output - turning the monitor off or putting it into standby mode.
'' //
'' // State - True for active and false for inactive.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  displayIndicator := state

PUB displayRate(rate) '' 4 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Returns true or false depending on the time elasped according to a specified rate.
'' //
'' // Rate - A display rate to return at. 0=0.234375Hz, 1=0.46875Hz, 2=0.9375Hz, 3=1.875Hz, 4=3.75Hz, 5=7.5Hz, 6=15Hz, 7=30Hz.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	' or= (take a int with 8 bit set), shift right by the frequency, bitwise and with syncIndicator
  result or= (($80 >> ((rate <# 7) #> 0)) & syncIndicator)

PUB displayWait(frames) '' 4 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Waits for the display vertical refresh.
'' //
'' // The best time to draw on screen for flicker free operation is right after this function returns.
'' //
'' // Frames - Number of vertical refresh frames to wait for.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	'ensure frames is positive
	' repeat equavilent to the number of frames
  repeat (frames #> 0)
    result := syncIndicator 'set the result to the current syncIndicator
		' wait until syncIndicator is the same value while syncInd cycles
    repeat until(result <> syncIndicator) '<> boolean is not equal

PUB displayColor(redAmount, greenAmount, blueAmount) '' 6 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Builds a color byte (%RR_GG_BB_xx) from red, green, and blue componets.
'' //
'' // RedAmount - The amount of red to add to the color byte. Between 0 and 3.
'' // GreenAmount - The amount of green to add to the color byte. Between 0 and 3.
'' // BlueAmount - The amount of blue to add to the color byte. Between 0 and 3.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	' build a color byte using bitwise shifts (%%RR_GG_BB_11)
  return ((((redAmount <# 3) #> 0) << 6) | (((greenAmount <# 3) #> 0) << 4) | (((blueAmount <# 3) #> 0) << 2) | $3)

PUB PIXEngineStart(pinGroup) '' 7 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Starts up the PIX driver running on a cog.
'' //
'' // Returns true on success and false on failure.
'' //
'' // PinGroup - Pin group to use to drive the video circuit. Between 0 and 3.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  PIXEngineStop
  if(chipver == 1)

    pinGroup := ((pinGroup <# 3) #> 0) ' ensure pinGroup is 3,2,1,0
    directionState := ($FF << (8 * pinGroup)) 'shift %1111_11111_RR_GG_BB_XX, where X is vert/hor sync,and X,R,G,B are set to 0
    videoState := ($30_00_00_FF | (pinGroup << 9)) ' ? mask left most bits?

    pinGroup := constant((25_175_000 + 1_600) / 4) ' no idea?
    frequencyState := 1

		' what is this doing? some sort of freqState/pinGroup shift based on clkFreq
		' cliqfreq = clicks per second, set with clkset, p.63
    repeat 32
      pinGroup <<= 1 'bitwise shift left one bit on pinGroup
      frequencyState <-= 1 'rotate left one bit on frequencyState
			                     'frequency state set  by frqa register
      if(pinGroup => clkfreq) 'boolean greater than or equal
        pinGroup -= clkfreq 'subtract clkfreq from pinGroup
        frequencyState += 1 'add 1 to frequency state

    displayIndicatorAddress := @displayIndicator 'Set to TRUE or FALSE for output w/
		                                             'displayState function
    syncIndicatorAddress := @syncIndicator 'Video update control
    cogNumber := cognew(@initialization, @displayBuffer) 'initatialize the new cog with
		' initialization corresponds to the vcfg register 
    result or= ++cogNumber

PUB PIXEngineStop '' 3 Stack Longs

'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'' // Shuts down the PIX driver running on a cog.
'' ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  if(cogNumber)
    cogstop(-1 + cogNumber~)

DAT
' all register information on p338
' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'                       PIX Driver
' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

                        org     0
				
' //////////////////////Initialization/////////////////////////////////////////////////////////////////////////////////////////
                       'fun  destination,  source
initialization          mov     vcfg,           videoState                 ' Setup video hardware.
                        mov     frqa,           frequencyState             '
												'frqa = counter a freq register, p338
                        movi    ctra,           #%0_00001_101              '
												'ctra control register
		
' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'                       Active Video
' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

loop                    mov     displayCounter, par                        ' Set/Reset tiles fill counter.
                        mov     tilesCounter,   #120                       '

tilesDisplay            mov     tileCounter,    #4                         ' Set/Reset tile fill counter.

tileDisplay             mov     vscl,           visibleScale               ' Set/Reset the video scale.
                        mov     counter,        #40                        '

' //////////////////////Visible Video//////////////////////////////////////////////////////////////////////////////////////////

videoLoop               rdlong  buffer,         displayCounter             ' Download new pixels.
                        add     displayCounter, #4                         '

                        or      buffer,         HVSyncColors               ' Update display scanline.
                        waitvid buffer,         #%%3210                    '

                        djnz    counter,        #videoLoop                 ' Repeat.

' //////////////////////Invisible Video////////////////////////////////////////////////////////////////////////////////////////

                        mov     vscl,           invisibleScale             ' Set/Reset the video scale.

                        waitvid HSyncColors,    syncPixels                 ' Horizontal Sync.                      'waitvid pause execution untill the video generator is available for pixel data, p.371

' //////////////////////Repeat/////////////////////////////////////////////////////////////////////////////////////////////////

                        sub     displayCounter, #160                       ' Repeat.
                        djnz    tileCounter,    #tileDisplay               '

                        add     displayCounter, #160                       ' Repeat.
                        djnz    tilesCounter,   #tilesDisplay              '

' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'                       Inactive Video
' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

                        add     refreshCounter, #1                         ' Update sync indicator.
                        wrbyte  refreshCounter, syncIndicatorAddress       '

' //////////////////////Front Porch////////////////////////////////////////////////////////////////////////////////////////////

                        mov     counter,        #11                        ' Set loop counter.

frontPorch              mov     vscl,           blankPixels                ' Invisible lines.
                       'vscl = video scale register, p.338
                        waitvid HSyncColors,    #0                         '

                        mov     vscl,           invisibleScale             ' Horizontal Sync.
                        waitvid HSyncColors,    syncPixels                 '

                        djnz    counter,        #frontPorch                ' Repeat # times.

' //////////////////////Vertical Sync//////////////////////////////////////////////////////////////////////////////////////////

                        mov     counter,        #(2 + 2)                   ' Set loop counter.

verticalSync            mov     vscl,           blankPixels                ' Invisible lines.
                        waitvid VSyncColors,    #0                         '

                        mov     vscl,           invisibleScale             ' Vertical Sync.
                        waitvid VSyncColors,    syncPixels                 '

                        djnz    counter,        #verticalSync              ' Repeat # times.

' //////////////////////Back Porch/////////////////////////////////////////////////////////////////////////////////////////////

                        mov     counter,        #31                        ' Set loop counter.

backPorch               mov     vscl,           blankPixels                ' Invisible lines.
                        waitvid HSyncColors,    #0                         '

                        mov     vscl,           invisibleScale             ' Horizontal Sync.
                        waitvid HSyncColors,    syncPixels                 '

                        djnz    counter,        #backPorch                 ' Repeat # times.

' //////////////////////Update Display Settings////////////////////////////////////////////////////////////////////////////////

                        rdbyte  buffer,         displayIndicatorAddress wz ' Update display settings.
                        muxnz   dira,           directionState             '
												' dira = direction register for 32 bit port
' //////////////////////Loop///////////////////////////////////////////////////////////////////////////////////////////////////

                        jmp     #loop                                      ' Loop.

' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'                       Data
' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

invisibleScale          long    (16 << 12) + 160                           ' Scaling for inactive video.
visibleScale            long    (4 << 12) + 16                             ' Scaling for active video.
blankPixels             long    640                                        ' Blank scanline pixel length.
syncPixels              long    $00_00_3F_FC                               ' F-porch, h-sync, and b-porch.
HSyncColors             long    $01_03_01_03                               ' Horizontal sync color mask.
VSyncColors             long    $00_02_00_02                               ' Vertical sync color mask.
HVSyncColors            long    $03_03_03_03                               ' Horizontal and vertical sync colors.

' //////////////////////Configuration Settings/////////////////////////////////////////////////////////////////////////////////

directionState          long    0
videoState              long    0
frequencyState          long    0

' //////////////////////Addresses//////////////////////////////////////////////////////////////////////////////////////////////

displayIndicatorAddress long    0
syncIndicatorAddress    long    0

' //////////////////////Run Time Variables/////////////////////////////////////////////////////////////////////////////////////

counter                 res     1
buffer                  res     1

tileCounter             res     1
tilesCounter            res     1

refreshCounter          res     1
displayCounter          res     1

' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

                        fit     496

DAT

' //////////////////////Variable Arrary////////////////////////////////////////////////////////////////////////////////////////

displayBuffer           long    0[(160 * 120) / 4]                         ' Display buffer.
displayIndicator        byte    1                                          ' Video output control.
syncIndicator           byte    0                                          ' Video update control.
cogNumber               byte    0                                          ' Cog ID.

' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

{{

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                  TERMS OF USE: MIT License
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}}
