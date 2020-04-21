; Practical 2 Sample Solution
; (c) Mike Brady 2020.

	area	tcd,code,readonly
	export	__main
__main


; Part one -- turn off the display

IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C



	ldr	r1,=IO1DIR
	ldr	r2,=0x000f0000	;select P1.19--P1.16
	str	r2,[r1]		;make them outputs
	ldr	r1,=IO1SET
	str	r2,[r1]		;set them to turn the LEDs off
	
	ldr	r2,=IO1CLR

; r1 points to the SET register
; r2 points to the CLEAR register

; The LEDS are active low -- writing a zero to the bit turns the LED on, writing a 1 turns the LED off.

; Part 2 -- convert the number to decimal digits and encode them

	ldr r4,=powersoften	; start with the billions
	ldr	r7,=result		; point to where the resulting characters will do

	ldr	r3,=sample
	ldr	r3,[r3]			; get the sample number
	cmp	r3,#0			; see if it's negative
	bpl	is_positive
	rsb	r3,#0				; get the negative number's magnitude
	mov r5,#2_1011	; code for "-"
	strb	r5,[r7]		; store the sign code
	add	r7,#1			; point to the next free space
is_positive
	mov	r8,#0			; use this a a flag. 1 means a non-zero digit was seen, 0 otherwise
loop2
	mov	r5,#0
	ldr	r6,[r4]         ; load the "next" power
	cmp	r6,#0			; are we finished?
	beq	conversion_done
	add	r4,#4			; point to the next lowest power of 10 for next time
loop1
	add	r5,#1
	subs	r3,r3,r6	; try to subtract another power of ten
	bcs	loop1			; so long as the C bit is set after a subtract, it was successful
	
	add	r3,r3,r6		; restore the over-subtraction
	sub	r5,#1			; one less than we thought
;now, if it was zero, substitute 0_21111
	cmp	r5,#0
	bne	not_zero
	mov	r5,#2_1111
	cmp	r8,#0			; have there been any non-zeros yet?
	beq	loop2			; branch if not
not_zero
	mov	r8,#1			; indicate at least one non-zero
	strb	r5,[r7]		; store the character
	add	r7,#1			; point to next space in the result
	b	loop2			; continue the conversion

conversion_done
	cmp	r8,#0			; was no non-zero seen (i.e. was the number zero?)
	bne	dont_put_in_a_zero
	mov	r6,#2_1111
	strb	r6,[r7]
	add	r7,#1			; point to next space in the result
; put a zero in the last byte to act as an end-of-string
dont_put_in_a_zero
	strb	r5,[r7]		; put a NUL on to the end of the sequence
	
; Part 3 -- enter an endless loop where you display the sign and the digits followed by a blank pause
	
	ldr	r7,=0x000f0000	; select all four LEDs
	ldr	r5,=lookuptable
display_loop
	ldr	r0,=result
display_next
	mov	r3,#0
	ldrb	r3,[r0]		; get next code to display
	mov	r6,r3			; keep if for later
	add	r0,#1			; point to the next code
	and	r3,#2_1111		; remove any other stuff
	mov	r3,r3,lsl #2	; by four because the entries are 4 bytes in size
	add	r3,r5,r3
	ldr	r3,[r3]			; get the 32-bit GPIO code

	str	r7,[r1]			; turn all the LEDs off
	str	r3,[r2]			; turn on the relevant bits

;delay for about a second
	ldr	r4,=8000000
dloop	subs	r4,r4,#1
	bne	dloop

	cmp	r6,#0			; was that the last part of it
	bne	display_next	; if not, do the next digit
	b	display_loop	; otherwise, start the display again from the start

sample
	dcd		2123456789		; this is a sample

lookuptable
	dcd	0x00000000 			; 0 (unused)
	dcd	0x00080000			; 1	
	dcd	0x00040000			; 2
	dcd	0x000c0000			; 3
	dcd 0x00020000			; 4	
	dcd	0x000A0000			; 5
	dcd	0x00060000			; 6
	dcd	0x000E0000			; 7
	dcd	0x00010000			; 8
	dcd	0x00090000			; 9
	dcd	0x00050000			; A (which is +)
	dcd	0x000D0000			; B (which is -)
	dcd	0x00030000			; C (unused)
	dcd	0x000B0000			; D (unused)
	dcd	0x00070000			; E (unused)
	dcd	0x000F0000			; F (which is 0)
		

; Use for converting the number to its decimal digits equivalent
powersoften
	dcd		1000000000
	dcd		100000000
	dcd		10000000
	dcd		1000000
	dcd		100000
	dcd		10000
	dcd		1000
	dcd		100
	dcd		10
	dcd		1
	dcd		0		; use this as a "sentinel" so we'll know when we're finished

	AREA	P2Data, DATA, READWRITE
result
	space	12

                END
