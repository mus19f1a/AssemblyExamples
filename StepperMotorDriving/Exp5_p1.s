;***************************************************************  
; Experiment 5 ; Preliminary Work Part 1;
; ----------- FSM Subroutine --------------
; GPIO Full Step Mode settings for step motor, | one step motion
;***************************************************************
; INPUT	:  R3 direction -| 0xF0 -> clockwise |- -| 0x0F ->counterclockwise	|-
; Outputs: B4: out1		B5: out2
;			   B6: out3		B7: out3
GPIO_PORTB_DATA	EQU 0x400053FC
	
;LABEL	DIRECTIVE	VALUE		COMMENT
		AREA		routines, READONLY, CODE
		THUMB	 
		EXPORT 	FSM
	
FSM	PUSH{R0,R1,R2}
	MOV	R2,#0xF0	;temp
	CMP	R3,R2
; get port B current data
	LDR	R1,=GPIO_PORTB_DATA
	LDR	R0,[R1]
	BFC	R0,#0,#8 ; clear R0
	LDRB R2,[R1] ; current pos. R2 
	BNE	ccw
	LSR	R2,#1		;ClockWise
	CMP	R2,#0x08
	BNE	upd ; pass	
	MOV	R2,#0x80;if 0000 1000 then Reset to #0x80
	B	upd

ccw	LSL	R2,#1		;CounterClockWise
	CMP	R2,#0x100
	BNE	upd ; pass	
	MOV	R2,#0x10 ; if 0001 0000 0000 then Reset to #0x10
upd ORR	R0,R2
	STR	R0,[R1]
		
	POP{R0,R1,R2}
	BX		LR
			
	ALIGN
	END