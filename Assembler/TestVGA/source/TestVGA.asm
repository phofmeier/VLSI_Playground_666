# -----------------------------------------------------
# Program TestVGA.asm
# This program implements a simple Test for the VGA Controller. 
# -----------------------------------------------------

# -----------------------------------------------------------------------------
# 
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

main:     load  spinit   # init-value for stack pointer
          store $sp      # store value in stack pointer register
		  load	const0
		  store	outputCharTest
		  load	vgaAddr
		  store	$ptr3
                    
# -----------------------------------------------------
# main loop
# -----------------------------------------------------

mloop:    call wait_for_knop
			load outputCharTest
			add	const1
			store	outputCharTest
			store ($ptr3)inc

          jump  mloop    # continue in loop


wait_for_knop:
	# poll the knob button
    load    debugAddr
    and     maskRotEvent
    bz      wait_for_knop # knob not pushed or rotated
    # knob pushed or rotated
	ret

# -----------------------------------------------------
# -----------------------------------------------------
# output functions
# -----------------------------------------------------
# -----------------------------------------------------

# function to init screen: clear screen and output welcome message surrounded by "-"-Lines
          .type outputInitScreen, @function
outputInitScreen:
          call  outputClrScreen   # clear screen
          call  outputLine        # start with line
          load  txtWelcomeAddr    # then output message
          store $ptr2
          call  outputText
          call  outputNewLine     
          call  outputLine        # and another line, start at beginning of new line
          call  outputNewLine
          ret



# -----------------------------------------------------------------------------
# DONE: 14.06.17
# TODO: Function outputClrScreen
# Functionality: If this function is called, the screen should be cleared and 
#                the next character should be outputted at the upper-left 
#                corner.
# -----------------------------------------------------------------------------

          .type outputClrScreen, @function
outputClrScreen:
          load 	vgaAddr
		  store	$ptr3
		  load	constNrOfVgaMemory
		  store	count
		loopOutputClrScreen:
			load	const_space
			store	($ptr3)inc
			load	count
			sub		const1
			store	count
			bz		skipLoopOutputClrScreen
			jump	loopOutputClrScreen
		skipLoopOutputClrScreen:	
		  load 	vgaAddr
		  store	screenLineAddr
		  store	$ptr3
		  load 	const0
		  store	screenSecondChar  # begin with first char
		  store	screenColum
		  
          ret   


# -----------------------------------------------------------------------------
# Done: 21.06.2017
# TODO: Function outputNewLine
# Functionality: If this function is called, the following text should be 
#                outputted in the next line
# -----------------------------------------------------------------------------

          .type outputNewLine, @function
outputNewLine:
			load 	const0
			store	screenColum
			store	screenSecondChar # begin with first char
			load	screenLineAddr
			add		constLineOffset
			store	screenLineAddr
			store	$ptr3
			load	constLastAddr
			sub		screenLineAddr
			bn		rowOverflow		# check if last row then jump to first row
          ret
rowOverflow:						# set first row
			load 	vgaAddr
			store	screenLineAddr
			store	$ptr3
			ret

# -----------------------------------------------------------------------------
# Done: 21.06.2017
# TODO: Function outputChar
# Functionality: output a single character, the character to be outputted is 
#                stored in the variable 'outpchar' (-> can be loaded with
#                load outpchar). The next character should be automatically 
#                outputted at the following position.
# -----------------------------------------------------------------------------
 
          .type outputChar, @function
outputChar:
			load	screenSecondChar
			bz		printSecondChar		# check if first char or second char should be printed
			load	outpchar
			add 	constFF00			# set first 8 bit to 1
			rotr						# rotate 8 times right to have the cahr on the first 8 bit
			rotr
			rotr
			rotr
			rotr
			rotr
			rotr
			rotr
			store	firstChar			# store first char for print second
			and		constFirstCharMask	# set second char to 0x20
			store	($ptr3)				# set char to Memory
			load 	const1
			store	screenSecondChar	# next Char is a second char
			add		screenColum			# keep track of screenColum
			store	screenColum
			load	constMaxScreenColum
			sub		screenColum
			bn		ScreenLineOverflow
          ret
ScreenLineOverflow:
			call	outputNewLine		# Start in a new Line
		  ret
printSecondChar:
			load	firstChar
			and		outpchar
			store	($ptr3)inc
			load	const0
			store	screenSecondChar	# next char is first char
			load	const1
			add		screenColum			# keep track of screen colum
			store	screenColum
		  ret
		

# -----------------------------------------------------------------------------
# Done: 21.06.2017
# TODO: Function outputText
# Functionality: If this function is called, the text where the pointer $ptr2
#                points to should be outputted. The end of the text is marked
#                with a zero-byte ( 0x00 ).
# Please note: each word you load contains two bytes -> two characters to be 
#               outputted
# -----------------------------------------------------------------------------

          .type outputText, @function
outputText: 
			load	($ptr2)
			shr							# rotate 8 bit
			shr
			shr
			shr
			shr
			shr
			shr
			shr
			bz	endOfText					# if zero -> end of text
			store	outpchar
			call	outputChar
			load	($ptr2)inc
			and		constSecondByteMask		# use only second byte
			bz	endOfText					# if zero -> end of text
			store	outpchar
			call	outputChar
			jump	outputText				# process next Addres
	endOfText:
			ret

# -----------------------------------------------------------------------------
# Done: 21.06.2017
# TODO: Function outputLine
# Functionality: If this function is called, a line of "-" should be outputted 
#                (thus simply 80 characters "-")
# -----------------------------------------------------------------------------

          .type outputLine, @function
outputLine:
          call	outputNewLine		# Start with new row
		  
		  load	constLineOffset		# Number of loops
		  store	count
		loopOutputLine:
			load	charDoubleMinus
			store	($ptr3)inc		# write '--' to VGA Controller
			load	count
			sub		const1
			store	count
			bz		skipLoopOutputLine	# loop 40 times
			jump	loopOutputLine
		skipLoopOutputLine:			
		  
		  call	outputNewLine		# End in new Row
          ret


# -----------------------------------------------------------------------------
# TODO: Function outputNumber
# Functionality: If this function is called, the number stored in the variable
#                'currNum' should be outputted
# Please note: If currNum is negative, a leading "-" needs to be outputted 
#              first
# -----------------------------------------------------------------------------

          .type outputNumber, @function
outputNumber:
			# initialize everything to 0
			load	const0
			store	OutputNr_0
			store	OutputNr_1
			store	OutputNr_2
			store	OutputNr_3
			store	OutputNr_4
          # branch if negative if negative -> write '-' and complement number
			load	currNum
			bn		OutputNegNumber
		OutputPositiveNr:	# Start calculating the bin 2 decimal of the Nr.
			load	currNum
			sub 	const10k	# substract 10000
			store	currNum
			bn		firstCharReady # if curNr. negative Nr < x*10000
			load	OutputNr_0		# else Nr > x*10000  
			add		const1			# increment Char (x)
			store	OutputNr_0		# store Char
			jump	OutputPositiveNr # try again with x incremented
		firstCharReady:
			add		const10k		# add 10000	again to get back the last Nr.
		secondCharProcess:	
			sub		const1k			# substract 1000 for next decimal Position	
			store	currNum			# store the new Nr.
			bn		secondCharReady	# if negative smaller than	x* 1000
			load	OutputNr_1		# increment Char
			add		const1
			store	OutputNr_1
			load	currNum			# load Nr
			jump	secondCharProcess # start again with incrementetd x 
		secondCharReady:
			add		const1k
		thirdCharProcess:	
			sub		const100
			store	currNum
			bn		thirdCharReady
			load	OutputNr_2
			add		const1
			store	OutputNr_2
			load	currNum
			jump	thirdCharProcess
		thirdCharReady:
			add		const100
		fourthCharProcess:	
			sub		const10
			store	currNum
			bn		fourthCharReady
			load	OutputNr_3
			add		const1
			store	OutputNr_3
			load	currNum
			jump	fourthCharProcess
		fourthCharReady:
			add		const10
			store	OutputNr_4
		
	# Output the calculated Number
		load	OutputNr_0		# load first Char
		bz		OutputNoFirstElement # if zero don't output first char
		call	OutputNumberPrint	# else output all chars
		load	OutputNr_1
	OutputSecondElement:	
		call	OutputNumberPrint
		load	OutputNr_2
	OutputThirdElement:	
		call	OutputNumberPrint
		load	OutputNr_3
	OutputFourthElement:	
		call	OutputNumberPrint
		load	OutputNr_1
	OutputFifthElement:	
		call	OutputNumberPrint
		
		ret		# end of OutputNumber
		
OutputNoFirstElement:
			load	OutputNr_1				# Load second char
			bz		OutputNoSecondElement 	# if zero don't output Second Char
			jump	OutputSecondElement		# else output second to fifth char
OutputNoSecondElement:
			load	OutputNr_2
			bz		OutputNoThirdElement
			jump	OutputThirdElement
OutputNoThirdElement:
			load	OutputNr_3
			bz		OutputNoFourthElement
			jump	OutputFourthElement
OutputNoFourthElement:
			load	OutputNr_4
			jump	OutputFifthElement	
				
				
OutputNumberPrint: # print Nr. in the Accu as Ascii
			add		const_ascii_offset
			store	outpchar
			call	outputChar
			ret
		
OutputNegNumber: # for negative Nr. print "-" sign
			comp   				# complement Nr. to get positive Nr
			store	currNum		
			load 	charminus	# print minus		
			store	outpchar
			call	outputChar
			load	currNum		# load positv Nr. back to Acc
			jump	OutputPositiveNr # Print rest of the Nr like a positive Nr
          




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
const1:   .word 0x0001  # constant one
const2:   .word 0x0002  # constant two
constA:   .word 0x000A  # constant ten
constFF00: .word	0xFF00 # constant 0xFF00
const10k:	.word	0x2710 # constant 10000	
const1k:	.word	0x03E8 # constant 1000
const100:	.word	0x0064 # constant 100
const10:	.word	0x000A # constant 10

spinit:   .word 0x06FF  # stack pointer init value
ieinit:   .word 0x0102  # interrupt enable 

maskOV:    .word 0x0008 # mask for overflow bit
maskByte1: .word 0x00FF # mask for lower byte

charplus:  .ascii "\0+" 
charminus: .ascii "\0-"
charmult:  .ascii "\0*"
charopbr:  .ascii "\0("
charclbr:  .ascii "\0)"
char0:     .ascii "\0000"
char1:     .ascii "\0001"
char2:     .ascii "\0002"
char3:     .ascii "\0003"
char4:     .ascii "\0004"
char5:     .ascii "\0005"
char6:     .ascii "\0006"
char7:     .ascii "\0007"
char8:     .ascii "\0008"
char9:     .ascii "\0009"
chardiv:   .ascii "\0/"
charEq:    .ascii "\0="
charDoubleMinus: .ascii "\--"
const_space: .word 0x2020 # ASCII for double Space

const_ascii_offset: .word	0x0030 # Offset to convert from binary to ascii

constFirstCharMask:	 .word	0xFF20 # Mask for hold first byte and set second byte to 0x20(space)
constFirstByteMask:	 .word	0xFF00 # Mask for first byte
constSecondByteMask: .word	0x00FF # Mask for second byte
	
txtError:  .ascii "Error!\0\0"
txtErrorAddr:  getaddr txtError

txtResult: .ascii "Result: \0\0"
txtResultAddr: getaddr txtResult

txtWelcome: .ascii "Welcome to the ultimate LME calculator! \0\0"
txtWelcomeAddr: getaddr txtWelcome


# .set    keyboardAddr,  0x0FFF << 1 # Adress for the Keyboard
.set	vgaAddr,		0x700 << 1 # First Adress for the VGA controller 
.set	debugAddr,		0x0FFF << 1 # Adresse for debug Module

constNrOfVgaMemory:	.word	0x0640 # Nr. of VGA Memory adresses
constLineOffset: 	.word	0x0028 # Nr of Characters in One row
constLastAddr:		.word	0x0D40 # Last Addr
constMaxScreenColum: .word	0x004F	# Maximum of char per colum


# -----------------------------------------------------
# variables
# -----------------------------------------------------

# new character variable
newchar:  .word 0x000

currNum:   .word 0x000






# variables VGA
count:			.word	0x000
screenLineAddr:		.word	0x000
screenColum:	.word	0x000
screenSecondChar:	.word	0x0000

firstChar:			.word	0x0000

# variables OutputNr

OutputNr_0:	.word	0x0000
OutputNr_1:	.word	0x0000
OutputNr_2:	.word	0x0000
OutputNr_3:	.word	0x0000
OutputNr_4:	.word	0x0000


	
# Test Output
outputCharTest: .word 0x0000




