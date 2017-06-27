;***************************************************************  
; Converts binary to 1 integer and 2 friction
;	Input : R5	| X.YZ
; Result stored at 0x2000.0500
;***************************************************************

ADDR	   	EQU	    	0x20004000	

;LABEL		DIRECTIVE	VALUE		COMMENT
			AREA    	routines, READONLY, CODE
			THUMB
			EXPORT  	calc_1
calc_1	
		PUSH{R0,R1,R2,R3,R7,LR}
		LDR		R7,=ADDR
		MOV		R0,#1241
		; integer X
		UDIV	R1,R5,R0
		ADD		R3,R1,#0x30
		STRB	R3,[R7],#1	; X

		MUL		R1,R1,R0
		SUB		R5,R5,R1
		
		MOV		R0,#0x2E  ; "."
		STRB	R0,[R7],#1
		; highest fraction Y		
		MOV		R0,#124
		UDIV	R2,R5,R0
		ADD		R3,R2,#0x30
		STRB	R3,[R7],#1 ; Y
		MUL		R2,R2,R0
		SUB		R1,R5,R2
		; second fraction Z
		MOV		R0,#12
		UDIV	R1,R1,R0
		ADD		R3,R1,#0x30
		STRB	R3,[R7],#1 ; Y
		MOV		R0,#0x0D;
		STRB	R0,[R7],#1
		MOV		R0,#0x04
		STRB	R0,[R7],#1
		
exit	POP{R0,R1,R2,R3,R7,LR}
		BX		LR
			
		ALIGN
		END