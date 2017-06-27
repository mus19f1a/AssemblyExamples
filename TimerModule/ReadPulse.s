;***************************************************************  
; Experiment 6 ; Preliminary Work Part 2;
; input pin is configured as P
; TIMER3A PB2
; Pulse width, Period and Duty Cycle detector
;***************************************************************
; ReadPulse.s
; Routine to Get Pulse width, Period and Duty Cycle of input
;Uses Timer1A to read digital input on PF3
; 	R8 : pos time
;	R9 : neg time
;	R11 : Current Level status | 0: low level	1:  high level |
;---------------------------------------------------					
; 16/32 Timer Registers
TIMER3_CFG			EQU 0x40033000
TIMER3_TAMR			EQU 0x40033004
TIMER3_CTL			EQU 0x4003300C
TIMER3_IMR			EQU 0x40033018
TIMER3_RIS			EQU 0x4003301C ; Timer Interrupt Status
TIMER3_ICR			EQU 0x40033024 ; Timer Interrupt Clear
TIMER3_TAILR		EQU 0x40033028 ; Timer interval : Period
TIMER3_TAPR			EQU 0x40033038 ; PreScale
TIMER3_TAR			EQU	0x40033048 ; Timer register : Current value of the timer

;GPIO Registers
GPIO_PORTB_DATA		EQU 0x40005000 ; Access BIT2
GPIO_PORTB_DIR 		EQU 0x40005400 ; Port Direction
GPIO_PORTB_AFSEL	EQU 0x40005420 ; Alt Function enable
GPIO_PORTB_DEN 		EQU 0x4000551C ; Digital Enable
GPIO_PORTB_AMSEL 	EQU 0x40005528 ; Analog enable
GPIO_PORTB_PCTL 	EQU 0x4000552C ; Alternate Functions
GPIO_PORTB_LOCK		EQU	0x40005520
GPIO_PORTB_COMMIT		EQU	0x40005524

;System Registers
SYSCTL_RCGCGPIO 	EQU 0x400FE608 ; GPIO Gate Control
SYSCTL_RCGCTIMER 	EQU 0x400FE604 ; GPTM Gate Control

; From 250 Hz to 4 MHz
MAX				EQU	0x0000ffff; sys clk : 16 MHz
ADDRS			EQU	0x20000400
;---------------------------------------------------
			AREA 	routines, CODE, READONLY
			THUMB
			EXPORT	Get_Value
					
Get_Value	PROC
			LDR	R1,=MAX
			SUB	R0, R1, R0
			MOV	R1,#0	; level detection
			CMP	R11,R1	; 0: low	1:high
			BEQ	low_level
			; set to positive edge detect
			MOV	R8,R0	; get positive level time 
			LDR R1, =TIMER3_CTL
			LDR R2, [R1]
			BFC R2, #2, #2 ; set bits 3:2 to 0x00
			STR R2, [R1]		
			MOV	R11,#0 ; set to pos-edge detection case
			B	calc
			; set to negative edge detect
low_level	MOV	R9,R0	; get negative level time
			LDR R1, =TIMER3_CTL
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
			MOV	R7,#0x04
			STRB R7,[R5],#1	;
			
go_on		BX 	LR 
			ENDP
;---------------------------------------------------

;LABEL	DIRECTIVE	VALUE		COMMENT
		AREA		main, READONLY, CODE
		THUMB
;		EXTERN	OutStr	; R5 is the address of data to be out
		EXTERN	CONVRT	; R6 is the input register (it include own OutStr)
		EXTERN	PULSE_INIT			
		EXPORT 	__main

__main	
		BL	PULSE_INIT
		;	READ_INIT
		LDR R1, =SYSCTL_RCGCGPIO ; start GPIO clock
		LDR R0, [R1]
		ORR R0, R0, #0x02 ; set bit 2 for port B
		STR R0, [R1]
		NOP ; allow clock to settle
		NOP
		NOP
		NOP
		NOP
		NOP
		LDR	R1,=GPIO_PORTB_LOCK
		MOV32	R2,#0x4C4F434B
		;LDR	R2,=0x4C4F434B
		STR	R2,[R1]; Unlock port B
		LDR	R1,=GPIO_PORTB_COMMIT
		MOV	R2,#0xFF
		STR	R2,[R1]; COMMIT port B
		LDR R1, =GPIO_PORTB_DIR ; set direction of PB2
		;LDR R0, [R1]
		;BIC R0, R0,#0x04; set input	PB2
		MOV R0,#0
		STR R0, [R1]
		LDR R1, =GPIO_PORTB_AFSEL ; regular port function
		LDR R0, [R1]
		ORR R0, R0, #0xFF;0x04; PB2 alternate function ENABLED
		STR R0, [R1]
		LDR R1, =GPIO_PORTB_PCTL ; SET alternate function
		LDR R0, [R1]
		BIC R0, R0, #0x77777777;0x00000700
		STR R0, [R1]
		LDR R1, =GPIO_PORTB_AMSEL ; disable analog
		MOV R0, #0x00
		STR R0, [R1]
		LDR R1, =GPIO_PORTB_DEN ; enable port digital
		LDR R0, [R1]
		ORR R0, R0, #0xff;0x04
		STR R0, [R1]
	
		LDR R1, =SYSCTL_RCGCTIMER ; Start Timer3
		LDR R2, [R1]
		ORR R2, R2, #0x08; 1000
		STR R2, [R1]
		NOP ; allow clock to settle
		NOP
		NOP
		NOP
		LDR R1, =TIMER3_CTL ; disable timer during setup
		LDR	R2,[R1]
		BIC R2, R2, #0x01
		STR R2, [R1]
		LDR R1, =TIMER3_CFG ; set 16 bit mode
		MOV R2, #0x04
		STR R2, [R1]
		LDR R1, =TIMER3_TAMR	; count down
		MOV R2, #0x07	; set bit2 to 0x01 for Edge Time Mode,
		STR R2, [R1]	; set bits 1:0 to 0x03 for Capture Mode
		; set edge detection || 0x0:pos || 0x1: neg ||	0x3: both ||
		LDR R1, =TIMER3_CTL
		LDR R2, [R1]
		ORR R2, #0x04;0x0C ; set bits 3:2 to 0x03 ; 0000 1100
		STR R2, [R1]			
		LDR R1, =TIMER3_TAPR
		MOV R2, #15 ; divide clock by 16 to
		STR R2, [R1] ; get 1us clocks
		LDR R1, =TIMER3_TAILR ; initialize match clocks
		LDR R2, =MAX
		STR R2, [R1]
; Enable timer
		LDR R1, =TIMER3_CTL
		LDR R2, [R1]
		ORR R2, R2, #0x03 	; set bit0 to enable
		STR R2, [R1] 		; and bit 1 to stall on debug
	
		; Wait edge capture event
loop2	LDR R1, =TIMER3_RIS
		MOV	R2,#0
poll	LDRB R2, [R1]
		ANDS R2, #0x04 ;0100 isolate CAERIS bit
		LDR R3, =GPIO_PORTB_DATA
		LDR	R4,[R3]
		CMP	R4,R2
		BEQ poll
		B poll
		BEQ poll ; if no capture, then loop
		LDR	R1,=TIMER3_ICR; Need to clear CAECINT bit of TIMER3_RIS.
		MOV	R2,#0x04
		STR	R2,[R1]
		LDR R1, =TIMER3_TAR ; address of timer register
		LDR R0, [R1] ; Get timer register value
		; Get and Write the values to memory
		BL	Get_Value	 
		;CONVERT ASCII to DECIMAL and Show on the Termite
		LDR	R5,=ADDRS
		MOV	R0,#4
outV	LDR	R6,[R5],#4
		BL	CONVRT	;include OutStr
		SUBS R0,#1
		BNE	outV
		
		B	loop2
		ALIGN
		END
