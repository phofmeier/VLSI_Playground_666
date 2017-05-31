# ------------------------------------------------------------------------------
# Program debug_processor_simple.asm
# This program performs some simple tests of the processor reading from and
# writing to the data bus.
#
# Required instructions:
# load, store, and, bz, jump
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
#   ++++++++
#
# Pushing or turning the knob again turns all LEDs off again.
#   ++++++++
# <push>
#   ........
# <push>
#   ++++++++
# <push>
#   ........
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
# -----------------------------------------------------
# initialization
# -----------------------------------------------------

init:
    # turn on all leds
    load    maskLEDs
    store   debugAddr

# -----------------------------------------------------
# main loop
# -----------------------------------------------------
mainloop:
    # poll the knob button
    load    debugAddr
    and     maskRotEvent
    bz      mainloop # knob not pushed or rotated
    # knob pushed or rotated
    load    varBlinkLEDs
    bz      enableBlinkLEDs # leds not blinking, turn them on
    # leds blinking, turn them off
    load    constZero
    store   varBlinkLEDs
    store   debugAddr
    jump    mainloop
enableBlinkLEDs:
    # leds off, make them blinking
    load    maskBlinkLEDs
    store   varBlinkLEDs
    store   debugAddr
    jump    mainloop


# ------------------------------------------------------------------------------
# constants
# ------------------------------------------------------------------------------
.set    debugAddr,  0x0FFF << 1 # bus address (12 bit) of the debug_module.vhd

maskRotEvent:   .word   0xE000  # mask either rotary knob event

# LED masks, high byte is blink_enable, low byte is for direct LED access as
# long as blink_enable for the particular LEDs is not set
maskBlinkLEDs:  .word   0xFF00  # mask for LEDs which are turned into blinking
                                # mode
maskLEDs:       .word   0x00FF  # mask for directly switching leds on and off
constZero:      .word   0x0000

# ------------------------------------------------------------------------------
# variables
# ------------------------------------------------------------------------------
varBlinkLEDs:   .word   0x0000  # LEDs that are currently blinking

