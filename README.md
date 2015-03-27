#balapiller
A centipede like game for Parallax Propeller By Russ and Adam    

### Priority TODO list
1) we need to organize the code into meaningful directories:
		what about throwing all the drivers(duplex,VGA) into a 'lib' dir?  
		then creating 'src' for the current version, then 'archive/versionX' for the older versions?     
2) DOCUMENTATION!!!!! Basic User Manual: How do we expect the user to interact with the 
program? What inputs are expected? What is the goal of the gameplay?    
3) How can we extend the game?    
		Gameplay     
		Graphical     
		Sounds    
4) Should we convert the game to Cpp, check ..../final/finalfinal/cpp
5) Figure out windows/linux compatibility issues. File encoding,naming standards, etc. Should be figured out before major work begins.  We can def work around issues, but we need to understand their scope and extent ahead of time.    
6) What does the VGA driver do, and how, exactly, does it do this?    


### Design Requirements:
#### We should try to fufill the following questions:
1) How can we best develop this program?   
What about developing a tool that allows us to quickly create, and subsequently encode pixel images for integration into the balapiller graphics engine.  This pixel images can be used similar to apples, 
and add to the appeal of the game.  Under this paradigm, we could keep the majority of code, extend the "drawApple" routine to drawItem(arg1), where arg1 is a collection of pixel based images, each with an associated score for balapiller eating it. Further, we can fill up the EEPROM with as many of these images as possible.  Only at this point, will using a compression scheme be needed.     
solution: does one of the following work for design given the limited pallette of the VGA driver? http://forums.rpgmakerweb.com/index.php?/topic/5027-software-for-making-pixel-art/. The difficulty will be programmatically exporting these images to our code base.      
2) How do store and generate pixel images in the most effective and extensible way?
We need to figure out how to generate coded pixel images and transfer to VGA  using cogs, which will force major limitations on memory. To do this, we need a comprehensive understanding of the VGA driver. Particularly, can we use multiple cogs to render different objects to the same VGA output? 
3) How do we make a soundtrack for the game?
We could dedicate one cog for the soundtrack, and additionally add 'feedback' noises.    


### Notes:
Why is there SynthAlt.spin? It appears the same as Synth.spin, I haven't
been able to find any differences(line by line comparison)


### Install SimpleIDE
http://learn.parallax.com/propeller-c-set-simpleide    
then select this repo...

### installing toolchain on linux...
https://github.com/wendlers/install-propeller-toolchain
sh ../install-propeller-toolchain/install-propeller-toolchain.sh


### Overview:
Objective: Make Balapiller awesome
Use DCT to store pixel images in low dimensional space, greatly
increasing the amount visual information in balapillar.    

### Needed for config:
1) Test SimpleIDE with propeller-elf-gcc
2) convert version1 balapiller to C & C++
   2.1) test on propeller
3) Figure out how to set SimpleIDE to repository/use with github

### Needed for Desgin
0) Figure out propeller video system, will DCT/IDCT work?
1) Image Design & DCT tool    
2) IDCT tool for propeller(sin/cos lookup, threading issues)      
3) Interface to draw images on VGA output    


### Usefull Resources:
#### ASM
http://www.parallax.com/propeller/qna/Content/QnaTopics/QnaAssembly.htm
http://www.parallax.com/propeller/qna/Content/TableTopics/AsmOpCodesPopup.htm



