*-------------------------------------------------------
* STARTING MEMORY ADDRESS FOR THE PROGRAMME $1000
*-------------------------------------------------------
    
    ORG $1000

*-------------------------------------------------------
*CHOOSE TO BE A PLUMBER OR A RABBIT 
*-------------------------------------------------------

*-------------------------------------------------------
*VALIDATION VALUES TO BE USED, MODIFY AS NEEDED
*ADD ADDITIONAL VALIDATION VALUES AS REQUIRED
*-------------------------------------------------------
EXIT        EQU 0      USED TO EXIT ASSEMBLY PROGRAM
MIN_POTIONS EQU 1      MIN NUMBER OF POTIONS
MAX_POTIONS EQU 9      MAX NUMBER OF POTIONS
MIN_WEAPONS EQU 1      MIN WEAPONS
MAX_WEAPONS EQU 3      MAX WEAPONS
WIN_POINT   EQU 5      POINTS ACCUMILATED ON WIN
LOSE_POINT  EQU 8      POINTS DEDUCTED ON A LOSS

MINE_LOC    EQU 100    USED BELOW FOR SOME SIMPLE COLLISION DETECTION USING CMP
                       * EXAMPLE FOR A HIT
TC_SCREEN   EQU 33
TC_S_SIZE   EQU 00
TC_KEYCODE  EQU 19
TC_DBL_BUF  EQU 92
TC_CURSR_P  EQU 11
TC_EXIT     EQU 09
PLYR_W_INIT EQU 08
PLYR_H_INIT EQU 08
PLYR_DFLT_V EQU 00
PLYR_JUMP_V EQU -20
PLYR_DFLT_G EQU 01
GND_TRUE    EQU 01
GND_FALSE   EQU 00
RUN_INDEX   EQU 00
JMP_INDEX   EQU 01
OPPS_INDEX  EQU 02
ENMY_H_INIT EQU 08
ENMY_W_INIT EQU 08
PLAYER_SHOT EQU 00  ; Couldn't figure out how to set up   
POINTS      EQU 01
SPACEBAR    EQU $20
ESCAPE      EQU $1B
RIGHT       EQU $39 ; For the shoot mechanic

*START OF GAME
START:
    MOVE.B  #100,$4000 PUT SCORE/HEALTH IN MEMORY LOCATION $4000
    LEA     $4000,A3   ASSIGN ADDRESS A3 TO THAT MEMORY LOCATION


    BSR     WELCOME    BRANCH TO THE WELCOME SUBROUTINE
    BSR     INPUT      BRANCH TO THE INPUT SUBROUTINE
    BSR     GAME       BRANCH TO THE GAME SUBROUTINE
    
INITIALISE:
    BSR     RUN_LOAD
    BSR     JUMP_LOAD
    BSR     OPPS_LOAD
    
    MOVE.B  #TC_SCREEN, D0
    MOVE.L  #TC_S_SIZE, D1
    TRAP    #15
    MOVE.W  D1,         SCREEN_H
    SWAP    D1
    MOVE.W  D1,         SCREEN_W
    
    CLR.L   D1
    MOVE.W  SCREEN_W,   D1
    DIVU    #02,        D1
    MOVE.L  D1,         PLAYER_X
    
    CLR.L   D1
    MOVE.W  SCREEN_H,   D1
    DIVU    #02,        D1
    MOVE.L  D1,         PLAYER_Y
    
    CLR.L   D1
    MOVE.L  #00,        D1
    MOVE.L  D1,         PLAYER_SCORE
    
    CLR.L   D1
    MOVE.B  #PLYR_DFLT_V, D1
    MOVE.L  D1,         PLYR_VELOCITY
    
    CLR.L   D1
    MOVE.L  #PLYR_DFLT_G,D1
    MOVE.L  D1,         PLYR_GRAVITY
    
    MOVE.L  #GND_TRUE,  PLYR_ON_GND
    
    CLR.L   D1
    MOVE.W  SCREEN_W,   D1
    MOVE.L  D1,         ENEMY_X
    
    CLR.L   D1
    MOVE.W  SCREEN_H,   D1
    DIVU    #02,        D1
    MOVE.L  D1,         ENEMY_Y
    
    MOVE.B  #TC_DBL_BUF,D0
    MOVE.B  #17,        D1
    TRAP    #15
    
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$FF00,     D1
    TRAP    #15
    

*GAME LOOP
    ORG     $3000      THE REST OF THE PROGRAM IS TO BE LOCATED FROM 3000 ONWARDS

*-------------------------------------------------------
*-------------------GAME SUBROUTINE---------------------
*-------------------------------------------------------
GAME:
    BSR     GAMELOOP   BRANCH TO GAMELOOP SUBROUTINE
    RTS                RETURN FROM GAME: SUBROUTINE

    
MOVE_ENEMY:
    SUB.L   #01,        ENEMY_X
    RTS
    
RESET_ENEMY_POSITION:
    CLR.L   D1
    MOVE.W  SCREEN_W,   D1
    MOVE.L  D1,         ENEMY_X
    RTS
    
DRAW:
    MOVE.B  #94,        D0
    TRAP    #15
    
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$FF00,     D1
    TRAP    #15
    
    BSR     DRAW_PLYR_DATA
    BSR     DRAW_PLAYER
    BSR     DRAW_ENEMY
    RTS

IS_PLAYER_ON_GND:
    CLR.L   D1
    CLR.L   D2
    MOVE.W  SCREEN_H,   D1
    DIVU    #02,        D1
    MOVE.L  PLAYER_Y,   D2
    CMP     D1,         D2
    BGE     SET_ON_GROUND
    BLT     SET_OFF_GROUND
    RTS
    
SET_ON_GROUND:
    CLR.L   D1
    MOVE.W  SCREEN_H,   D1
    DIVU    #O2,        D1
    MOVE.L  D1,         PLAYER_Y
    CLR.L   D1
    MOVE.L  #00,        D1
    MOVE.L  D1,         PLYR_VELOCITY
    MOVE.L  #GND_TRUE,  PLYR_ON_GND
    RTS
    
SET_OFF_GROUND:
    MOVE.L  #GND_FALSE, PLYR_ON_GND
    RTS
    
JUMP:
    CMP.L   #GND_TRUE,  PLYR_ON_GND
    BEQ     PERFORM_JUMP
    BRA     JUMP_DONE
PERFORM_JUMP:
    BSR     PLAY_JUMP
    MOVE.L  #PLYR_JUMP_V,PLYR_VELOCITY
    RTS
JUMP_DONE:
    RTS
    
IDLE:
    BSR     PLAY_RUN
    RTS
    
RUN_LOAD:
    MOVE    #RUN_INDEX, D1
    MOVE    #71,        D0
    TRAP    #15
    RTS
    
JUMP_LOAD:
    MOVE    #JMP_INDEX, A1
    MOVE    #71,        D0
    TRAP    #15
    RTS
    
PLAY_JUMP:
    MOVE    #JMP_INDEX, D1
    MOVE    #72,        D0
    TRAP    #15
    RTS
    
OPPS_LOAD:
    LEA     OPPS_WAY,   A1
    MOVE    #OPPA_INDEX,D1
    MOVE    #71,        D0
    TRAP    #15
    RTS
    
PLAY_OPPS:
    MOVE    #OPPS_INDEX,D1
    MOVE    #72,        D0
    TRAP    #15
    RTS
    
DRAW_PLAYER:
    MOVE.L  #WHITE,     D1
    MOVE.B  #80,        D0
    TRAP    #15
    
    MOVE.L  PLAYER_X,   D1
    MOVE.L  PLAYER_Y,   D2
    MOVE.L  PLAYER_Y,   D3
    ADD.L   #PLYR_W_INIT,   D3
    MOVE.L  PLAYER_Y,   D4
    ADD.L   #PLAYER_H_INIT, D4
    
    MOVE.B  #87,        D0
    TRAP    #15
    RTS
    
DRAW_ENEMY:
    MOVE.L  #RED,       D1
    MOVE.B  #80,        D0
    TRAP    #15
    
    MOVE.L  ENEMY_X,    D1
    MOVE.L  ENEMY_Y,    D2
    MOVE.L  ENEMY_X,    D3
    ADD.L   #ENEMY_H_INIT,  D3
    MOVE.L  ENEMY_Y,    D4
    ADD.L   #EMEMY_H_INIT,  D4
    
    MOVE.B  #87,        D0
    TRAP    #15
    RTS
     
END:
    SIMHALT

*-------------------------------------------------------
*---------GAMEPLAY INPUT VALUES SUBROUTINE--------------
*-------------------------------------------------------    
INPUT:
    CLR.L   D1
    MOVE.B  #TC_KEYCODE,D0
    TRAP    #15
    MOVE.B  D1,         D2
    CMP.B   #00,        D2
    BEQ     PROCESS_INPUT
    TRAP    #15
    CMP.B   #$FF,       D1
    BEQ     PROCESS_INPUT
    RTS
    
PROCESS_INPUT:
    MOVE.L  D2,         CURRENT_KEY
    CMP.L   #ESCAPE,    CURRENT_KEY
    BEQ     EXIT
    CMP.L   #SPACEBAR,  CURRENT_KEY
    BEQ     JUMP
    BRA     IDLE
    RTS

*-------------------------------------------------------
*----------------GAMELOOP (MAIN LOOP)-------------------
*------------------------------------------------------- 
GAMELOOP:
    GAMELOOP:
    BSR     INPUT
    BSR     UPDATE
    BSR     IS_PLAYER_ON_GND
    BSR     CHECK_COLLISIONS
    BSR     DRAW
    BRA     GAMELOOP


*-------------------------------------------------------
*----------------UPDATE QUEST PROGRESS------------------
*  COMPLETE QUEST
*------------------------------------------------------- 
UPDATE:
    UPDATE:
    CLR.L   D1
    MOVE.L  PLYR_VELOCITY,  D1
    MOVE.L  PLYR_GRAVITY,   D2
    ADD.L   D2,         D1
    MOVE.L  D1,         PLYR_VELOCITY
    ADD.L   PLAYER_Y,   D1
    MOVE.L  D1,         PLAYER_Y
    
    CLR.L   D1
    CLR.L   D1
    MOVE.L  ENEMY_X,    D1
    CMP.L   #00,        D1
    BLE     RESET_ENEMY_POSITION
    BRA     MOVE_ENEMY
    
    RTS

*-------------------------------------------------------
*-----------------DRAW QUEST UPDATES--------------------
* DRAW THE GAME PROGRESS INFORMATION, STATUS REGARDING
* QUEST
*------------------------------------------------------- 
DRAW:
    BSR     ENDL
    BSR     DECORATE
    LEA     DRAW_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    BSR     DECORATE
    RTS

*-------------------------------------------------------
*--------------------POTIONS INVENTORY---------------------
* NUMBER OF POTIONS TO BE USED IN A QUEST 
*------------------------------------------------------- 
POTIONS:
    BSR     ENDL
    BSR     DECORATE
    LEA     POTIONS_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    BSR     DECORATE
    RTS

*-------------------------------------------------------
*-------------------------WEAPONS-----------------------
* NUMBER OF WEAPONS
*-------------------------------------------------------   
WEAPONS:
    BSR     ENDL
    BSR     DECORATE
    LEA     WEAPONS_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    BSR     DECORATE
    RTS

*-------------------------------------------------------
*---GAME PLAY (QUEST PROGRESS)--------------------------
*------------------------------------------------------- 
GAMEPLAY:
    BSR     ENDL
    BSR     DECORATE
    LEA     GAMEPLAY_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #4,D0
    TRAP    #15
    BSR     DECORATE
    BSR     COLLISION
    RTS

*-------------------------------------------------------
*-----------------HEADS UP DISPLAY (SCORE)--------------
* RETRIEVES THE SCORE FROM MEMORY LOCATION
*-------------------------------------------------------   
HUD:

    BSR     ENDL
    BSR     DECORATE
    LEA     HUD_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  (A3),D1     RETRIEVE THE VALUE A3 POINT TO AND MOVE TO D1
    MOVE.B  #3,D0       MOVE LITERAL 3 TO D0
    TRAP    #15         INTREPRET VALUE IN D0, WHICH 3 WHICH DISPLAYS D1
    BSR     DECORATE
    RTS

*-------------------------------------------------------
*-----------------------BEING ATTACKED------------------
* THIS COULD BE USED FOR COLLISION DETECTION
*-------------------------------------------------------
CHECK_COLLISIONS:
    CLR.L   D1
    CLR.L   D2     
COLLISION_CHECK_DONE:
    ADD.L   #POINTS,    D1
    ADD.L   PLAYER_SCORE,D1
    MOVE.L  D1,         PLAYER_SCORE
    RTS
COLLISION:
    BSR     PLAY_OPPS
    MOVE.L  #00,        PLAYER_SCORE
    RTS

*-------------------------------------------------------
*------------------SCREEN DECORATION--------------------
*-------------------------------------------------------
DECORATE:
    MOVE.B  #60, D3
    BSR     ENDL
OUT:
    LEA     LOOP_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
	SUB     #1,D3   DECREMENT LOOP COUNTER
    BNE     OUT	    REPEAT UNTIL D0=0
    BSR     ENDL
    RTS
    
CLEAR_SCREEN: 
    MOVE.B  #11,D0      CLEAR SCREEN
    MOVE.W  #$FF00,D1
    TRAP    #15
    RTS
ENDL:
    MOVEM.L D0/A1,-(A7)
    MOVE    #14,D0
    LEA     CRLF,A1
    TRAP    #15
    MOVEM.L (A7)+,D0/A1
    RTS
    
*-------------------------------------------------------
*-------------------DATA DELARATIONS--------------------
*-------------------------------------------------------

CRLF:           DC.B    $0D,$0A,0
WELCOME_MSG:    DC.B    '************************************************************'
                DC.B    $0D,$0A
                DC.B    'STRATEGY GAMES SUCH AS ZORK, AVALON, OR RABBITS VS PLUMBERS'
                DC.B    $0D,$0A
                DC.B    '************************************************************'
                DC.B    $0D,$0A,0
POTION_MSG:     DC.B    'POTION ....'
                DC.B    $0D,$0A
                DC.B    'ENTER POTION : ',0
POTIONS_MSG:    DC.B    'NUMBER OF POTIONS : ',0
WEAPONS_MSG:    DC.B    'EACH QUEST NEED AT LEAST 2 WEAPONS'
                DC.B    $0D,$0A
                DC.B    'MINIMUM REQUIREMENT IS 2 I.E. SWORD X 1 AND SPEER X 1.'
                DC.B    $0D,$0A
                DC.B    'ENTER # OF WEAPONS : ',0
UPDATE_MSG:     DC.B    'UPDATE GAMEPLAY !',0
DRAW_MSG:       DC.B    'DRAW SCREEN !',0
HIT_MSG:        DC.B    'STRIKE!',0
MISS_MSG:       DC.B    'MISS!',0
LOOP_MSG:       DC.B    '.',0
REPLAY_MSG:     DC.B    'ENTER 0 TO QUIT ANY OTHER NUMBER TO REPLAY : ',0
HUD_MSG:        DC.B    'SCORE : ',0

HEALTH:     DS.W    1   PLAYERS HEALTH
SCORE:      DS.W    1   RESERVE SPACE FOR SCORE

    END START


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
