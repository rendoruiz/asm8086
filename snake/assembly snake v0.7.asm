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

;Snake (Alpha v0.7): Basic Game Logic
; TODO:
; > Add character detection system
; > Add pre-loaded food/points, system
; > Add pre-loaded obstacle(s), system
; > added restart function
; > added exit function
; > added status bar and messages
; > added position checking (game over)

data segment
    snakeBodyX db 100 dup (0)   ; column, dl
    snakeBodyY db 100 dup (0)   ; row,    dh
    snakeLength db 2
    snakeHeadDirection db 0
    
    startCoordinatesX db 39
    startCoordinatesY db 13
    
    statusBarContent db "Press 'esc' key to return to main menu.$"
    statusBarRestart db "Restarting. . .$"
    
    gameOverMessage db "Game Over!  Press the 'enter' key to restart, or 'esc' to return to main menu$"
    gameOver db 0
    
    levelTotalPoints db 0
    levelAcquiredPoints db 0
    character db 0
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
    
    ; hide mouse pointer
    mov ax, 1
    int 33h
    
    ; hide text cursor (compiled executable)
    mov ch, 32
    mov ah, 1
    int 10h
    
    ; display status bar on top of the window
    call ShowStatusBar
    
    call GenerateObstacle1
    
    ; initialize defined snake elements
    call InitializeSnakeBody
    
Update:
    ; get keyboard input, skippable
    mov ah, 6
    mov dl, 255
    int 21h
    
    
    ; enter key, restart game
    cmp al, 13      ; enter
    je Restart
    
    ; escape key, back main menu/ exit
    cmp al, 27
    je Exit
    
    ; error trap: game must be restarted or closed after the game is over
    cmp gameOver, 1
    je Update
    
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
    
    jmp Update
    
Exit:
    mov ax, 4c00h
    int 21h
    
ends


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
    je Update
    
               
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
    cmp snakeBodyX[0], 0
    jl GameOverStatus
    
    cmp snakeBodyX[0], 79
    jg GameOverStatus
    
    cmp snakeBodyY[0], 2
    jl GameOverStatus
    
    cmp snakeBodyY[0], 24
    jg GameOverStatus
    
    jmp Draw    

                      
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
                      
 
Draw:
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
    
    jmp Update 
 
 
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
        jl Update
        
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
    mov cx, 80
    mov ah, 09h
    int 10h     
    
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
             

GameOverStatus:
    mov gameOver, 1
    
    mov dh, 0
    mov dl, 1
    mov bh, 0
    mov ah, 2
    int 10h
    
    lea dx, gameOverMessage
    mov ah, 9
    int 21h

    jmp Update


Restart:
    cmp gameOver, 1
    jne Update
    
    mov dh, 0
    mov dl, 1
    mov bh, 0
    mov ah, 2
    int 10h
    
    mov al, 000
    mov bh, 0
    mov cx, 79
    mov ah, 0ah
    int 10h
    
    lea dx, statusBarRestart
    mov ah, 9
    int 21h
    
    ; clear the whole field
    mov gameOver, 2
    ClearField:
    
        ; set position
        mov dh, gameOver
        mov dl, 0
        mov bh, 0
        mov ah, 2
        int 10h
        
        ; clear row
        mov al, 000
        mov bh, 0
        mov bl, 0111b
        mov cx, 79
        mov ah, 09h
        int 10h     
        
        inc gameOver
        cmp gameOver, 24
        jle ClearField
    
    ; reset components
    mov gameOver, 0
    mov snakeHeadDirection, 0
    
    ; initialize components
    call ShowStatusBar
    call InitializeSnakeBody
    
    jmp Update
     


proc GenerateObstacle1
    ; upper left corner
    mov snakeBodyX[99], 9
    mov snakeBodyY[99], 25
    mov cl, 201
    call LocateAndPrint
          
    ; upper right corner
    mov snakeBodyY[99], 54
    mov cl, 187
    call LocateAndPrint
          
    ; lower right corner
    mov snakeBodyX[99], 17
    mov cl, 188
    call LocateAndPrint
          
    ; lower lef corner 
    mov snakeBodyY[99], 25
    mov cl, 200
    call LocateAndPrint    
    
    
    ; horizontal line
    mov dh, 9
    GenerateHorizontalLine:
        mov dl, 26
        mov bh, 0
        mov ah, 2
        int 10h
        
        mov al, 205
        mov bh, 0
        mov cx, 28
        mov ah, 0ah
        int 10h
        
        add dh, 8
        cmp dh, 17
        je GenerateHorizontalLine
        
    ret
endp GenerateObstacle1

proc LocateAndPrint
    ; snakeBodyX[0] = row; snakeBodyY[0] = column; cl = ascii; si = amount
    mov dh, snakeBodyX[99]
    mov dl, snakeBodyY[99]
    mov bh, 0
    mov ah, 2
    int 10h
    
    mov al, cl
    mov bh, 0
    mov cx, 1
    mov ah, 0ah
    int 10h
    ret
endp LocateAndPrint


end start 