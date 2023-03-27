*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

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
POINTS      EQU 01
SPACEBAR    EQU $20
ESCAPE      EQU $1B

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
    
GAME:
    BSR     PLAY_RUN
GAMELOOP:
    BSR     INPUT
    BSR     UPDATE
    BSR     IS_PLAYER_ON_GND
    BSR     CHECK_COLLISIONS
    BSR     DRAW
    BRA     GAMELOOP
    
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
    
DRAW_PLYRDATA:
    CLR.L   D1
    
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$0201,     D1
    TRAP    #15
    LEA     SCORE_MSG,  A1
    MOVE    #13,        D0
    TRAP    #15
    
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$0901,     D1
    TRAP    #15
    MOVE.B  #03,        D0
    MOVE.L  PLAYER_SCORE,D1
    TRAP    #15
    
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$0202,     D1
    TRAP    #15
    LEA     X_MSG,      A1
    MOVE    #13,        D0
    TRAP    #15
    
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$0502,     D1
    TRAP    #15
    MOVE.B  #03,        D0
    MOVE.L  PLAYER_X,   D1
    TRAP    #15
    
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$1002,     D1
    TRAP    #15
    LEA     Y_MSG,      A1
    MOVE    #13,        D0
    TRAP    #15
    
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$1202,     D1
    TRAP    #15
    MOVE.B  #03,        D0
    MOVE.L  PLAYER_Y,   D1
    TRAP    #15
    
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$0203,     D1
    TRAP    #15
    LEA     V_MSG,      A1
    MOVE    #13,        D0
    TRAP    #15
    
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$0503,     D1
    TRAP    #15
    MOVE.B  #03,        D0
    MOVE.L  PLYR_VELOCITY,D1
    TRAP    #15
    
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$1003,     D1
    TRAP    #15
    LEA     G_MSG,      A1
    MOVE    #13,        D0
    TRAP    #15
    
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$1203,     D1
    TRAP    #15
    MOVE.B  #03,        D0
    MOVE.L  PLYR_GRAVITY,D1
    TRAP    #15
    
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$0204,     D1
    TRAP    #15
    LEA     GND_MSG,    A1
    MOVE    #13,        D0
    TRAP    #15
    
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$0604,     D1
    TRAP    #15
    MOVE.B  #03,        D0
    MOVE.L  PLYR_ON_GND,D1
    TRAP    #15
    
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$2001,     D1
    TRAP    #15
    LEA     KEYCODE_MSG,A1
    MOVE    #13,        D0
    TRAP    #15
    
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$3001,     D1
    TRAP    #15
    MOVE.L  CURRENT_KEY,D1
    MOVE.B  #03,        D0
    TRAP    #15
    
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$0205,     D1
    TRAP    #15
    LEA     UPDATE_MSG, A1
    MOVE    #13,        D0
    TRAP    #15
    
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$0206,     D1
    TRAP    #15
    LEA     DRAW_MSG,   A1
    MOVE    #13,        D0
    TRAP    #15
    
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$0207,     D1
    TRAP    #15
    LEA     IDLE_MSG,   A1
    MOVE    #13,        D0
    TRAP    #15
    
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
    
CHECK_COLLISIONS:
    CLR.L   D1
    CLR.L   D2
PLAYER_X_LTE_TO_ENEMY_X_PLUS_W:
    MOVE.L  PLAYER_X,   D1
    MOVE.L  ENEMY_X,    D2
    ADD.L   EMMY_W_INIT,D2
    CMP.L   D1,         D2
    BLE     PLAYER_X_PLUS_W_LTE_TO_ENEMY_X
    BRA COLLISION_CHECK_DONE
PLAYER_X_PLUS_W_LTE_TO_ENEMY_X:
    ADD.L   PLYR_W_INIT,D1
    MOVE.L  ENEMY_X,    D2
    CMP.L   D1,         D2
    BGE     PLAYER_Y_LTE_TO_ENEMY_Y_PLUS_H
    BRA     COLLISION_CHECK_DONE
PLAYER_Y_LTE_TO_ENEMY_PLUS_H:
    MOVE.L  PLAYER_Y,   D1
    MOVE.L  ENEMY_Y,    D2
    ADD.L   ENMY_H_INIT,D2
    CMP.L   D1,         D2
    BLE     PLAYER_Y_PLUS_H_LTE_TO_ENEMY_Y
    BRA     COLLISION_CHECK_DONE
PLAYER_Y_PLUS_H_LTE_TO_ENEMY_Y:
    ADD.L   PLYR_H_INIT,D1
    MOVE.L  ENEMY_Y,    D2
    CMP.L   D1,         D2
    BGE     COLLISION
    BRA     COLLISION_CHECK_DONE
COLLISION_CHECK_DONE:
    ADD.L   #POINTS,    D1
    ADD.L   PLAYER_SCORE,D1
    MOVE.L  D1,         PLAYER_SCORE
    RTS
COLLISION:
    BSR     PLAY_OPPS
    MOVE.L  #00,        PLAYER_SCORE
    RTS
    
EXIT:
    MOVE.B  #TC_CURSR_P,D0
    MOVE.W  #$4004,     D1
    TRAP    #15
    LEA     EXIT_MSG,   A1
    MOVE    #13,        D0
    TRAP    #15
    MOVE    #TC_EXIT,   D0
    TRAP    #15
    SIMHALT             ; halt simulator

* Put variables and constants here
SCORE_MSG       DC.B    'SCORE :',  0
KEYCODE_MSG     DC.B    'KEYCODE :', 0
JUMP_MSG        DC.B    'JUMP....' 0

IDLE_MSG        DC.B    'IDLE....', 0
UPDATE_MSG      DC.B    'UPDATE...', 0
DRAW_MSG        DC.B    'DRAW....', 0

X_MSG           DC.B    'X:', 0
Y_MSG           DC.B    'Y:', 0
V_MSG           DC.B    'V:', 0
G_MSG           DC.B    'G:', 0
GND_MSG         DC.B    'GND:', 0

EXIT_MSG        DC.B    'EXISTING...', 0

WHITE           EQU     $00FFFFFF
RED             EQU     $000000FF

SCREEN_W        DS.W    01
SCREEN_H        DS.W    01

CURRENT_KEY     DS.L    01

PLAYER_X        DS.L    01
PLAYER_Y        DS.L    01
PLAYER_SCORE    DS.L    01

PLYR_VELOCITY   DS.L    01
PLYR_GRAVITY    DS.L    01
PLYR_ON_GND     DS.L    01

ENEMY_X         DS.L    01
ENEMY_Y         DS.L    01


    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
