# -----------------------------------------------------
# Program TestPS2.asm
# This program implements a Test for the PS2-Controller. 
# -----------------------------------------------------

# -----------------------------------------------------------------------------
# The Test read a Characters and put the Ascii code on the Debug LED's
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
int1:     jump  getCharRoutine
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

main:     load  spinit   # init-value for stack pointer
          store $sp      # store value in stack pointer register
          load  ieinit   # init interrupts: enable interrupt 1 and gie
          store $ien     
          # reset variables to 0
          load  const0
          store newchar
		  store debugAddr # all Leds out
          
# -----------------------------------------------------
# main loop
# -----------------------------------------------------

mloop:    load  newchar  # check if a new character has been entered
          bz    mloop    # if not, continue
		  store debugAddr
          load  const0   # load 0
          store newchar  # and reset newchar
          jump  mloop    # continue in loop

# -----------------------------------------------------
# -----------------------------------------------------
# interrupt routine to handle keyboard interface
# -----------------------------------------------------
# -----------------------------------------------------

# -----------------------------------------------------------------------------
# DONE: 14.06.17
# TODO: Interrupt Service Routine getCharRoutine 
# Functionality: This function is the Interrupt Service Routine for an 
#                interrupt caused by the keyboard interface. 
#                The ASCII code of the new character needs to be written to the
#                variable 'newchar', especially the codes important for the 
#                operation of the calculator: 
#                  digits 0-9, '/', '*', '-', '+','(',')','='
#                scancodes apart from the ones responsible for these characters
#                may be ignored. You can choose which key causes the output of
#                character '=', possible are e.g. the actual key '=' or an 
#                'enter' key.
#                The translation between scancodes and ascii codes may either 
#                be implemented in hardware or software.
# Please note: As this routine is a interrupt service routine, it is important
#              to save and restore all registers that are altered!
# -----------------------------------------------------------------------------

getCharRoutine:
        # FILL YOUR CODE HERE
		push
		load keyboardAddr # Load value from Keyboard Controller
		store newchar		
		pop
        reti





# -----------------------------------------------------
# constants
# -----------------------------------------------------
const0:   .word 0x0000  # constant zero


spinit:   .word 0x06FF  # stack pointer init value
ieinit:   .word 0x0102  # interrupt enable 

.set    keyboardAddr,  	0x0FFF << 1 # Adress for the Keyboard
.set	vgaAddr,			0x700 << 1 # First Adress for the VGA controller 
.set	debugAddr,		0xFFF << 1 # Adress of the debuging module


# -----------------------------------------------------
# variables
# -----------------------------------------------------

# new character variable
newchar:  .word 0x000
