; Recon Game Library is a library that implements snake and tictactoe game 
; in 8086 assembly.
; Copyright (C) 2022 Rendo Ruiz

; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.

; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.

; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <https://www.gnu.org/licenses/>.

; v0.5
; TODO:
; > learn file handling
; > insert game description to file
; > read file and position items accordingly
; > use 'LoadContent()' and 'UnloadContent()' concepts for file handling
; > refactor code
; > increase accuracy on button's hitboxes
 
 
data segment               
    menuGameLogo db "RRRRR                                 $"
                 db "RR  RR                                $"
                 db "RR  RR  EEEE   CCCCC   OOOOOO  N NNNN $"
                 db "RR RR  EE  EE CCC  CC OOO  OOO NNNNNNN$"
                 db "RRRR   EE  EE CC      OO    OO NN   NN$"
                 db "RRRR   EEEEE  CC      OO    OO NN   NN$"
                 db "RR RR  EE     CCC  CC OOO  OOO NN   NN$"
                 db "RR  RR  EEEE   CCCCC   OOOOOO  NN   NN$"
                 db 10,13,"   G  A  M  E     L  I  B  R  A  R  Y  $"
    
    menuSelect db "Select a game below!$"
    menuTTTButton db "TicTacToe$"
    menuSnakeButton db "Snake$"    
    
    menuReturn db "[Return to Main Menu]$" 
    menuTempDescription db "Game: version, goal/purpose, description, controls, known bugs/issues, etc.$"              
    menuPlayButton db "[ P L A Y   G A M E ]$"    
    gameState db 0 
    
    
    
    
    
    ; 
    ;   TIC-TAC-TOE COMPONENTS
    ;
    
    
    mouseInput db 0
    
    rowCoordinates db 0
    columnCoordinates db 0
    
    boardRow0 db 3 dup(0)
    boardRow1 db 3 dup(0) 
    boardRow2 db 3 dup(0)
    filledBoardBlocks db 0
    
    continuousCircle db 0
    continuousCross db 0
    
    circleHorizontal db 3 dup(0)
    circleVertical db 3 dup(0)
    circleDiagonal db 3 dup(0)
    
    crossHorizontal db 3 dup(0)
    crossVertical db 3 dup(0)
    crossDiagonal db 3 dup(0)
    
    circleScore db 48    ; to be implemented
    crossScore db 48     ; to be implemented
    hasScored db 0
    
    circleDrawing db "  OOOOO  $" 
                  db " OO   OO $" 
                  db "OO     OO$"
    crossDrawing db "XXX   XXX$" 
                 db " XXX XXX $" 
                 db "  XXXXX  $"
             
    ; TicTacToe MenuBar components             
    menuBarStatus db "Loading . . .$"       ; [0] - load 
                  db "Restarting . . .$"    ; [14] - restart  
                  db "Clearing . . .$"      ; [31] - clear
                  db "Clearing in $"        ; [46] - clearing in
    gameStatus db 0
                       
    menuBarContents db " [Restart]  [Clear]  [Auto-Clear:                         [Return to Main Menu]$"
    
    menuBarAutoClearToggle db " Off]$"      ; [0] - off
                           db "  On]$"      ; [6] - on
    autoClearToggle db 1   ; 0 - off, 1 - on  
    
    ; TicTacToe Scoreboard components
    scoreboardCircle db "    000    $"
                     db "  0000000  $"
                     db " 000   000 $"
                     db "000     000$"
    scoreboardCross db "XXX     XXX$"
                    db " XXX   XXX $"
                    db "  XXX XXX  $"
                    db "   XXXXX   $"
    scoreboardScore db "Score: $"      
    
    
    
    ;
    ;   SNAKE COMPONENTS
    ;                   
    
    snake_x db 100 dup(0) ; column | dl
    snake_y db 100 dup(0) ; row    | dh
    snake_length db 2                    
    
    head_direction db 0     ; 1 - north, 2 - south, 3 - east, 4 - west    
    startposition_column db 39      
    startposition_row db 12
    
    statusbar db "Press `esc' to go back to main menu.$"                             
ends                          


code segment
start:
    mov ax, data
    mov ds, ax
    
    
MainMenu:
    ; set video mode to 40x25
    mov al, 00h
    mov ah, 0 
    int 10h
    
    ; hide text cursor
    mov ch, 32
    mov ah, 1
    int 10h
    
    ; TEMP: show mouse pointer
    mov ax, 1
    int 33h
           
           
    ; display game logo
    mov si, 0
    mov cl, 2
    ShowGameLogo:
        mov dh, cl
        mov dl, 1
        mov bh, 0
        mov ah, 2
        int 10h    
    
        lea dx, menuGameLogo[si]
        mov ah, 9
        int 21h
        
        inc cl
        add si, 39
        cmp cl, 10
        jle ShowGameLogo
    
    
    ; display instruction
    mov dh, 14
    mov dl, 10
    mov bh, 0
    mov ah, 2
    int 10h
    
    lea dx, menuSelect
    mov ah, 9
    int 21h
       
       
    ; display Tic-Tac-Toe button
    mov dh, 17
    mov dl, 16
    mov bh, 0
    mov ah, 2
    int 10h
        
    lea dx, menuTTTButton
    mov ah, 9
    int 21h
      
      
    ; display snake button
    mov dh, 20
    mov dl, 16
    mov bh, 0
    mov ah, 2
    int 10h
    
    lea dx, menuSnakeButton
    mov ah, 9
    int 21h
            
            
    ; reset value of gameState
    mov gameState, 0
           
           
    Update:
        ; mouse inputs  
        ; get mouse position, stored in CX and DX 
        mov ax, 3
        int 33h  
         
        ; if left mouse button is pressed
        cmp bx, 00000001b
        je GameSelected
        
        call SelectionArrow
        ; update selection arrow
                    
        jmp Update
    
ends



GameSelected:
    ; errortrap: higher than tic-tac-toe button
    cmp dx, 136d    ; 88h
    jl Update
    
    ; errortrap: lower than snake button
    cmp dx, 168d    ; a8h
    jg Update 

    ; errortrap: left-hand side of the buttons
    cmp cx, 128d    ; 80h
    jl Update   
    
    ; errortrap: right-hand side of tictactoe button
    cmp cx, 199d    ; c7h
    jg Update
    
    ; if tictactoe button is clicked
    cmp dx, 144d
    jle ShowGameInfo
    
    ; if snake button is clicked
    cmp dx, 160d
    jge ShowGameInfo

    jmp Update

   
   
   
proc SelectionArrow
    ; errortrap: higher than tic-tac-toe button
    cmp dx, 136d    ; 88h
    jl Update
    
    ; errortrap: lower than snake button
    cmp dx, 168d    ; a8h
    jg Update 

    ; errortrap: left-hand side of the buttons
    cmp cx, 128d    ; 80h
    jl Update   
    
    ; errortrap: right-hand side of tictactoe button
    cmp cx, 199d    ; c7h
    jg Update    
    
    
    ; display selection arrow to the left side of tictactoe button
    cmp dx, 144d
    jle SelectTictactoe
    
    ; display selection arrow to the left side of snake button
    cmp dx, 160d
    jge SelectSnake
     
     
    ret      
          
    SelectTictactoe:
        cmp gameState, 1
        je Update
        
        ; removes the selection arrow from snake button
        mov dh, 20
        mov dl, 14
        mov bh, 0
        mov ah, 2
        int 10h    
        
        mov al, 000
        mov bh, 0
        mov cx, 1
        mov ah, 0ah
        int 10h
               
        ; displays the selection arrow to the tic-tac-toe button       
        mov dh, 17
        mov dl, 14
        mov bh, 0
        mov ah, 2
        int 10h    
        
        mov al, 26
        mov bh, 0
        mov cx, 1
        mov ah, 0ah
        int 10h    
        
        mov gameState, 1
        ret
    
    
    SelectSnake:
        cmp gameState, 2
        je Update
        
        ; removes the selection arrow from tic-tac-toe button
        mov dh, 17
        mov dl, 14
        mov bh, 0
        mov ah, 2
        int 10h    
        
        mov al, 000
        mov bh, 0
        mov cx, 1
        mov ah, 0ah
        int 10h  
    
        ; displays the selection arrow to the snake button
        mov dh, 20
        mov dl, 14
        mov bh, 0
        mov ah, 2
        int 10h    
        
        mov al, 26
        mov bh, 0
        mov cx, 1
        mov ah, 0ah
        int 10h             
        
        mov gameState, 2
        ret    
    
endp SelectionArrow


ShowGameInfo:
    ; reset value of bx
    xor bx, bx
    
    ; set video mode to 80x25
    mov al, 03h
    mov ah, 0 
    int 10h    
    
    ; display return to main menu button
    mov dh, 0
    mov dl, 58
    mov bh, 0
    mov ah, 2
    int 10h     
    
    lea dx, menuReturn
    mov ah, 9
    int 21h
    
    
    ; TEMPORARY display description
    mov dh, 3 
    mov dl, 2
    mov bh, 0
    mov ah, 2
    int 10h
    
    lea dx, menuTempDescription
    mov ah, 9
    int 21h
    
    
    ; display play button
    mov dh, 21
    mov dl, 30
    mov bh, 0
    mov ah, 2
    int 10h
    
    lea dx, menuPlayButton
    mov ah, 9
    int 21h
    
    
    ; reset cursor position to 0,0
    mov dh, 0
    mov dl, 0
    mov bh, 0
    mov ah, 2
    int 10h     
    
    
    cmp gameState, 1
    je InfoTictactoe
    
    cmp gameState, 2
    je InfoSnake
    
    jmp MainMenu  


InfoTictactoe:
    lea dx, menuTTTButton
    mov ah, 9
    int 21h
    
    ; display game description/features/controls/bugs here
    
    jmp InfoUpdate


InfoSnake:
    lea dx, menuSnakeButton
    mov ah, 9
    int 21h
    
    ; display game description/features/controls/bugs here
    
    jmp InfoUpdate

               
InfoUpdate:
    ; get mouse position
    mov ax, 3
    int 33h
    
    ; continue if left mouse button is clicked
    cmp bx, 00000001b
    je InfoUpdateButtonPressed  
    
        
    jmp InfoUpdate               
        
               
InfoUpdateButtonPressed:
    ; errortrap: below the play button
    cmp dx, 176d    ; b0h
    jg InfoUpdate
    
    ; play button row
    cmp dx, 168d    ; a8h
    jge InfoPlayButton 
    
    ; main menu row
    cmp dx, 8d      ; 08h 
    jle InfoMainMenuButton
    
    
    jmp InfoUpdate
    
    InfoPlayButton:
        ; errortrap: right side of play button
        cmp cx, 407d    ; 0197h
        jg InfoUpdate
        
        ; errortrap: left side of play button
        cmp cx, 240d    ; f0h
        jl InfoUpdate
    
        jmp PlayButtonPressed
    
    
    InfoMainMenuButton:
        cmp cx, 464d    ; 01d0h
        jl InfoUpdate
        
        jmp MainMenu               
               
PlayButtonPressed:
    cmp gameState, 1
    je G1_Initialize
    
    cmp gameState, 2
    je G2_Initialize
    
    jmp MainMenu
                       



    
    
    
    

;
;
;
;  TIC-TAC-TOE COMPONENTS
;
;


G1_Initialize:

    ; set video mode to 80x25
    mov al, 03h
    mov ah, 0
    int 10h
    
    ; displays status
    mov gameStatus, 0
    call ShowStatus
    
    ; displays the 9x9 board
    call ShowGameBoard 
    
    ; displays scoreboard
    call ShowScoreBoard
    
    ; displays the menu bar
    call ShowMenuBar
    
    ; display mouse cursor
    mov ax, 1
    int 33h
        
    G1_Update:
        ; get mouse cursor position 
        mov ax, 3
        int 33h    
    
        ; left mouse button is clicked
        mov mouseInput, 1
        cmp bx, 00000001b
        je VerifyInput 
        
        ; right mouse button is clicked
        mov mouseInput, 2    
        cmp bx, 00000010b
        je VerifyInput 
    
        jmp G1_Update 



VerifyInput:
    ; will jump is mouse position is below the menubar components
    cmp dx, 8
    jg BoardInput
    
    
    ; error trap: right side of return to main menu button
    cmp cx, 631d
    jg G1_Update           
               
    ; return to main menu or exit
    cmp cx, 464d
    jge MainMenu    
    
    
    cmp cx, 303
    jg G1_Update
    
    cmp cx, 7
    jl G1_Update 
    
    ; Auto-Clear, On/Off toggle button
    cmp cx, 167
    jg AutoClearToggleButton
                   
    ; Restart button
    cmp cx, 80
    jl RestartFunction                   
    
    cmp cx, 151
    jg G1_Update
                   
    ; Clear Button 
    cmp cx, 95
    jg ClearFunction  


BoardInput:
    ; error trap: if a player scores, board must be cleared after
    cmp hasScored, 0
    jne G1_Update
    
    ; error trap: ignore if any clicks outside the 9x9 board
    cmp dx, 24d
    jl G1_Update
    
    cmp dx, 184d
    jg G1_Update
    
    cmp cx, 200d
    jl G1_Update
    
    cmp cx, 431d
    jg G1_Update
                 
    ; error trap: prevents same continuous inputs
    cmp mouseInput, 1
    jne AdjustCross
    
    ; prevents circle to be displayed twice in a row
    inc continuousCircle    
    cmp continuousCircle, 1
    jg G1_Update
    
    mov continuousCross, 0
    jmp VerifyRow
    
    AdjustCross:
        ; prevents cross to be displayed twice in a row
        inc continuousCross
        cmp continuousCross, 1
        jg G1_Update
        
        mov continuousCircle, 0
        jmp VerifyRow
        
      
VerifyRow:          ; si = row coordinate index
    ; 3rd row 
    mov rowCoordinates, 17
    mov si, 2
    cmp dx, 136d
    jge VerifyColumn
    
    ; error trap: horizontal line between row index 1 and 2
    cmp dx, 128d
    jg AdjustMouseInput  
    
    ; 2nd row
    mov rowCoordinates, 10    
    mov si, 1
    cmp dx, 80d
    jge VerifyColumn 
    
    ; 1st row           
    mov rowCoordinates, 3               
    mov si, 0
    cmp dx, 72d
    jle VerifyColumn
    
    ; will jump if the horizontal line between row index 1 and 2 is selected              
    ;jmp Update
    jmp AdjustMouseInput
          
                  
VerifyColumn:       ; di = column coordinate index
    ; 3rd column
    mov columnCoordinates, 45
    mov di, 2
    cmp cx, 359d
    jg VerifyBoardContents
    
    ; error trap: vertical line between column index 1 and 2
    cmp cx, 352d
    jge AdjustMouseInput
    
    ; 2nd column
    mov columnCoordinates, 35
    mov di, 1
    cmp cx, 280d
    jge VerifyBoardContents
    
    ; 1st column
    mov columnCoordinates, 25
    mov di, 0
    cmp cx, 271d
    jle VerifyBoardContents
    
    ; will jump if the vertical line between column index 1 and 2 is selected
    ;jmp Update
    jmp AdjustMouseInput
    
    
VerifyBoardContents:
    ; will jump based on the assigned row coordinate index (si)
    cmp si, 0
    je VerifyBoardRow0
    
    cmp si, 1
    je VerifyBoardRow1
    
    cmp si, 2
    je VerifyBoardRow2
    
    
    VerifyBoardRow0:
        ; if block is filled, mouse input will reset
        cmp boardRow0[di], 1
        je FixMouseInput         
        
        ; fill the block
        mov boardRow0[di], 1
        inc filledBoardBlocks
        
        ; fill the horizontal and vertical checking blocks
        call FillPerpendicularBlock
        
        jmp FillDiagonalBlockRow0
        FillDiagonalRow0Return:
        
        jmp G1_Draw
    
    
    VerifyBoardRow1:
        ; if block is filled, mouse input will reset
        cmp boardRow1[di], 1
        je FixMouseInput
        
        ; fill the block
        mov boardRow1[di], 1
        inc filledBoardBlocks
        
        ; fill the horizontal and vertical checking blocks
        call FillPerpendicularBlock
        
        jmp FillDiagonalBlockRow1
        FillDiagonalRow1Return:
        
        jmp G1_Draw
        
        
    VerifyBoardRow2:
        ; if block is filled, mouse input will reset
        cmp boardRow2[di], 1
        je FixMouseInput
        
        ; fill the block
        mov boardRow2[di], 1
        inc filledBoardBlocks
        
        ; fill the horizontal and vertical checking blocks
        call FillPerpendicularBlock
        
        jmp FillDiagonalBlockRow2
        FillDiagonalRow2Return:
        
        jmp G1_Draw  
  

; mouse input will reset if a line is selected 
AdjustMouseInput:
    cmp mouseInput, 1
    jne AdjustCrossValue
    
    dec continuousCircle
    jmp G1_Update
    
    AdjustCrossValue:
        dec continuousCross
        jmp G1_Update
        

; mouse input will reset if the selected block is filled/not empty 
FixMouseInput:
    cmp mouseInput, 1
    jne FixCrossValue 
    
    inc continuousCross
    dec continuousCircle
    jmp G1_Update
    
    FixCrossValue:
        inc continuousCircle  
        dec continuousCross
        jmp G1_Update
                          
                          
proc FillPerpendicularBlock
    cmp mouseInput, 1
    jne FillCrossBlock
    
    inc circleHorizontal[si]
    inc circleVertical[di]   
    ret
    
    FillCrossBlock:
        inc crossHorizontal[si]
        inc crossVertical[di]
        ret
endp FillPerpendicularBlock


FillDiagonalBlockRow0:
    cmp mouseInput, 1
    jne CrossRow0Column0
    
    cmp di, 0
    jne CircleRow0Column2
    
    inc circleDiagonal[0]
    jmp FillDiagonalRow0Return
    
    CircleRow0Column2:
        cmp di, 2
        jne FillDiagonalRow0Return
        
        inc circleDiagonal[1]
        jmp FillDiagonalRow0Return
    
    CrossRow0Column0:
        cmp di, 0
        jne CrossRow0Column2                
        
        inc crossDiagonal[0]
        jmp FillDiagonalRow0Return
        
    CrossRow0Column2:
        cmp di, 2
        jne FillDiagonalRow0Return
        
        inc crossDiagonal[1]
        jmp FillDiagonalRow0Return                
                    
                    
FillDiagonalBlockRow1:
    cmp mouseInput, 1
    jne CrossRow1Column1
    
    cmp di, 1
    jne FillDiagonalRow1Return
    
    inc circleDiagonal[0]
    inc circleDiagonal[1]
    jmp FillDiagonalRow1Return
    
    CrossRow1Column1:
        cmp di, 1
        jne FillDiagonalRow1Return
        
        inc crossDiagonal[0]
        inc crossDiagonal[1]
        jmp FillDiagonalRow1Return       
           
           
FillDiagonalBlockRow2:
    cmp mouseInput, 1
    jne CrossRow2Column0
    
    cmp di, 0
    jne CircleRow2Column2
    
    inc circleDiagonal[1]
    jmp FillDiagonalRow2Return
    
    CircleRow2Column2:
        cmp di, 2
        jne FillDiagonalRow2Return
        
        inc circleDiagonal[0]
        jmp FillDiagonalRow2Return
        
    CrossRow2Column0:
        cmp di, 0
        jne CrossRow2Column2
        
        inc crossDiagonal[1]
        jmp FillDiagonalRow2Return
        
    CrossRow2Column2:
        cmp di, 2
        jne FillDiagonalRow2Return
        
        inc crossDiagonal[0]
        jmp FillDiagonalRow2Return
        
        
G1_Draw:
    cmp mouseInput, 1
    je DrawCircle
    
    cmp mouseInput, 2
    je DrawCross
    
    G1_DrawReturn:
    call VerifyCompletion
    
    jmp G1_Update
    
    
proc VerifyCompletion    
    mov si, 0
    VerifyLineValues:
        cmp circleHorizontal[si], 3
        je CircleWin
        
        cmp circleVertical[si], 3
        je CircleWin
        
        cmp circleDiagonal[si], 3
        je CircleWin
        
        cmp crossHorizontal[si], 3
        je CrossWin
        
        cmp crossVertical[si], 3
        je CrossWin
        
        cmp crossDiagonal[si], 3
        je CrossWin
        
        inc si
        cmp si, 3
        jne VerifyLineValues
        
        ; if all the blocks are filled, game will end
        cmp filledBoardBlocks, 9
        je Scored         
        ret
    
    CircleWin:
        inc circleScore
        jmp Scored         
        
    CrossWin:
        inc crossScore
        jmp Scored
        
    Scored:
        inc hasScored
        call Updatescore        
        call AutoClear
        ret
endp VerifyCompletion    
    
    
DrawCircle:
    mov si, 0
           
    DrawCircleUpper:
        mov dh, rowCoordinates
        mov dl, columnCoordinates
        mov bh, 0
        mov ah, 2
        int 10h
        
        lea dx, circleDrawing[si]
        mov ah, 9
        int 21h
        
        add si, 10
        inc rowCoordinates
        
        cmp si, 20
        jle DrawCircleUpper
        
        sub si, 10       
       
    DrawCircleLower:
        mov dh, rowCoordinates
        mov dl, columnCoordinates
        mov bh, 0
        mov ah, 2
        int 10h
        
        lea dx, circleDrawing[si]
        mov ah, 9
        int 21h
        
        sub si, 10
        inc rowCoordinates
        
        cmp si, 0
        jge DrawCircleLower
       
    jmp G1_DrawReturn
       
       
DrawCross:
    mov si, 0
           
    DrawCrossUpper:
        mov dh, rowCoordinates
        mov dl, columnCoordinates
        mov bh, 0
        mov ah, 2
        int 10h
        
        lea dx, crossDrawing[si]
        mov ah, 9
        int 21h
        
        add si, 10
        inc rowCoordinates
        
        cmp si, 20
        jle DrawCrossUpper
        
        sub si, 10       
       
    DrawCrossLower:
        mov dh, rowCoordinates
        mov dl, columnCoordinates
        mov bh, 0
        mov ah, 2
        int 10h
        
        lea dx, crossDrawing[si]
        mov ah, 9
        int 21h
        
        sub si, 10
        inc rowCoordinates
        
        cmp si, 0
        jge DrawCrossLower 
        
    jmp G1_DrawReturn 
    
    
proc ShowStatus
    mov dh, 0
    mov dl, 0
    mov bh, 0
    mov ah, 2
    int 10h
    
    mov al, 000
    mov bh, 0
    mov cx, 79
    mov ah, 0ah
    int 10h 
        
    cmp gameStatus, 1
    je Load
    
    cmp gameStatus, 2
    je Restart
    
    cmp gameStatus, 3
    je Clear
    
    cmp gameStatus, 4
    je ClearCountdown
    
    Load:
        lea dx, menuBarStatus[0]
        mov ah, 9
        int 21h    
        ret
    
    Restart:
        lea dx, menuBarStatus[14]
        mov ah, 9
        int 21h
        ret
        
    Clear:
        lea dx, menuBarStatus[31]
        mov ah, 9
        int 21h
        ret
        
    ClearCountdown:
        lea dx, menuBarStatus[46]
        mov ah, 9
        int 21h
        
        mov cl, 57
        ShowCount:
            mov dh, 0
            mov dl, 12
            mov bh, 0
            mov ah, 2
            int 10h
            
            mov dl, cl
            mov ah, 2
            int 21h
            
            dec cl
            cmp cl, 48
            jge ShowCount
            ret       
endp ShowStatus   
     
     
proc ShowMenuBar
    ; displays horizontal bar   
    mov dh, 1
    mov dl, 0
    mov bh, 0
    mov ah, 2
    int 10h
    
    mov al, 205
    mov bh, 0
    mov cx, 80
    mov ah, 0ah
    int 10h 
    
    ; displays menu buttons: restart, clear, & auto-clear toggle
    mov dh, 0
    mov dl, 0
    mov bh, 0
    mov ah, 2
    int 10h
    
    lea dx, menuBarContents
    mov ah, 9
    int 21h
    
    call ShowAutoClearStatus
        
    ret
endp ShowMenuBar
             
             
proc ShowAutoClearStatus
    mov dh, 0
    mov dl, 33
    mov bh, 0
    mov ah, 2
    int 10h      
    
    cmp autoClearToggle, 0
    jne ShowToggleOn
    
    lea dx, menuBarAutoClearToggle[0]
    mov ah, 9
    int 21h
    ret
    
    ShowToggleOn:
        lea dx, menuBarAutoClearToggle[6]
        mov ah, 9
        int 21h
        ret
endp ShowAutoClearStatus


AutoClearToggleButton:
    cmp autoClearToggle, 0
    jne ToggleOff 
    
    mov autoClearToggle, 1
    call ShowAutoClearStatus
    jmp G1_Update
    
    ToggleOff:
        mov autoClearToggle, 0
        call ShowAutoClearStatus
        jmp G1_Update
        

; Resets the board and player score
RestartFunction:
    mov gameStatus, 2
    call ShowStatus
    
    mov circleScore, 48
    mov crossScore, 48
    call UpdateScore
    
    call ClearBoard
    call ShowMenuBar
    jmp G1_Update
  
  
; Resets the whole board only    
ClearFunction:
    mov gameStatus, 3
    call ShowStatus
    
    call ClearBoard
    call ShowMenuBar
    jmp G1_Update


proc AutoClear
    ; disable auto-clear if it is turned off
    cmp autoClearToggle, 0
    je G1_Update
    
    mov gameStatus, 4
    call ShowStatus
    
    mov gameStatus, 3
    call ShowStatus
    
    call ClearBoard
    call ShowMenuBar
    ret
endp AutoClear
           
           
proc ClearBoard
    ; reset all board component values
    mov hasScored, 0
    mov mouseInput, 0
    mov continuousCircle, 0
    mov continuousCross, 0
    
    ; skip procedure if the board is empty
    cmp filledBoardBlocks, 0
    je SkipClearBoard    
    
    mov filledBoardBlocks, 0
    
    ; reset all array entity verifiers
    mov si, 0
    ResetArrays:
        mov boardRow0[si], 0
        mov boardRow1[si], 0
        mov boardRow2[si], 0
        
        mov circleHorizontal[si], 0
        mov circleVertical[si], 0
        mov circleDiagonal[si], 0
        
        mov crossHorizontal[si], 0
        mov crossVertical[si], 0
        mov crossDiagonal[si], 0
        
        inc si
        cmp si, 2
        jle ResetArrays
    
    ; reset all board blocks
    mov rowCoordinates, 3
    mov columnCoordinates, 25
    
    ResetBoardRow1:
        call ClearRowBlocks
        cmp rowCoordinates, 9
        jne ResetBoardRow1     
    
    inc rowCoordinates
    ResetBoardRow2:
        call ClearRowBlocks
        cmp rowCoordinates, 16
        jne ResetBoardRow2
        
    inc rowCoordinates
    ResetBoardRow3:
        call ClearRowBlocks
        cmp rowCoordinates, 23
        jne ResetBoardRow3
        
    SkipClearBoard:
    ret 
endp ClearBoard


proc ClearRowBlocks
    mov si, 0
    ClearBlock:
        mov dh, rowCoordinates
        mov dl, columnCoordinates
        mov bh, 0
        mov ah, 2
        int 10h
        
        mov al, 000
        mov bh, 0
        mov cx, 9
        mov ah, 0ah
        int 10h
        
        add columnCoordinates, 10
        
        inc si
        cmp si, 2
        jle ClearBlock
        
    sub columnCoordinates, 30
    inc rowCoordinates
    ret
endp ClearRowBlocks


proc UpdateScore
    mov dh, 16
    mov dl, 15
    mov bh, 0
    mov ah, 2
    int 10h
    
    mov dl, circleScore
    int 21h
    
    mov dl, 71
    int 10h
    
    mov dl, crossScore
    int 21h
    
    ret
endp UpdateScore


proc ShowScoreBoard
    mov si, 0
    mov bl, 7
    mov bh, 0
    ScoreBoardUpper:
        mov dh, bl
        mov dl, 6
        mov ah, 2
        int 10h
        
        lea dx, scoreboardCircle[si]
        mov ah, 9
        int 21h
        
        mov dh, bl
        mov dl, 62
        mov ah, 2
        int 10h
        
        lea dx, scoreboardCross[si]
        mov ah, 9
        int 21h
        
        add si, 12
        inc bl
        
        cmp si, 36
        jle ScoreBoardUpper
    
    sub si, 12
    ScoreBoardLower:
        mov dh, bl
        mov dl, 6
        mov ah, 2
        int 10h
        
        lea dx, scoreboardCircle[si]
        mov ah, 9
        int 21h
        
        mov dh, bl
        mov dl, 62
        mov ah, 2
        int 10h
        
        lea dx, scoreboardCross[si]
        mov ah, 9
        int 21h
        
        sub si, 12
        inc bl
        
        cmp si, 0
        jge ScoreBoardLower
              
    mov bl, 7
    ScoreBoardScoreString:
        mov dh, 16
        mov dl, bl
        mov ah, 2
        int 10h
        
        lea dx, scoreboardScore
        mov ah, 9
        int 21h
        
        add bl, 56
        cmp bl, 63
        je ScoreBoardScoreString         
    
    call UpdateScore
    ret
endp ShowScoreBoard


proc ShowGameBoard
    xor bx, bx
    mov si, 2
    
    CreateVertical:
        inc si
        mov bx, si
        
        ; left vertical line generation      
        mov dh, bl ; row
        mov dl, 34 ; column
        mov bh, 0
        mov ah, 2
        int 10h
        
        mov al, 179 ; ascii character
        mov bh, 0
        mov cx, 1 ; display amount
        mov ah, 0ah
        int 10h
           
           
        ; right vertical line generation 
        mov dh, bl ; row
        mov dl, 44 ; column
        mov bh, 0
        mov ah, 2
        int 10h
        
        mov al, 179 ; ascii character
        mov bh, 0
        mov cx, 1 ; display amount
        mov ah, 0ah
        int 10h
        
        cmp si, 22
        jl CreateVertical
    
    ; upper horizontal line generation
    mov dh, 9 ; row
    mov dl, 25 ; column
    mov bh, 0
    mov ah, 2
    int 10h
    
    mov al, 196 ; ascii character
    mov bh, 0
    mov cx, 29 ; display amount
    mov ah, 0ah
    int 10h         
                    
    ; lower horizontal line generation
    mov dh, 16 ; row
    mov dl, 25 ; column
    mov bh, 0
    mov ah, 2
    int 10h
    
    mov al, 196 ; ascii character
    mov bh, 0
    mov cx, 29 ; display amount
    mov ah, 0ah
    int 10h
    
    ret
endp ShowGameBoard




;
;
;   SNAKE COMPONENTS
;
;



G2_Initialize:
    ; set video mode to 80x25
    mov al, 03h
    mov ah, 0
    int 10h 

    ; hide mouse pointer
    mov ax, 2
    int 33h
    
    lea dx, statusbar
    mov ah, 9
    int 21h
    
    mov head_direction, 4
    ;initialize the position of the snake
    call initialize_snakebody

G2_Update:
    ; get keyboard input without buffer, skippable
    mov ah, 6
    mov dl, 255
    int 21h
    
    cmp al, 119 ; W (north | up)
    je up 
            
    cmp al, 115 ; S (south | down)
    je down
          
    cmp al, 97  ; A (west | left)
    je left

    cmp al, 100 ; D (east | right)
    je right   
    
    cmp al, 27
    je MainMenu
    
    ; the last action of pressed key will be repeated continously            
    jmp continuousmovement
    
    ;cmp mouse pos is food
    
    jmp G2_Update


continuousmovement:
    cmp head_direction, 0
    je G2_Update
    cmp head_direction, 1
    je up
    cmp head_direction, 2
    je down
    cmp head_direction, 3
    je left
    cmp head_direction, 4
    je right
    

up: 
    mov head_direction, 1
    call adjust_values
    dec snake_y[0]
    jmp G2_Draw
down:
    mov head_direction, 2
    call adjust_values
    inc snake_y[0]
    jmp G2_Draw 
left:
    mov head_direction, 3
    call adjust_values
    dec snake_x[0]
    jmp G2_Draw
right:
    mov head_direction, 4
    call adjust_values   
    inc snake_x[0]
    jmp G2_Draw   
   
   

proc adjust_values
    ; adjusts the values starting from the last index to the first index
    xor cx, cx
    mov cl, snake_length
    mov si, cx
    
    re_adjustvalues:
        mov cl, snake_y[si-1]
        mov snake_y[si], cl
        
        mov cl, snake_x[si-1]
        mov snake_x[si], cl
    
        dec si
        cmp si, 0
        jne re_adjustvalues
        
    ret    
endp adjust_values

     
G2_Draw:
    ; draws the body of the snake starting from the head up
    xor cx, cx
    mov cl, snake_length
    mov di, cx
    mov si, 0
    re_drawbody:
    
        ; mov snake head accordingly to x and y coordinates
        mov dh, snake_y[si]
        mov dl, snake_x[si] 
        mov bh, 0
        mov ah, 2
        int 10h  
        
        ; draw snake head
        mov al, 219
        mov bh, 0
        mov bl, 9h
        mov cx, 1
        mov ah, 09h
        int 10h
                                     
        inc si
        cmp si, di
        jne re_drawbody 
    
     
    ; remove tail's last position after moving
    xor cx, cx
    mov cl, snake_length
    mov si, cx
     
    ; position tail
    mov dh, snake_y[si]
    mov dl, snake_x[si] 
    mov bh, 0
    mov ah, 2
    int 10h 
    
    ; nullify tail
    mov al, 000
    mov bh, 0
    mov cx, 1
    mov ah, 0ah
    int 10h
    
    jmp G2_Update
    
    
ends


proc initialize_snakebody
    xor cx, cx
    
    mov cl, startposition_column
    mov snake_x[0], cl
    
    mov cl, startposition_row
    mov snake_y[0], cl
    
    mov cl, snake_length
    mov di, cx 
    
    mov si, 0 
    
    re_initialize_snakebody:
        ; set position of head on screen
        mov dh, snake_y[si]
        mov dl, snake_x[si] 
        mov bh, 0
        mov ah, 2
        int 10h  
        
        ; sets the next position of the snake body
        mov snake_y[si+1], dh
        mov snake_x[si+1], dl
        dec snake_x[si+1]
        
        ; draw snake body
        mov al, 219
        mov bh, 0
        mov bl, 9h
        mov cx, 1
        mov ah, 09h
        int 10h    
        
        inc si
        
        ; if snake_length value is lesser than 2, then only the head is drawn
        cmp snake_length, 2
        jl G2_Update
        
        ; if snake_length value is greater or equal than 2, the rest of the body is drawn
        cmp si, di
        jl re_initialize_snakebody
    ret
endp initialize_snakebody 


end start

