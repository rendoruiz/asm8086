; v1.1 [2015-02-27]
; Fixes:
; > fixed all errors


data segment
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
                                           
ends

code segment
start:
    mov ax, data
    mov ds, ax

Initialize:

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
        
    Update:
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
    
        jmp Update         
         
ends




VerifyInput:
    ; will jump is mouse position is below the menubar components
    cmp dx, 8
    jg BoardInput
    
    ; error trap: right side of return to main menu button
    cmp cx, 631d
    jg Update           
               
    ; return to main menu or exit
    ;cmp cx, 464d
    ;jge MainMenu
    
    cmp cx, 303d
    jg Update
    
    cmp cx, 7d
    jl Update 
    
    ; Auto-Clear, On/Off toggle button
    cmp cx, 167d
    jg AutoClearToggleButton
                   
    ; Restart button
    cmp cx, 80d
    jl RestartFunction                   
    
    cmp cx, 151d
    jg Update
                   
    ; Clear Button 
    cmp cx, 95d
    jg ClearFunction  


BoardInput:
    ; error trap: if a player scores, board must be cleared after
    cmp hasScored, 0
    jne Update
    
    ; error trap: ignore if any clicks outside the 9x9 board
    cmp dx, 24d
    jl Update
    
    cmp dx, 184d
    jg Update
    
    cmp cx, 200d
    jl Update
    
    cmp cx, 431d
    jg Update
                 
    ; error trap: prevents same continuous inputs
    cmp mouseInput, 1
    jne AdjustCross
    
    ; prevents circle to be displayed twice in a row
    inc continuousCircle    
    cmp continuousCircle, 1
    jg Update
    
    mov continuousCross, 0
    jmp VerifyRow
    
    AdjustCross:
        ; prevents cross to be displayed twice in a row
        inc continuousCross
        cmp continuousCross, 1
        jg Update
        
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
        
        jmp Draw
    
    
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
        
        jmp Draw
        
        
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
        
        jmp Draw  
  

; mouse input will reset if a line is selected 
AdjustMouseInput:
    cmp mouseInput, 1
    jne AdjustCrossValue
    
    dec continuousCircle
    jmp Update
    
    AdjustCrossValue:
        dec continuousCross
        jmp Update
        

; mouse input will reset if the selected block is filled/not empty 
FixMouseInput:
    cmp mouseInput, 1
    jne FixCrossValue 
    
    inc continuousCross
    dec continuousCircle
    jmp Update
    
    FixCrossValue:
        inc continuousCircle  
        dec continuousCross
        jmp Update
                          
                          
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
        
        
Draw:
    cmp mouseInput, 1
    je DrawCircle
    
    cmp mouseInput, 2
    je DrawCross
    
    DrawReturn:
    call VerifyCompletion
    
    jmp Update
    
    
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
    jmp Update
    
    ToggleOff:
        mov autoClearToggle, 0
        call ShowAutoClearStatus
        jmp Update
        

; Resets the board and player score
RestartFunction:
    mov gameStatus, 2
    call ShowStatus
    
    mov circleScore, 48
    mov crossScore, 48
    call UpdateScore
    
    call ClearBoard
    call ShowMenuBar
    jmp Update
  
  
; Resets the whole board only    
ClearFunction:
    mov gameStatus, 3
    call ShowStatus
    
    call ClearBoard
    call ShowMenuBar
    jmp Update


proc AutoClear
    ; disable auto-clear if it is turned off
    cmp autoClearToggle, 0
    je Update
    
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

end start
