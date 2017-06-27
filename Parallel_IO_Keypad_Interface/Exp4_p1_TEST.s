		AREA        sdata, DATA, READONLY
        THUMB
MSG		DCB     	"DONE.."
		DCB			0x0D
		DCB			0x04
		
;***************************************************************
;LABEL	DIRECTIVE	VALUE		COMMENT
 		AREA    	main, READONLY, CODE
		THUMB
		EXTERN		Delay100	; Imports subroutines
		EXTERN		OutStr	
		EXPORT  	__main
			
__main  

rst		BL		Delay100
		BL		Delay100
		BL		Delay100
		BL		Delay100
		BL		Delay100
		BL		Delay100
		BL		Delay100
		BL		Delay100
		BL		Delay100
		BL		Delay100

		LDR		r5,=MSG
		BL		OutStr
		B	rst
		
	;old version	
;rst		MOV 	r1,#100
		
;tut		BL		Delay100
		;SUBS	r1,#1
		;BNE		tut
		
		;LDR		r5,=MSG
		;BL		OutStr
		;B	rst
		
		ALIGN
		END