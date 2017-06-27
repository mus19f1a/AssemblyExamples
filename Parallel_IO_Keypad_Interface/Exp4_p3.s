;*************************************************************** 
; Exp4_p3.s  Part-III
; Keypad press detection program

GPIO_PORTB_DATA		EQU 0x400053FC ; base address
GPIO_PORTB_ROW		EQU 0x400053C0 ; Rows   (L1-L4) Output 
GPIO_PORTB_CLMN		EQU 0x4000503C ; Columns(R1-R4) Input
GPIO_PORTB_DIR		EQU 0x40005400
GPIO_PORTB_AFSEL	EQU 0x40005420
GPIO_PORTB_DEN		EQU 0x4000551C
GPIO_PORTB_PUR		EQU 0x40005510 ; PUR actual address
IOB					EQU 0xF0; B7-4 output | B3-0 input 
SYSCTL_RCGCGPIO		EQU 0x400FE608
;***************************************************************
	AREA	main, READONLY, CODE
	THUMB
	EXTERN	Delay100
	EXTERN	OutStr
	EXTERN	CONVRT
	EXPORT __main
	
__main	LDR R1, =SYSCTL_RCGCGPIO
		LDR R0, [R1]
		ORR R0, R0, #0x02 ;0000 0010 ;Enable clock of port B
		STR R0, [R1]
		NOP
		NOP
		NOP ; let GPIO clock stabilize
		
		LDR R1, =GPIO_PORTB_DIR ; config. of port B starts
		LDR R0, [R1]
		BIC R0, #0xFF	; clear 8 bit	  Output	 Input
		ORR R0, #IOB	; b11110000  (L1-L2-L3-L4,R1-R2-R3-R4)
		STR R0, [R1]	; 1-Out 0-In (B7,B6,B5,B4,B3,B2,B1,B0)
		LDR R1, =GPIO_PORTB_AFSEL
		LDR R0, [R1]
		BIC R0, #0xFF	; clear left 8-bit
		STR R0, [R1]	; set func. to GPIO
		LDR R1, =GPIO_PORTB_DEN
		LDR R0, [R1]
		ORR R0, #0xFF	; GPIO Enabled
		STR R0, [R1]
		LDR	R1,=GPIO_PORTB_PUR ; pull up E3-0(inputs)
		MOV	R0,#0x0F 	;
		STR	R0,[R1] ; config. of port E ends
;************* port initilization done *************************

		LDR	R1,=GPIO_PORTB_ROW  ; L1-L4 |3C0
		LDR	R2,=GPIO_PORTB_CLMN ; R1-R4 |03C
		mov	r5,#4	;constant
		; Detect Pressed key
start	MOV	R0,#0x00
		STR R0,[R1]	; set rows to 0
chk_1	LDR r3,[R2] ; read column data
		CMP r3,#0x0F
		BEQ chk_1	;if all one stay in the check loop
		BL	Delay100
		mov	r4,#0x70	; rows 0111
		STR	r4,[R1]		;update rows
		BL Delay100
		LDR R0,[R2]
		CMP R0,#0x0F
		BNE	calcID
		mov	r4,#0xB0	; rows 1011
		STR	r4,[R1]		;update rows
		BL	Delay100
		LDR R0,[R2]
		CMP R0,#0x0F
		BNE	calcID		
		mov	r4,#0xD0	; rows 1101
		STR	r4,[R1]		;update rows
		BL	Delay100
		LDR R0,[R2]
		CMP R0,#0x0F
		BNE	calcID		
		mov	r4,#0xE0	; rows 1110
		STR	r4,[R1]		;update rows
		BL	Delay100
		LDR R0,[R2]
		CMP R0,#0x0F
	;	r3-column data | r4-row data
calcID	BFC	 r3,#8,#24
		BFC	 r4,#8,#24
		LSRS r3,#1
		BHS	 rs	; if carry 0 4th row else go 'rs'
		MOV	 r3,#4	; 4th column
		B	 gec_1
rs		LSR	 r3,#1	; r3 show column number
gec_1	ADDS r3,#0 ; clear xPSR
		LSRS r4,#5
		BHS  cs ; if carry 0 4th column
		MOV	 r4,#4	; 4th row
		B	 gec_2
cs		LSR	 r4,#1	; r4 show row number
		SUB	 r4,r4,#1
gec_2	MUL	 r4,r5;MLA  R6,r4,r5,r3 ; get the key ID
		ADD	 r6,r3,r4
		; ID = (row-1)*4+column
		; Detect Released key
chk_2	BL	Delay100
		LDR r3,[R2] ; read column data
		CMP r3,#0x0F
		BNE chk_2	;if key pressed stay in loop
		BL	CONVRT	; out the R6 data to uart
		B	start
	
		ALIGN
		END			