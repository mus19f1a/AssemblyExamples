;*************************************************************** 
; Exp2_p2.s  Part-II
; Print decimal equvilent of the character that entered   

;LABEL		DIRECTIVE	VALUE		COMMENT
NUM	   	EQU	    	0x20000100	
;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
 			AREA    	main, READONLY, CODE
			THUMB
			EXTERN		InChar	; Imports subroutines
			EXTERN		OutStr	
			EXTERN		CONVRT	
			EXPORT  	__main	; Make available

__main
start		BL		InChar
			MOV		R4,R5	; CONVRT take data from R4
			LDR		R5,=NUM ; Address of the data(DEC)
			BL		CONVRT
			B		start
;***************************************************************
			ALIGN
			END
