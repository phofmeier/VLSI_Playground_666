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


.section .data

.section .text

_start: .global _start

        .global main
int0:   jump  main
        .type int1, @function
int1:   jump  int1sr
        .type int2, @function
int2:   jump  int2sr
        .type int3, @function
int3:   jump  int3sr
        .type int4, @function
int4:   jump  int4sr
        .type int5, @function
int5:   jump  int5sr
        .type int6, @function
int6:   jump  int6sr
        .type int7, @function
int7:   jump  int7sr

        
main:   load  spinit   # initial value for stack pointer
        store $sp      # store value in stack pointer register
        load  const1   # load constant 1 to ACC -> ACC = 1
        add   const9   # add 9         -> ACC = 10
        sub   const5   # substract 5   -> ACC = 5
        and   const6   # do AND with 6 -> ACC = 4
        not            # invert        -> ACC = -5
        comp           # complement    -> ACC = 5
        rotr           # rotate right  -> ACC = -32766
        bn    mark0    # branch to mark0

mark3:  store ADDR     # store result (1) at address 0x12A
        sub   const1   # substract 1 -> ACC = 0
mark1:  bz    mark4    # at ACC = 0 (should be the case here...) go to mark4

mark0:  shr            # shift right -> ACC = 16385
	nop	       # no operation
        bn    forbid0  # branch to forbid0 (to nothing..) -> should not be taken
        bz    forbid1  # branch to forbid1 (to nothing..) -> should not be taken
        and   const7   # do AND  with 7 -> ACC = 1
        jump  mark3    # jump to mark3
        
mark4:  call  chkptrpsw # call subroutine which checks pointer and psw functionalities 
        load  ieenmask  # enable interrupts 1-7
        store $ien      
        load  iflmask   # set interrupts 1-7 active
        store $iflag
        nop             # insert nops for case that interrupt service is delayed by 1 instruction
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        load  icnt      # check value of icnt -> were 7 interrupt service routines called?
        sub   const7
marke:  bz    marke     # if yes, end with infinite loop
jump    forbid0         # otherwise jump out
        
    

      .type chkptrpsw, @function
chkptrpsw: 
        load  val1ad     # get address of first value
        store $ptr1      # save in pointer 1
        load  val2ad     # get address of second value
        store $ptr2      # save in pointer 2
        load  val3ad     # get address of third value
        store $ptr3      # save in pointer 3
        
        load  ($ptr1)    # load value: 0x5000 @ val1ad
        add   const1     # add 1
        store ($ptr1)    # store new value: 0x5001
        load  $psw       # load status word 
        bz    cont1      # should be zero 
        jump  forbid0    # -> jump out if not
cont1:  load ($ptr1)inc    # load value with post-increment: 0x5001 @ val1ad
        store tmp1       # store in temporary variable
        load  dec($ptr2)   # load value with pre-decrement: 0x7000 @ val2ad-1
        add   tmp1       # add values -> carry bit should be not set, overflow bit should be set
        load  $psw       # load psw
        store ($ptr3)inc   # save this psw at val3ad
        and   maskC      # check whether carry bit is set
        bz    cont2      # if not, got to error area
        jump  forbid0
cont2:  store ($ptr3)    # store masked psw at val3ad+1
        load  dec($ptr3)   # load psw
        and   maskOV     # check if overflow bit is set
        bz    forbid0
        load  ($ptr2)    # load value: 0x7000 @ val2ad-1
        store tmp1       
        load  ($ptr1)inc   # load value with post-increment: 0x1000 val1ad+1
        sub   tmp1       # subtract -> negative result, carry bit should be not set, overflow should be not set
        load  $psw       # load psw and...
        store dec($ptr2)   # store @ val2ad-2
        and   maskC      # check if carry bit is set
        bz    cont3    
        jump  forbid0
cont3:  load  ($ptr2)    # re-load psw and check if negative bit is set
        and   maskN      # check if negative bit is set
        bz    forbid0    
        load  ($ptr2)    # re-load psw and check if overlow bit is not set
        and   maskOV
        bz    cont4
        jump  forbid0
cont4:  load  ($ptr1)    # load value 0xA000 @ val1ad+2
        sub   const1     # substract 1 -> carry should be set, overflow shouldn't
        load  $psw       # load and store current psw
        store ($ptr2)    
        and   maskC      # check if carry bit is set
        bz    forbid0     
        load  ($ptr2)    # re-load psw
        and   maskOV     # check if overflow bit is not set
        bz    cont5      
        jump   forbid0
cont5:  load  dec($ptr2)   # load value 0x4000 @ val2ad-3
        store tmp1       
        load  ($ptr1)    # load value 0xA000 @ val1ad+2
        sub   tmp1       # substract -> carry should be set, overflow should be set
        load  $psw       
        store tmp1      
        and   maskOV     # check if overflow is set
        bz    forbid0    
        load  tmp1
        and   maskC      # check if carry is set
        bz    forbid0
        load  const0     # load 0 -> zero-flag should be set
        load  $psw  
        and   maskZ      # check if it is set
        bz    forbid0
        load  $psw       # now Z and N in psw should be reset
        and   maskZN
        bz    cont6      # check if zero
        jump  forbid0
cont6:  ret              # return

        
int1sr: load  $psw    # load psw and push on stack
        push
        load  icnt    # add 1 to icnt variable
        add   const1
        store icnt
        pop            # pop psw from stack
        store $psw
        reti          # return from interrupt

int2sr: load  $psw    # load psw and push on stack
        push
        load  icnt    # add 1 to icnt variable
        add   const1
        store icnt
        pop           # pop psw from stack
        store $psw
        reti          # return from interrupt

int3sr: load  $psw    # load psw and push on stack
        push
        load  icnt    # add 1 to icnt variable
        add   const1
        store icnt
        pop           # pop psw from stack
        store $psw
        reti          # return from interrupt

int4sr: load  $psw    # load psw and push on stack
        push
        load  icnt    # add 1 to icnt variable
        add   const1
        store icnt
        pop           # pop psw from stack
        store $psw
        reti          # return from interrupt

int5sr: load  $psw    # load psw and push on stack
        push
        load  icnt    # add 1 to icnt variable
        add   const1
        store icnt
        pop           # pop psw from stack
        store $psw
        reti          # return from interrupt

int6sr: load  $psw    # load psw and push on stack
        push
        load  icnt    # add 1 to icnt variable
        add   const1
        store icnt
        pop           # pop psw from stack
        store $psw
        reti          # return from interrupt

int7sr: load  $psw    # load psw and push on stack
        push
        load  icnt    # add 1 to icnt variable
        add   const1
        store icnt
        pop           # pop psw from stack
        store $psw
        reti          # return from interrupt


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
const0Addr: getaddr const0

spinit: .word 0x7FF

vals1:  .word 0x5000
        .word 0x1000
        .word 0xA000
val1ad: getaddr vals1

vals2:  .word 0x4000
        .word 0x0000
        .word 0x7000
val2ad: getaddr val2ad

vals3:  .fill 2,2
val3ad: getaddr val3ad
        
tmp1:   .word 0x0000
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

 