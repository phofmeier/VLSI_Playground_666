# -----------------------------------------------------
# Program Calculator.asm
# This program implements a simple calculator.
# -----------------------------------------------------

# -----------------------------------------------------------------------------
# This software is not usable as is! You need to add various functions
# implementing the interfaces to your hardware.
#
# The functions which need to be implemented are:
#    -> outputClrScreen: Clear Screen
#    -> outputNewLine: Go to new screen line
#    -> outputChar: Output a single character
#    -> outputText: Output a string
#    -> outputLine: Output a line of '-'
#    -> outputNumber: Output a number
#    -> getCharRoutine: Interrupt service routine for keyboard
# Details about each of the functions can be found below, where the function
# bodys are already defined.
#
# Upon implementing your functions, please be careful not to use any symbol
# names which are already defined somewhere else.
#
# You may of course use other functions already defined within the program,
# especially helpful might be the functions 'multiply' and 'divide' which
# implement integer multiplication and division.
# Details on how to call these functions can also be found below at the
# definition of the functions.
#
# You may of course also alter any other part of the program apart from the
# function definitions (e.g. if you need to initialize values etc.)
# -----------------------------------------------------------------------------

.section    .data

.section    .text

_start:     .global _start

      .global main
      .type main, @function
int0: jump  main

# -----------------------------------------------------
# interrupt vector routines
# -----------------------------------------------------
      .type int1, @function
int1: jump  getCharRoutine
      .type int2, @function
int2: reti
      .type int3, @function
int3: reti
      .type int4, @function
int4: reti
      .type int5, @function
int5: reti
      .type int6, @function
int6: reti
      .type int7, @function
int7: reti


# -----------------------------------------------------
# initialization
# -----------------------------------------------------
main:
      load  spinit      # init-value for stack pointer
      store $sp         # store value in stack pointer register
      load  ieinit      # init interrupts: enable interrupt 1 and gie
      store $ien
      load  brFrameBaseAddr   # init for bracket frames pointer
      store $ptr1
      load  const2      # init character mode to 2 so that - is allowed as first char
      store charmode
      # reset variables to 0
      load  const0
      store newchar
      store nextops
      store nextopp
      store charmode
      store currNum
      store currSum
      store currProd
      store lastops
      store lastopp
      store brCounter
      store error
      # call screen and output welcome message
      call  outputInitScreen

# -----------------------------------------------------
# main loop
# -----------------------------------------------------
mloop:
      load  newchar           # check if a new character has been entered
      bz    mloop             # if not, continue
      push
      load  splashShown
      bz    mloop2            # skip clearing the screen
      call  outputClrScreen   # clear screen
      load  constCalcColors
      store vgaSetColors      # set the colors
      call  outputLine        # start with line
      load  const0
      store splashShown       # screen cleared
      pop
mloop2:
      call  prcsChar          # if yes, process char
      load  const0            # load 0
      store newchar           # and reset newchar
      jump  mloop             # continue in loop



# -----------------------------------------------------
# function processing character:
# check if character is legal and if it is, call
# corresponding function
# -----------------------------------------------------

# modes:  charmode 0: last char was +,-,*,/,( : next may be number, (
#         charmode 1: last char was ) :         next may be +,-,*,/, )
#         charmode 2: last char was number :    next may be +,-,*,/, ) , number

      .type prcsChar, @function
prcsChar:
      load charmode    # load current mode
      bz   cmode0
      # obviously in mode 1 or 2 -> check common characters
      load newchar     # check if it is one of the carcters allowed in mode 1 and 2
      sub  charplus    # check +
      bz   prcsPlus
      load newchar
      sub  charminus   # check -
      bz   prcsMinus
      load newchar
      sub  charmult    # check *
      bz   prcsMult
      load newchar
      sub  chardiv     # check /
      bz   prcsDiv
      load newchar
      sub  charclbr    # check )
      bz   prcsClbr
      load newchar
      sub  charEq      # check =
      bz   prcsEq
      load charmode    # load current mode, check if in mode 1
      sub  const1
      bz   illchar     # if yes, current character is illegal
      load newchar     # in mode 2: check if number
      sub  char0
      bn   illchar     # negative result when substracting char0 code -> no number
      load char9
      sub  newchar
      bn   illchar     # negative result -> no number
      jump prcsNum

cmode0:
      load newchar
      sub  charopbr    # check (
      bz   prcsOpbr
      load newchar     # in mode 2: check if number
      sub  char0
      bn   illchar     # negative result when substracting char0 code -> no number
      load char9
      sub  newchar
      bn   illchar      # negative result -> no number
      jump prcsNum

illchar:
      ret                     # no further processing, no legal character


prcsPlus:
      load  const0            # next operation: Plus
      store nextops
      jump  prcsPlMi          # common processing of plus and minus
prcsMinus:
      load const1             # next operation: Plus
      store nextops
      jump  prcsPlMi          # common processing of plus and minus
prcsPlMi:
      load  const0            # set character mode to 0 because last char was + or -
      store charmode
      call  prcsFull          # do "full" processing: open multiplicatins, additions and resetting of
                              # lastopp, lastops, currNum
      load  nextops           # set next "stroke" operation
      store lastops
      jump  prcsChkErrAndOutp # check for errors, output and return

prcsMult:
      load  const1            # next operation: Multiply
      store nextopp
      jump  prcsMuDi          # jump to common processing for Multiplication and Division
prcsDiv:
      load  const2            # next operation: Divide
      store nextopp
prcsMuDi:
      load  const0            # set character mode to 0 because last char was * or /
      store charmode
      load  lastopp           # what was the last "point" operation
      bz    prcsMuDiNoP       # no other "point" operation to process -> only store currNum
      # otherwise need to execute either division or multiplication -> do so
      call  prcsPointOps
      load  poResult          # load multiplication or division result
      jump  prcsMuDiFinal     # do final processing steps

prcsMuDiNoP:
      load  currNum           # store current number as product term
prcsMuDiFinal:
      store currProd          # store in currProd for further processing
      load  const0            # reset currNum
      store currNum
      load  nextopp           # store next point operation
      store lastopp
      jump  prcsChkErrAndOutp # check for errors, output and return

prcsOpbr:
      load  const0            # set character mode to 0 because last char was (
      store charmode
      # opening bracket -> store currSum, currNum, lastops, lastopp (currNum has to be 0 anyways)
      load  currSum
      store ($ptr1)inc # store at pointer 1 location and increment
      load  currProd
      store ($ptr1)inc
      load  lastops
      store ($ptr1)inc
      load  lastopp
      store ($ptr1)inc
      # reset current values to 0
      load  const0
      store currSum
      store currProd
      store lastops
      store lastopp
      # increase brCounter by one
      load  brCounter
      add   const1
      store brCounter
      jump  prcsChkErrAndOutp  # check for errors, output and return

prcsClbr: # check whether there are open brackets -> if not, illegal character at this point
      load  brCounter
      bz    illchar
      load  const1            # set character mode to 1 because last char was )
      store charmode
      call  prcsClbrFunc      # call function processing closing bracket
      jump  prcsChkErrAndOutp # check for errors, output and return

prcsNum:
      load  const2            # set character mode to 2 because last char was number
      store charmode
      load  currNum           # multiply current number by 10
      store poArg1
      load  constA
      store poArg2
      call  multiply          # multiplication result in poResult
      load  newchar           # get new digit
      sub   char0
      add   poResult
      store currNum           # store as new number
      # check if overflow occured, if so, set error
      load  $psw
      and   maskOV            # mask overflow bit
      bz    prcsChkErrAndOutp # do nothing if not set
      load  const1            # otherwise, set error bit
      store error
      jump  prcsChkErrAndOutp # check for errors, output and return


prcsEq:   # check if there are still open brackets -> if so, process these first until all are closed
prcsEqBrLoop:
      load  brCounter
      bz    prcsEqNoBr
      call  prcsClbrFunc
      jump  prcsEqBrLoop
prcsEqNoBr:
      # do full processing of current values and store result in currNum
      call  prcsFull
      load  currSum
      store currNum
      # check if error occured
      load  error
      bz    prcsEqNoErr
      # if yes, go to standard error processing routine
      jump  prcsChkErrAndOutp
prcsEqNoErr:
      # output result in new line
      call  outputNewLine
      # output text "Result:"
      load  txtResultAddr
      store $ptr2
      call  outputText
      # output result
      call  outputNumber
      # output new line and separation line
      call  outputNewLine
      call  outputLine
      # reset all values and proceed
      jump  prcsResetAll


prcsChkErrAndOutp:
      load  error             # check if error occured
      bz    prcsChkErrNoErr
      # error occured -> output text "Error!" in new line
      call  outputNewLine
      load  txtErrorAddr
      store $ptr2
      call  outputText
      # output new line and separation line
      call  outputNewLine
      call  outputLine
      # then reset all variables
prcsResetAll:
      load  const0
      store currNum
      store currSum
      store currProd
      store lastops
      store lastopp
      store brCounter
      store error
      store charmode
      load  const2            # reset character mode to 2
      store charmode
      load  brFrameBaseAddr
      store $ptr1
      ret                     # and return

prcsChkErrNoErr:
      # output current character
      load  newchar
      store outpchar
      call  outputChar
      ret                     # and return


# function to process point operations -> check which operation is to be executed, execute it
# and store result in poResult
      .type prcsPointOps, @function
prcsPointOps:
      load  currNum           # current number
      store poArg2            # store as argument 2 (divisor or product term)
      load  currProd          # product value
      store poArg1            # store as argument 1
      load  lastopp           # 1 if multiplication
      sub   const1
      bz    prcsPointOpsMult
      call  divide            # call division function
      jump  prcsPointOpsCont1
prcsPointOpsMult:
      call  multiply
prcsPointOpsCont1:
      ret


# function to do full processing: first do open multiplications, then additions, store result in currSum
      .type prcsFull, @function
prcsFull:
      load lastopp
      bz    prcsFullNoPop  # no open point operation
      # otherwise process point operations
      call  prcsPointOps
      load  poResult          # load multiplication or division result
      store currNum           # store in currNum for further processing
      load  const0            # set lastopp to zero as it has been regarded
      store lastopp
      # continue with necessary additions / substractions
prcsFullNoPop:
      load  lastops           # get last "stroke" operation
      bz    prcsFullAdd       # 0 -> Addidion
      load  currSum           # load current Sum value
      sub   currNum           # substract current number value
      store currSum           # store as sum
      jump  prcsFullChkErr    # common continuation
prcsFullAdd:
      load  currSum           # load current Sum value
      add   currNum           # add current number value
      store currSum           # store as sum
prcsFullChkErr:
      # check if overflow occured, if so, set error
      load  $psw
      and   maskOV            # mask overflow bit
      bz    prcsFullFinal     # do nothing if not set
      load  const1            # otherwise, set error bit
      store error
prcsFullFinal:
      load  const0            # reset current number value
      store currNum
      ret                     # return from subprogram


# function to process closing bracket: do full processing of current values and rebuilt former value frame
      .type prcsClbrFunc, @function
prcsClbrFunc:
      # closing bracket -> first, full processing of current values
      call  prcsFull
      # save result in currNum
      load  currSum
      store currNum
      # get back value frame
      load  dec($ptr1)
      store lastopp
      load  dec($ptr1)
      store lastops
      load  dec($ptr1)
      store currProd
      load  dec($ptr1)
      store currSum
      # decrease brCounter by one
      load  brCounter
      sub   const1
      store brCounter
      ret                     # return from subprogram


# -----------------------------------------------------
# Multiplication function
# -----------------------------------------------------
# -----------------------------------------------------
# Use: Store first argument in the variable poArg1,
#      the second argument in poArg2
#      This function calculates the value of
#      poArg1*poArg2,
#      the result is stored in the variable poResult
#      The values of poArg1 and poArg2 are altered
#      after the function call!
# -----------------------------------------------------
# function implementing multiplication
      .global multiply
      .type multiply, @function
multiply: # first make all input numbers positive and check if multiplication result needs to be negated
      load  const0
      store poResult          # set poResult to definite 0
      store negResult
      load  poArg1            # load first argument
      bn    multiplyNegA1     # check if negative
      jump  multiplyChkNegA2
multiplyNegA1:
      comp                    # if negative, make positive
      store poArg1
      load  negResult         # negate negResultFlag
      not
      store negResult
multiplyChkNegA2:             # check same way for argument 2
      load  poArg2
      bn    multiplyNegA2
      jump  multiplyStart
multiplyNegA2:
      comp
      store poArg2
      load  negResult
      not
      store negResult

multiplyStart:
      load  poArg2
# multiplication main loop: check each bit of arg1 on being set or not, if set, add accordingly shifted arg2
multiplyLoop:
      bz    multiplyNeg
      and   const1
      bz    multiplyCont1
      load  poArg1
      add   poResult
      bn    multiplyErr       # if the result becomes negative, an overflow occured -> error
      store poResult
multiplyCont1:
      load  poArg1            # emulate left-shift by addition
      add   poArg1
      store poArg1
      bn    multiplyErr       # if the left-shifted argument becomes negative, an overflow occured -> error
      load  poArg2
      shr
      store poArg2
      jump  multiplyLoop

multiplyNeg:
      load  negResult         # make result negative if necessary
      bz    multiplyFinish
      load  poResult
      comp
      store poResult
multiplyFinish:
      ret

multiplyErr:                  # if error occured, only set error flag and leave subroutine
      load  const1
      store error
      ret



# -----------------------------------------------------
# Divivion function
# -----------------------------------------------------
# -----------------------------------------------------
# Use: Store first argument in the variable poArg1,
#      the second argument in poArg2
#      This function calculates the integer value of
#      poArg1/poArg2,
#      the result is stored in the variable poResult,
#      the remainder of the division is stored in the
#      variable poArg1.
# -----------------------------------------------------
      .type divide, @function
divide: # first make all input numbers positive and check if division result needs to be negated
      load  poArg2
      bz    divideThroughZero
      load  const0
      store poResult          # set poResult to definite 0
      store negResult
      load  poArg1            # load first argument
      bn    divideNegA1       # check if negative
      jump  divideChkNegA2
divideNegA1:
      comp                    # if negative, make positive
      store poArg1
      load  negResult         # negate negResultFlag
      not
      store negResult
divideChkNegA2:               # check same way for argument 2
      load  poArg2
      bn    divideNegA2
      jump  divideStart
divideNegA2:
      comp
      store poArg2
      load  negResult
      not
      store negResult

# right-shift arg2 until arg2>arg1 and accordingly right-shift 1 in dividePos to show current position
divideStart:
      load  const1            # init dividePos
      store dividePos
divideUpLoop:
      load  poArg1
      sub   poArg2
      bn    divideStartDown   # arg2 > arg1 -> start reverse process
      load  poArg2            # calc poArg2 * 2
      add   poArg2
      store poArg2
      load  dividePos         # calc dividePos * 2 (equals dividePos << 1)
      add   dividePos
      store dividePos
      jump  divideUpLoop

divideStartDown:              # init values to value where poArg2 just smaller poArg1
      load  poArg2
      shr
      store poArg2
      load  dividePos
      shr
      store dividePos

divideDownLoop:
      bz    divideNeg         # when dividePos == 0 (value shifted "out") quit division loop
      load  poArg1            # otherwise calc poArg1-poArg2
      sub   poArg2
      bn    divideDownLoopCont # if poArg2 > poArg1 don't save result, continue loop
      store poArg1            # otherwise store result
      load  dividePos         # and add corresponding value to result
      add   poResult
      store poResult
divideDownLoopCont:
      load  poArg2            # shift right (-> divide by 2) poArg2 and dividePos
      shr
      store poArg2
      load  dividePos
      shr
      store dividePos
      jump  divideDownLoop    # and continue
divideNeg:
      load  negResult         # make result negative if necessary
      bz    divideFinish
      load  poResult
      comp
      store poResult
divideFinish:
      ret

divideThroughZero:
      call  outputNewLine
      load  txtDivideThroughZeroAddr    # then output message
      store $ptr2
      call  outputText
      load  const1            # otherwise, set error bit
      store error
      ret



# -----------------------------------------------------
# -----------------------------------------------------
# output functions
# -----------------------------------------------------
# -----------------------------------------------------

# function to init screen: clear screen and output welcome message surrounded by "-"-Lines
      .type outputInitScreen, @function
outputInitScreen:
      ;call  outputClrScreen   # clear screen
      ;call  outputLine        # start with line
      ;load  txtWelcomeAddr    # then output message
      ;store $ptr2
      ;call  outputText
      ;call  outputNewLine
      ;call  outputLine        # and another line, start at beginning of new line
      ;call  outputNewLine
      load  constSplashColors
      store vgaSetColors      # set the colors
      store vgaCmdLoadSplash  # load the splash data to the VGA memory
      load  const1
      store splashShown       # splash is shown
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
      load  vgaAddr
      store $ptr3
      load  constNrOfVgaMemory
      store count
loopOutputClrScreen:
      load  const_space
      store ($ptr3)inc
      load  count
      sub   const1
      store count
      bz    skipLoopOutputClrScreen
      jump  loopOutputClrScreen
skipLoopOutputClrScreen:
      load  vgaAddr
      store screenLineAddr
      store $ptr3
      load  const0
      store screenColum
      load  const1
      store screenFirstChar  # begin with first char
      ret


# -----------------------------------------------------------------------------
# Done: 21.06.2017
# TODO: Function outputNewLine
# Functionality: If this function is called, the following text should be
#                outputted in the next line
# -----------------------------------------------------------------------------
      .type outputNewLine, @function
outputNewLine:
      load  const1
      store screenFirstChar         # begin with first char
      load  const0
      store screenColum
      load  screenLineAddr
      add   constLineOffset
      store screenLineAddr
      store $ptr3
      load  constLastAddr
      sub   screenLineAddr
      bn    rowOverflow             # check if last row then jump to first row
      ret
rowOverflow:                        # set first row
      call  outputClrScreen
      load  vgaAddr
      store screenLineAddr
      store $ptr3
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
      load  screenFirstChar
      bz    printSecondChar         # check if first char or second char should be printed
      load  outpchar
      #add   constFF00               # set first 8 bit to 1
      rotr                          # rotate 8 times right to have the cahr on the first 8 bit
      rotr
      rotr
      rotr
      rotr
      rotr
      rotr
      rotr
      store	firstChar               # store first char for print second
      and   constFirstCharMask      # set second char to 0x20
      store ($ptr3)                 # set char to Memory
      load  const0
      store screenFirstChar         # next Char is a second char
      add   screenColum             # keep track of screenColum
      store screenColum
      load  constMaxScreenColum
      sub   screenColum
      bn    ScreenLineOverflow
      ret
ScreenLineOverflow:
      call  outputNewLine           # Start in a new Line
      ret
printSecondChar:
      ;load  firstChar
      ;and   outpchar
      load  outpchar
      add   firstChar
      store ($ptr3)inc
      load  const1
      store screenFirstChar         # next char is first char
      load  const1
      add   screenColum             # keep track of screen colum
      store screenColum
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
      load  ($ptr2)
      shr                           # shift 8 bit
      shr
      shr
      shr
      shr
      shr
      shr
      shr
      bz    endOfText               # if zero -> end of text
      store outpchar
      call  outputChar
      load  ($ptr2)inc
      and   constSecondByteMask     # use only second byte
      bz    endOfText               # if zero -> end of text
      store outpchar
      call  outputChar
      jump  outputText              # process next Addres
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
      load  constLineOffset         # Number of loops
      store count
loopOutputLine:
      load  charDoubleMinus
      store ($ptr3)inc              # write '--' to VGA Controller
      load  count
      sub   const1
      store count
      bz    skipLoopOutputLine      # loop 40 times
      jump  loopOutputLine
skipLoopOutputLine:
      call  outputNewLine           # End in new Row
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
      load  const0
      store OutputNr_0
      store OutputNr_1
      store OutputNr_2
      store OutputNr_3
      store OutputNr_4
      # branch if negative if negative -> write '-' and complement number
      load  currNum
      bn    OutputNegNumber
OutputPositiveNr:             # Start calculating the bin 2 decimal of the Nr.
      load  currNum
      sub   const10k          # substract 10000
      store currNum
      bn    firstCharReady    # if curNr. negative Nr < x*10000
      load  OutputNr_0        # else Nr > x*10000
      add   const1            # increment Char (x)
      store OutputNr_0        # store Char
      jump  OutputPositiveNr  # try again with x incremented
firstCharReady:
      add   const10k          # add 10000 again to get back the last Nr.
secondCharProcess:
      sub   const1k           # substract 1000 for next decimal Position
      store currNum           # store the new Nr.
      bn    secondCharReady   # if negative smaller than	x* 1000
      load  OutputNr_1        # increment Char
      add   const1
      store OutputNr_1
      load  currNum           # load Nr
      jump  secondCharProcess # start again with incrementetd x
secondCharReady:
      add   const1k
thirdCharProcess:
      sub   const100
      store currNum
      bn    thirdCharReady
      load  OutputNr_2
      add   const1
      store OutputNr_2
      load  currNum
      jump  thirdCharProcess
thirdCharReady:
      add   const100
fourthCharProcess:
      sub   const10
      store currNum
      bn    fourthCharReady
      load  OutputNr_3
      add   const1
      store OutputNr_3
      load  currNum
      jump  fourthCharProcess
fourthCharReady:
      add   const10
      store OutputNr_4

      # Output the calculated Number
      load  OutputNr_0              # load first Char
      bz    OutputNoFirstElement    # if zero don't output first char
      call  OutputNumberPrint       # else output all chars
      load  OutputNr_1
OutputSecondElement:
      call  OutputNumberPrint
      load  OutputNr_2
OutputThirdElement:
      call  OutputNumberPrint
      load  OutputNr_3
OutputFourthElement:
      call  OutputNumberPrint
      load  OutputNr_4
OutputFifthElement:
      call  OutputNumberPrint
      ret               # end of OutputNumber

OutputNoFirstElement:
      load	OutputNr_1                    # Load second char
      bz		OutputNoSecondElement   # if zero don't output Second Char
      jump	OutputSecondElement           # else output second to fifth char
OutputNoSecondElement:
      load	OutputNr_2
      bz		OutputNoThirdElement
      jump	OutputThirdElement
OutputNoThirdElement:
      load  OutputNr_3
      bz    OutputNoFourthElement
      jump  OutputFourthElement
OutputNoFourthElement:
      load  OutputNr_4
      jump  OutputFifthElement

OutputNumberPrint: # print Nr. in the Accu as Ascii
      add   const_ascii_offset
      store outpchar
      call  outputChar
      ret

OutputNegNumber: # for negative Nr. print "-" sign
      comp                    # complement Nr. to get positive Nr
      store currNum
      load  charminus         # print minus
      store outpchar
      call  outputChar
      load  currNum           # load positv Nr. back to Acc
      jump  OutputPositiveNr  # Print rest of the Nr like a positive Nr





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
      load keyboardAddr  # Load value from Keyboard Controller
      store newchar
      pop
      reti


# -----------------------------------------------------
# constants
# -----------------------------------------------------
const0:     .word 0x0000  # constant zero
const1:     .word 0x0001  # constant one
const2:     .word 0x0002  # constant two
constA:     .word 0x000A  # constant ten
constFF00:  .word 0xFF00 # constant 0xFF00
const10k:   .word 0x2710 # constant 10000
const1k:    .word 0x03E8 # constant 1000
const100:   .word 0x0064 # constant 100
const10:    .word 0x000A # constant 10

spinit:     .word 0x07FF  # stack pointer init value
ieinit:     .word 0x0102  # interrupt enable

maskOV:     .word 0x0008 # mask for overflow bit
maskByte1:  .word 0x00FF # mask for lower byte

charplus:   .ascii "\0+"
charminus:  .ascii "\0-"
charmult:   .ascii "\0*"
charopbr:   .ascii "\0("
charclbr:   .ascii "\0)"
char0:      .ascii "\0000"
char1:      .ascii "\0001"
char2:      .ascii "\0002"
char3:      .ascii "\0003"
char4:      .ascii "\0004"
char5:      .ascii "\0005"
char6:      .ascii "\0006"
char7:      .ascii "\0007"
char8:      .ascii "\0008"
char9:      .ascii "\0009"
chardiv:    .ascii "\0/"
charEq:     .ascii "\0="
charDoubleMinus: .ascii "\--"
const_space: .word 0x2020 # ASCII for double Space

const_ascii_offset:     .word 0x0030 # Offset to convert from binary to ascii

constFirstCharMask:     .word 0xFF20 # Mask for hold first byte and set second byte to 0x20(space)
constFirstByteMask:     .word 0xFF00 # Mask for first byte
constSecondByteMask:    .word 0x00FF # Mask for second byte

txtError:         .ascii "Error!\0\0"
txtErrorAddr:     getaddr txtError

txtResult:        .ascii "Result: \0\0"
txtResultAddr:    getaddr txtResult

txtWelcome:       .ascii "Welcome to the ultimate LME calculator! \0\0"
txtWelcomeAddr:   getaddr txtWelcome

txtDivideThroughZero: .ascii "Really??? \0\0"
txtDivideThroughZeroAddr: getaddr txtDivideThroughZero


vgaAddr:    .word 0x0800 # First Address for the VGA controller
.set    keyboardAddr,     0x0FFF << 1  # Address for the Keyboard
.set    vgaSetColors,     0x0FFE << 1  # Address to set new colors
.set    vgaCmdLoadSplash, 0x0FFD << 1  # Address to trigger reloading the splash

constNrOfVgaMemory:   .word 0x0640  # Nr. of VGA Memory adresses
constLineOffset:      .word 0x0028  # Nr of Characters in One row
constLastAddr:        .word 0x0E3F  # Last Addr
constMaxScreenColum:  .word 0x004F  # Maximum of char per colum

constSplashColors:    .word 0x0019  # cyan (background) & blue (foreground)
constCalcColors:      .word 0x0006  # black (background) & yellow (foreground)


# -----------------------------------------------------
# variables
# -----------------------------------------------------
splashShown:      .word 0x0001

# new character variable
newchar:    .word 0x000

# variables in processing routines
nextops:    .word 0x000
nextopp:    .word 0x000
charmode:   .word 0x000

currNum:    .word 0x000
currSum:    .word 0x000
currProd:   .word 0x000
lastops:    .word 0x000
lastopp:    .word 0x000

brCounter:  .word 0x000

# error flag
error:      .word 0x000


# variables in divide/multiplication routines
poArg1:     .word 0x000
poArg2:     .word 0x000
poResult:   .word 0x000

negResult:  .word 0x000
dividePos:  .word 0x000

# variables in output functions
outpchar:         .word 0x0000

# variables VGA
count:            .word 0x000
screenLineAddr:   .word 0x000
screenColum:      .word 0x000
screenFirstChar:  .word 0x0001

firstChar:        .word 0x0000

# variables OutputNr

OutputNr_0:       .word 0x0000
OutputNr_1:       .word 0x0000
OutputNr_2:       .word 0x0000
OutputNr_3:       .word 0x0000
OutputNr_4:       .word 0x0000

# bracket pointer frame base
brFrameBaseAddr:  getaddr brFrameBase
brFrameBase:      .word 0x000
