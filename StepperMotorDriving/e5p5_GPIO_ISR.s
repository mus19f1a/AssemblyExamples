;*************************************************************** 
; e5p5_GPIO_ISR.s  Part-V
;  Subroutine for ISR 	e5p5_ST_ISR
;
;  R6 :	Direction	E1: ClockWise	E0: CounterClockWise					
;  R7 : Speed		E3: Speed UP	E2; Speed DOWN
;  R3 is the input value to the FSM Driver
;***************************************************
R3ADRES		EQU	0X20004000
STCTRL		EQU 0xE000E010 ; SysTick | +4 STRELOAD | +8 STCURRENT	
GPIO_PORTE_DATA	EQU 0x400243FC
;LABEL		DIRECTIVE	VALUE		COMMENT
			AREA    	routines, READONLY, CODE
			THUMB
			EXTERN		FSM
			EXPORT  	e5p5_GPIO_ISR
e5p5_GPIO_ISR
		PUSH{R0,R1,R2,LR}
		MOV32	R0,#0xFFFFF	; ~0.5 milisecond
delay	SUBS R0,#1		; debouncing
		BNE	delay
		
		LDR	R1,=GPIO_PORTE_DATA
		LDR	R0,[R1]
		BFC	R0,#4,#28
		MOV	R2,#0x0F
		CMP	R0,R2
		BEQ	Apply
		MOV	R2,#0x07; 0111 = 7
		CMP	R0,R2
		BEQ	sUP
		MOV	R2,#0x0B; 1011 = 11
		CMP	R0,R2
		BEQ	sDOWN
		MOV	R2,#0x0D; 1101 = 13
		CMP	R0,R2
		BEQ	CW
		MOV	R2,#0x0E; 1110 = 14
		CMP	R0,R2
		BEQ	CCW
		B	exit
		
sUP		MOV	R0,#2
		UDIV	R7,R0
		;LSR	R7,#1
		B	exit
sDOWN	MOV	R0,#2
		MUL	R7,R0
		;LSL	R7,#1
		B	exit
CW		MOV	R6,#0xF0
		B	exit
CCW		MOV	R6,#0x0F
		B	exit
		
Apply	MOV	R3,R6;#0xF0	; clockwise
		LDR	R0,=R3ADRES
		STR	R3,[R0]
		MOV	R4,R7;#3999999	; 1 second = 4x10^6 x 1/4x10^6
		BL	INIT_TIMER
		
exit	POP{R0,R1,R2,LR}
		BX		LR
		
INIT_TIMER		; Speed of the Stepper Motor
		LDR	R0,=STCTRL
		MOV	R1,#0
		STR	R1,[R0]	; stop SysTick counter
		MOV	R1,R4	; Update Rotation speed
		STR	R1,[R0,#4]	; set STRELOAD 
		STR	R1,[R0,#8]	; clear  COUNT
		MOV	R1,#0x3		; 0011 PIOSC(16/4 MHz) | interrupt Enabled
		STR	R1,[R0]
		BX	LR
		
		ALIGN
		END