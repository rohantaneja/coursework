; sample solution to practical 3
; (c) Mike Brady, 2020.


; GPIO stuff
IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C
IO1PIN  EQU 0xE0028010


; Button Significances
nplus           equ     23
nminus          equ     22
btn_add         equ     21
btn_sub         equ     20
clear           equ     -21
allclear        equ     -20
        
        
; State Machine States
sm_initial_state        equ     0
sm_getting_number       equ     1
sm_getting_operator     equ     2     

; Calculator Operators
co_tx                   equ     0       ; acc := x
co_add                  equ     1       ; acc := acc + x
co_sub                  equ     2       ; acc := acc - x;

	area	tcd,code,readonly
	export	__main
__main
;initialise the LEDs
		ldr	r1,=IO1DIR
		ldr	r2,=0x000f0000	;select P1.19--P1.16
		str	r2,[r1]		;make them outputs
		ldr	r1,=IO1SET
		str	r2,[r1]		; clear them all
		

; use r1 to hold the calculator's state: sm_initial_state, sm_getting_number, sm_getting_operator
; use r2 to hold its "acc"
; use r3 to hold its "x"
; use r4 to hold the pending operator -- add or subtract

clear_all
        mov     r1,#sm_initial_state    ; initial state
        mov     r2,#0                   ; 0        
        mov     r3,#0                   ; 0
        mov     r4,#co_tx               ; transfer from x to acc
        mov     r0,#0
update_display_and_loop
        bl      display                 ; clear the display
event_loop
        bl      getkey                  ; get next key
        bl      blink                   ; show a response
        
; now, check if the state machine is in the initial state
        mov     r5,#sm_initial_state
        cmp     r1,r5
        bne     not_initial_state
; in initial state
        mov     r5,#nplus
        cmp     r5,r0                   ; was that an nplus
        beq     sm_is_00                ; branch if so
        mov     r5,#nminus
        cmp     r5,r0                   ; was that an nminus
		bne     event_loop              ; if not, just ignore it
        sub     r3,#1                   ; x := x - 1
        mov     r0,r3                   ; display "x"
        mov     r1,#sm_getting_number   ; change state
        b       update_display_and_loop
sm_is_00
        add     r3,#1                   ; x := x + 1
        mov     r0,r3
        mov     r1,#sm_getting_number
        b       update_display_and_loop

not_initial_state
; now, check if the state machine is in the getting_number state
        mov     r5,#sm_getting_number
        cmp     r1,r5
        bne     not_getting_number
; in the getting_number state
        mov     r5,#nplus
        cmp     r5,r0
        bne     sm_gn_00        ; branch if not n+
        add     r3,#1           ; x := x+1
        mov     r0,r3           ; display x
        b       update_display_and_loop
sm_gn_00
        mov     r5,#nminus
        cmp     r5,r0
        bne     sm_gn_01        ; branch if not n-
        sub     r3,#1
        mov     r0,r3
        b       update_display_and_loop
sm_gn_01
        mov     r5,#btn_sub
        cmp     r5,r0
        bne     sm_gn_02        ; branch if not sub(tract)
        bl      perform_pending_op
        mov     r4,#co_sub      ; store "subtract" as the pending operator
        mov     r1,#sm_getting_operator
        b       event_loop
sm_gn_02
        mov     r5,#btn_add
        cmp     r5,r0
        bne     sm_gn_03        ; branch if not add
        bl      perform_pending_op
        mov     r4,#co_add      ; store "add" as the pending operator        
        mov     r1,#sm_getting_operator
        b       event_loop
sm_gn_03
        mov     r5,#clear
        cmp     r5,r0
        bne     sm_gn_04        ; branch if not clear
        mov     r3,#0
        mov     r0,r3
        b       update_display_and_loop
sm_gn_04
        mov     r5,#allclear
        cmp     r5,r0
        bne     event_loop      ; branch if not allclear
        b       clear_all

not_getting_number
; now, check if the state machine is in the getting_operator state
        mov     r5,#sm_getting_operator
        cmp     r1,r5
        bne     event_loop      ; branch if not in the getting operator state -- this is an error, but ignore it
        mov     r5,#nplus
        cmp     r5,r0
        bne     sm_go_00        ; branch if not n+
        mov     r1,#sm_getting_number
        mov     r3,#0           ; x := 0
        mov     r0,r3
        b       update_display_and_loop
sm_go_00
        mov     r5,#nminus
        cmp     r5,r0
        bne     sm_go_01        ; branch if not n-
        mov     r1,#sm_getting_number
        mov     r3,#0           ; x := 0
        mov     r0,r3
        b       update_display_and_loop
sm_go_01
        mov     r5,#btn_sub
        cmp     r5,r0
        bne     sm_go_02        ; branch if not the sub(tract) button
        mov     r4,#co_sub
        b       event_loop
sm_go_02
        mov     r5,#btn_add
        cmp     r5,r0
        bne     sm_go_03        ; branch if not the add button
        mov     r4,#co_add
        b       event_loop
sm_go_03
        mov     r5,#allclear
        cmp     r5,r0
        bne     event_loop      ; branch if not the all clear button
        b       clear_all       ; start over        

; the program will never reach the next line
stop	B	stop


perform_pending_op
        stmfd   sp!,{r0,lr}
        mov     r0,#co_tx
        cmp     r4,r0
        bne     ppo_0           ; branch if not a transfer
        mov     r2,r3           ; do the transfer
        b       ppo_x
ppo_0   mov     r0,#co_add
        cmp     r4,r0
        bne     ppo_1           ; branch if not an add
        add     r2,r3
        b       ppo_x
ppo_1   mov     r0,#co_sub
        cmp     r4,r0
        bne     ppo_x           ; branch if not a sub -- actually this is an error
        sub     r2,r3
ppo_x   
		mov	r0,r2
		bl	display
		ldmfd   sp!,{r0,lr}
        bx      lr

lptime  equ     1000000  ; long press time
dbtime  equ     40000   ; minimum time to allow debounce

; this displays the rightmost 4 bits of r0 in the ARM board's LEDs
; assumes the IO1DIR is already correctly set up

display stmfd   sp!,{r1,r2}
        ldr	r2,=0x000f0000	; select P1.19--P1.16	str	r2,[r1]		;make them outputs
		ldr	r1,=IO1SET
		str	r2,[r1]			; set them to turn the LEDs off
        mov     r2,r0
        and     r2,#2_1111      ; clean it up
		mov	r2,r2,lsl #2	
        ldr	r1,=revtab
		add	r1,r2
		ldr	r2,[r1]        
		ldr	r1,=IO1CLR
        str     r2,[r1]         ; turn on the relevant bits
        ldmfd   sp!,{r1,r2}
        bx      lr

revtab	dcd	0x00000000      ; 0
        dcd	0x00080000	; 1
		dcd	0x00040000	; 2
		dcd	0x000c0000	; 3
		dcd	0x00020000	; 4
		dcd	0x000a0000	; 5
		dcd	0x00060000	; 6
		dcd	0x000e0000	; 7
		dcd	0x00010000	; 8
		dcd	0x00090000	; 9
		dcd	0x00050000	; A
		dcd	0x000d0000	; B
		dcd	0x00030000	; C
		dcd	0x000b0000	; D
		dcd	0x00070000	; E
		dcd	0x000f0000	; F

; this blinks the rightmost 4 bits of r0 in the ARM board's LEDs
; assumes the IO1DIR is already correctly set up

blink   stmfd   sp!,{r1-r4}
        ldr	r2,=0x000f0000	; select P1.19--P1.16	str	r2,[r1]		;make them outputs
	ldr	r1,=IO1PIN
        ldr     r3,[r1]         ; get current LEDs
	ldr	r1,=IO1SET       
	str	r2,[r1]		; set them to turn the LEDs off
        
        ldr     r1,=2000000     ; guess
blink0  subs    r1,#1
        bne     blink0
        eor     r3,r2           ; get those bit that were 0 turned to 1
        and     r3,r2           ; turn off all those other bits
	ldr	r1,=IO1CLR
        str     r3,[r1]         ; turn on the relevant bits
        ldmfd   sp!,{r1-r4}
        bx      lr

; this returns the index number of the button pressed,
; or its negative if long-pressed in r0
getkey  stmfd	sp!,{r1-r8}
        ldr     r1,=0x00f00000  ; mask of all the keys
        ldr     r2,=IO1PIN      ; GPIO 1 Pin Register
        ldr     r8,=dbtime      ; minimum debounce count
getk02  mov     r3,#0           ; number of successive samples of key down
getk03  ldr     r4,=keytab      ; start of the table
        mov     r5,#4           ; entries in table
        ldr     r6,[r2]         ; read the GPIO
        and     r6,r6,r1        ; mask off all the other stuff
getk01  ldr     r7,[r4]         ; get entry in keytab
        add     r4,#8           ; point to next one
        cmp     r6,r7           ; match?
        beq     getk00          ; branch if so
        subs    r5,#1
        bne     getk01          ; loop until all checked
        b       getk02          ; go back if no match found
; here, a match was found, so increment the down count up to the limit
getk00	add     r3,#1
        cmp     r3,r8           ; has it reached the debounce count?
        bne     getk03
; here it means that the key was really pressed and debounced
; so we must get its value and wait for it to be released
        sub     r4,#4           ; point to previous entry in table
        ldr     r0,[r4]         ; load the result
; now, watch for a debounce time for the buttons to be all up
; so we should see either all buttons up or this button down
; anything else means more than one key is being pressed
; so start over
; r7 has the button down pattern, r1 has the all buttons up
; r3 has the down count, used to distinguish short press from long press
        ldr     r5,=lptime      ; get the long press time
getk05  mov     r4,#0           ; to debounce the release
getk06  ldr     r6,[r2]         ; read the GPIO
        and     r6,r6,r1        ; mask all the other bits?
        cmp     r6,r7           ; same as before?
        bne     getk04          ; branch if not
        cmp     r3,r5           ; have we a long press?
        addne   r3,#1           ; if not, add 1
        b       getk05          ; and keep waiting
getk04  cmp     r6,r1           ; all keys up?
        bne     getk02          ; another button -- start over
        add     r4,#1           ; otherwise, add 1 to the debounce        
        cmp     r4,r8           ; debounce time elapsed?
        bne     getk06          ; if not, wait another while
; finished -- we have the index number in r0.
; if it was a long press, r3 will contain lptime, equal to r5
        cmp     r3,r5           ; are they the same, i.e. long press?
        bne     getk07
        rsb     r0,#0           ; negate it
getk07  ldmfd	sp!,{r1-r8}
	bx      lr
        
keytab  dcd	0x00F00000-(1<<23),23
		dcd	0x00F00000-(1<<22),22
		dcd	0x00F00000-(1<<21),21
		dcd	0x00F00000-(1<<20),20
		end