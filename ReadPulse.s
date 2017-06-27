;***************************************************************  
; EE 447-INTRODUCTION TO MICROPROCESSOR HOMEWORK 
; input pin is configured as PF3
; Pulse width, Period and Duty Cycle detector
;***************************************************************
; ReadPulse.s
; Routine to Get Pulse width, Period and Duty Cycle of input
; Uses Timer1A to read digital input on PF2
; 	R8 : pos time
;	R9 : neg time
;	R11 : Current Level status | 0: low level	1:  high level |
;---------------------------------------------------					
ADDRS	EQU	0x20000400	; to store the results
	
			AREA 	routines, CODE, READONLY
			THUMB
			EXPORT	Get_Value
;---------------------------------------------------					
Get_Value	PROC
			LDR	R1,=MAX
			SUB	R0, R1, R0
			MOV	R1,#0	; level detection
			CMP	R11,R1	; 0: low	1:high
			BEQ	low_level
			; set to positive edge detect
			MOV	R8,R0	; get positive level time 
			LDR R1, =TIMER1_CTL
			LDR R2, [R1]
			BFC R2, #2, #2 ; set bits 3:2 to 0x00
			STR R2, [R1]		
			MOV	R11,#0 ; set to pos-edge detection case
			B	calc
			; set to negative edge detect
low_level	MOV	R9,R0	; get negative level time
			LDR R1, =TIMER1_CTL
			LDR R2, [R1]
			BFC R2, #2, #2 ; set bits 3:2 to 0x01 ; 0000 0100
			ORR	R2,	#0x0C;	
			STR R2, [R1]		
			MOV	R11,#1 ; set to neg-edge detection case
			B	go_on
calc		ADD	R10,R8,R9
			MOV	R4,#16 ;tmp
			UDIV R3,R10,R4;	R3 is period in us(microsecond)	
			LDR	R5,=ADDRS
			STR	R3,[R5],#4;	Period
			STR	R8,[R5],#4;	Pulse Width
			MOV	R4,#100	;tmp
			MUL	R8,R8,R10
			UDIV R4,R8,R10
			STR	R4,[R5],#4;	Duty Cycle
			MOV32 R12,#16000000
			UDIV  R6,R12,R10	
			STR	R6,[R5],#4	; Frequency in Hz
			MOV	R7,0x04
			STRB R7,[R5],#1	; 
			LDR	R5,=ADDRS
			BL	OutStr
			
go_on		BX 	LR 
			ENDP
;---------------------------------------------------
; 16/32 Timer Registers
TIMER1_CFG			EQU 0x40031000
TIMER1_TAMR			EQU 0x40031004
TIMER1_CTL			EQU 0x4003100C
TIMER1_IMR			EQU 0x40031018
TIMER1_RIS			EQU 0x4003101C ; Timer Interrupt Status
TIMER1_ICR			EQU 0x40031024 ; Timer Interrupt Clear
TIMER1_TAILR		EQU 0x40031028 ; Timer interval : Period
TIMER1_TAPR			EQU 0x40031038 ; PreScale
TIMER1_TAR			EQU	0x40031048 ; Timer register : Current value of the timer
;TIMER1_MATCHR		EQU 0x40031030 ; Match Register Value (set lower 16 bit only)

;GPIO Registers
GPIO_PORTF_DATA		EQU 0x40025010 ; Access BIT2
GPIO_PORTF_DIR 		EQU 0x40025400 ; Port Direction
GPIO_PORTF_AFSEL	EQU 0x40025420 ; Alt Function enable
GPIO_PORTF_DEN 		EQU 0x4002551C ; Digital Enable
GPIO_PORTF_AMSEL 	EQU 0x40025528 ; Analog enable
GPIO_PORTF_PCTL 	EQU 0x4002552C ; Alternate Functions

;System Registers
SYSCTL_RCGCGPIO 	EQU 0x400FE608 ; GPIO Gate Control
SYSCTL_RCGCTIMER 	EQU 0x400FE604 ; GPTM Gate Control

;---------------------------------------------------
; From 250 Hz to 4 MHz
MAX				EQU	0x0000ffff; sys clk : 16 MHz
;---------------------------------------------------

;LABEL	DIRECTIVE	VALUE		COMMENT
		AREA		main, READONLY, CODE
		THUMB
		EXTERN	OutStr	; R5 is the address of data to be out
		EXPORT 	__main

__main		;	READ_INIT
		LDR R1, =SYSCTL_RCGCGPIO ; start GPIO clock
		LDR R0, [R1]
		ORR R0, R0, #0x20 ; set bit 5 for port F
		STR R0, [R1]
		NOP ; allow clock to settle
		NOP
		NOP
		LDR R1, =GPIO_PORTF_DIR ; set direction of PF3
		LDR R0, [R1]
		BFC R0, #3, #1 ; 1000 set bit3 for input	PF3
		STR R0, [R1]
		LDR R1, =GPIO_PORTF_AFSEL ; regular port function
		LDR R0, [R1]
		BIC R0, R0, #0x08	; 1000 pin4 alternate function DISABLED
		STR R0, [R1]
		LDR R1, =GPIO_PORTF_PCTL ; no alternate function
		LDR R0, [R1]
		BIC R0, R0, #0x0000F000
		STR R0, [R1]
		LDR R1, =GPIO_PORTF_AMSEL ; disable analog
		MOV R0, #0
		STR R0, [R1]
		LDR R1, =GPIO_PORTF_DEN ; enable port digital
		LDR R0, [R1]
		ORR R0, R0, #0x08
		STR R0, [R1]
	
		LDR R1, =SYSCTL_RCGCTIMER ; Start Timer0
		LDR R2, [R1]
		ORR R2, R2, #0x01
		STR R2, [R1]
		NOP ; allow clock to settle
		NOP
		NOP
		LDR R1, =TIMER1_CTL ; disable timer during setup LDR R2, [R1]
		BIC R2, R2, #0x01
		STR R2, [R1]
		LDR R1, =TIMER1_CFG ; set 16 bit mode
		MOV R2, #0x04
		STR R2, [R1]
		LDR R1, =TIMER1_TAMR
		MOV R2, #0x07	; set bit2 to 0x01 for Edge Time Mode,
		STR R2, [R1]	; set bits 1:0 to 0x03 for Capture Mode
		; set edge detection || 0x0:pos || 0x1: neg ||	0x3: both ||
		LDR R1, =TIMER1_CTL
		LDR R2, [R1]
		;ORR R2, R2, #0x0C ; set bits 3:2 to 0x03 ; 0000 1100
		BFC R2, #2, #2 ; set bits 3:2 to 0x03 ; 0000 1100
		STR R2, [R1]			
		; no prescale
		LDR R1, =TIMER1_TAILR ; initialize match clocks
		LDR R2, =MAX
		STR R2, [R1]
	
; Enable timer
		LDR R1, =TIMER1_CTL
		LDR R2, [R1]
		ORR R2, R2, #0x03 	; set bit0 to enable
		STR R2, [R1] 		; and bit 1 to stall on debug
	
		; Await edge capture event
loop2	LDR R1, =TIMER1_RIS
loop	LDR R2, [R1]
		ANDS R2, #04 ; isolate CAERIS bit
		BEQ loop ; if no capture, then loop
		; Need to clear CAERIS bit of TIMER0_RIS.
		LDR R1, =TIMER1_TAR ; address of timer register
		LDR R0, [R1] ; Get timer register value
		
		BL	Get_Value	; Write this part
		B	loop2
		ALIGN
		END