Name: 			Jacob Henry & Adam Weaver
Institution:		Slippery Rock University of Pennsylvania
Course:			Cpsc 370
Instructor:		Dr. Conlon
Date Started:		Feb 3, 2015
Last Mod:		April 8, 2015
Purpose of Program:	Classic game of blockade written in 6502 assembly. 
			Two player game. Drive the snakes around the screen 
			for as long as possible without colliding with any 
			surfaces. The first player to collide with anything
 			loses. Have a good time. 
Specifics:		Game should be run using "Symon Simulator version 
			1.1.0" locally on a Microsoft Windows operating system. More information on
                       	Symon Simulator can be found at https://github.com/sethm/symon.
			It should be assembled using SB-Assembler "sbasm" from sbprojects.com. 6502.org
			and easy6502.com were referenced and adapted from 
  			during production of this program.



SBASM
The included sbasm .zip file is Version 3 from sbprojects.com.

Installation Guide:
http://www.sbprojects.com/sbasm/install.php


DIRECTIONS
1) Download and extract the master .zip file.
2) Run the symon-1.1.0-SS.jar executable.
3) If editing the blockade.asm code, you will need to install sbasm (SB-Assembler)
   in order to compile your new code. Reference sbprojects.com and the link provided 
   in the 'SBASM' section above.
4) To compile, make sure you save your edited blockade.asm file, 
   set up and install sbasm and simply type 'sbasm <filename>' in a command prompt. It will
   generate a new file called 'blockade.prg' or similar in the working directory
   of your command prompt.
   If you just want to use the program I have provided and don't plan on editing the code,
   then don't worry about this. I have provided a precompiled blockade.prg file in the master.
5) In the symon simulator, click 'File' -> ' Program...' and then navigate to where
   the blockade.prg file is. This is the compiled program file. Open it.
6) Click 'View' -> 'Video Window' and then click the 'Run' button on the simulator.
   Make sure to keep the simulator window, NOT the video window, in the foreground
   so that keyboard input will be registered. 
   
Note: If the game runs too fast, add more NOP operators in the 'stall' subroutine of 
blockade.asm as needed until your computer's speed makes the game playable. You may need 
to remove some NOP operators as well if it runs too slow. Basically, manipulate the 'stall' 
method as needed.

      __                 __
     (  |               |  )
  ____\  \             /  /_____
 (____ _) \           /   (_____)
 (_____ ) _)__(-̮-)__(_  ( _____)
 (__ ___)  )  |___|  (   (_  ___)
  (_____)__/  /_/\_\  \__(____)
              ™   ™
