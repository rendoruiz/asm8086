;Snake (Alpha v0.6): Streamlining

data segment
    snakeBodyX db 100 dup (0)   ; column, dl
    snakeBodyY db 100 dup (0)   ; row,    dh
    snakeLength db 5
    
    snakeHeadDirection db 0
    
    startCoordinatesX db 39
    startCoordinatesY db 12
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
    mov ax, 2
    int 33h
    
    ; initialize defined snake elements
    call InitializeSnakeBody
    
    
Update:
    ; get keyboard input, skippable
    mov ah, 6
    mov dl, 255
    int 21h
    
    cmp al, 119     ; W
    je MoveUp
    
    cmp al, 115     ; S
    je MoveDown
    
    cmp al, 97      ; A
    je MoveLeft
    
    cmp al, 100     ; D
    je MoveRight
    
    jmp AutomatedMovement
    
    jmp Update

    
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
    je Draw
    
    ; increase Y coordinate if direction is downward
    add snakeBodyY[0], 2
    cmp snakeHeadDirection, 2
    je Draw
             
    ; decrease X coordinate if direction is left-sideward         
    dec snakeBodyY[0]
    dec snakeBodyX[0]
    cmp snakeHeadDirection, 3
    je Draw                 
             
    ; increase X coordinate if direction is right-sideward         
    add snakeBodyX[0], 2
    cmp snakeHeadDirection, 4
    je Draw
    
    ; display the snake using the adjusted values
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
                      
end start 
