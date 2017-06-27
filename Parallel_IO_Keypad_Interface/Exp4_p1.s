;***************************************************
; Experiment 4 ; pre_part-1;
; Subroutine	100 msec delay
;***************************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
			AREA    	routines, READONLY, CODE
			THUMB
			EXPORT  	Delay100
Delay100
		PUSH{r0}
		MOV32	r0,#0xC3500
say		SUBS	r0,#1
		BNE		say
		POP{r0}
		BX		LR
		
		ALIGN
		END