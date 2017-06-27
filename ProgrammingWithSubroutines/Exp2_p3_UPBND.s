;***************************************************
; Experiment 2 ; pre_part-3;
; Subroutine	Update Bands (UPBND)
;***************************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
			AREA    	routines, READONLY, CODE
			THUMB
			EXPORT  	UPBND
		; R1 = LowerBand  R2= UpperBand
		; R4 = Current Value R5 = U-D input
UPBND	
		CMP		R5,#0x55 ;U
		MOVEQ	R1,R4	;update lower band
		
		CMP 	R5,#0x44 ;D
		MOVEQ	R2,R4	;update upper band
		
		BX		LR
			ALIGN
			END