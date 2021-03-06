{{
***********************************************
*  Title:  Pong
*  Author: Thomas P. Sullivan
*  Date:   3/17/2011
***********************************************

 -----------------REVISION HISTORY-----------------
 v1.00 - Original Version - 11/11/2010 
 v1.01 - Work done for 2011 Microprocessor Class ENT234 3/17/2011
 v2.00 - Switched to full 512x384 using Jim Pyne's Bresenham code.  3/18/2011
 v2.01 - Ch ch ch ch changes...added a lot of new Constants  3/24/2011
 v3.00 - 160x120 Pong  4/21/2011

}}

CON

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  _RX           = 31                         
  _TX           = 30                         

  ''Boundary Values
  NOT_AT_BOUNDARY = 0
  TW    =       1               ''Top Wall
  LW    =       2               ''Left Wall
  BW    =       3               ''Bottom Wall
  RW    =       4               ''Right Wall
  NWC   =       5               ''NorthWest Corner
  SWC   =       6               ''SouthWest Corner
  NEC   =       7               ''NorthEast Corner
  SEC   =       8               ''SouthEast Corner
  PAD   =       9               ''The Paddle



  
  ''Ball Directions MODIFIED[][][]
  
  _UP    =       0               ''UP
  _DN    =       1               ''DOWN
  _LT    =       2               ''LEFT
  _RT    =       3               ''RIGHT

  ''ASCII Characters for Up and Down for the Paddle  MODIFIED[][][]
  UPCHAR  =     $38             ''8 is UP
  DNCHAR  =     $32             ''2 is DOWN
  DNCHR2  =     $35             ''5 is also down
  LTCHAR  =     $34             ''4 is LEFT
  RTCHAR  =     $36             ''6 is RIGHT

  ''Constants for Up and Down [BALL] in the game      MODIFIED[][][]
  UP      =     1
  DOWN    =     2
  LEFT    =     3
  RIGHT   =     4
  

  ''Constants for drawing and erasing the ball
  PEN_ERASE =   0
  PEN_DRAW  =   1

  ''The screen size we are using
  SCREENWIDTH = 160             ''Screen Width
  SCREENHEIGHT = 120            ''Screen Heigth

  ''Paddle Constants  
  HPH     =     8                       ''Half PaddleHeight (width)
  GOALWIDTH  =  16                      ''Width of Goal area
  PADSUR  =     SCREENWIDTH-GOALWIDTH   ''Paddle Surface X coordinate
  PADINC  =     4                      ''Paddle Increment

  ''The Ball
  BALL_BACK_IN_PLAY_DELAY = 3   ''Seconds
  BALL_OUT_OF_PLAY = 0
  BALL_IN_PLAY = 1
  BALLSIZE = 3                  ''Width and Height of the Ball is the same
                                ''Actual Ball Width and Height is determined by (BALLSIZE*2)+1

  BALLSPEED = 256             ''Used as a divisor into CLKFREQ for WAITCNT                         [M0D]
  BALLRATIO = 16                ''Used to set the ratio of Ball ON time to Ball OFF time

  ''Our game screen coordinate limits (the edges of the game screen)
  SCREEN_TOP_OFFSET = 0
  SCREEN_BOTTOM_OFFSET = 1
  SCREEN_LEFT_OFFSET = 0
  SCREEN_RIGHT_OFFSET = 1
  
  ''Do not change these
  SCREENMINX = SCREEN_LEFT_OFFSET                       ''Minimum X screen coordinate
  SCREENMAXX = SCREENWIDTH-SCREEN_RIGHT_OFFSET          ''Maximum X screen coordinate
  SCREENMINY = SCREEN_TOP_OFFSET                        ''Minimum Y screen coordinate
  SCREENMAXY = SCREENHEIGHT-SCREEN_BOTTOM_OFFSET        ''Maximum Y screen coordinate

  ''Do not change these
  MIN_X_COORDINATE = SCREENMINX+BALLSIZE
  MAX_X_COORDINATE = SCREENMAXX-BALLSIZE
  MIN_Y_COORDINATE = SCREENMINY+BALLSIZE
  MAX_Y_COORDINATE = SCREENMAXY-BALLSIZE 

  _pinGroup = 2
  _switchRate = 5

  'These are my constants for soundtypes.
  GOOD = 1
  BAD = 2
  WIN = 3


  
OBJ
  SCREEN   : "VGA64_PIXEngine"
  SPORT    : "FullDuplexSerial"
  SYNTH    : "Synth"

  'RANDO : "RealRandom"

VAR
  long xBall, yBall, dirBall
  long xPaddle, yPaddle
  long Bound, perOff, perOn
  long DeadBallTime
  long BallInPlay

  long xNewBall, yNewBall, xEraseBall, yEraseBall
  long balls
  long xSnake[500]
  long ySnake[500]
  long xOldBall, yOldBall
                  
  long ballInc

  long Apple[50], xApple[50], yApple[50]
  long Apples, AppleLevel
  
  long SoundCommand, stack[32]

  byte drawSwitch   

PUB Main | i,lastx,lasty,StartBallDir,key, inx
  ''----
  ''Pong
  ''----

  ''Start the serial port
  SPORT.start(_RX, _TX, %0000, 19200)

  ''Start the synthesizer
  SoundCommand := 0
  cognew(MakeSound(@SoundCommand), @stack)

  ''Start VGA screen and graphics
  ifnot(SCREEN.PIXEngineStart(_pinGroup))
    reboot

  ''Wait for everything to start up
  waitcnt(clkfreq*2+cnt)
  
  ''Set Ball initial position, direction and speed
  ''ToDo: Maybe this could be a function that adds some
  ''randomness to the ball's initial position and direction!?
  StartBallDir := 1
  xBall := SCREENWIDTH-SCREENWIDTH/2 ''''''''''''                               'MODIFIED [REPLACED 4 WITH 2 SO BALL IS IN MIDDLE]
  yBall := SCREENHEIGHT - SCREENHEIGHT/4
  dirBall := _UP ''''''''''''''''''''''''''''''''                               'MODIFIED [REPLACED NW WITH _UP]
  plotball(xBall,yBall,PEN_DRAW)       ''Draw Ball at initial Position
  BallInPlay := BALL_IN_PLAY

  ''This is how we set the speed of the ball along with how it is
  ''drawn and erased on the screen.
  perOn := BALLSPEED/BALLRATIO
  perOff := BALLSPEED-(BALLSPEED/BALLRATIO)

  ''Set Paddle initial position
  'xPaddle := SCREENWIDTH - GOALWIDTH   ''Set X position of the paddle
  'yPaddle := SCREENHEIGHT/2            ''Paddle starts in the middle of the screen in the Y direction
  'lasty := yPaddle

  balls := 1
  Apples := 10

  'draw background
  SCREEN.plotBox(SCREEN.displayColor(3,2,1),MIN_X_COORDINATE,MIN_Y_COORDINATE,MAX_X_COORDINATE,MAX_Y_COORDINATE)
  SCREEN.plotBox(SCREEN.displayColor(0,0,0),MIN_X_COORDINATE+1,MIN_Y_COORDINATE+1,MAX_X_COORDINATE-1,MAX_Y_COORDINATE-1)


  
  PlaceApples   ' Place Apples at initial random positions


  ''------------------------------
  ''Repeat Forever
  ''------------------------------
  repeat
    ''------------------------------
    ''Update Paddle Position
    ''------------------------------

    ''Get Ball/Boundary Status
    Bound := AtBoundary     
     
    CheckApples                                    
       
      ''------------------------------
      ''Update Ball Position
      ''------------------------------
      If(BallInPlay==BALL_IN_PLAY)
        ''Erase at old position
        
        key := getKeyPressed
        dirBall := GetNewDirection(key, DirBall)

        ''Based on heading,update position
        MoveBall
        UpdateSnake
        ''Draw at new position
        DrawSnake
        
        Waitcnt(clkfreq/perOn+cnt)
      Else
        ''----------------------------------------------------------------
        ''Ball out of play. Check to see if we have to kick one off again.
        ''----------------------------------------------------------------
        If(DeadBallTime<cnt)
          ''Put another ball in play, resets ball count
          
          'PlaceApples
          
          BallInPlay := BALL_IN_PLAY        
          ''Set Ball initial position, direction and speed
          StartBallDir++
          xBall := SCREENWIDTH/2                                    'MODIFIED[]
          yBall := SCREENHEIGHT - SCREENHEIGHT/4
          if(StartBallDir & $1)
            dirBall := _UP                                                      'MODIFIED[]
          else
            dirBall := _UP                                                      'MODIFIED[]
           
          
          UpdateSnake
          
          
    if(Bound<>NOT_AT_BOUNDARY) OR ( CheckCollision==1)
      ''---------------------------------------------------------------
      ''The ball is at the boundary...WE missed the ball!
      ''---------------------------------------------------------------
      ''Erase the Ball
      BallInPlay := BALL_OUT_OF_PLAY

      EraseSnake

      SoundCommand := BAD
      
      Apples := 10
      PlaceApples

      xEraseBall := 0
      yEraseBall := 0
      xOldBall := 0
      yOldBall := 0

      
      ''ToDo: Play taps (or some other sound to indicate FAIL)
      'Stick the ball (even though not in play) back inside the game field
      xBall := SCREENWIDTH-SCREENWIDTH/2                                          'MODIFIED[]
      yBall := SCREENHEIGHT -SCREENHEIGHT/4                                       '[m]    
      DeadBallTime := CLKFREQ*BALL_BACK_IN_PLAY_DELAY+cnt
       
PUB AtBoundary : TheBoundary
  ''-------------------------------------------------------------------
  ''Function to determine if we are at a boundary.
  ''Returns -1 if not, otherwise returns boundary (UW, LW, BW, RW, etc)
  ''-------------------------------------------------------------------
  if xBall==MIN_X_COORDINATE OR xBall +1 ==MIN_X_COORDINATE OR xBall-1==MIN_X_COORDINATE
    TheBoundary := LW
  elseif xBall==MAX_X_COORDINATE OR xBall +1 ==MAX_X_COORDINATE OR xBall-1==MAX_X_COORDINATE
    TheBoundary := RW
  elseif yBall==MIN_Y_COORDINATE OR yBall +1 ==MIN_Y_COORDINATE OR yBall-1==MIN_Y_COORDINATE
    TheBoundary := TW
  elseif yBall==MAX_Y_COORDINATE OR yBall +1 ==MAX_Y_COORDINATE OR yBall-1==MAX_Y_COORDINATE
    TheBoundary := BW      
  '  
  else
    TheBoundary := NOT_AT_BOUNDARY   

  return TheBoundary

PUB PlotBall(x,y,k)
  ''-------------------------------------------------------
  ''Draw a series of horizontal lines to form a square ball 
  ''-------------------------------------------------------
    'SCREEN.displayWait(1)
    case k
      PEN_ERASE:
        SCREEN.plotBox(SCREEN.displayColor(0,0,0),x-1,y-1,x+1,y+1)
      PEN_DRAW:
        SCREEN.plotBox(SCREEN.displayColor(3,0,1),x-1,y-1,x+1,y+1)


PUB PlotApple(x,y,k, num) | AppleColor

    case num
      1:
        AppleColor := SCREEN.displayColor(3,0,0)
      2:
        AppleColor := SCREEN.displayColor(0,3,0)
      3:
        AppleColor := SCREEN.displayColor(3,3,0)
      4:
        AppleColor := SCREEN.displayColor(3,0,3)
      5:
        AppleColor := SCREEN.displayColor(0,0,3)
        

    case k
      PEN_ERASE:
        SCREEN.plotBox(SCREEN.displayColor(0,0,0),x-1,y-1,x+1,y+1)
      PEN_DRAW:
        SCREEN.plotBox(AppleColor,x-1,y,x+1,y+1)
        SCREEN.plotPixel(SCREEN.displayColor(0,1,0),x,y-1)

PUB PlotBadApple(x,y)
     SCREEN.plotPixel(SCREEN.displayColor(0,0,0),x+1,y+1) 

PUB PlotGoodApple(x,y)
     SCREEN.plotBox(SCREEN.displayColor(3,3,3),x-1,y,x+1,y+1)
     
PUB PlotBanana(x,y,k)
    case k
      PEN_ERASE:
        SCREEN.plotBox(SCREEN.displayColor(0,0,0),x-1,y-1,x+1,y+1)
      PEN_DRAW:
        SCREEN.plotBox(SCREEN.displayColor(3,3,0),x-1,y-1,x+1,y+1)
        SCREEN.plotPixel(SCREEN.displayColor(0,0,0),x+1,y-1)
        SCREEN.plotPixel(SCREEN.displayColor(0,0,0),x-1,y)
        SCREEN.plotPixel(SCREEN.displayColor(0,0,0),x+1,y+1)

PUB getKeyPressed  | UpDown                 'MODIFIED[]
  ''--------------------------------------------------------------
  ''WhatKey reads the serial port looking for the Up and Down keys
  ''to move the paddle. It returns 0 if no 'valid' key is pressed
  ''otherwise it returns Up or Down.
  ''--------------------------------------------------------------
  UpDown := SPORT.rxcheck
  case UpDown
    UPCHAR:
      UpDown := UP
    DNCHR2:
      UpDown := DOWN  
    DNCHAR:
      UpDown := DOWN
    LTCHAR:
      UpDown := LEFT
    RTCHAR:
      UpDown := RIGHT
    other:
      UpDown := 0

  return UpDown

PUB GetNewDirection(whichKey, oldDirection) : NewDirection
 ''--------------------------------------------------------
  ''gets key pressed, changes ball's direction if different, adds ball if different
  ''--------------------------------------------------------
  ballInc := 0
  
  Case whichKey 
    UP:    'UP
      if(OldDirection<>_UP and OldDirection<>_DN) 
        'balls++
        'ballInc := 1
      if(OldDirection<>_DN)
        NewDirection := _UP
      else
        NewDirection := _DN
    DOWN:    'down
      if(OldDirection<>_DN and OldDirection<>_UP)
        'balls++
        'ballInc := 1
      if(OldDirection<>_UP)
        NewDirection := _DN
      else
        NewDirection := _UP
    LEFT:    'left
      if(OldDirection<>_LT and OldDirection<> _RT)
        'balls++
        'ballInc := 1
      if(OldDirection<>_RT)
        NewDirection := _LT
      else
        NewDirection := _RT
    RIGHT:    'Right
      if(OldDirection<>_RT and OldDirection<> _LT)
        'balls++
        'ballInc := 1
      if(OldDirection<> _LT)
        NewDirection := _RT
      else
        NewDirection := _LT
    other:
       return oldDirection
  
  return newDirection


PUB MoveBall '''''''''''''''''''''MODIFIED[][][]
  ''--------------------------------
  ''Function to update Ball position
  ''--------------------------------


  xOldBall := xBall
  yOldBall := yBall
   
  
  case dirBall
    _UP:    'up
      yBall := yBall-3    
    _DN:    'DOWN
      yBall := yBall+3   
    _LT:    'LEFT
      xBall := xBall-3 
    _RT:    'RIGHT
      xBall := xBall+3

PUB UpdateSnake | index
''maintains arrays

  
  
    if(balls<2)
      xEraseBall := xOldBall
      yEraseBall := yOldBall
    if(balls>1)
      xEraseBall := xSnake[balls-1]
      yEraseBall := ySnake[balls-1]

  index := balls-1

  repeat while(index>0)
    xSnake[index] := xSnake[index-1]
    ySnake[index] := ySnake[index-1]
    index--

  xSnake[0] := xBall
  ySnake[0] := yBall 


PUB DrawSnake
  'draws the snake: draws the new segment in front, and erases the last segment if balls was not incremented.

  PlotBall(xSnake[0],ySnake[0],PEN_DRAW)
        if ballInc==0
          PlotBall(xEraseBall, yEraseBall, PEN_ERASE)


PUB EraseSnake  | ix
  'Function to erase the snake and start it over with one segment.


                      
  repeat ix from 0 to balls-1
    PlotBall(xSnake[ix], ySnake[ix], PEN_ERASE)

  balls :=1

  SCREEN.plotBox(SCREEN.displayColor(3,2,1),MIN_X_COORDINATE,MIN_Y_COORDINATE,MAX_X_COORDINATE,MAX_Y_COORDINATE)
  SCREEN.plotBox(SCREEN.displayColor(0,0,0),MIN_X_COORDINATE+1,MIN_Y_COORDINATE+1,MAX_X_COORDINATE-1,MAX_Y_COORDINATE-1)


PUB CheckCollision  | collide, idx
  'Function to check if the snake collides with itself.

collide :=0
 if balls>1
  repeat  idx from 2 to balls-1
   if (xSnake[idx]==xBall) AND (ySnake[idx]==yBall)
       collide := 1

return collide


PUB PlaceApples | index, x, ran, z


      'Assigns each apple with a random x,y coordinate that is in range and overlaps with the ball. 
   ran := cnt

   repeat index from 0 to Apples-1

       xApple[index] := 5 + ||(((ran?)//148)/3)*3
       yApple[index] := 6 + ||(((ran?)//108)/3)*3
       Apple[index] := 1

       'Makes sure apples aren't on top of each other.                                 
      repeat x from 0 to Apples-1 
        repeat while(xApple[x]==xApple[index]) AND (yApple[x]==yApple[index]) AND (index<>x)
          xApple[index] := 5 + ||(((ran?)//148)/3)*3
          yApple[index] := 6 + ||(((ran?)//108)/3)*3




       'Makes sure apples aren't on the snake    
      repeat z from 0 to balls-1 
        repeat while(xSnake[z]==xApple[index]) AND (ySnake[z]==yApple[index])
          xApple[index] := 5 + ||(((ran?)//148)/3)*3
          yApple[index] := 6 + ||(((ran?)//108)/3)*3






      'plots different colored apples depending on the quantity                                                                                                             
     if(Apples==10)
        plotApple(xApple[index],yApple[index],PEN_DRAW, 1)
     if(Apples==20)
        plotApple(xApple[index],yApple[index],PEN_DRAW, 2)
     if(Apples==30)
        plotApple(xApple[index],yApple[index],PEN_DRAW, 3)
     if(Apples==40)
        plotApple(xApple[index],yApple[index],PEN_DRAW, 4)
     if(Apples > 40)
        plotApple(xApple[index],yApple[index],PEN_DRAW, 5)    

      'plots a few bad apples and a good apple (probably won't use)
      {
   if(Apples=>20)
      repeat index from 0 to (Apples/10 - 1)
        plotBadApple(xApple[index], yApple[index])
        Apple[index] := 2
      plotGoodApple(xApple[Apples-1], yApple[Apples-1])
      Apple[Apples - 1] := 3
      }
    
PUB CheckApples | index, AppleDone
'Checks if we are on an apple, and if we are out of apples.

  AppleDone := 1
  repeat index from 0 to Apples-1
    if(xBall==xApple[index])AND(yBall==yApple[index])AND(Apple[index]==1)
      Apple[index] := 0
      balls++
      ballInc := 1
    if(Apple[index]==1)
      AppleDone := 0
      SoundCommand := GOOD


  if(AppleDone == 1)
     Apples := Apples + 10

     SoundCommand := WIN
     
     PlaceApples  'Place a new set of 10 more apples than before.

{
PUB AppleSound | A

    repeat A from 100 to 2000 Step 50
      SYNTH.Synth("A",10,A)
      SYNTH.Synth("B",11,A+1000)  

  ctra := 0
  ctrb := 0

PUB WinSound | A

  repeat 3
    repeat A from 100 to 2000 Step 50
      SYNTH.Synth("A",10,A)
      SYNTH.Synth("B",11,A+1000)

  ctra := 0
  ctrb := 0


PUB LoseSound | A

  repeat 3     
    repeat A from 2000 to 100 Step 50
      SYNTH.Synth("A",10,A)
      SYNTH.Synth("B",11,A+1000)  

  ctra := 0
  ctrb := 0
}
PUB MakeSound(command)| A

  repeat
    if(long[command]<>0)
      case command
        GOOD:'if we hit one apple.
          repeat A from 100 to 2000 Step 50
            SYNTH.Synth("A",10,A)
            SYNTH.Synth("B",11,A+1000)
        BAD:'if we lose.
          repeat 3     
            repeat A from 2000 to 100 Step 50
              SYNTH.Synth("A",10,A)
              SYNTH.Synth("B",11,A+1000)
        WIN: 'if we get all the current apples.
            repeat 3
              repeat A from 100 to 2000 Step 50
               SYNTH.Synth("A",10,A)
               SYNTH.Synth("B",11,A+1000)
       'wait one second.        
      waitcnt(clkfreq + cnt)
      ctra:=0
      ctrb:=0
     
      long[command] := 0      
         
     
{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}    