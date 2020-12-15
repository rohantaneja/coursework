; Tiny two-thread scheduler

; Definitions  -- references to 'UM' are to the User Manual.

; Timer Stuff -- UM, Table 173

T0	equ	0xE0004000	; Timer 0 Base Address
T1	equ	0xE0008000

IR	equ	0		; Add this to a timer'ss base address to get actual register address
TCR	equ	4
MCR	equ	0x14
MR0	equ	0x18

TimerCommandReset		equ	2
TimerCommandRun			equ	1
TimerModeResetAndInterrupt	equ	3
TimerResetTimer0Interrupt	equ	1
TimerResetAllInterrupts	equ	0xFF

; VIC Stuff -- UM, Table 41
VIC		equ	0xFFFFF000	; VIC Base Address
IntEnable	equ	0x10
VectAddr	equ	0x30
VectAddr0	equ	0x100	; fixed -- was 0x30 in the lecture
VectCtrl0	equ	0x200

Timer0ChannelNumber	equ	4	; UM, Table 63
Timer0Mask		equ	1<<Timer0ChannelNumber	; UM, Table 63
IRQslot_en		equ	5		; UM, Table 58

IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C

	area	tcd,code,readonly
	export	__main
__main
; initialisation code
	mov	r0,#0
	ldr	r1,=curTh
	str	r0,[r1]	       		; zero indicates no 'current thread'

; initialise thread1 data space

	ldr	r1,=t1Space

	ldr	r2,=t1prog		; first instruction of program 1
	str	r2,[r1,#pcs]		; initial program counter

	add	r2,r1,#threadSpace
	str	r2,[r1,#rss+13*4]	; initial stack pointer (r13) value

	mov	r2,#0x00000010		; user mode, all other bits zeroed
	str	r2,[r1,#cpsrs]		; initial CPSR

	ldr	r2,=t2Space	   	; make the 'next' thread t2
	str	r2,[r1,#next]

; initialise thread2 data space

	ldr	r1,=t2Space

	ldr	r2,=t2prog		; first instruction of program 2
	str	r2,[r1,#pcs]		; initial program counter

	add	r2,r1,#threadSpace
	str	r2,[r1,#rss+13*4]	; initial stack pointer (r13) value

	mov	r2,#0x00000010		; user mode, all other bits zeroed
	str	r2,[r1,#cpsrs]		; initial CPSR

	ldr	r2,=t1Space		; make the 'next' thread t1
	str	r2,[r1,#next]

; Initialise the VIC

	ldr	r0,=VIC			; looking at the VIC

	ldr	r1,=irqhan
	str	r1,[r0,#VectAddr0] 	; associate our interrupt handler with Vectored Interrupt 0

	mov	r1,#Timer0ChannelNumber+(1<<IRQslot_en)
	str	r1,[r0,#VectCtrl0] 	; make Timer 0 interrupts the source of Vectored Interrupt 0

	mov	r1,#Timer0Mask
	str	r1,[r0,#IntEnable]	; enable Timer 0 interrupts to be recognised by the VIC

	mov	r1,#0
	str	r1,[r0,#VectAddr]   	; remove any pending interrupt (may not be needed)

; Initialise Timer 0

	ldr	r0,=T0			; looking at Timer 0

	mov	r1,#TimerCommandReset
	str	r1,[r0,#TCR]		; reset and stop counting

	mov	r1,#TimerResetAllInterrupts
	str	r1,[r0,#IR]	   	; remove any pending interrupt requests

	ldr	r1,=(14745600/400)-1	; 2.5 ms = 1/400 second
	str	r1,[r0,#MR0]

	mov	r1,#TimerModeResetAndInterrupt
	str	r1,[r0,#MCR]		; reset count and generate an interrupt each time

	mov	r1,#TimerCommandRun
	str	r1,[r0,#TCR]		; Start timer

;from here, initialisation is finished -- we wait here until the threads have started.
idle	b	idle  			; Once the scheduler has started, it'll never be executed again.

; Initialisation is finished, now do the "application" part of the program -- make the LEDs light in sequence

; Thread 1 Code -- this is the program that will be executed by Thread 1
t1prog

; This is identical to the walking-led sample

	ldr	r1,=IO1DIR
	ldr	r2,=0x000f0000	;select P1.19--P1.16
	str	r2,[r1]		;make them outputs
	ldr	r1,=IO1SET
	str	r2,[r1]		;set them to turn the LEDs off
	ldr	r2,=IO1CLR
; r1 points to the SET register
; r2 points to the CLEAR register

	ldr	r5,=0x00100000	; end when the mask reaches this value
wloop	ldr	r3,=0x00010000	; start with P1.16.
floop	str	r3,[r2]	   	; clear the bit -> turn on the LED

;delay for about a half second
	ldr	r4,=4000000
dloop	subs	r4,r4,#1
	bne	dloop

	str	r3,[r1]		;set the bit -> turn off the LED
	mov	r3,r3,lsl #1	;shift up to next bit. P1.16 -> P1.17 etc.
	cmp	r3,r5
	bne	floop
	b	wloop
; Thread execution will never drop below the statement above.

; Thread 2 Code -- this is the program that will be executed by Thread 2
t2prog
; This is almost a direct copy of the "application" part of Practical 4 -- driving the RGB LEDS
; the interrupt handler incorporates the timer update code.
; and this runs as before in the user mode, polling on the tick count.
; Some labels have been changed to prevent a clash.

IO0DIR	EQU	0xE0028008
IO0SET	EQU	0xE0028004
IO0CLR	EQU	0xE002800C

RGB_R_BIT       EQU     17
RGB_G_BIT       EQU     21
RGB_B_BIT       EQU     18

	ldr	r1,=IO0DIR
	ldr	r0,=(1<<RGB_R_BIT)+(1<<RGB_G_BIT)+(1<<RGB_B_BIT)
	str	r0,[r1]		;make them outputs
	ldr	r1,=IO0SET
	str	r0,[r1]		;set them to turn the LEDs off
	ldr	r2,=IO0CLR

; so, R0 has the mask, R1 the address of the set register, R2 the address of the clear register
floop2   mov     r3,#8           ; number of entries in the table
        ldr     r4,=displaytable

finc    ldr     r5,[r4]
        add     r4,#4
        str     r5,[r2]         ; turn on the LED
        ldr     r6,=tickcount
        ldr     r7,[r6]
        add     r7,#1000000/2500      ; number of ticks corresponding to 2.5 milliseconds seconds
dloop2  ldr     r8,[r6]
        cmp     r8,r7
        bne     dloop2           ; loop until a second has gone by
        str     r5,[r1]         ; turn off the LED
        subs    r3,#1
        bne     finc
        b       floop2

; thread execution will never drop below here

displaytable			; see https://lospec.com/palette-list/3-bit-rgb
		dcd		1<<RGB_R_BIT										; red:	 	#ff0000
		dcd     1<<RGB_G_BIT										; green:	#00ff00
        dcd     1<<RGB_B_BIT										; blue:		#0000ff
		dcd     1<<RGB_G_BIT :OR: 1<<RGB_B_BIT						; cyan:		#00ffff
        dcd     1<<RGB_R_BIT :OR: 1<<RGB_B_BIT						; magenta:	#ff00ff
        dcd     1<<RGB_R_BIT :OR: 1<<RGB_G_BIT						; yellow:	#ffff00
        dcd     1<<RGB_R_BIT :OR: 1<<RGB_G_BIT	:OR: 1<<RGB_B_BIT	; white:	#ffffff
		dcd     0													; black:	#000000

	AREA	InterruptStuff, CODE, READONLY
; This is based closely on the solution for Lab 4. Setting up the timer and VIC
; is almost identical

; Extra code is needed to store the context of the thread that was interrupted
; in its designated storage area.

; Then, extra code is needed to retrieve the other thread's context from its
; designated storage area.

irqhan
	sub	lr,lr,#4	; fix the return address, as this is an interrupt exception handler
	stmfd	sp!,{r0-r2}	; temporary store -- we need to use these registers

	ldr	r1,=curTh	; get pointer to current thread's space
	ldr	r0,[r1]		; r0 points to current thread's space

	cmp	r0,#0		; is there a current thread?
	bne	irq00		; branch if so
	add	sp,#3*4		; pop saved register contents from stack -- don't need 'em
	ldr	r0,=t1Space	; point to first thread...
	b	irq01		; don't try to store any current thread stuff

irq00
	str	lr,[r0,#pcs]	; store return address as user's r15 (i.e. PC)
	add	r2,r0,#rss+3*4	; point to where r3-r14 will be stored
	stmia	r2,{r3-r14}^	; store user's r3-r14
	add	r2,r0,#rss 	; point to where r0-r2 will be stored
	ldmfd	sp!,{r3-r5}	; get r0-r2 back from temporary store
	stmia	r2,{r3-r5}	; store user's r0-r2
	mrs	r3,spsr
	str	r3,[r0,#cpsrs]	; store the user's CPSR

	ldr	r0,[r0,#next]	; get pointer to the other thread

irq01
	str	r0,[r1]		; make it the new current thread

; Here, update the counter and acknowledge the interrupts
	ldr	r2,=tickcount
	ldr	r3,[r2]	    	; get the count

	add	r3,#1	      	; increment it

	str	r3,[r2]		; save updated count

	ldr	r2,=T0
	mov	r3,#TimerResetTimer0Interrupt
	str	r3,[r2,#IR]	; remove MR0 interrupt request from timer

	ldr	r2,=VIC
	mov	r3,#0
	str	r3,[r2,#VectAddr]	; reset VIC

; Now get ready to restore the newly-current thread
	ldr	r3,[r0,#cpsrs]	; get the old spsr
	msr	spsr_cxsf,r3	; put it in as the current spsr
	ldr	lr,[r0,#pcs]	; get the return address into the link register
	add	r2,r0,#rss
	ldmia	r2,{r0-r14}^	; restore user registers
	nop			; allow time for h/w to recover
	movs	pc,lr	    	; restore PC & CPSR, i.e. dispatch thread

	AREA	Stuff, DATA, READWRITE
; equates for accessing fields in the threads' data spaces
next	equ	0
rss	equ	4	        ; offset to where register storage starts
pcs	equ	rss+15*4	; offset to where the PC storage is
cpsrs	equ	rss+16*4	; offset to where the CPSR storage is

; size of each thread's space

threadSpace	equ	1024
t1Space	space	threadSpace ; private storage for thread 1
t2Space	space	threadSpace	; private storage for thread 2

; pointer to the current thread's space

curTh	space	4		; pointer to private storage of current thread
tickcount space 4
	end