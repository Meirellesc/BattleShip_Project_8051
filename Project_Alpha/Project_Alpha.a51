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

;-------------------------------
;-------------MAIN--------------
;-------------------------------
code at 0000h

        LJMP MAIN

code 

;----------------HARD_INIT--------------------
code at 0100h
	
HARD_INIT:
        MOV P0,#00h			;Initializing the ports
        MOV P1,#00h
        MOV P2,#00h
        MOV P3,#0FFh
        RET
code


;---------------------------------------------
;----------------JOYSTICK---------------------
;---------------------------------------------

;----------------BUTTOM_UP--------------------
code at 0400h

BU:		
        MOV PSW,#00h
        MOV A,50h					;Armazenando a posi��o em (A)
		CLR C						;Limpando o Carry
		SUBB A, #10h				;Subtraindo (A)-#10h -> para subir o cursor
		JC BU_1						;Caso (A) < 10 -> o cursor est� na borda superior [retorna]
		MOV A,50h					;Armazenando a posi��o em (A)
		CLR C						;Limpando o Carry
		SUBB A, #10h				;Subtraindo (A)-#10h -> para subir o cursor
		MOV 50h,A					;Carrega o end. (50h) o novo valor do cursor
BU_1:	RET
	
code 

;----------------BUTTOM_DOWN--------------------
code at 0500h

BD:		MOV PSW,#00h
        MOV A,50h					;Armazenando a posi��o em (A)
		CLR C						;Limpando o Carry
		SUBB A, #70h				;Subtraindo (A)-#70h -> para descer o cursor
		JNC BD_1					;Caso (A) >= 70 -> o cursor est� na borda inferior [retorna]
		MOV A,50h					;Armazenando a posi��o em (A)
		ADD A, #10h  				;Subtraindo (A)-#70h -> para descer o cursor
		MOV 50h,A					;Carrega o end. (50h) o novo valor do cursor
BD_1:	RET

code

;----------------BUTTOM_LEFT--------------------
code at 0600h

BL:		MOV PSW,#00h
        MOV A,50h					;Armazenando a posi��o em (A)
		ANL A,#03h					;(A) AND #03h -> M�scara
		CLR C						;Limpando o Carry
		SUBB A, #01h				;Subtraindo (A)-#01h -> para mover o cursor a esquerda
		JC BL_1						;Caso (A) < 01 -> o cursor est� na borda esquerda [retorna]
		DEC 50h						;Decrementa o conte�do de (50h)
BL_1:	RET

code

;----------------BUTTOM_RIGHT--------------------
code at 0700h

BR:		MOV PSW,#00h
        MOV A,50h					;Armazenando a posi��o em (A)
		ANL A,#03h					;(A) AND #03h -> M�scara
		CLR C						;Limpando o Carry
		SUBB A, #02h				;Subtraindo (A)-#02h -> para mover o cursor a direita
		JNC BR_1					;Caso (A) >= 02 -> o cursor est� na borda direita [retorna]
		INC 50h						;Incremeta o conte�do de (50h)
BR_1:	RET

code

;----------------BUTTOM_SAVE--------------------
code at 0800h

BS:		MOV PSW,#00h
        MOV R0,61h					;Carregando o (R0) com o conteudo de 61h [Auxiliar para Salvar]
		MOV @R0,50h					;Salvando a posi��o do cursor
		INC 61h						;Atualizando buffer de salvar
		RET

code

;----------------BUTTOM_FIRE--------------------
code at 0900h

BF:		MOV PSW, #00h					;Inicializando PSW -> Banco:0
		MOV R0,#40h                     ;Armazenando o end 40h [primeiro navio] em (R0)
		MOV R1,#04h                     ;Armazenando a quantidade de navios em (R1)
		
BF_1:	MOV A,50h                       ;Armazenando o end 50h [cursor] em (A)
        CLR C                           ;Limpa Carry
		SUBB A,@R0                      ;(A) - (R0)
		JNZ BF_2                        ;Caso (Z) = 0 [errou o navio], pula para a sub-rotina BF_2
		INC 60h                         ;Incrementa a pontua��o
		MOV A,@R0                       ;Pega o endere�o no navio
		SETB ACC.7                      ;Set '1' [flag] no bit mais significativo no end do navio
        MOV @R0,A                       ;Retorna o valor para o end do navio 

BF_2:   INC R0                          ;Incrementa o buffer do (R0) para checar outros navios
        DJNZ R1, BF_1                   ;Decrementa (R1) e verifica se checou a quantidade de navios
        DEC 67h                         ;Decrementa (67h) [numero de tentativas]
        
        MOV R0,63h
        MOV R1,64h
        MOV R2,65h
        MOV 63h,#00h
        MOV 64h,#00h
        MOV 65h,#00h
        LCALL ATTLED
        LCALL WAIT
        LCALL WAIT
        LCALL WAIT
        MOV 63h,#0FFh
        MOV 64h,#0FFh
        MOV 65h,#0FFh
        LCALL ATTLED
        LCALL WAIT
        LCALL WAIT
        LCALL WAIT
        MOV 63h,R0
        MOV 64h,R1
        MOV 65h,R2
        LCALL ATTLED
        RET                             
        
code

;----------------XY_P--------------------
code at 0A00h
    
XYP:    MOV PSW,#00h
        MOV A,62h                       ;Armazena end (62h) [buffer convers�o] em (A)
        ANL A,#03h                      ;Aplica m�scara em (A) [0000 0111]
        ADD A,#63h                      ;(A) + (63h) [end de mem inicial das portas]
        MOV R0,A                        ;Armazena (A) em (R0) [selecionou qual das portas]
        
        MOV A,62h                       ;Armazena end (62h) [buffer convers�o] em (A)
        ANL A,#70h                      ;Aplica m�scara em (A) [0111 0000]
        SWAP A                          ;Troca o MSB com LSB de (A)
        MOV R1,A                        ;Armazena (A) em (R1)
        MOV R2,#01h                     ;Armazena #01h em (R2)
        
        JZ, XYP_2                       ;Caso (Z)=0 de (A) pula para XYP_2
        
XYP_1:  MOV A,R2                        ;Armazena (R2) em (A)
        RL A                            ;Rotaciona a esquerda (A)
        MOV R2,A                        ;Armazena (A) em (R2)
        DJNZ R1,XYP_1                   ;Decrementa (R1) e caso (Z)!=0 pula para XYP_1
        
XYP_2:  MOV A,R2                        ;Armazena (R2) em (A)
        ORL A,@R0                       ;Realiza "OR" entre((R0)) e (A)
        MOV @R0,A                       ;Armazena (A) em ((R0))
        RET
        
code

;------------------CURSOR---------------------
code at 0B00h
        
CURSOR: MOV PSW,#00h
        MOV A,50h                       ;Armazena end (50h) [buffer cursor XY] em (A)
        ANL A,#03h                      ;Aplica m�scara em (A) [0000 0111]
        ADD A,#63h                      ;(A) + (63h) [end inicial das portas]
        MOV R0,A                        ;Armazena (A) em (R0) [selecionou qual das portas]
        
        MOV A,50h                       ;Armazena end (50h) [buffer cursor XY] em (A)
        ANL A,#70h                      ;Aplica m�scara em (A) [0111 0000]
        SWAP A                          ;Troca o MSB com LSB de (A)
        MOV R1,A                        ;Armazena (A) em (R1)
        MOV R2,#01h                     ;Armazena #01h em (R2)
        
        JZ, CURSOR_2                    ;Caso (Z)=0 de (A) pula para CURSOR_2
        
CURSOR_1:
        MOV A,R2                        ;Armazena (R2) em (A)
        RL A                            ;Rotaciona a esquerda (A)
        MOV R2,A                        ;Armazena (A) em (R2)
        DJNZ R1,CURSOR_1                ;Decrementa (R1) e caso (Z)!=0 pula para CURSOR_1
        
CURSOR_2:
        MOV 51h,R2                      ;Armazena (R2) em (51h) [end de leds (modo->P)]
        MOV 52h,R0                      ;Armazena (R2) em (52h) [end de porta (modo->P)] 
        RET
code

;----------------WAIT [0,5s]------------------
code at 0D00h

;DEFINIR OS VALORES DAS CONSTANTES DE R0 E R1 PARA DAR 0,5s

WAIT:   MOV PSW, #00h
        MOV R0,#01h                    ;Define constante para (R0)

WAIT_1: MOV R1,#00h                    ;Define constante para (R1)

WAIT_2: MOV R2, #00h

        DJNZ R2, $
        DJNZ R1,WAIT_2                  ;Decrementa (R1). Caso (Z)!=0 pula para a pr�pria linha
        DJNZ R0,WAIT_1                  ;Decrementa (R0). Caso (Z)!=0 pula para WAIT_1
        RET

code

;----------------ATT LED's------------------
code at 0E00h
ATTLED: MOV P0,63h                      ;Atualiza Porta 0
        MOV P1,64h                      ;Atualiza Porta 1
        MOV P2,65h                      ;Atualiza Porta 2
        RET
code

;----------------SHIPS_ON------------------
code at 0F00h
SHIPS_ON: 
        MOV PSW, #18h                   ;BANCO 4 
        MOV R0, #40h                    ;R0 armazena o inicio do buffer dos navios
        MOV A, 61h
        CLR C
        SUBB A, #40h
        MOV R7, A                       ;R7 armazena a quantidade de navios salvos
        
        ; >>> VERIFICAR SE TEM PELOMENOS 1 NO BUFFER <<<<
        JZ SHIPS_ON_2
        
        ; >>> TEM PELOMENOS 1! ENT�O LE O BUFFER <<<
SHIPS_ON_1:
        MOV 62h, @R0                    ;PREPARA PARA CONVERTER O VALOR DO BUFFER E ACENDER O LED
        LCALL XYP
        MOV PSW,#18h
        INC R0
        
        ; >>> CONFERE SE AINDA TEM NAVIOS NO BUFFER
        DJNZ R7, SHIPS_ON_1
        
SHIPS_ON_2:
        RET
code

;----------------SHIPS_ON_FIRE------------------
code at 1000h

SHIPS_ON_FIRE:                          ;ACENDE NAVIOS QUE FORAM ATINGIDOS

        MOV PSW, #18h                   ;BANCO 4 
        MOV R0, #40h                    ;R0 armazena o inicio do buffer dos navios
        MOV R7, #04h                    ;R7 armazena a quantidade de navios salvos
        
SHIPS_ON_FIRE1:
        MOV A, @R0
        JNB ACC.7,SHIPS_ON_FIRE2        ;VERIFICA SE O NAVIO FOI ATINGIDO (ACC.7 == 1)
        MOV 62h, @R0                    ;PREPARA PARA CONVERTER O VALOR DO BUFFER E ACENDER O LED
        LCALL XYP
        MOV PSW,#18h
        
SHIPS_ON_FIRE2:
        INC R0
        DJNZ R7, SHIPS_ON_FIRE1
        RET
code

;-------------------MAIN----------------------
code at 0200h

MAIN:		
		LCALL HARD_INIT		            ;Call to initialize the ports
; =============================================================
; SOFTWARE INIT
        MOV PSW, #00h
        MOV 40h, #00h
        MOV 41h, #00h
        MOV 42h, #00h
        MOV 43h, #00h
        MOV 50h, #00h
        MOV 51h, #01h
        MOV 52h, #63h
        MOV 60h, #00h
        MOV 67h, #07h
        MOV 61h, #40h
        MOV 62h, #00h
        MOV 63h, #01h
        MOV 64h, #00h
        MOV 65h, #00h
        MOV 66h, #00h

; =============================================================
; Player 1 (Posicionando navios)
        
PLAYER1_START:
        MOV PSW, #00h                   ;Debouncing
        LCALL ATTLED
        MOV A, P3
        CLR C
        SUBB A, #0FFh
        JZ PLAYER1_START
        LCALL WAIT
        MOV A, P3
        CLR C
        SUBB A, #0FFh
        JZ PLAYER1_START
        MOV A, P3
        
        LCALL CURSOR                    ;Salvou posi��o do cursor no end's [51h e 52h - modo -> P]
        
        MOV A, P3
        JB ACC.7, JUMPBU
        LCALL BU
JUMPBU:
        MOV A, P3
        JB ACC.6, JUMPBD
        LCALL BD
JUMPBD:
        MOV A, P3 
        JB ACC.4, JUMPBL
        LCALL BL
JUMPBL:
        MOV A, P3 
        JB ACC.3, JUMPBR
        LCALL BR
JUMPBR:
        MOV A, P3
        JB ACC.1, JUMPBS
        LCALL BS
JUMPBS:
        MOV A, P3                       ;Debouncing
        CLR C
        SUBB A, #0FFh
        JNZ JUMPBS                      ;Esperando soltar bot�o
        LCALL WAIT
        MOV A, P3
        CLR C
        SUBB A, #0FFh
        JNZ JUMPBS                      ;Esperando soltar bot�o
        
        MOV 63h, #00h                   ;Limpando mapa
        MOV 64h, #00h
        MOV 65h, #00h
        
        MOV 62h, 50h                    ;Armazena a posi��o do cursor no buffer para convers�o [XY -> P]
        LCALL XYP                       ;Convertendo a nova posi��o do cursor
        
        LCALL SHIPS_ON
        
        MOV A, 61h                      ;Verificando o auxiliar salvamento
        CLR C
        SUBB A, #44h                    ;Verificando se salvou 4 navios
        JC PLAYER1_START
        
        
; =============================================================
; Player 2 (Game)

PLAYER2_START:
        ; SOFTWARE INIT
        MOV 50h, #00h
        MOV 51h, #01h
        MOV 52h, #63h
        MOV 60h, #00h
        MOV 67h, #07h
        MOV 62h, #00h
        MOV 63h, #01h
        MOV 64h, #00h
        MOV 65h, #00h
        MOV 66h, #00h
        
; GAME
GAME_LOOP:
        MOV PSW, #00h                   ;BANCO 0
        LCALL ATTLED                    ;Atualiza as portas
        MOV A, P3                       ;L� a porta P3
        CLR C
        SUBB A, #0FFh                   ;Verifica se foi pressionado bot�o
        JZ GAME_LOOP                    ;Caso (Z)=0, n�o foi pressionado
        LCALL WAIT                      ;ESPERA 0,5s
        MOV A, P3                       ;DEBOUNCING
        CLR C
        SUBB A, #0FFh
        JZ GAME_LOOP
        MOV A, P3
        
        LCALL CURSOR                    ;Salvou posi��o do cursor no end's [51h e 52h - modo -> P]
        
        MOV A, P3
        JB ACC.7, JUMPBU_GAME
        LCALL BU
JUMPBU_GAME:
        MOV A, P3
        JB ACC.6, JUMPBD_GAME
        LCALL BD
JUMPBD_GAME:
        MOV A, P3 
        JB ACC.4, JUMPBL_GAME
        LCALL BL
JUMPBL_GAME:
        MOV A, P3 
        JB ACC.3, JUMPBR_GAME
        LCALL BR
JUMPBR_GAME:
        MOV A, P3
        JB ACC.0, JUMPBF_GAME
        LCALL BF
JUMPBF_GAME:
        MOV A, P3                       ;Debouncing
        CLR C
        SUBB A, #0FFh
        JNZ JUMPBF_GAME                 ;Esperando soltar bot�o
        LCALL WAIT
        MOV A, P3
        CLR C
        SUBB A, #0FFh
        JNZ JUMPBF_GAME                 ;Esperando soltar bot�o
       
        
        MOV 63h, #00h                   ;Limpando mapa
        MOV 64h, #00h
        MOV 65h, #00h
        
        MOV 62h, 50h                    ;Armazena a posi��o do cursor no buffer para convers�o [XY -> P]
        LCALL XYP                       ;Convertendo a nova posi��o do cursor
        
        LCALL SHIPS_ON_FIRE
        
        ;VERIFICAR VITORIA
        MOV A,60h                       ;Copia a pontua��o do jogador em A
        CLR C
        SUBB A,#04h                     ;Verifica se tem 4 pontos
        JZ END_GAME_VICTORY
     
        ;VERIFICAR NUMERO DE TENTATIVAS 
        MOV A,67h                       ;Copia as tentivas restantes do jogador em A
        JZ END_GAME_LOOSE    
        LJMP GAME_LOOP
        
END_GAME_VICTORY:
        MOV 63h,#0FFh
        MOV 64h, #70h
        MOV 65h, #0FFh
        LCALL ATTLED
        LCALL WAIT
        LCALL WAIT
        LCALL WAIT
        MOV 63h,#00h
        MOV 64h, #00h
        MOV 65h, #00h
        LCALL ATTLED
        LCALL WAIT
        LCALL WAIT
        LCALL WAIT
        MOV 63h,#0FFh
        MOV 64h, #70h
        MOV 65h, #0FFh
        LCALL ATTLED
        SJMP $
        
END_GAME_LOOSE:
        MOV 63h,#0FFh
        MOV 64h, #80h
        MOV 65h, #80h
        LCALL ATTLED
        LCALL WAIT
        LCALL WAIT
        LCALL WAIT
        MOV 63h,#00h
        MOV 64h, #00h
        MOV 65h, #00h
        LCALL ATTLED
        LCALL WAIT
        LCALL WAIT
        LCALL WAIT
        MOV 63h,#0FFh
        MOV 64h, #80h
        MOV 65h, #80h
        LCALL ATTLED
        SJMP $        
code
END