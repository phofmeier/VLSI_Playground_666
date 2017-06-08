# ------------------------------------------------------------------------------
# Program debug_processor_UKM910.asm
# This program performs some simple tests of the processor reading from and
# writing to the data bus and checking for all listed instructions
#
# Required instructions:
# load, store, and, add, shr, bz, jump, sub, not, comp, rotr, bn
#
# Note: SW0 is the reset switch.
#
# Expected functionality (# == LED on, . == LED off, + == LED blinking):
# After reset, LEDs 0 to 7 are turned on:
#   ########
#
# Pushing the rotary encoder knob lets LED0 and LED7 blink with 1Hz and turns
# LEDs 1,2,5 and 6 off again:
#   ########
# <push>
#   +..##..+
#
# The LEDs are counting up binary with every knop press.
# Every count is a test of one more Command.
#
#
# Pushing the knob again turns LED0 and LED7 off again (pushing toggles blinking
# of LED 0 and 7):
#   +..##..+
# <push>
#   ...##...
# <push>
#   +..##..+
# <push>
#   ...##...
#
# Turning the knob will move the bar (LEDs 3 and 4 are on) accross LEDs 1 to 6
# and wrap around on the borders.
#   ...##...
# <turnLeft>
#   ..##....
# <turnLeft>
#   .##.....
# <push>
#   +##....+
# <turnLeft>
#   +#....#+
# <turnLeft>
#   +....##+
# <turnLeft>
#   +...##.+
# <turnRight>
#   +....##+
# <turnRight>
#   +#....#+
# <turnRight>
#   +##....+
# <turnRight>
#   +.##...+
# <turnRight>
#   +..##..+
# <turnRight>
#   +...##.+
# <turnRight>
#   +....##+
#
# Hints for debugging:
# - All LEDs stay off:
#		Did the configuration download work? Then check the led connections from
#		the debug_module to the toplevel.
# - LEDs show pattern "10101010":
#		Check reset polarity, the clock signal, IO- and bus-connections. The
#		first two instructions (load+store) might also be the cause of the
#		problem.
# - All LEDs stay on:
#   	The load/store instructions seems to work, but one of the others
#		doesn't. Try to figure out which instruction fails by using some
#		additional stores for writing different values to the LEDs.
#
# You can extend this program to test your peripherials and other instructions,
# once it works as expected.
# ------------------------------------------------------------------------------

.section  .data

.section  .text

_start:   .global _start

          .global init
          .type init, @function
int0:	  jump init
		  
# -----------------------------------------------------
# interrupt vector routines
# -----------------------------------------------------
          .type int1, @function
int1:     jump  ISR1
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

init:
	load  spinit   # init-value for stack pointer
    store $sp      # store value in stack pointer register
    load  ieinit   # init interrupts: enable interrupt 1 and gie
    store $ien 
    # turn on all leds
    load    maskLEDs
    store   debugAddr
initloop:
    # poll the knob button
    load    debugAddr
    and     maskRotEvent
    bz      initloop # knob not pushed or rotated
    # knob pushed or rotated
    load    maskBlinkLEDs
    store   varBlinkLEDs
    add     varLEDs
    store   debugAddr
# Sub 1 -----------------------------------------------
	call wait_for_knop
	# check if sub works
    load 	const_10
	sub		const_9
	store	debugAddr    
#  not 2 --------------------------------------------------	
	call wait_for_knop
	# check if not works
	load 	const_FFFD
	not
	store	debugAddr
#  comp 3 -------------------------------------------------	
	call wait_for_knop
	# check if comp works	
    load	const_FFFD
	comp
	store	debugAddr
#  rotr 4 -------------------------------------------------
	call wait_for_knop
	# check if rotr works
	load	const_0xFFFF
	rotr
	not
	bz		rotr_ok
	jump	failureState
rotr_ok:
	load	const_4
	store	debugAddr
# bn 5 -------------------------------------------------	
	call wait_for_knop
	# check if BN works
	load	const_10
	bn		failureState
	load	const_0xFFFF
	bn		bn_ok
	jump	failureState
bn_ok:
	load	const_5
	store	debugAddr
# STORER/LOADR 6 -------------------------------------
	call wait_for_knop
	load	const_10
	store	$ptr1
	load	$ptr1
	sub const_4
	store	debugAddr
# STORERI/LOADRI 7 -----------------------------------
    call wait_for_knop
	load test_var_addr
	store	$ptr2
	load	const_10
	store	($ptr2)
	load	const_3
	load	($ptr2)
	sub		const_3
	store	debugAddr
# Debug
	call wait_for_knop
	load	Array_1_addr
	store	$ptr2
	load	const_10
	store	($ptr2)inc
	load	const_1
	load	Array_1_addr
	store	debugAddr
# STORERIinc/LOADRIinc 8 -----------------------------
	call wait_for_knop
	load	Array_1_addr
	store	$ptr2
	load	const_10
	store	($ptr2)inc
	load	const_9
	store	($ptr2)inc
	load	const_5
	store	($ptr2)inc
	load	Array_1_addr
	store	$ptr2
	load	($ptr2)inc
	store	test_var
	load	($ptr2)inc
	add		test_var
	store	test_var
	load	($ptr2)inc
	add		test_var
	store	test_var
	sub		const_16
	store	debugAddr
# STORERIdec/LOADRIdec 9	---------------------------------
	call wait_for_knop
	load	Array_3_addr
	add		const_1		#increment by 1
	store	$ptr3
	load	const_6
	store	dec($ptr3)
	load	const_5
	store	dec($ptr3)
	load	const_9
	store	dec($ptr3)
	load	Array_3_addr
	add		const_1		#increment by 1
	store	$ptr3
	load	dec($ptr3)
	store	test_var
	load	dec($ptr3)
	add		test_var
	store	test_var
	load	dec($ptr3)
	add		test_var
	store	test_var
	sub		const_11
	store	debugAddr
# OVERFLOW 10 ----------------------------------------
	call	wait_for_knop
	load	const_0xFFFF
	add		const_10
	# OVERFLOW should occures
	load 	$psw
	and 	maskOV
	bz 		failureState
	load 	const_10
	store	debugAddr
	
	
# ----------------------------------------------------	
# End of tests goto Main Loop
	call wait_for_knop
    jump    mainloop

# -----------------------------------------------------
# main loop
# -----------------------------------------------------

mainloop:
    # read debug register
    load    debugAddr
    store   varEvents
checkRotPush:
    # check if the rotary encoder knob was pushed
    and     bitRotPush
    bz      checkRotLeft # RotPush bit not present
    # knob was pushed, toggle BlinkLED bits
toggleBitsFast:
    # two possible start conditions:  case1 (enabled),  case2 (disabled)
    load    varBlinkLEDs            # 0x8100            0x0000
    add     maskBlinkLEDs           # 0x0200 (+OV)      0x8100
    and     maskBlinkLEDs           # 0x0000 (disab.),  0x8100 (enabled)
    store   varBlinkLEDs
    jump    writeLEDs # update debug register
checkRotLeft:
    load    varEvents
    and     bitRotLeft
    bz      checkRotRight # RotLeft bit not present
    # knob rotated to the left, shift bar left one bit
    load    varLEDs
    add     varLEDs
    store   varLEDs
    and     maskLEDBarOV
    bz      writeLEDs # no overflow, update debug register
    # overflow detected, remove highest bit and push it in on the right side
    load    varLEDs
    and     maskLEDBar
    add     bitLEDBarLow
    store   varLEDs
    jump    writeLEDs # update debug register
checkRotRight:
    load    varEvents
    and     bitRotRight
    bz      mainloop # RotRight bit not present
    # knob rotated to the right, shift bar right by one bit
    load    varLEDs
    shr
    store   varLEDs
    and     maskLEDBarUN
    bz      writeLEDs # no underflow, update debug register
    # underflow detected, remove lowest bit and push it in on the left side
    load    varLEDs
    and     maskLEDBar
    add     bitLEDBarHigh
    store   varLEDs
#    jump    writeLEDs
writeLEDs:
    # update debug register with new values for
    load    varBlinkLEDs
    add     varLEDs
    store   debugAddr
    jump    mainloop

# If the Program lands in this state something went wrong
failureState:
	jump	failureState
	
# Subroutine for waiting for handeling the knop
wait_for_knop:
	# poll the knob button
    load    debugAddr
    and     maskRotEvent
    bz      wait_for_knop # knob not pushed or rotated
    # knob pushed or rotated
	ret

#-------------------------------------------------------------------------------
# Interrupt Service Routine
#-------------------------------------------------------------------------------
ISR1:
	store	accu_int_save # save accu
	# IFLAG should be 0x0002
	load $iflag
	sub const_2
	bz	ISR1_ok
	jump	failureState
ISR1_ok:	
	load    const_0x00AA
    store   debugAddr
	call wait_for_knop
	load	accu_int_save # load back saved accu before leaving ISR
	reti

	
# ------------------------------------------------------------------------------
# constants
# ------------------------------------------------------------------------------
.set    debugAddr,  0x0FFF << 1 # bus address (12 bit) of the debug_module.vhd
spinit:   .word 0x07FF  # stack pointer init value
ieinit:   .word 0x0102  # interrupt enable

maskRotEvent:   .word   0xE000  # mask either rotary knob event
bitRotPush:     .word   0x8000  # rotary knob pushed
bitRotLeft:     .word   0x4000  # rotary knob turned left
bitRotRight:    .word   0x2000  # rotary knob turned right

# LED masks, high byte is blink_enable, low byte is for direct LED access as
# long as blink_enable for the particular LEDs is not set
maskBlinkLEDs:  .word   0x8100  # mask for LEDs which are turned into blinking
                                # mode on a rotary knob push, set bits have to
                                # be non-adjacient for the fast-toggle trick to
                                # work (see toggleBitsFast label)
maskLEDs:       .word   0x00FF  # mask for directly switching leds on and off
maskLEDBar:     .word   0x007E  # mask for LEDs which are part of the moving bar

maskOV:    .word 0x0008 # mask for overflow bit

# constants used for over/under-flow handling of the moving bar
maskLEDBarUN:   .word   0x0001  # underflow
bitLEDBarLow:   .word   0x0002  # lowest bit of the bar
bitLEDBarHigh:  .word   0x0040  # highest bit of the bar
maskLEDBarOV:   .word   0x0080  # overflow


# constants Numbers
const_10: 		.word	0x000A	# konstant 10
const_9:        .word   0x0009  # konstant 9
const_4:		.word	0x0004	# konstant 4
const_FFFD:		.word	0xFFFD	# konstante 0xFFFD
const_0xFFFF:	.word	0xFFFF	# konstant 0xFFFF
const_0x00AA:	.word	0x00AA	# konstant 0x00AA
const_5:		.word	0x0005	# konstant 5
const_2:		.word	0x0002	# konstant 2
const_3:		.word	0x0003	# konstant 3
const_6:		.word	0x0006	# konstant 6
const_1:		.word	0x0001	# konstant 1
const_11:		.word	0x000B	# konstant 11
const_16:		.word	0x0010	# konstant 16

# Addresses
const_10_addr:	getaddr	const_10 # address  of const_10


# ------------------------------------------------------------------------------
# variables
# ------------------------------------------------------------------------------
varBlinkLEDs:   .word   0x0000  # LEDs that are currently blinking
                                # (either 0x8100 or 0x0000)
varLEDs:        .word   0x0018  # initial LED value defining the bar
varEvents:      .word   0x0000  # temporary storage of the pushed buttons/events
test_var:		.word	0x0000	# variable for different tests

Array_1:		.word	0x0000	# Array with 3 entries
Array_2:		.word	0x0000
Array_3:		.word	0x0000

accu_int_save:	.word	0x0000	# Variable for saving the accu if an interrupt occures


# Addresses
test_var_addr:	getaddr	test_var # address  of test_var
Array_1_addr:	getaddr	Array_1 # address of Array Pos 1
Array_3_addr:	getaddr Array_3 # address of Array Pos 3
