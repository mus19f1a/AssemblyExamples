;*************************************************************** 
; Exp2_p2.s  Part-III
; Number guess game

ADDR	   	EQU	    	0x20000400	
;***************************************************************
		AREA        sdata, DATA, READONLY
        THUMB
MSG     DCB     	"Set the n value.."
		DCB			0x0D
		DCB			0x04
;***************************************************************
;LABEL	DIRECTIVE	VALUE		COMMENT
 		AREA    	main, READONLY, CODE
		THUMB
		EXTERN		InChar	; Imports subroutines
		EXTERN		OutStr	
		EXTERN		CONVRT	
		EXTERN		UPBND	
		EXPORT  	__main
				
__main
start	MOV		R0,#10
		MOV		R3,#1	;for right shift
		LDR	    R5,=MSG
		BL		OutStr
		MOV		R5,#0
		BL		InChar
		SUB		R1,R5,#0x30	; convert hex to DEC
		MUL		R1,R1,R0	; 1st digit*10
		BL		InChar
		SUB		R0,R5,#0x30	; hex to DEC
		ADD		R0,R1	; R0 = n
		MOV		R1,#1	; R1 = Lower Band Limit
		MOV		R2,#1
		LSL		R2,R0	; R2 = Upper Band Limit
		
loop	ADD		R4,R1,R2	
		LSR		R4,R3	; R4 current guess
		LDR		R5,=ADDR
		BL		CONVRT		; Out R4 value
		MOV		R5,#0
		BL		InChar		; Get information
		CMP		R5,#0x43 	; C  check
		BEQ		done
		BL		UPBND	; Update the band limits
		B 		loop
done	B		start
			ALIGN
			END