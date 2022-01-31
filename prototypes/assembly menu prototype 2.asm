; Menu Prototype 2
; 1. The screen will start at 40x25
; 2. there will be two buttons to be pressed: TTT and Snake
; 3. When pressed the screen size will change to 80x25
; 4. the screen will contain the information there is in the game
; 5. on the right-hand side there will be a play button
; 6. if play button is pressed, game state will change to the respective game
; 7. game descriptions will be written to a file and loaded when needed

data segment               
    btnTTT db "TicTacToe$"
    btnSnake db "Snake$"
    gameState db 0
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
    
    ; Show Tic-Tac-Toe button
    mov dh, 12
    mov dl, 16
    mov bh, 0
    mov ah, 2
    int 10h
        
    lea dx, btnTTT
    mov ah, 9
    int 21h
    
    ; Show snake button
    mov dh, 17
    mov dl, 16
    mov bh, 0
    mov ah, 2
    int 10h
    
    lea dx, btnSnake
    mov ah, 9
    int 21h
    
    
    ; set default selection pointer to tic-tac-toe
    jmp SelectTicTacToe
    
    Update:  
    
    ; keyboard inputs
        ; direct console input, ascii value stored in al   
        mov dl, 255
        mov ah, 6
        int 21h
        
        ; if W key is pressed, tic-tac-toe button will be selected(focused)
        cmp al, 119
        je SelectTicTacToe
        
        ; if S key is pressed, snake button will be selected(focused)
        cmp al, 115
        je SelectSnake
        
        ; if enter key is pressed,
        cmp al, 13
        je gameInfo
        
        
    ; mouse inputs
        ; if left mouse button is pressed
        cmp bx, 00000001b
        je gameInfo 
     
        ; get mouse position, stored in CX and DX 
        mov ax, 3
        int 33h         
         
        ; errortrap: higher than tic-tac-toe button
        cmp dx, 96d     ; 60h
        jl Update
        
        ; errortrap: lower than snake button
        cmp dx, 144d    ; 90h
        jg Update 
    
        ; errortrap: left-hand side of the buttons
        cmp cx, 128d    ; 80h
        jl Update   
        
                    
        ; errortrap: right-hand side of tictactoe button
        cmp cx, 199d    ; c7h
        jg Update
        
        ; tictactoe button
        cmp dx, 104d    ; 68h
        jl SelectTictactoe
        
        
        ; errortrap: right-hand side of snake button
        cmp cx, 168d    ; a8h
        jg Update
        
        ; snake button
        cmp dx, 136d    ; 88h
        jge SelectSnake 
        
        
        ; if left mouse button is pressed
        cmp bx, 00000001b
        je gameInfo 
                
        jmp Update
    
ends


gameInfo:
    ; reset value of bx
    xor bx, bx
    
    ; set video mode to 80x25
    mov al, 03h
    mov ah, 0 
    int 10h    
    
    cmp gameState, 1
    je InfoTictactoe
    
    cmp gameState, 2
    je InfoSnake
    
    jmp MainMenu  


InfoTictactoe:
    lea dx, btnTTT
    mov ah, 9
    int 21h
    
    mov ah, 00h
    int 16h
    
    jmp MainMenu


InfoSnake:
    lea dx, btnSnake
    mov ah, 9
    int 21h
    
    mov ah, 00h
    int 16h
    
    jmp MainMenu

               
               
               
               
               
               
SelectTictactoe:
    cmp gameState, 1
    je Update
    
    mov gameState, 1

    ; removes the selection arrow from snake button
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
           
    ; displays the selection arrow to the tic-tac-toe button       
    mov dh, 12
    mov dl, 14
    mov bh, 0
    mov ah, 2
    int 10h    
    
    mov al, 26
    mov bh, 0
    mov cx, 1
    mov ah, 0ah
    int 10h
        
    jmp Update
       
       
SelectSnake:
    cmp gameState, 2
    je Update
    
    mov gameState, 2

    ; removes the selection arrow from tic-tac-toe button
    mov dh, 12
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

    jmp Update



end start
