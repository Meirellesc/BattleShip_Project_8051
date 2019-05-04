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
			MOV P0,#00h			;Initializing the ports
			MOV P1,#00h
			MOV P2,#00h
			MOV P3,#00h
			RET
code


;----------------SHIP_POS--------------------
code at 0300h
	
			
code

;---------------------------------------------
;----------------JOYSTICK---------------------
;---------------------------------------------

;----------------BUTTOM_UP--------------------
code at 0400h

BU:		MOV A,50h					;Armazenando a posição em (A)
		CLR C						;Limpando o Carry
		SUBB A, #10h				;Subtraindo (A)-#10h -> para subir o cursor
		JC BU_1						;Caso (A) < 10 -> o cursor está na borda superior [retorna]
		MOV A,50h					;Armazenando a posição em (A)
		CLR C						;Limpando o Carry
		SUBB A, #10h				;Subtraindo (A)-#10h -> para subir o cursor
		MOV 50h,A					;Carrega o end. (50h) o novo valor do cursor
BU_1:	RET
	
code 

;----------------BUTTOM_DOWN--------------------
code at 0500h

BD:		MOV A,50h					;Armazenando a posição em (A)
		CLR C						;Limpando o Carry
		SUBB A, #70h				;Subtraindo (A)-#70h -> para descer o cursor
		JNC BD_1					;Caso (A) >= 70 -> o cursor está na borda inferior [retorna]
		MOV A,50h					;Armazenando a posição em (A)
		CLR C						;Limpando o Carry
		SUBB A, #70h				;Subtraindo (A)-#70h -> para descer o cursor
		MOV 50h,A					;Carrega o end. (50h) o novo valor do cursor
BD_1:	RET

code

;----------------BUTTOM_LEFT--------------------
code at 0600h

BL:		MOV A,50h					;Armazenando a posição em (A)
		ANL A,#03h					;(A) AND #03h -> Máscara
		CLR C						;Limpando o Carry
		SUBB A, #01h				;Subtraindo (A)-#01h -> para mover o cursor a esquerda
		JC BL_1						;Caso (A) < 01 -> o cursor está na borda esquerda [retorna]
		DEC 50h						;Decrementa o conteúdo de (50h)
BL_1:	RET

code

;----------------BUTTOM_RIGHT--------------------
code at 0700h

BR:		MOV A,50h					;Armazenando a posição em (A)
		ANL A,#03h					;(A) AND #03h -> Máscara
		CLR C						;Limpando o Carry
		SUBB A, #02h				;Subtraindo (A)-#02h -> para mover o cursor a direita
		JNC BR_1					;Caso (A) >= 02 -> o cursor está na borda direita [retorna]
		INC 50h						;Incremeta o conteúdo de (50h)
BR_1:	RET

code

;----------------BUTTOM_SAVE--------------------
code at 0800h

BS:		MOV R0,80h					;Carregando o (R0) com o conteudo de 80h [Auxiliar para Salvar]
		MOV @R0,50h					;Salvando a posição do cursor
		INC 80h						;Atualizando buffer de salvar
		RET

code

;----------------BUTTOM_FIRE--------------------
code at 0900h

BF:		MOV PSW, #00h					;Inicializando PSW -> Banco:0
		MOV A,50h
		MOV A,#40h
		MOV R1,#05h
		
BF_1:	CLR C
		SUBB A,@R0
		JNZ BF_2
		INC 60h
		MOV A,@R0
		;SET ACC.7

BF_2:
code

;-------------------MAIN----------------------
code at 0200h

MAIN:		
			LCALL HARD_INIT		;Call to initialize the ports

			END
code