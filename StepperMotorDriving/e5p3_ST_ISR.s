;*************************************************************** 
; Exp5_p3.s  Part-III
;  Subroutine for ISR 	e5p3_ST_ISR
;  R5 should not be changed! 	R3 is the input value from the button
;***************************************************
GPIO_PORTE_DATA	EQU 0x400243FC
;LABEL		DIRECTIVE	VALUE		COMMENT
			AREA    	routines, READONLY, CODE
			THUMB
			EXTERN		FSM
			EXPORT  	e5p3_ST_ISR
e5p3_ST_ISR
		PUSH{R1,R2,R3,LR}
		MOV	R2,#0x03 ;	0000 0011	no pushed button
		MOV	R3,#0	 ; temp
		LDR	R1,=GPIO_PORTE_DATA
		LDR	R1,[R1] 
		BFC	R1,#2,#30 ;R1 current button status
		CMP	R1,R2
		BEQ	done
		LSR	R2,#1	; 0001
		CMP	R1,R2		; D1 check
		MOV	R3,#0xF0	; means D1,  CW
		BEQ	done
		MOV	R3,#0x0F	; means D0, CCW
		; R3  0: no change 
		;	 F0: CW
		;	 0F: CCW
done	CMP	R5,R3
		BEQ	exit	; if no change
		CMP	R3,R2
		BHI	Updt		; R3 non-zero	
		MOV	R3,R5		; get rotate direction
		MOV	R5,#0	; reset R0
		BL		FSM		; do operation
		B		exit
Updt	MOV	R5,R3		; update R0
exit	POP{R1,R2,R3,LR}
		BX		LR
		
		ALIGN
		END