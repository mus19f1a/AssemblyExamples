;*************************************************************** 
; Exp4_p2.s  Part-II
; Simple data transfer

GPIO_PORTB_DATA		EQU 0x400053FC ; base address
GPIO_PORTB_DIR		EQU 0x40005400
GPIO_PORTB_AFSEL	EQU 0x40005420
GPIO_PORTB_DEN		EQU 0x4000551C
IOB					EQU 0x0F
GPIO_PORTE_DATA		EQU 0x400243FC ; base address
GPIO_PORTE_DIR		EQU 0x40024400
GPIO_PORTE_AFSEL	EQU 0x40024420
GPIO_PORTE_DEN		EQU 0x4002451C
IOE					EQU 0x00
SYSCTL_RCGCGPIO		EQU 0x400FE608

;***************************************************************
	AREA	|.text|, READONLY, CODE, ALIGN=2
	THUMB
	EXTERN	Delay100
	EXPORT __main
	
__main	LDR R1, =SYSCTL_RCGCGPIO
		LDR R0, [R1]
		ORR R0, R0, #0x12 ;0001 0010 ;Enable E and B clock
		STR R0, [R1]
		NOP
		NOP
		NOP ; let GPIO clock stabilize
		
		LDR R1, =GPIO_PORTB_DIR ; config. of port B starts
		LDR R0, [R1]
		BIC R0, #0xFF	; clear left 8 bit
		ORR R0, #IOB	; set R0[7:0] = 8'b00001111
		STR R0, [R1]	; 1-Output 0-Input
		LDR R1, =GPIO_PORTB_AFSEL
		LDR R0, [R1]
		BIC R0, #0xFF	; clear left 8-bit
		STR R0, [R1]	; set func. to GPIO
		LDR R1, =GPIO_PORTB_DEN
		LDR R0, [R1]
		ORR R0, #0xFF	; GPIO Enabled
		STR R0, [R1] ; config. of port B ends
		
		LDR R1, =GPIO_PORTE_DIR ; config. of port E starts
		LDR R0, [R1]
		ORR R0, #IOE
		STR R0, [R1]
		LDR R1, =GPIO_PORTE_AFSEL
		LDR R0, [R1]
		BIC R0, #0xFF
		STR R0, [R1]
		LDR R1, =GPIO_PORTE_DEN
		LDR R0, [R1]
		ORR R0, #0xFF
		STR R0, [R1] ; config . of port E ends			
;************* port initilization done *****************
update	LDR	R1,=GPIO_PORTB_DATA
		LDR	R0,[R1]	; read portE data
		LSR	R0,#4	;get higher ports

		STR		R0,[R1]
		MOV		R2,#49	;	7sn	; 35'5sn
wait	BL		Delay100
		SUBS	R2,#1
		BNE		wait
		B		update	
		
done	B	done
	
		ALIGN
		END			