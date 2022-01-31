; v0.2
; TODO:
; > Fix mouse update
; > remove keyboard input in homescreen
 
 
data segment               
    menuTTTButton db "TicTacToe$"
    menuSnakeButton db "Snake$"
 
    
    menuReturn db "Press 'Esc' to return to main menu$"
    
    menuSelect db "Select a game below!$"
                                                 
    menuGameLogo db "RRRRR                                 $"
                 db "RR  RR                                $"
                 db "RR  RR  EEEE   CCCCC   OOOOOO  N NNNN $"
                 db "RR RR  EE  EE CCC  CC OOO  OOO NNNNNNN$"
                 db "RRRR   EE  EE CC      OO    OO NN   NN$"
                 db "RRRR   EEEEE  CC      OO    OO NN   NN$"
                 db "RR RR  EE     CCC  CC OOO  OOO NN   NN$"
                 db "RR  RR  EEEE   CCCCC   OOOOOO  NN   NN$"
                 db 10,13,"  G  A  M  E     L  I  B  R  A  R  Y  $"
              
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
    
    ; errortrap: the gap between tictactoe and snake button
    cmp dx, 160d
    jl Update
    
    ; errortrap: the gap between snake and tictactoe button
    cmp dx, 144d
    jg Update  
      
    
    cmp gameState, 1
    je ShowGameInfo
    
    cmp gameState, 2
    je ShowGameInfo

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
    ; if clicked in play button coordinates, play selected game

    ; if esc key is pressed, return to main menu
    mov dh, 0
    mov dl, 45
    mov bh, 0
    mov ah, 2
    int 10h     
    
    lea dx, menuReturn
    mov ah, 9
    int 21h
              
    mov dl, 255
    mov ah, 6
    int 21h
    
    cmp al, 27
    je MainMenu 
    
    jmp InfoUpdate               
               
               
               
               


end start
