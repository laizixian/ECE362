; ECE 362 Lab 4 - Fall 2016

; Name: < enter name here >

; Lab: < enter lab division here >

; Class Number: < enter class number here >

; Use Code Warrior (CW) in Background Debug Mode (BDM) w/ USBDMLT pod

;***********************************************************************
;
; This turn-key application is a (12-hour) time-of-day clock that uses
; software delay as a timing reference.
;
;                                                                            
; Example session:
;                          
;  9S12C32 Tick Tock Clock V1.0
;  Created by:  your name and class number
;  Last updated:  date code was last updated
;
;  Enter hours: 00
;  *** ERROR *** Invalid entry - try again
;  Enter hours: 01
;  Enter minutes: A
;  *** ERROR *** Invalid entry - try again
;  Enter minutes: 30
;  Enter seconds: 99
;  *** ERROR *** Invalid entry - try again
;  Enter seconds: 2B
;  *** ERROR *** Invalid entry - try again
;  Enter seconds: 15
;  Enter a/p: x
;  *** ERROR *** Invalid entry - try again
;  Enter a/p: p
;  Starting...
;  01:30:15 pm
;  01:30:16 pm
;  01:30:17 pm
;  .
;  .
;  .
; 
; (program keeps running until process is terminated)
;


;***********************************************************************
;
; Print macro (from notes) - use to output "prompt" strings

print		MACRO
		jsr	pmsg
		fcb	CR,LF
		fcc	\1
 		fcb	CR,LF
		fcb	NULL
		ENDM

;***********************************************************************
;
; ASCII character definitions
;
CR	equ	$D	; RETURN
LF	equ	$A	; LINE FEED
NULL	equ	$0	; NULL
COLN	equ	':'	; COLON

;***********************************************************************

	org	$3800	; start of SRAM - variable declarations
hrs	rmb	1	; packed BCD storage for hours
min	rmb	1	; packed BCD storage for minutes
sec	rmb	1	; packed BCD storage for seconds
ampm	rmb	1	; am/pm flag (0 -> am, 1 -> pm)

;***********************************************************************

	org	$8000	; start of application program memory (32K Flash)

;
;Boot-up entry point
;

bootupe
	movb	#$39,INITRM	; map RAM ($3800 - $3FFF)
        lds 	#$3FCE	    	; initialize stack pointer
	jsr 	ssinit	    	; initialize system clock and serial I/O

;***********************************************************************
;
; Start Time-of-Day Clock Application (main)
;

main
	jsr	pmsg	; display welcome message
	fcb	CR,LF
	fcc	"9S12C32 Tick Tock Clock V1.0"
	fcb	CR,LF
	fcc	"Created by:  <Zixian Lai 9418-L>"
	fcb	CR,LF
	fcc	"Last updated:  <9/19/2016>"
	fcb	CR,LF,NULL

	jsr	prompt	; prompt user for initial time setting
;
; main loop
;

mloop	jsr	tdisp	; display time
	ldx	#1000	; 1000 ms delay
	jsr	delay
	jsr	clock	; increment clock by one second
	bra	mloop	; (infinite loop)

;***********************************************************************
;
; Step 1:
;
; delay subroutine
; number of milliseconds to delay (max=1000) is passed via (X) register

delay

; < place your code for delay here >
  pshx
  pshy
  pshc

loopo  
  ldy #7992
  
loopi
  dbne  y,loopi
  
  dbne  x,loopo
   
  pulc
  puly
  pulx

	rts

;***********************************************************************
;
; Step 2:
;
; clock subroutine
; increments clock by one second

clock

; < place your code for clock here >

add_sec
  ldaa  sec
  adda  #1
  daa
  staa  sec
  clc
  
check_second
  cmpa  #$60
  bne exit
  beq clr_second
  
clr_second
  ldaa  #$0
  staa  sec
  sec
  
  ldaa  min
  adca  #$0
  daa
  staa  min
  clc
  
check_minute
  cmpa  #$60
  bne exit
  beq clr_minute
  
clr_minute
  ldaa  #$0
  staa  min
  sec
  
  ldaa  hrs
  adca  #$0
  daa
  staa  hrs
  clc
  
check_hours
  cmpa  #$12
  bne change_hrs
  beq change_am_pm
  
change_am_pm
  staa  hrs
  ldaa  ampm
  eora  #1
  staa  ampm
  bra exit
  
change_hrs
  ldaa  hrs
  cmpa  #$13
  beq reset_hrs
  bra exit
  
reset_hrs
  ldaa  #$01
  staa  hrs
  
  

exit
	rts

;***********************************************************************
;
; Step 3:
;
; tdisp subroutine
; displays current time as hrs:min:sec a/p

tdisp

; < place your code for tdisp here >
  ldaa  hrs
  jsr disbyte
  ldaa  #':'
  jsr outchar
  
  ldaa  min
  jsr disbyte
  ldaa  #':'
  jsr outchar
  
  ldaa  sec
  jsr disbyte
  ldaa  #' '
  jsr outchar
  
  ldaa  ampm
  cmpa  #$0
  beq out_a
  bne out_p
  
out_a
  ldaa  #'a'
  jsr outchar
  bra end
  
out_p
  ldaa  #'p'
  jsr outchar
  bra end
  
end
  ldaa  #'m'
  jsr outchar
  jsr pmsg
  fcb CR,LF
  fcb NULL


	rts

;***********************************************************************
;
; Step 4:
;
; prompt subroutine
; initializes time variables

prompt

; < place your code for prompt here >
enter_hour
  jsr pmsg
  fcb CR, LF
  fcb 'Enter hours: '
  fcb NULL
  jsr inchar
  jsr outchar
  
  suba  #'0'
  
  
  cmpa  #$1
  bhi error_h
  cmpa  #$0
  blo error_h
  tfr a,b
  
  lslb
  lslb
  lslb
  lslb
  
  jsr inchar
  jsr outchar
  suba  #'0'
  aba
  
  cmpa  #$12
  bhi error_h
  cmpa  #$0
  blo error_h
  staa  hrs
  bra enter_minute
error_h

  print "*** ERROR *** Invalid entry - try again"

  bra enter_hour
;************************************************
enter_minute
  jsr pmsg
  fcb CR, LF
  fcb 'Enter minutes:'
  fcb NULL
  jsr inchar
  jsr outchar
  
  suba #$30
  
  cmpa  #$5
  bhi error_m
  cmpa  #$0
  blo error_m
  tfr a,b
  
  lslb
  lslb
  lslb
  lslb
  
  jsr inchar
  jsr outchar
  suba  #'0'  
  cmpa  #$9
  bhi error_m
  cmpa  #$0
  blo error_m
  
  aba
  cmpa #$59
  bhi error_m
  cmpa #$0
  blo error_m
  staa min
  
  bra enter_second
error_m  

  print "*** ERROR *** Invalid entry - try again"

  bra enter_minute
  
;************************************************
enter_second
  jsr pmsg
  fcb CR, LF
  fcb 'Enter seconds:'
  fcb NULL
  jsr inchar
  jsr outchar
  
  suba #$30
  
  cmpa  #$5
  bhi error_s
  cmpa  #$0
  blo error_s
  tfr a,b
  
  lslb
  lslb
  lslb
  lslb
  
  jsr inchar
  jsr outchar
  suba  #'0'  
  cmpa  #$9
  bhi error_s
  cmpa  #$0
  blo error_s
  
  aba
  cmpa #$59
  bhi error_s
  cmpa #$0
  blo error_s
  staa sec
  
  bra enter_ampm
error_s

  print "*** ERROR *** Invalid entry - try again"

  bra enter_second
;************************************************
enter_ampm 
  jsr pmsg
  fcb CR, LF
  fcb 'Enter a/p:'
  fcb NULL
  jsr inchar
  jsr outchar
  
  cmpa #'a'
  beq am
  cmpa #'p'
  beq pm
  bra error_ampm
  
am
  ldaa  #$0
  staa  ampm
  bra end_input

pm  
  ldaa  #$1
  staa  ampm 
  bra end_input
  
;************************************************



error_ampm

  print "*** ERROR *** Invalid entry - try again"

  bra enter_ampm
  
end_input
  jsr pmsg
  fcb CR, LF
  fcb NULL  

	rts


;***********************************************************************
; Character I/O Library and Startup Routines 
; for 9S12C32 for flash-resident applications
;***********************************************************************

; ==== SRAM Remapping Definitions

INITRM	equ	$0010	; INITRM - INTERNAL SRAM POSITION REGISTER
INITRG	equ	$0011	; INITRG - INTERNAL REGISTER POSITION REGISTER
RAMBASE	equ	$3800	; 2KB SRAM located at 3800-3FFF

; ==== CRG - Clock and Reset Generator Definitions

SYNR	EQU	$0034           ;CRG synthesizer register
REFDV	EQU	$0035           ;CRG reference divider register
CTFLG	EQU	$0036		;TEST ONLY
CRGFLG	EQU	$0037		;CRG flags register
CRGINT	EQU	$0038
CLKSEL	EQU	$0039		;CRG clock select register
PLLCTL	EQU	$003A		;CRG PLL control register
RTICTL	EQU	$003B
COPCTL	EQU	$003C
FORBYP	EQU	$003D
CTCTL	EQU	$003E
ARMCOP	EQU	$003F

; ==== SCI Register Definitions

SCIBDH	EQU	$00C8		;SCI0BDH - SCI BAUD RATE CONTROL REGISTER
SCIBDL	EQU	$00C9		;SCI0BDL - SCI BAUD RATE CONTROL REGISTER
SCICR1	EQU	$00CA		;SCI0CR1 - SCI CONTROL REGISTER
SCICR2	EQU	$00CB		;SCI0CR2 - SCI CONTROL REGISTER
SCISR1	EQU	$00CC		;SCI0SR1 - SCI STATUS REGISTER
SCISR2	EQU	$00CD		;SCI0SR2 - SCI STATUS REGISTER
SCIDRH	EQU	$00CE		;SCI0DRH - SCI DATA REGISTER
SCIDRL	EQU	$00CF		;SCI0DRL - SCI DATA REGISTER
PORTB	EQU	$0001		;PORTB - DATA REGISTER
DDRB	EQU	$0003		;PORTB - DATA DIRECTION REGISTER

;
; Initialize system clock serial port (SCI) for 9600 baud
;
; Engages PLL -> CPU bus clock is 24 MHz (instruction cycle is 41.67 ns)
;

ssinit	bclr	CLKSEL,$80	; disengage PLL to system
	bset	PLLCTL,$40	; turn on PLL
	movb	#$2,SYNR	; set PLL multiplier
	movb	#$0,REFDV	; set PLL divider
	nop
	nop
plllp   brclr CRGFLG,$08,plllp  ; while (!(crg.crgflg.bit.lock==1))
	bset  CLKSEL,$80	; engage PLL to system
;
; Disable watchdog timer (COPCTL register)
;
	movb	#$40,COPCTL	; COP off; RTI and COP stopped in BDM-mode
;
; Initialize SCI (COM port)
;
	movb	#$00,SCIBDH	; set baud rate to 9600
	movb	#$9C,SCIBDL	; 24,000,000 / 16 / 156 = 9600 (approx)
	movb	#$00,SCICR1	; $9C = 156
	movb	#$0C,SCICR2	; initialize SCI for program-driven operation
	movb	#$10,DDRB	; set PB4 for output mode
	movb	#$10,PORTB	; assert DTR pin of COM port
	rts

;
; SCI handshaking status bits
;

rxdrf    equ   $20    ; receive data register full (RDRF) mask pattern
txdre    equ   $80    ; transmit data register empty (TDRE) mask pattern

;***********************************************************************
; Name:         inchar
; Description:  inputs ASCII character from SCI serial port
;                  and returns it in the A register
; Returns:      ASCII character in A register
; Modifies:     A register
;***********************************************************************

inchar  brclr  SCISR1,rxdrf,inchar
        ldaa   SCIDRL ; return ASCII character in A register
        rts


;***********************************************************************
; Name:         outchar
; Description:  outputs ASCII character passed in the A register
;                  to the SCI serial port
;***********************************************************************

outchar brclr  SCISR1,txdre,outchar
        staa   SCIDRL ; output ASCII character to SCI
        rts


;***********************************************************************
; pmsg -- Print string following call to routine.  Note that subroutine
;         return address points to string, and is adjusted to point to
;         next valid instruction after call as string is printed.
;***********************************************************************


pmsg    pulx            ; Get pointer to string (return addr).
        psha
ploop   ldaa    1,x+    ; Get next character of string.
        beq     pexit   ; Exit if ASCII null encountered.
        jsr     outchar ; Print character on terminal screen.
        bra     ploop   ; Process next string character.
pexit   pula
        pshx            ; Place corrected return address on stack.
        rts             ; Exit routine.


;***********************************************************************
; Subroutine:	htoa
; Description:  converts the hex nibble in the A register to ASCII
; Input:	hex nibble in the A accumualtor
; Output:	ASCII character equivalent of hex nibble
; Reg. Mod.:	A, CC
;***********************************************************************

htoa    adda	 #$90
	daa
	adca	 #$40
	daa
	rts


;***********************************************************************
; Subroutine:	atoh
; Description:  converts ASCII character to a hexadecimal digit
; Input:	ASCII character in the A register
; Output:	converted hexadecimal digit returned in A register
;               CF = 0 if result OK; CF = 1 if error occurred (invalid input)
; Reg. Mod.:	A, CC
;***********************************************************************

atoh       pshb
           pshx
           pshy
           suba    #$30   ; subtract "bias" to get ASCII equivalent
           blt     outhex
           cmpa    #$0a
           bge     cont1
quithx	   clc             ; return with CF = 0 to indicate result OK
           puly
           pulx
           pulb
           rts

cont1      suba    #$07
           cmpa    #$09
           blt     outhex
           cmpa    #$10
           blt     quithx
           suba    #$20
           cmpa    #$09
           blt     outhex
           cmpa    #$10
           blt     quithx

outhex	   sec            ; set CF <- 1 to indicate error
           puly
           pulx
           pulb
           rts


;***********************************************************************
; Subroutine:	disbyte
; Description:  displays packed BCD value as two ASCII characters
; Input:	8-bit packed BCD value passed in A register
; Output:	<none>
; Reg. Mod.:	A, CC
;***********************************************************************

disbyte	psha		; save value passed on stack
	anda	#$F0	; get most significant digit of result
	lsra
	lsra
	lsra
	lsra
	jsr	htoa
	jsr	outchar	; display most significant digit
	pula		; restore original value
	anda	#$0F	; get least significant digit of resust
	jsr	htoa	; convert result to ASCII character
	jsr	outchar	; display least significant digit
	rts


;***********************************************************************
;
; If get bad interrupt, just return
;
BadInt  rti
;
;***********************************************************************
;
; Define 'where you want to go today' (reset and interrupt vectors)
;
; Note this is the "re-mapped" table in Flash (located outside debug monitor)
;
; ------------------ VECTOR TABLE --------------------

	org	$FF8A
	fdb	BadInt	;$FF8A: VREG LVI
	fdb	BadInt	;$FF8C: PWM emergency shutdown
	fdb	BadInt	;$FF8E: PortP
	fdb	BadInt	;$FF90: Reserved
	fdb	BadInt	;$FF92: Reserved
	fdb	BadInt	;$FF94: Reserved
	fdb	BadInt	;$FF96: Reserved
	fdb	BadInt	;$FF98: Reserved
	fdb	BadInt	;$FF9A: Reserved
	fdb	BadInt	;$FF9C: Reserved
	fdb	BadInt	;$FF9E: Reserved
	fdb	BadInt	;$FFA0: Reserved
	fdb	BadInt	;$FFA2: Reserved
	fdb	BadInt	;$FFA4: Reserved
	fdb	BadInt	;$FFA6: Reserved
	fdb	BadInt	;$FFA8: Reserved
	fdb	BadInt	;$FFAA: Reserved
	fdb	BadInt	;$FFAC: Reserved
	fdb	BadInt	;$FFAE: Reserved
	fdb	BadInt	;$FFB0: CAN transmit
	fdb	BadInt	;$FFB2: CAN receive
	fdb	BadInt	;$FFB4: CAN errors
	fdb	BadInt	;$FFB6: CAN wake-up
	fdb	BadInt	;$FFB8: FLASH
	fdb	BadInt	;$FFBA: Reserved
	fdb	BadInt	;$FFBC: Reserved
	fdb	BadInt	;$FFBE: Reserved
	fdb	BadInt	;$FFC0: Reserved
	fdb	BadInt	;$FFC2: Reserved
	fdb	BadInt	;$FFC4: CRG self-clock-mode
	fdb	BadInt	;$FFC6: CRG PLL Lock
	fdb	BadInt	;$FFC8: Reserved
	fdb	BadInt	;$FFCA: Reserved
	fdb	BadInt	;$FFCC: Reserved
	fdb	BadInt	;$FFCE: PORTJ
	fdb	BadInt	;$FFD0: Reserved
	fdb	BadInt	;$FFD2: ATD
	fdb	BadInt	;$FFD4: Reserved
	fdb	BadInt	;$FFD6: SCI Serial System
	fdb	BadInt	;$FFD8: SPI Serial Transfer Complete
	fdb	BadInt	;$FFDA: Pulse Accumulator Input Edge
	fdb	BadInt	;$FFDC: Pulse Accumulator Overflow
	fdb	BadInt	;$FFDE: Timer Overflow
	fdb	BadInt	;$FFE0: Standard Timer Channel 7
	fdb	BadInt  ;$FFE2: Standard Timer Channel 6
	fdb	BadInt	;$FFE4: Standard Timer Channel 5
	fdb	BadInt	;$FFE6: Standard Timer Channel 4
	fdb	BadInt	;$FFE8: Standard Timer Channel 3
	fdb	BadInt	;$FFEA: Standard Timer Channel 2
	fdb	BadInt	;$FFEC: Standard Timer Channel 1
	fdb	BadInt	;$FFEE: Standard Timer Channel 0
	fdb	BadInt	;$FFF0: Real Time Interrupt (RTI)
	fdb	BadInt	;$FFF2: IRQ (External Pin or Parallel I/O) (IRQ)
	fdb	BadInt	;$FFF4: XIRQ (Pseudo Non-Maskable Interrupt) (XIRQ)
	fdb	BadInt	;$FFF6: Software Interrupt (SWI)
	fdb	BadInt	;$FFF8: Illegal Opcode Trap ()
	fdb	bootupe	;$FFFA: COP Failure (Reset) ()
	fdb	BadInt	;$FFFC: Clock Monitor Fail (Reset) ()
	fdb	bootupe	;$FFFE: /RESET

	end

