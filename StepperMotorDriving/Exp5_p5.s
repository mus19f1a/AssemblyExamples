;***************************************************************  
; Experiment 5 ; Preliminary Work Part 5;
; Step motor Speed and Direction control by 4 buttons
;***************************************************************
; INPUT	:  2 switch button connected to D0 CCW and D1 CW 
;STCTRL		EQU 0xE000E010 ; SysTick | +4 STRELOAD | +8 STCURRENT	

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
GPIO_PORTE_IS		EQU 0x40024404 ; Interrupt Sense 
GPIO_PORTE_IBE		EQU 0x40024408 ; Interrupt Both Edge
GPIO_PORTE_IEV		EQU 0x4002440C ; Interrupt Event
GPIO_PORTE_IM		EQU 0x40024410 ; Interrupt Mask
GPIO_PORTE_RIS		EQU 0x40024414 ; Raw Interrupt Status
GPIO_PORTE_ICR		EQU 0x4002441C ; Interrupt Clear Register

;LABEL	DIRECTIVE	VALUE		COMMENT
		AREA		main, READONLY, CODE
		THUMB
		EXTERN e5p5_GPIO_ISR
		EXPORT 	__main
__main	
		CPSID	I
		BL	INIT_GPIO
		MOV	R6,#0xF0	; clockwise
		;MOV32	R7,#3999999	; 1 second = 4x10^6 x 1/4x10^6
		LDR	R7,=39999	; 1 second = 4x10^6 x 1/4x10^6
		NOP
		CPSIE	I
	
loop	BL		e5p5_GPIO_ISR

		B	loop

INIT_GPIO
		LDR	R1,=SYSCTL_RCGCGPIO	
		LDR	R0,[R1]
		ORR	R0,R0, #0x12 ;0001 0010 ;Enable B and E port's clock
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
		
;SET PORT E FOR INPUT BUTTONS and INTERRUPTS
		LDR	R1,=GPIO_PORTE_DIR
		MOV	R0,#0xf0; e0,e1,e2,e3 input
		STR	R0,[R1]	
		LDR	R1,=GPIO_PORTE_AFSEL
		STR	R0,[R1]
		LDR	R1,=GPIO_PORTE_AMSEL
		STR	R0,[R1]	; disabled
		LDR	R1,=GPIO_PORTE_DEN
		MOV	R0,#0x0F
		STR	R0,[R1]	; enabled
; SET INTERRUPT 
		;LDR	R1,=GPIO_PORTE_IM
		;MOV	R0,#0
		;STR	R0,[R1] ; disable intterrupt before configuration
		;LDR	R1,=GPIO_PORTE_IS
		;STR	R0,[R1]; Edge sensitive
		;LDR	R1,=GPIO_PORTE_IBE	
		;MOV	R0,#0xFF
		;STR	R0,[R1] ;Both edge
	;; Clear GPIORIS register by using GPIOICR 
		;LDR	R1,=GPIO_PORTE_ICR
		;STR	R0,[R1]	; clear interrupt flags
		;LDR	R1,=GPIO_PORTE_IM	; Unmask 
		;MOV	R0,#0x0F
		;STR	R0,[R1]	; E0,E1,E2,E3 Interrupt Activated
		BX	LR

			ALIGN
			END