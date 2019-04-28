;----------------------------------------------
;--------------Project_BattleShip--------------
;----------------------------------------------
;
;	@Authors: Lucas Meirelles
;			  Pedro Domingues
;
;	@Date: 27/04/2019
;	
;----------------------------------------------

;-------------------LIBS-----------------------
$include (REG51.inc)

;-------------------INIT-----------------------
code at 0000h

			LJMP MAIN
	
code 

;----------------HARD_INIT--------------------
code at 0100h
	
HARD_INIT:
			MOV P0,#00h		;Initializing the ports
			MOV P1,#00h
			MOV P2,#00h
			MOV P3,#00h
			RET
code


;----------------SHIP_POS--------------------
code at 0300h
	
			
code

;-------------------MAIN-----------------------
code at 0200h

MAIN:		
			LCALL HARD_INIT

			END
code