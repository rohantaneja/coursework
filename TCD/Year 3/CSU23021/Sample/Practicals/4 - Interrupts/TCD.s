; Practical 4 Sample Solution
; (c) Mike Brady, 2020.

	area	tcd,code,readonly
	export	__main
__main

; Definitions  -- references to 'UM' are to the User Manual.

; Timer Stuff -- UM, Table 173

T0	equ	0xE0004000		; Timer 0 Base Address
T1	equ	0xE0008000

IR	equ	0			; Add this to a timer's base address to get actual register address
TCR	equ	4
MCR	equ	0x14
MR0	equ	0x18

TimerCommandReset	equ	2
TimerCommandRun	equ	1
TimerModeResetAndInterrupt	equ	3
TimerResetTimer0Interrupt	equ	1
TimerResetAllInterrupts	equ	0xFF

; VIC Stuff -- UM, Table 41
VIC	equ	0xFFFFF000		; VIC Base Address
IntEnable	equ	0x10
VectAddr	equ	0x30
VectAddr0	equ	0x100
VectCtrl0	equ	0x200

Timer0ChannelNumber	equ	4	; UM, Table 63
Timer0Mask	equ	1<<Timer0ChannelNumber	; UM, Table 63
IRQslot_en	equ	5		; UM, Table 58

; initialisation code

; Initialise the VIC
	ldr	r0,=VIC			; looking at you, VIC!

	ldr	r1,=irqhan
	str	r1,[r0,#VectAddr0] 	; associate our interrupt handler with Vectored Interrupt 0

	mov	r1,#Timer0ChannelNumber+(1<<IRQslot_en)
	str	r1,[r0,#VectCtrl0] 	; make Timer 0 interrupts the source of Vectored Interrupt 0

	mov	r1,#Timer0Mask
	str	r1,[r0,#IntEnable]	; enable Timer 0 interrupts to be recognised by the VIC

	mov	r1,#0
	str	r1,[r0,#VectAddr]   	; remove any pending interrupt (may not be needed)

; Initialise Timer 0
	ldr	r0,=T0			; looking at you, Timer 0!

	mov	r1,#TimerCommandReset
	str	r1,[r0,#TCR]

	mov	r1,#TimerResetAllInterrupts
	str	r1,[r0,#IR]

	ldr	r1,=(14745600/1600)-1	 ; 626 us = 1/1600 second
	str	r1,[r0,#MR0]

	mov	r1,#TimerModeResetAndInterrupt
	str	r1,[r0,#MCR]

	mov	r1,#TimerCommandRun
	str	r1,[r0,#TCR]

;from here, initialisation is finished, so it should be the main body of the main program

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
floop   mov     r3,#8           ; number of entries in the table
        ldr     r4,=displaytable
        
finc    ldr     r5,[r4]
        add     r4,#4
        str     r5,[r2]         ; turn on the LED
        ldr     r6,=tickcount
        ldr     r7,[r6]
        add     r7,#1000000/625      ; number of ticks corresponding to 1.0 seconds
dloop   ldr     r8,[r6]
        cmp     r8,r7
        bne     dloop           ; loop until a second has gone by
        str     r5,[r1]         ; turn off the LED
        subs    r3,#1
        bne     finc
        b       floop

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
irqhan	sub	lr,lr,#4
	stmfd	sp!,{r0-r1,lr}	; the lr will be restored to the pc

; the main purpose of the interrupt handler is merely to update a tick counter
        ldr     r0,=tickcount
        ldr     r1,[r0]
        add     r1,#1
        str     r1,[r0]

;this is the body of the interrupt handler

;here you'd put the unique part of your interrupt handler
;all the other stuff is "housekeeping" to save registers and acknowledge interrupts


;this is where we stop the timer from making the interrupt request to the VIC
;i.e. we 'acknowledge' the interrupt
	ldr	r0,=T0
	mov	r1,#TimerResetTimer0Interrupt
	str	r1,[r0,#IR]	   	; remove MR0 interrupt request from timer

;here we stop the VIC from making the interrupt request to the CPU:
	ldr	r0,=VIC
	mov	r1,#0
	str	r1,[r0,#VectAddr]	; reset VIC

	ldmfd	sp!,{r0-r1,pc}^	; return from interrupt, restoring pc from lr
				; and also restoring the CPSR

; TCD Read-Write Definitions.

		AREA	MutableDate, DATA, READWRITE
tickcount       space 4

                END
