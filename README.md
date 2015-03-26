#balapiller
A centipede like game for Parallax Propeller By Russ and Adam    

### Priority TODO list
1) we need to organize the code into meaningful directories:
		what about throwing all the drivers(duplex,VGA) into a 'lib' dir?  
		then creating 'src' for the current version, then 'archive/versionX' for the older versions?     
2) Basic User Manual: How do we expect the user to interact with the 
program? What inputs are expected? What is the goal of the gameplay?    
3) How can we extend the game?    
		Gameplay     
		Graphical     
		Sounds    



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



