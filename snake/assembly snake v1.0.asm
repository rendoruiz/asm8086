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

;Snake (Release v1.0)

data segment
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
    
Initialize:
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
    
         
Update:
    ; get keyboard input, skippable
    mov ah, 6
    mov dl, 255
    int 21h
    
    ; enter key: restart game
    cmp al, 13      ; enter
    je Restart
    
    ; escape key: back main menu / exit
    cmp al, 27
    je Exit
    
    ; error trap: game must be restarted or closed after the game is over
    cmp isGameOver, 1
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
  
  
proc IncreaseSnakeLength
    xor cx, cx
    mov cl, levelAcquiredPoints
    mov si, cx   
    
    ; if the x-coordinates of the head and food are not equal, ignore
    mov cl, snakeFoodX[si]
    cmp snakeBodyX[0], cl
    jne Draw
    
    ; if the y-coordinates of the head and food are not equal, ignore
    mov cl, snakeFoodY[si]
    cmp snakeBodyY[0], cl
    jne Draw
    
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
    je Draw    
    
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
    
    ; stop the game if all the food/points has been eaten
    xor cx, cx
    mov cl, levelTotalPoints
    cmp levelAcquiredPoints, cl
    je GameOver   
    
    jmp Update          


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

    jmp Update


Restart:
    cmp isGameOver, 1
    jne Update
    
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
    ClearField:
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
        jle ClearField
    
    ; reset components
    mov isGameOver, 0
    mov snakeHeadDirection, 0
    
    ; re-initialize components
    call ShowStatusBar    
    call GenerateLevel1Food
    call InitializeSnakeBody
    
    jmp Update         
         
         
end start
