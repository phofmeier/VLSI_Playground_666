# -----------------------------------------------------
# Program TestVGA.asm
# This program implements a simple Test for the VGA Controller. 
# -----------------------------------------------------

# -----------------------------------------------------------------------------
# The Programm write with every knop action two characters to the first two
# Characters after every write the characters will be incremented. The last 8 bit 
# of the current written Character will be outputed at the LED's
# -----------------------------------------------------------------------------

.section  .data

.section  .text

_start:   .global _start

          .global main
          .type main, @function
int0:     jump  main

# -----------------------------------------------------
# interrupt vector routines
# -----------------------------------------------------
          .type int1, @function
int1:     reti
          .type int2, @function
int2:     reti
          .type int3, @function
int3:     reti
          .type int4, @function
int4:     reti
          .type int5, @function
int5:     reti
          .type int6, @function
int6:     reti
          .type int7, @function
int7:     reti


# -----------------------------------------------------
# initialization
# -----------------------------------------------------

main:   load  	spinit   # init-value for stack pointer
        store 	$sp      # store value in stack pointer register
		load	const0
		store	outputCharTest # initilize variable with 0
		load	vgaAddr # store first VGA Adress in the third pointer
		store	$ptr3
		load 	constF
		store	debugAddr # All LEDs on
                    
# -----------------------------------------------------
# main loop
# -----------------------------------------------------

mloop:  call 	wait_for_knop  # wait until Knop is pulled	
		load 	outputCharTest # load the characters to be outputed
		add		const1         # increment by 1
		store	outputCharTest
		store 	($ptr3)inc	   # write Character to VGA
		store	debugAddr	   # write Character to LED's	
        jump  	mloop    # continue in loop


wait_for_knop: # only return when the knop is used
	# poll the knob button
    load    debugAddr
    and     maskRotEvent
    bz      wait_for_knop # knob not pushed or rotated
    # knob pushed or rotated
	ret

# -----------------------------------------------------
# constants
# -----------------------------------------------------
const0:   		.word 0x0000  # constant zero
const1:   		.word 0x0001  # constant one
constF:			.word 0x000F # constant 0xF
maskRotEvent:   .word 0xE000  # mask either rotary knob event

spinit:   		.word 0x06FF  # stack pointer init value
#ieinit:   		.word 0x0102  # interrupt enable 

#.set	keyboardAddr,	0x0FFF << 1 # Adress for the Keyboard
.set	vgaAddr,		0x0700 << 1 # First Adress for the VGA controller 
.set	debugAddr,		0x0FFF << 1 # Adresse for debug Module

#constNrOfVgaMemory:	.word	0x0640 # Nr. of VGA Memory adresses
#constLineOffset: 		.word	0x0028 # Nr of Characters in One row
#constLastAddr:			.word	0x0D40 # Last Addr
#constMaxScreenColum: 	.word	0x004F	# Maximum of char per colum


# -----------------------------------------------------
# variables
# -----------------------------------------------------
# Test Output
outputCharTest: .word 0x0000
