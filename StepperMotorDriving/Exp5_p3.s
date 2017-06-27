;***************************************************************  
; Experiment 5 ; Preliminary Work Part 3;
; Step motor one step rotate control by buttons
;***************************************************************
; INPUT	:  2 switch button connected to D0 CCW and D1 CW 
STCTRL		EQU 0xE000E010 ; SysTick | +4 STRELOAD | +8 STCURRENT	

SYSCTL_RCGCGPIO		EQU 0x400FE608 ; clock
GPIO_PORTB_DIR		EQU 0x40005400 ;  0: input | 1: output
GPIO_PORTB_AFSEL	EQU 0x40005420 ; disable AFSEL & PCTL
GPIO_PORTB_DEN		EQU 0x4000551C ; digital Enabled
GPIO_PORTB_AMSEL	EQU 0x40005528 ; analog Disabled
GPIO_PORTB_DATA		EQU 0x400053FC
GPIO_PORTE_DIR		EQU 0x40024400 ;  0: input | 1: output
GPIO_PORTE_AFSEL	EQU 0x40024420 ; disable AFSEL & PCTL
GPIO_PORTE_DEN		EQU 0x4002451C ; digital Enabled
GPIO_PORTE_AMSEL	EQU 0x40024528 ; analog Disabled
	
;LABEL	DIRECTIVE	VALUE		COMMENT
		AREA		main, READONLY, CODE
		THUMB
		EXPORT 	__main
__main	
		BL	INIT_TIMER	;initilization of SysTick
		BL	INIT_GPIO
		MOV	R5,#0 ; R5 is used to detect pressed Button
loop	B	loop

INIT_TIMER
		LDR	R0,=STCTRL
		MOV	R1,#0
		STR	R1,[R0]	; stop SysTick counter
		LDR	R1,=39999; 10msec'4 MHz; | 27100	for 16 MHz| trigger duration
		STR	R1,[R0,#4]	; set STRELOAD 
		STR	R1,[R0,#8]	; clear  COUNT
		MOV	R1,#0x3		; 0011 PIOSC(16/4 MHz) | interrupt Enabled
		STR	R1,[R0]
		BX		LR
	
INIT_GPIO
		LDR	R1,=SYSCTL_RCGCGPIO	
		LDR	R0,[R1]
		ORR	R0,R0, #0x12 ;0001 0010 ;Enable B and D port's clock
		STR	R0,[R1]
		NOP
		NOP
		NOP
;set  direction register		
		LDR	R1,=GPIO_PORTB_DIR
		LDR	R0,[R1]
		ORR	R0,R0, #0xF0 ;1111 0000 ;b4,b5,b6,b7 output
		STR	R0,[R1]	
; disable alternative functions
		LDR	R1,=GPIO_PORTB_AFSEL
		MOV	R0,#0
		STR	R0,[R1]
; disable Analog & Enable Digital
		LDR	R1,=GPIO_PORTB_AMSEL
		STR	R0,[R1]	; disabled
		LDR	R1,=GPIO_PORTB_DEN
		MOV	R0,#0xFF
		STR	R0,[R1]	; enabled
		; load default value
		LDR	R1,=GPIO_PORTB_DATA
		LDR	R0,[R1]
		ORR	R0,#0x80
		STR	R0,[R1]
;SET PORT E FOR INPUT BUTTONS
		LDR	R1,=GPIO_PORTE_DIR
		MOV	R0,#0; e0,e1,e2,e3 input
		STR	R0,[R1]	
		LDR	R1,=GPIO_PORTE_AFSEL
		STR	R0,[R1]
		LDR	R1,=GPIO_PORTE_AMSEL
		STR	R0,[R1]	; disabled
		LDR	R1,=GPIO_PORTE_DEN
		MOV	R0,#0xFF
		STR	R0,[R1]	; enabled
		BX	LR

			ALIGN
			END