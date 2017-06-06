# -----------------------------------------------------------------------------
# TestProgram2
#
# This is a testProgram checking much of the required functionality of the
# processor UKM910.
# If the processor works properly, this test program should
#   -> store the value 0x001 at the address 0x12A
#   -> never branch to forbid0 or forbid1 (PC may never be 0x0ad or bigger)
#   -> end with an infinite loop at marke (address 0x02c)
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
int1:     jump  isr_int1
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


main:   load  spinit   # initial value for stack pointer
        store $sp      # store value in stack pointer register
        load  ieinit   # init interrupts: enable interrupt 1 and gie
        store $ien
        load  const1   # load constant 1 to ACC -> ACC = 1
        add   const9   # add 9         -> ACC = 10
        sub   const5   # substract 5   -> ACC = 5
        and   const6   # do AND with 6 -> ACC = 4
        not            # invert        -> ACC = -5
        comp           # complement    -> ACC = 5
        rotr           # rotate right  -> ACC = -32766

        push          # push ACC to stack
        load  const6
        push          # push arg1 on call stack
        load  $sp
        store $ptr1   # store address to A in ptr1
        load  const7
        push          # push arg2 on call stack
        load  $sp
        store $ptr2   # store address to B in ptr2
        call  multiply  # ACC = A * B = 42
        store result  # store the result
        pop           # pop arg2 from call stack
        pop           # pop arg1 from call stack
        pop           # restore ACC from stack

        bn    mark0    # branch to mark0


mark3:  store ADDR     # store result (1) at address 0x12A
        sub   const1   # substract 1 -> ACC = 0
mark1:  bz    mark1    # at ACC = 0 (infinite loop)

mark0:  shr            # shift right -> ACC = 16385
	nop	       # no operation
        bn    forbid0  # branch to forbid0 (to nothing..) -> should not be taken
        bz    forbid1  # branch to forbid1 (to nothing..) -> should not be taken
        and   const7   # do AND  with 7 -> ACC = 1
        jump  mark3    # jump to mark3

isr_int1:
        push          # push ACC to stack
        load  constF
        store tmp1    # store 0xF at tmp1
        pop           # restore ACC from stack
        reti          # return from interrupt

.type multiply, @function
multiply:
        # multiply [ptr1] and [ptr2] using the symbol 'calc'
        load  const0  # load 0
        store calc    # store current result in calc
        load  ($ptr1) # load operand A
        bz    multiply_return  # return if operand a is 0
multiply_loop:
        store ($ptr1) # save operand A
        load  ($ptr2) # load operand B
        add   calc    # compute B + [calc]
        store calc    # [calc] = ACC
        load  ($ptr1) # restore operand A
        sub   const1  # decrement A
        bz    multiply_return  # return if operand A == 0
        jump  multiply_loop  # continue the loop for A > 0
multiply_return:
        load  calc    # load result into the ACC
        ret


const0: .word 0x000
const1: .word 0x001
const2: .word 0x002
const3: .word 0x003
const4: .word 0x004
const5: .word 0x005
const6: .word 0x006
const7: .word 0x007
const8: .word 0x008
const9: .word 0x009
constA: .word 0x00A
constB: .word 0x00B
constC: .word 0x00C
constD: .word 0x00D
constE: .word 0x00E
constF: .word 0x00F

spinit:   .word 0x07FF  # stack pointer init value
ieinit:   .word 0x0102  # interrupt enable

tmp1:   .word 0x0000
calc:   .word 0x0000
result: .word 0x0000
maskZ:  .word 0x0001
maskN:  .word 0x0002
maskC:  .word 0x0004
maskOV: .word 0x0008
maskZN: .word 0x0003

ieenmask: .word 0x01FE
iflmask:  .word 0x00FE
icnt:     .word 0x0000

.set    ADDR, 0x12A << 1

forbid0: nop
forbid1: nop
        .end

