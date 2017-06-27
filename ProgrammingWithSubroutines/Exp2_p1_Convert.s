;***************************************************************  
; Experiment 2 ; Preliminary Work 1;
; Subroutine
; Converts an m-digit decimal number represented by n bits
;***************************************************************

;LABEL		DIRECTIVE	VALUE		COMMENT
			AREA    	routines, READONLY, CODE
			THUMB
			EXTERN		OutStr 
			EXPORT  	CONVRT
CONVRT	
		PUSH{R0,R1,R2,R3,R4,R6,R7,LR}
		PUSH{R5}
		MOV		R0,#0
		MOV		R6,R5
		;clear the work area	
clear	STR		R0,[R6],#4	;clear 2 words | A is cleared
		SUB		R1,R6,R5
		CMP		R1,#0x2C	;28
		BNE		clear
		SUB		R6,#8
		MOV		R1,#-1
		MOV		R0,R4		 ;	R0 temp
say		LSLS	R0,R0,#1
		ADD		R1,#1
		BCC		say		; if C=0 stay in the loop
		LSL		R4,R1	; R4'ü sola hizala
		RSB		R1,R1,#32
		
		; 1 shift left
sLoop	LDRD	R2,R3,[R6]
		LSLS	R3,R3,#1	; {S} used to clear PSR
		LSLS	R2,R2,#1
		ADCS	R3,#0		;if carry exists add to R3 and Clear PRS 
		LSLS	R4,R4,#1
		ADCS	R2,#0		;if carry exists add to R2 and clear PRS
		STRD	R2,R3,[R6]
		
		MOV		R0,#0		; R0 = offset
		MOV		R2,#0
		SUB		R1,R1,#1	; R1 <= R1-1
		CMP		R1,#0
		BEQ		store
		
loop1	LDRB	R2,[R6,R0]
		MOV		R3,R2
		BFC		R2,#4,#28	; get R2
		LSR		R3,#4		; get R3
		
		CMP		R2,#5
		BLO		chk7
		LDR		r7,[R6,R0]
		ADD		r7,#0x00000003	; ADDS?
		STR		r7,[R6,R0]
		CMP		R2,#13
		ADC		R3,#0

chk7	CMP		R3,#5
		BLO		offset
		LDR		r7,[R6,R0]
		ADD		r7,#0x00000030
		STR		r7,[R6,R0]

offset	ADD		R0,#1
		CMP		R0,#5
		BNE		loop1
		B		sLoop
		
store	MOV		R0,#0
		MOV		R2,#0
		MOV		R1,#4
Count	LDRB	R2,[R6,R1]
		MOV		R3,R2
		LSR		R3,#4		; check Ax(7:4)
		CMP		R3,#0
		BNE		wLoop
		BFC		R2,#4,#28	; check Ax(3:0)
		CMP		R2,#0
		ADDNE	R0,#1
		BNE		wLoop
		SUB		R1,R1,#1
		CMP		R1,#0xffffffff
		BEQ		exit
		B		Count
		
wLoop	LDRB	R2,[R6,R1]
		SUB		R1,R1,#1
		MOV		R3,R2
		LSR		R3,#4		; get A1(7:4)
		CMP		R0,#1
		BEQ		pass
		ADD		R3,#0x30	; get ASCII value
		STRB	R3,[R5],#1
pass	BFC		R2,#4,#28	; get A1(3:0)
		ADD		R2,#0x30	; get ASCII value
		STRB	R2,[R5],#1
		SUBEQ	R0,#1
		CMP		R1,#0xFFFFFFFF
		BNE		wLoop
		
		; Output
		MOV		R0,#0x0D
		STRB	R0,[R5],#1
		MOV		R0,#0x04
		STRB	R0,[R5],#1
		POP{R5}	;load the address
		
		BL		OutStr
exit	POP{R0,R1,R2,R3,R4,R6,R7,LR}
		BX		LR
			
			ALIGN
			END