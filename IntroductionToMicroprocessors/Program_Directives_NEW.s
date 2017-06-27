;*************************************************************** 
; Program_Directives_NEW.s  
; Copies the table from one location
; to another memory location.
;***************************************************************	

;*************************************************************** 
; EQU Directives
; These directives do not allocate memory
;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
FIRST	   	EQU	    	0x20000480
	
;***************************************************************
; Directives - This Data Section is part of the code
; It is in the read only section  so values cannot be changed.
;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
            AREA        sdata, DATA, READONLY
            THUMB
CTR1    	DCB     	0x0A
MSG     	DCB     	"Copying table..."
			DCB			0x0D
			DCB			0x04
;***************************************************************
; Program section					      
;***************************************************************
;LABEL		DIRECTIVE	VALUE		COMMENT
			AREA    	main, READONLY, CODE
			THUMB
			EXTERN		OutStr	; Reference external subroutine	
			EXPORT  	__main	; Make available

__main
start		LDR    		R0,=FIRST	; baslangic adresi
			MOV			R1, R0		; Guncel adres
			LDR    		R2,=CTR1 	; bitis sayisini ekle
			LDRB		R2,[R2]
			MOV    		R4,#0		; tekrar sayisini tutan register
			
DigerTur	CMP			R2,R4		; son sayi kontrolu
			BEQ			TabloTamam
			ADD			R4,R4,#1	; tekrar sayisini güncelle
			MOV			R3,R4		; gecici index
			
loopInner  	STRB   		R4,[R1]		; Store table
			ADD			R1,R1,#1	
			SUBS		R3,R3,#1	
			BNE     	loopInner
			
			B			DigerTur
			
TabloTamam	LDR	    	R5,=MSG
			BL			OutStr	        ; Copy message
			MOV			R2,R1			; Son Adres R2'ye kaydedildi
			SUB			R1,R1,R0		; R1 artik Ofset degerini tutuyor
										; R0 güncel adres tutuyor
										; R4 güncel data tutuyor
loop2   	LDRB    	R4,[R0]
			STRB	   	R4,[R0,R1]		; Copy table
			ADD			R0,R0,#1		; update R0
			CMP			R2,R0			; tablo sonu kontrolu
			BNE			loop2
			B			start
;***************************************************************
; End of the program  section
;***************************************************************
;LABEL      DIRECTIVE       VALUE                           COMMENT
			ALIGN
			END
