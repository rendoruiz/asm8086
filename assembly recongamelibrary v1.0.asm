; Recon Game Library (Release v1.0): Compiled [2015-03-08]

data segment
;==                               ==
;==     Main Menu Components      ==
;==                               ==

    menuGameLogo db " RRRRR"
                 db 10,13," RR  RR"
                 db 10,13," RR  RR  EEEE   CCCCC   OOOOOO  N NNNN"
                 db 10,13," RR RR  EE  EE CCC  CC OOO  OOO NNNNNNN"
                 db 10,13," RRRR   EE  EE CC      OO    OO NN   NN"
                 db 10,13," RRRR   EEEEE  CC      OO    OO NN   NN"
                 db 10,13," RR RR  EE     CCC  CC OOO  OOO NN   NN"
                 db 10,13," RR  RR  EEEE   CCCCC   OOOOOO  NN   NN"
                 db 10,13,10,13,"   G  A  M  E     L  I  B  R  A  R  Y$"
    
    menuSelect db "Select a game below!$"
    menuTTTButton db "TicTacToe$"
    menuSnakeButton db "Snake$"    
    
    menuReturn db "[Return to Main Menu]$" 
    menuTempDescription db "Game: version, goal/purpose, description, controls, known bugs/issues, etc.$"              
    menuPlayButton db "[ P L A Y   G A M E ]$"    
    gameState db 0
                    
    menuSnakeDescription db " (Release v1.2b): Compiled [2015-03-08]"
                         db 10,13,""
                         db 10,13," Goal/Purpose:"
                         db 10,13,"  > To present an assembly program using keyboard-driven interrupts."
                         db 10,13,""
                         db 10,13," Description:"
                         db 10,13,"  > An implementation of snake using the assembly language, based on"
                         db 10,13,"    the old mobile snake games."
                         db 10,13,"  > It is a level-driven mode, not endless-mode. Meaning after eating"
                         db 10,13,"    all the available points/food, a new level ladder/door will open."
                         db 10,13,"    But in this case, with only 1 level, the game will end." 
                         db 10,13,""
                         db 10,13," Controls:"
                         db 10,13,"  > Navigation Keys: W (up)"
                         db 10,13,"                     A (left)"
                         db 10,13,"                     S (down)"   
                         db 10,13,"                     D (right)"
                         db 10,13,"  > Back to Menu: Esc key"
                         db 10,13,"  > Restart: Enter key (only when prompted (game over state))"
                         db 10,13,"$"
                         
    menuTictactoeDescription db " (Release v1.2b): Compiled [2015-03-08]"
                             db 10,13,""
                             db 10,13," Goal/Purpose:"
                             db 10,13,"  > To present an assembly program using mouse-driven interrupts."
                             db 10,13,""
                             db 10,13," Description:"
                             db 10,13,"  > An implementation of Tic-Tac-Toe using the assembly language."
                             db 10,13,"  > The player(s) must click on the 9x9 grid/board with their respective"
                             db 10,13,"    inputs (round/cross)."
                             db 10,13,"  > The player(s) must only place an input on an empty slot/space."
                             db 10,13,"  > A player cannot place more than a single input consecutively."
                             db 10,13,"  > Once a player forms a straight line (horizontal/vertical/diagonal)," 
                             db 10,13,"    the game will end. And the board will be automatically cleared if"
                             db 10,13,"    'Auto-Clear' toggle button is set to 'Yes'."
                             db 10,13,""
                             db 10,13," Controls:"
                             db 10,13,"  > Player 1 (Round): Left mouse-click"
                             db 10,13,"  > Player 2 (Cross): Right mouse-click"
                             db 10,13,"  > Menu Bar Buttons: Restart & Clear button, Auto-Clear toggle button,"
                             db 10,13,"                      Back to menu button"
                             db 10,13,"$"
                               
    ; file-handling components
        filePath db "C:\ReconGL\",0
    fileName db "C:\ReconGL\playerName.txt",0
    fileHandle dw ?
    
    nameEnter db "Enter your name: $"
    nameGreet db "Hi! $"
    nameChangeButton db "[Change Name]$"    
    
    nameBuffer db 13 dup(' '), '$'
    nameSizeLimit db 12

        
                
;==                               ==
;==    Tic-tac-toe Components     ==
;==                               ==

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
    
    circleScore db 48    
    crossScore db 48     
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



;==                               ==
;==       Snake Components        ==
;==                               ==

    startCoordinatesX db 19
    startCoordinatesY db 13     
    
    snakeBodyX db 50 dup (0)   ; column, dl
    snakeBodyY db 50 dup (0)   ; row,    dh
    snakeLength db 2
    snakeHeadDirection db 0                
    
    snakeFoodX db 31, 25, 8, 8, 24
    snakeFoodY db 13, 19, 18, 5, 6
    levelTotalPoints db 5
    levelAcquiredPoints db 0
    
    statusBarContent db "Press 'esc' to return to main menu.$"
    statusBarRestart db "Restarting. . .$"
    
    gameOverMessage db "Game Over! ENTER=Restart, ESC=MainMenu$"
    isGameOver db 0

ends


code segment
start:
    mov ax, data
    mov ds, ax
           
           
LoadContent:
    ; set video mode to 40x25
    mov al, 00h
    mov ah, 0 
    int 10h
    
    ; hide text cursor
    mov ch, 32
    mov ah, 1
    int 10h

    ; open playername file
    mov al, 2
    mov dx, offset fileName
    mov ah, 3dh
    int 21h  
    mov fileHandle, ax
    
    LoadFileToBuffer:
    ; make a name, will skip if file exists          
    call CreatePlayerName
                   
    ; specify / SEEK character position in file 
    mov al, 0
    mov bx, fileHandle
    mov cx, 0
    mov dx, 0
    mov ah, 42h
    int 21h
    
    ; read from file
    xor cx, cx
    mov cl, nameSizeLimit
    mov si, cx
    
    ; store file data to nameBuffer
    mov bx, fileHandle
    mov cx, si     
    mov dx, offset nameBuffer
    mov ah, 3fh
    int 21h
    
    ; close file
    mov bx, fileHandle
    mov ah, 3eh
    int 21h
    
    jmp MainMenu

    
; initialize components before Update    
MainMenu:
    ; set video mode to 40x25
    mov al, 00h
    mov ah, 0 
    int 10h
    
    ; hide text cursor
    mov ch, 32
    mov ah, 1
    int 10h

    ; display greetings
    lea dx, nameGreet
    mov ah, 9
    int 21h    
    
    ; display player name
    lea dx, nameBuffer
    mov ah, 9
    int 21h
           
    ; display game logo
    mov dh, 3
    mov dl, 0
    mov bh, 0
    mov ah, 2
    int 10h    

    lea dx, menuGameLogo
    mov ah, 9
    int 21h
    
    ; display instruction
    mov dh, 15
    mov dl, 10
    mov bh, 0
    mov ah, 2
    int 10h
    
    lea dx, menuSelect
    mov ah, 9
    int 21h
       
    ; display Tic-Tac-Toe button
    mov dh, 18
    mov dl, 16
    mov bh, 0
    mov ah, 2
    int 10h
        
    lea dx, menuTTTButton
    mov ah, 9
    int 21h
      
    ; display snake button
    mov dh, 21
    mov dl, 16
    mov bh, 0
    mov ah, 2
    int 10h
    
    lea dx, menuSnakeButton
    mov ah, 9
    int 21h
    
    ; display changename button
    mov dh, 1
    mov dl, 0
    mov bh, 0
    mov ah, 2
    int 10h
    
    lea dx, nameChangeButton
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
  
  
;==                               ==
;==     Main Menu Components      ==
;==                               ==

proc CreatePlayerName
    ; if file doesnt exists, create a name
    cmp ax, 3
    je CreateName
    ret
    
    CreateName:
        ; set position of string
        mov dh, 11
        mov dl, 4
        mov bh, 0
        mov ah, 2
        int 10h
        
        ; display string "enter name"
        lea dx, nameEnter
        mov ah, 9
        int 21h    
    
        xor cx, cx
        mov cl, nameSizeLimit
        mov di, cx
        mov si, 0
        InputName:
            ; erases character when backspace key is pressed
            mov al, 000
            mov bh, 0
            mov cx, 1
            mov ah, 0ah
            int 10h  
            
            ; accepts single keyboard input
            mov ah, 1
            int 21h
            
            ; stores keyboard input in the buffer
            mov nameBuffer[si], al
            
            ; end the input if enter key is pressed
            cmp al, 13
            je NameEntered
            
            ; adjust value if backspace key is presed
            cmp al, 8
            je AdjustName
            
            ; end the input if exceed character limit
            inc si
            cmp si, di
            jle InputName
            
            ; gets current cursor position
            mov bh, 0
            mov ah, 03h
            int 10h
             
            ; decrements cursor position's column value 
            dec dl
            mov ah, 2
            int 10h
            
            ; goes back to input
            dec si
            jmp InputName
        
    
    NameEntered:
        ; remove enter key ascii code
        mov nameBuffer[si], 000
           
        ; create folder/directory
        mov dx, offset filePath
        mov ah, 39h
        int 21h           
           
        ; create and open file
        mov cx, 0
        mov dx, offset fileName
        mov ah, 3ch
        int 21h
        
        mov fileHandle, ax
        
        ; write name into file
        inc si
        mov bx, fileHandle
        mov cx, si
        mov dx, offset nameBuffer
        mov ah, 40h
        int 21h 
        
        ret
    
    AdjustName:
        ; don't adjust value if nameBuffer is empty
        cmp si, 0
        je InputName
        
        dec si
        jmp InputName
                    
endp CreatePlayerName


ChangePlayerName:
    ; reset display
    mov al, 00h
    mov ah, 0 
    int 10h
    
    ; delete file
    mov dx, offset fileName
    mov ah, 41h
    int 21h
    
    ; delete directory
    mov dx, offset filePath
    mov ah, 3ah
    int 21h
    
    ; reset nameBuffer
    xor cx, cx
    mov cl, nameSizeLimit
    mov si, cx
    ResetNameBuffer:
        mov nameBuffer[si], 000
        dec si
        cmp si, 0
        jge ResetNameBuffer
    
    mov ax, 3
    ; Create player name 
    jmp LoadFileToBuffer


GameSelected:
    cmp dx, 16d
    jg ButtonArea 
     
    cmp dx, 8d
    jl Update
     
    cmp cx, 104d
    jl ChangePlayerName
    
    
ButtonArea:    
    ; errortrap: higher than tic-tac-toe button
    cmp dx, 144d    ; 90h
    jl Update
    
    ; errortrap: lower than snake button
    cmp dx, 176d    ; b0h
    jg Update 

    ; errortrap: left-hand side of the buttons
    cmp cx, 128d    ; 80h
    jl Update   
    
    ; errortrap: right-hand side of tictactoe button
    cmp cx, 199d    ; c7h
    jg Update
    
    ; if tictactoe button is clicked
    cmp dx, 152d
    jle ShowGameInfo
    
    ; if snake button is clicked
    cmp dx, 168d
    jge ShowGameInfo

    jmp Update

   
proc SelectionArrow
    ; errortrap: higher than tic-tac-toe button
    cmp dx, 144d    ; 90h
    jl Update
    
    ; errortrap: lower than snake button
    cmp dx, 176d    ; b0h
    jg Update 

    ; errortrap: left-hand side of the buttons
    cmp cx, 128d    ; 80h
    jl Update   
    
    ; errortrap: right-hand side of tictactoe button
    cmp cx, 199d    ; c7h
    jg Update    
    
    
    ; display selection arrow to the left side of tictactoe button
    cmp dx, 152d
    jle SelectTictactoe
    
    ; display selection arrow to the left side of snake button
    cmp dx, 168d
    jge SelectSnake
     
    ret      
          
    SelectTictactoe:
        ; do nothing if already selected
        cmp gameState, 1
        je Update
        
        ; removes the selection arrow from snake button
        mov dh, 21
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
        mov dh, 18
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
        ; do nothing if already selected
        cmp gameState, 2
        je Update
        
        ; removes the selection arrow from tic-tac-toe button
        mov dh, 18
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
        mov dh, 21
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
    
    
    ; display play button
    mov dh, 22
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
    
    lea dx, menuTictactoeDescription
    mov ah, 9
    int 21h
    
    jmp InfoUpdate


InfoSnake:
    lea dx, menuSnakeButton
    mov ah, 9
    int 21h
    
    lea dx, menuSnakeDescription
    mov ah, 9
    int 21h
    
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
    cmp dx, 184d    ; b8h
    jg InfoUpdate
    
    ; play button row
    cmp dx, 176d    ; b0h
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
        cmp cx, 631     ; 0277h
        jg InfoUpdate
        
        cmp cx, 464d    ; 01d0h
        jle InfoUpdate
        
        jmp MainMenu               
          
               
PlayButtonPressed:
    cmp gameState, 1
    je G1_Initialize
    
    cmp gameState, 2
    je G2_Initialize
    
    ;jmp MainMenu





;==                               ==
;==    Tic-tac-toe Components     ==
;==                               ==

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
    ;mov ax, 1
    ;int 33h
    
    ; hide text cursor (for compiled executable) 
 	mov ch, 32
 	mov ah, 1
 	int 10h
        
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
    
    
;TIC-TAC-TOE PROCEDURES/FUNCTIONS 
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
    ;jge G1_Exit
    
    cmp cx, 303d
    jg G1_Update
    
    cmp cx, 7d
    jl G1_Update 
    
    ; Auto-Clear, On/Off toggle button
    cmp cx, 167d
    jg AutoClearToggleButton
                   
    ; Restart button
    cmp cx, 80d
    jl RestartFunction                   
    
    cmp cx, 151d
    jg G1_Update
                   
    ; Clear Button 
    cmp cx, 95d
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
    
    DrawReturn:
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
       
    jmp DrawReturn
       
       
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
        
    jmp DrawReturn 
    
    
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





;==                               ==
;==       Snake Components        ==
;==                               ==

G2_Initialize:
    ; set video mode to 40x25
    mov al, 00h
    mov ah, 0
    int 10h
    
    ; hide mouse pointer
    mov ax, 2
    int 33h
    
    ; hide text cursor (for compiled executable)
    mov ch, 32
    mov ah, 1
    int 10h    
         
    ; initialize components
    call ShowStatusBar
    call InitializeSnakeBody
    call GenerateLevel1Food
    
         
G2_Update:
    ; get keyboard input, skippable
    mov ah, 6
    mov dl, 255
    int 21h
    
    ; enter key: restart game
    cmp al, 13      ; enter
    je G2_Restart
    
    ; escape key: back main menu / exit
    cmp al, 27
    je MainMenu
    
    ; error trap: game must be restarted or closed after the game is over
    cmp isGameOver, 1
    je G2_Update
    
    cmp al, 119     ; W
    je MoveUp
    
    cmp al, 115     ; S
    je MoveDown
    
    cmp al, 97      ; A
    je MoveLeft
    
    cmp al, 100     ; D
    je MoveRight
    
    ; automatically move the snake even without keyboard input
    jmp AutomatedMovement
    
    jmp G2_Update


;SNAKE PROCEDURES/FUNCTIONS
MoveUp:
    mov snakeHeadDirection, 1
    jmp AutomatedMovement

MoveDown:
    mov snakeHeadDirection, 2
    jmp AutomatedMovement
    
MoveLeft:
    mov snakeHeadDirection, 3
    jmp AutomatedMovement
    
MoveRight:
    mov snakeHeadDirection, 4
    jmp AutomatedMovement         
         
         
AutomatedMovement:
    ; if no default direction is set, stand by
    cmp snakeHeadDirection, 0
    je G2_Update
    
    ; adjust the values of snakeBody X&Y indexes
    call AdjustSnakeBody    

    ; decrease Y coordinate if direction is upward
    dec snakeBodyY[0]
    cmp snakeHeadDirection, 1
    je VerifySnakePosition
    
    ; increase Y coordinate if direction is downward
    add snakeBodyY[0], 2
    cmp snakeHeadDirection, 2
    je VerifySnakePosition
             
    ; decrease X coordinate if direction is left-sideward         
    dec snakeBodyY[0]
    dec snakeBodyX[0]
    cmp snakeHeadDirection, 3
    je VerifySnakePosition                 
             
    ; increase X coordinate if direction is right-sideward         
    add snakeBodyX[0], 2
    cmp snakeHeadDirection, 4
    je VerifySnakePosition         
         
         
VerifySnakePosition:
    ; error trap: borders
    cmp snakeBodyX[0], 0    ; left side
    jl GameOver
    
    cmp snakeBodyX[0], 39   ; right side
    jg GameOver
    
    cmp snakeBodyY[0], 2    ; above: on the status bar horizontal line
    jl GameOver
    
    cmp snakeBodyY[0], 24   ; below 
    jg GameOver         
         
    ; check if snakeBody and snakeFood coordinates are equal
    call IncreaseSnakeLength
    
    jmp G2_Draw     
         
         
proc AdjustSnakeBody
    ; adjust the values of X & Y indexes starting from the last index up to the first index (0) / head
    xor cx, cx
    mov cl, snakeLength
    mov si, cx
    
    AdjustXYValues:
        mov cl, snakeBodyY[si-1]
        mov snakeBodyY[si], cl
        
        mov cl, snakeBodyX[si-1]
        mov snakeBodyX[si], cl
        
        dec si
        cmp si, 0
        jne AdjustXYValues
    
    ret
endp AdjustSnakeBody                      
  
  
proc IncreaseSnakeLength
    xor cx, cx
    mov cl, levelAcquiredPoints
    mov si, cx   
    
    ; if the x-coordinates of the head and food are not equal, ignore
    mov cl, snakeFoodX[si]
    cmp snakeBodyX[0], cl
    jne G2_Draw
    
    ; if the y-coordinates of the head and food are not equal, ignore
    mov cl, snakeFoodY[si]
    cmp snakeBodyY[0], cl
    jne G2_Draw
    
    ; adjust snake components
    inc snakeLength
    inc levelAcquiredPoints    
    
    ; after eating, generate next food
    call GenerateLevel1Food       
    
    ret
endp IncreaseSnakeLength

         
proc GenerateLevel1Food
    xor cx, cx
    mov cl, levelAcquiredPoints
    mov si, cx
    
    ; dont generate food if total and acquired points is equal
    cmp levelTotalPoints, cl
    je G2_Draw    
    
    ; position the mouse cursor to the food coordinates
    mov dh, snakeFoodY[si]
    mov dl, snakeFoodX[si]
    mov bh, 0
    mov ah, 2
    int 10h    
    
    ; draw the food
    mov al, 004
    mov bh, 0
    mov bl, 1100b
    mov cx, 1
    mov ah, 09h
    int 10h
    
    ret
endp GenerateLevel1Food         
         
         
G2_Draw:
    ; display the body of snake starting from the first index / head
    xor cx, cx
    mov cl, snakeLength
    mov di, cx
    mov si, 0
    
    DrawSnakeBody:
        mov dh, snakeBodyY[si]
        mov dl, snakeBodyX[si]
        mov bh, 0
        mov ah, 2
        int 10h
        
        mov al, 42
        mov bh, 0
        mov bl, 1010b
        mov cx, 1
        mov ah, 09h
        int 10h
        
        inc si
        cmp si, di
        jne DrawSnakeBody
              
    ; remove the displayed tail / last index          
    xor cx, cx
    mov cl, snakeLength
    mov si, cx
    
    mov dh, snakeBodyY[si]
    mov dl, snakeBodyX[si]
    mov bh, 0
    mov ah, 2
    int 10h
    
    mov al, 000
    mov bh, 0
    mov bl, 7h
    mov cx, 1
    mov ah, 09h
    int 10h
    
    ; stop the game if all the food/points has been eaten
    xor cx, cx
    mov cl, levelTotalPoints
    cmp levelAcquiredPoints, cl
    je GameOver   
    
    jmp G2_Update          


Level1End:
    mov isGameOver, 1
    jmp GameOver
         
         
proc InitializeSnakeBody
    ; display the body of the snake on the start of the game based on the default arguments
    xor cx, cx
    
    mov cl, startCoordinatesX
    mov snakeBodyX[0], cl
    
    mov cl, startCoordinatesY
    mov snakeBodyY[0], cl
    
    mov cl, snakeLength
    mov di, cx
    
    mov si, 0
    
    DrawSnakeInitialization:
        mov dh, snakeBodyY[si]
        mov dl, snakeBodyX[si]
        mov bh, 0
        mov ah, 2
        int 10h
        
        mov snakeBodyY[si+1], dh
        mov snakeBodyX[si+1], dl
        dec snakeBodyX[si+1]
        
        mov al, 42
        mov bh, 0
        mov bl, 1010b
        mov cx, 1
        mov ah, 09h
        int 10h
        
        inc si
        cmp snakeLength, 2
        jl G2_Update
        
        cmp si, di
        jl DrawSnakeInitialization
    
    ret
endp InitializeSnakeBody          
            
            
proc ShowStatusBar
    ; displays horizontal bar   
    mov dh, 1
    mov dl, 0
    mov bh, 0
    mov ah, 2
    int 10h
    
    mov al, 205
    mov bh, 0
    mov bl, 0111b
    mov cx, 40
    mov ah, 09h
    int 10h     
    
    ; display content
    mov dh, 0
    mov dl, 1
    mov bh, 0
    mov ah, 2
    int 10h
    
    lea dx, statusBarContent
    mov ah, 9
    int 21h
    
    ret
endp ShowStatusBar
             

GameOver:
    mov isGameOver, 1
    
    mov dh, 0
    mov dl, 1
    mov bh, 0
    mov ah, 2
    int 10h
    
    lea dx, gameOverMessage
    mov ah, 9
    int 21h

    jmp G2_Update


G2_Restart:
    cmp isGameOver, 1
    jne G2_Update
    
    mov dh, 0
    mov dl, 1
    mov bh, 0
    mov ah, 2
    int 10h
    
    mov al, 000
    mov bh, 0
    mov cx, 40
    mov ah, 0ah
    int 10h
    
    lea dx, statusBarRestart
    mov ah, 9
    int 21h
    
    ; clear the whole field
    mov dh, 2
    G2_ClearField:
        ; set position
        mov dl, 0
        mov bh, 0
        mov ah, 2
        int 10h
        
        ; clear row
        mov al, 000
        mov bh, 0
        mov bl, 0111b
        mov cx, 40
        mov ah, 09h
        int 10h     
        
        inc dh
        cmp dh, 24
        jle G2_ClearField
    
    ; reset components
    mov isGameOver, 0
    mov snakeHeadDirection, 0
    mov snakeLength, 2 
    mov levelAcquiredPoints, 0
    
    ; re-initialize components
    call InitializeSnakeBody
    call GenerateLevel1Food
    call ShowStatusBar   
   
    jmp G2_Update  

end start
