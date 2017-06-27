;***************************************************************  
; Experiment 6 ; Preliminary Work Part 2;
; input pin is configured as PB2
; Pulse width, Period and Duty Cycle detector
;***************************************************************
	
;LABEL	DIRECTIVE	VALUE		COMMENT
		AREA		main, READONLY, CODE
		THUMB
		EXTERN	OutStr	; R5 is the address of data to be out
		EXTERN	READ_PULSE
		EXTERN	PULSE_INIT
		EXPORT 	__main
__main	
		BL	PULSE_INIT
		BL	READ_PULSE	; initiliaze the Pulse
		
		
loop	B	loop


			ALIGN
			END