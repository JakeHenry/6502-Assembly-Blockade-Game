; Name: 		Jacob Henry & Adam Weaver
; Course:		Cpsc 370
; Instructor:		Dr. Conlon
; Date Started:		Feb 3, 2015
; Last Mod:		April 8, 2015
; Purpose of Program:	Classic game of blockade written in 6502 assembly. 
;			Two player game. Drive the snakes around the screen 
;			for as long as possible without colliding with any 
;			surfaces. The first player to collide with anything
; 			loses. Have a good time. 
; Specifics:		Game should be run using "Symon Simulator version 
;			1.1.0" locally on a Microsoft Windows operating system
;			and assembled using SB-Assembler "sbasm". 6502.org
;			and easy6502.com were referenced and adapted from 
;  			during production of this program.
; ***Note:		Should the game run too fast or too slow on your system,
;			the stall subroutine can be fiddled with to allow more
;			or less NOP's to better fit your computer speed.

	.CR 6502		; Assemble 6502 Language
	.LI on,toff		; Listing on, no timings included, options separated by commas
	.TF blockade.prg,BIN	; Object file and format

;______________________________________________________________________________
;VARIABLES

;screen
first		=	$7000
second		=	$7100
third		=	$7200
fourth		=	$7300
last		=	$73e7

;Bytes that will contain the snake head address
snake1head 	= 	$10
snake2head 	= 	$12

;What each snake will look like
snake1image 	= 	snake2head+2
snake2image 	=	snake1image+1

;Key that each player presses
s1keypressed	=	snake2image+1
s2keypressed	= 	s1keypressed+1

;Snake Directions
snake1dir	=	s2keypressed+1
snake2dir	= 	snake1dir+1

;Variables for screenbox
leftboxvar 	=	snake2dir+1
rightboxvar	=	leftboxvar+2

;Key Input Variables
iobase  	= 	$8800
iostatus 	= 	$8801
iocmd   	=	$8802
ioctrl  	= 	$8803

;______________________________________________________________________________
;MAIN PROGRAM
	
			.OR $0300		;Set origin.
	
main			jsr scrclr		;Clear the screen
			jsr makebox		;Draw box around perimeter of the screen
			jsr print		;Print info on top and bottom of screen
			jsr initgame		;Initialize the game
				
mainl			jsr pollkey		;Poll for a key pressed by the user
			jsr updatesnake1	;Update snake1 using key user pressed
			jsr updatesnake2	;Update snake2 using key user pressed
			jsr tbone		;Check if snake head addresses collide
			jsr collision1		;Check if snake1 hit anything
			jsr collision2		;Check if snake2 hit anything
			jsr drawsnakes		;Draw a new piece of snake at head address
			jsr stall		;Stall so user has time to react
			jmp mainl		;Repeat entire game loop
				
;______________________________________________________________________________
; clear screen

scrclr			lda #$20		;load A with a space
			ldx #$0			;load X with a zero
cLoop			dex			;decrement x by 1 (becomes #$ff first time)
			sta first,x		;store a space at $7000 with offset of x
			sta second,x		;store a space at $7100 with offset of x
			sta third,x		;store a space at $7200 with offset of x
			cpx #$e8		;compare x to last location on screen
			bcs next		;if carry was set, skip $7300 with x offset
			sta fourth,x		;if not, store space at $7300 with offset x
next			cpx #0			;compare x to zero
			bne cLoop		;if it is not zero, branch back to cLoop
			rts			;if it is, we have cleared the screen.Done.

;______________________________________________________________________________

makebox			lda #$70		;initialize starting locations
			sta rightboxvar+1	;store "70" at high byte of rightboxvar
			sta leftboxvar+1	;store "70" at high byte of leftboxvar
			lda #$28		;load a with 40 
			sta leftboxvar		;store 40 at low byte of leftboxvar
			lda #$27		;load a with 39	
			sta rightboxvar		;store 39 at low byte of rightboxvar
			ldx #00			;load x with 0

;Print a line down the left side of screen
leftloop		lda #$E6		;load a with a checkered square
			sta (leftboxvar,x)	;store it at dereferenced leftboxvar
			clc			;clear the carry for 16 bit addition
			lda leftboxvar		;load a with low byte of leftboxvar
			adc #$28		;add 40 to it
			sta leftboxvar		;store the new value at leftboxvar low bye
			bcs overflow1		;if a carry was set, it overflowed
			ldy leftboxvar		;if it didn't overflow
			cmp #$c0		;compare it to the bottom left of screen
			beq rightloop		;if its equal, go to print the right side
			jmp leftloop 		;if not, go back to loop start
overflow1		ldy leftboxvar+1	;load y with the highbyte of leftboxvar
			iny			;increment it by 1
			tya			;transfer it back to a
			sta leftboxvar+1	;store new value at high byte of leftboxvar
			jmp leftloop		;go back to loop start
				
;Print a line down the right side of screen
rightloop		lda #$E6		;load a with a checkered square
			sta (rightboxvar,x)	;store it at dereferenced rightboxvar
			clc			;clear the carry for 16 bit addition
			lda rightboxvar		;load a with low byte of rightboxvar
			adc #$28		;add 40 to it
			sta rightboxvar		;store the new value at low byte 
			bcs overflow2		;if a carry was set, it overflowed
			ldy rightboxvar		;load y with low byte of rightboxvar
			cmp #$e7		;compare it to bottom right of screen
			beq topbot		;if its equal, go print the top and bottom
			jmp rightloop 		;if not go back to loop start
overflow2		ldy rightboxvar+1	;load y with the highbyte of rightboxvar
			iny			;increment it by 1
			tya			;transfer it back to a
			sta rightboxvar+1	;store new value at high byte
			jmp rightloop		;go back to loop start				
								
;Print lines on top/bottom of screen
topbot			ldx #00			;load x with 0
			lda #$E6		;load a with checkered square
boxloop			cpx #$28		;compare x to 40
			beq out			;if it is 40, branch to out
			sta $7000,x		;store square at $7000 with offset of x
			sta $73c0,x		;store square at $73c0 with offset of x
			inx			;increment x by 1
			jmp boxloop		;restart loop
out 			rts			;Done. Return to subroutine.

;______________________________________________________________________________
;Print instructional strings on the box perimeter 

print			ldy #$00		;load y with 0
loop			lda gametitle,y		;load a with y'th character of string
			beq print1		;if it is a 0, Done. Go print next string
			sta $7008,y		;if not, store A at $7008 with y-offset
			iny			;increment y by 1
			jmp loop		;restart loop
print1			ldy #00			;reload y with 0
loop1			lda info1,y		;load a with y'th character of string
			beq print2		;if it's a zero, Done. Go print next string
			sta $73c5,y		;if not, store A at $73c0 with y-offset
			iny			;increment y by 1
			jmp loop1		;restart loop1
print2			ldy #00			;reload y with 0
loop2			lda info2,y		;load a with y'th character of string
			beq out2		;if it's a zero, Done. Branch to out2
			sta $73d7,y		;if not, store A at $73d7 with y-offset
			iny			;increment y by 1
			jmp loop2		;restart loop2

out2			rts			;Done. Return to subroutine.

;______________________________________________________________________________
;Initialize Snakes
				
initgame		lda right		;initialize snake1's direction to right
			sta snake1dir
			lda left		;initialize snake2's direction to left
			sta snake2dir

			lda #$29		;initialize start location of snake1 head
			sta snake1head		;lowbyte
			lda #$70
			sta snake1head+1	;highbyte
				
			lda #$be		;initialize start location of snake2 head
			sta snake2head		;lowbyte
			lda #$73
			sta snake2head+1	;highbyte
				
			lda #$DE		;initialize snake1 image to a square
			sta snake1image
			lda #$DF     		;initialize snake2 image to similar square
			sta snake2image
				
			jsr drawsnakes		;draw snake head at initialized location
			
			rts			;Done. Return to subroutine
				
;______________________________________________________________________________
;Read input from keyboard for snake direction
			
pollkey			cli			;Clear interrupt to prepare for polling 
			lda #$0b		;Load A with 11
			sta iocmd		;Store 11 at iocmd ($8802)
			lda #$1d		;Load A with 29
			sta ioctrl		;Store 29 at ioctrl ($8803)
			lda iostatus		;Read the value at iostatus into A
			and #$08		;AND it with 8
			bne write		;If it's a 1, theres a character. Branch. 
			rts			;If it's not a 1, no character. Done.
write			lda iobase		;Load the character into A
			pha			;Push it to the stack
writel			lda iostatus		;Load A with the value at iostatus
			and #$10		;AND it with 10
			beq writel		;If it is 0, reloop from writel
			pla			;If its not 0, pull character from stack
			cmp w			;Compare it with a 'w' character
			beq snake1up		;If it is a 'w', we move snake1 upwards
			cmp a			;Compare it with an 'a' character
			beq snake1left		;If it is an 'a', we move snake1 left
			cmp s			;Compare it with a 's' character
			beq snake1down		;If it is a 's', we move snake1 down
			cmp d			;Compare it with a 'd' character
			beq snake1right		;If it is a 'd', we move snake1 right
			cmp i			;Compare it with an 'i' character
			beq snake2up		;If it is an 'i', we move snake2 upwards
			cmp j			;Compare it with a 'j' character
			beq snake2left		;If it is a 'j', we move snake2 left
			cmp k			;Compare it with a 'k' character
			beq snake2down		;If it is a 'k', we move snake2 down
			cmp l			;Compare it with an 'l' character
			beq snake2right		;If it is an 'l', we move snake2 right
			rts			;Not an applicable character. Done.
				
;______________________________________________________________________________
;Manipulate snake1's direction based on user key input
				
snake1up		lda snake1dir		;load A with the current snake direction
			cmp down		;if the snake was moving down
			beq invaliddir		;you aren't allowed to go up, so branch 
						;if the snake wasn't moving down
			lda up			;load A with the the value of 'up'
			sta snake1dir		;change the snake direction to up
			rts			;Done. Return to subroutine.
				
snake1left		lda snake1dir		;load A with the current snake direction
			cmp right		;if the snake was moving right
			beq invaliddir		;you aren't allowed to go left, so branch 
						;if the snake wasn't moving right
			lda left		;load A with the the value of 'left'
			sta snake1dir		;change the snake direction to left
			rts			;Done. Return to subroutine.
				
snake1down		lda snake1dir		;load A with the current snake direction
			cmp up			;if the snake was moving up
			beq invaliddir		;you aren't allowed to go down, so branch
						;if the snake wasn't moving up
			lda down		;load A with the the value of 'down'
			sta snake1dir		;change the snake direction to down
			rts			;Done. Return to subroutine.
				
snake1right		lda snake1dir		;load A with the current snake direction
			cmp left		;if the snake was moving left
			beq invaliddir		;you aren't allowed to go right, so branch
						;if the snake wasn't moving left
			lda right		;load A with the the value of 'right'
			sta snake1dir		;change the snake direction to right
			rts			;Done. Return to subroutine.
				
;______________________________________________________________________________
;Manipulate snake2's direction based on user key input
				
snake2up		lda snake2dir		;load A with the current snake direction
			cmp down		;if the snake was moving down
			beq invaliddir		;you aren't allowed to go up, so branch
						;if the snake wasn't moving down
			lda up			;load A with the the value of 'up'
			sta snake2dir		;change the snake direction to up
			rts			;Done. Return to subroutine.
				
snake2left		lda snake2dir		;load A with the current snake direction
			cmp right		;if the snake was moving right
			beq invaliddir		;you aren't allowed to go left, so branch
						;if the snake wasn't moving right
			lda left		;load A with the the value of 'left'
			sta snake2dir		;change the snake direction to left
			rts			;Done. Return to subroutine
				
snake2down		lda snake2dir		;load A with the current snake direction
			cmp up			;if the snake was moving up
			beq invaliddir		;you aren't allowed to go down, so branch
						;if the snake wasn't moving up
			lda down		;load A with the the value of 'down'
			sta snake2dir		;change the snake direction to down
			rts			;Done. Return to subroutine
				
snake2right		lda snake2dir		;load A with the current snake direction
			cmp left		;if the snake was moving left
			beq invaliddir		;you aren't allowed to go right, so branch
						;if the snake wasn't moving left
			lda right		;load A with the the value of 'right'
			sta snake2dir		;change the snake direction to right
			rts			;Done. Return to subroutine
			
invaliddir		rts			;leave so snake keeps going same direction

;______________________________________________________________________________
;Update Snake1's Head Address based off of the current snake direction 
;using a 16 bit add/subtract algorithm.

updatesnake1		lda snake1dir		;Load A with the current snake1 direction
				
			cmp up			;Check if snake1 is going up
			bne cmpleft		;Its not. Go check if it is going left.
			sec			;It is. Set carry for subtraction borrow
			lda snake1head		;Load A with lowbyte of snake1's head.
			sbc #$28		;Subtract 40 from it.
			sta snake1head		;Store the new value back into lowbyte.
			bcc s1highdec		;If carry cleared, go decrement highbyte
			rts			;Subtraction Done. Return to subroutine.
		
cmpleft			cmp left		;Check if snake1 is going left
			bne cmpdown		;Its Not. Go check if it is going down.
			sec			;It is. Set carry for subtraction borrow
			lda snake1head		;Load A with lowbyte of snake1's head.
			sbc #$01		;Subtract 1 from it.
			sta snake1head		;Store the new value back into lowbyte.
			bcc s1highdec		;If carry cleared, go decrement highbyte
			rts			;Subtraction Done. Return to subroutine.
				
cmpdown			cmp down		;Check if snake1 is going down
			bne cmpright		;Its Not. It is going right. Branch.
			clc			;It is. Clear carry to set up addition
			lda snake1head		;Load A with lowbyte of snake1's head.
			adc #$28		;Add 40 to it.
			sta snake1head		;Store the new value back into lowbyte.
			bcs s1highinc		;If carry was set, go increment highbyte
			rts			;Addition Done. Return to subroutine.
	
						;Not other 3 directions so must be right.
cmpright		clc			;Clear carry to set up addition
			lda snake1head		;Load A with lowbyte of snake1's head.
			adc #$01		;Add 1 to it.	
			sta snake1head		;Store the new value back into lowbyte.
			bcs s1highinc		;If carry was set, go increment highbyte
			rts			;Addition Done. Return to subroutine.	
				
s1highdec		ldy snake1head+1	;Load y with highbyte of snake1's head
			dey			;Decrement it by 1
			tya			;Transfer it back to A
			sta snake1head+1	;Store it back in the highbyte location
			rts			;Subtraction Done. Return to subroutine.
				
s1highinc		ldy snake1head+1	;Load y with highbyte of snake1's head
			iny			;Increment it by 1
			tya			;Transfer it back to A
			sta snake1head+1	;Store it back in the highbyte location
			rts			;Addition Done. Return to subroutine.
				
;______________________________________________________________________________	
;Update Snake2's Head Address based off of the current snake direction 
;using a 16 bit add/subtract algorithm.		

updatesnake2		lda snake2dir
				
			cmp up			;Check if snake2 is going up
			bne cmpleft2		;Its not. Go check if it is going left.
			sec			;It is. Set carry for subtraction borrow
			lda snake2head		;Load A with lowbyte of snake2's head.
			sbc #$28		;Subtract 40 from it.
			sta snake2head		;Store the new value back into lowbyte.
			bcc s2highdec		;If carry cleared, go decrement highbyte
			rts			;Subtraction Done. Return to subroutine.
				
cmpleft2		cmp left		;Check if snake2 is going left
			bne cmpdown2		;Its not. Go check if it is going down.
			sec			;It is. Set carry for subtraction borrow
			lda snake2head		;Load A with lowbyte of snake2's head.
			sbc #$01		;Subtract 1 from it.
			sta snake2head		;Store the new value back into lowbyte.
			bcc s2highdec		;If carry cleared, go decrement highbyte
			rts			;Subtraction Done. Return to subroutine.	
				
cmpdown2		cmp down		;Check if snake2 is going down
			bne cmpright2		;Its Not. It is going right. Branch.	
			clc			;It is. Clear carry to set up addition
			lda snake2head		;Load A with lowbyte of snake2's head.
			adc #$28		;Add 40 to it.
			sta snake2head		;Store the new value back into lowbyte.
			bcs s2highinc		;If carry was set, go increment highbyte
			rts			;Addition Done. Return to subroutine.	
				
						;Not other 3 directions so must be right.
cmpright2		clc			;Clear carry to set up addition
			lda snake2head		;Load A with lowbyte of snake2's head.
			adc #$01		;Add 1 to it.
			sta snake2head		;Store the new value back into lowbyte.
			bcs s2highinc		;If carry was set, go increment highbyte
			rts			;Addition Done. Return to subroutine.
				
s2highdec		ldy snake2head+1	;Load y with highbyte of snake2's head
			dey			;Decrement it by 1
			tya			;Transfer it back to A
			sta snake2head+1	;Store it back in the highbyte location
			rts			;Subtraction Done. Return to subroutine.
				
s2highinc		ldy snake2head+1	;Load y with highbyte of snake2's head
			iny			;Increment it by 1
			tya			;Transfer it back to A
			sta snake2head+1	;Store it back in the highbyte location
			rts			;Addition Done. Return to subroutine.
				
;______________________________________________________________________________
;Collision Testing

tbone			lda snake1head		;Load A with snake1's head lowbyte
			cmp snake2head		;Is it the same as snake2's head lowbyte?
			beq tbone1		;It is. Go test the high bytes now.
			rts			;No collision. Return to subroutine
tbone1			lda snake1head+1	;Load A with snake1's head highbyte
			cmp snake2head+1	;Is it the same as snake2's head highbyte?
			beq gameover3		;It is. Tie Game. Branch to gameover3.
			rts			;Head addresses not the same. No collision.

collision1		ldx #0			;Load x with 0
			lda (snake1head,x)	;Load what's at address of snake1's head
			cmp #$20		;Is it a space (from the clearscreen)?
			bne doubleCol		;Collision. Go test if snake2 crashed too.
			rts			;No Collision. Return to subroutine
				
doubleCol		lda (snake2head,x)	;Load what's at address of snake2's head
			cmp #$20		;Is it a space (from the clearscreen)?
			bne gameover3		;No. Snakes crashed simultaneously. Tie.
			jmp gameover1		;Yes. Only Snake1 crashed. Branch.
				
collision2		lda (snake2head,x)	;Load what's at address of snake2's head
			cmp #$20		;Is it a space (from the clearscreen)?
			bne gameover2		;No? Collision. Snake2 has crashed. Branch.
			rts			;Yes? No collision. Return to subroutine.

gameover1		jsr scrclr		;Clear the screen again.
			ldy #$00		;Load y with 0.
loop4			lda win2,y		;Load A with the y'th character of string.
			beq final		;If it is a 0, done printing. Branch.
			sta $71ec,y		;Store character at $71ec with offset y
			iny			;increment y by 1
			jmp loop4		;restart loop4

gameover2		jsr scrclr		;Clear the screen again.
			ldy #$00		;Load y with 0
loop3			lda win1,y		;Load A with the y'th character of string. 
			beq final		;If it is a 0, done printing. Branch.
			sta $71ec,y		;Store character at $71ec with offset y
			iny			;increment y by 1
			jmp loop3		;restart loop3
				
gameover3		jsr scrclr		;Clear the screen again.
			ldy #$00		;Load y with 0
loop5			lda tie,y		;Load A with the y'th character of string.
			beq final		;If it is a 0, done printing. Branch.
			sta $71ed,y		;Store character at $71ed with offset y
			iny			;increment y by 1
			jmp loop5		;restart loop5
				
final			brk			;Program is done executing. Break.	

;______________________________________________________________________________
;Draw Snake heads at their current address on the screen

drawsnakes		ldx #00			;Load x with 0
			lda snake1image		;Load A with what snake1 looks like
			sta (snake1head,x)	;Store it at the address of snake1's head.
			lda snake2image		;Load A with what snake2 looks like
			sta (snake2head,x)	;Store it at the address of snake2's head.
			rts			;Done drawing. Return to subroutine.
				
;______________________________________________________________________________
;Stall the game so it slows down enough for the user to react
;(255 inner-loop cycles * 4 nop's)*255 outer-loop cycles = 260100 total nop's

stall			ldy #0			;Load y with 0
stallouterloop		jsr stallinner		;Go stall the game for 1020 nop's 
			dey			;Decrement y (will become 255 first time)
			bne stallouterloop	;If y isn't 0, restart the stallouterloop.
			rts			;Done stalling. Return to subroutine.

stallinner		ldx #0			;Load x with 0
stallinnerloop		nop			;Don't do anything.
			nop			;Don't do anything.
			nop			;Don't do anything.
			nop			;Don't do anything.
			dex			;decrement x (will become 255 first time)
			bne stallinnerloop	;if x isn't 0, restart the stallinnerloop.
			rts			;Done. Return to stallouterloop.
				
;______________________________________________________________________________
;DIRECTIVES

;Strings
gametitle		.AZ "BLOCKADE-DON'T-COLLIDE!"
win1			.AZ "PLAYER 1 WINS!!!"
win2			.AZ "PLAYER 2 WINS!!!"
info1			.AZ "Player1-WASD"
info2			.AZ "Player2-IJKL"
tie			.AZ "TIE GAME O.O"

;Snake1 Controls
w     			.AS "w"
a			.AS "a"
s			.AS "s"
d  			.AS "d"

;Snake2 Controls
i			.AS "i"
j			.AS "j"
k			.AS "k"
l			.AS "l"

;Snake movement
up			.DB 1
left			.DB 2
down			.DB 3
right			.DB 4

;END OF PROGRAM			
