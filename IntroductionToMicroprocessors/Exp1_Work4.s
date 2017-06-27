;***************************************************************
; Exp1_Work4.s  
; Experiment 1 experimental work 4;
; Serial communication between the Board and user copmuter.
;***************************************************************

;***************************************************************
; Directives - This Data Section is part of the code
; It is in the read only section  so values cannot be changed.
;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
            AREA        sdata, DATA, READONLY
            THUMB
MSG	    	DCB			0x0D ; ASCII Satirbasi
			DCB     	"Press Spacebar to exit!"
			DCB			0x0D 
			DCB			0x04 ; end
			
;***************************************************************
; Program section					      
;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
			AREA    	main, READONLY, CODE
			THUMB
			EXTERN		InChar	; Reference external subroutines
			EXTERN		OutChar
			EXTERN		OutStr 
			EXPORT  	__main		; Make available

__main
get		BL		InChar
		CMP 	R5,#0x20 ; 0x20 = Spacebar in ASCII
		BEQ		done
		BL		OutChar
		LDR		R5,=MSG ; additional
		BL		OutStr	; additional
		B		get
done	B		done

;***************************************************************
; End of the program  section
;***************************************************************
;LABEL      DIRECTIVE       VALUE                           COMMENT
			ALIGN
			END
