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

; v0.2
; TODO:
; > Fix mouse update
; > remove keyboard input in homescreen
 
 
data segment               
    btnTTT db "TicTacToe$"
    btnSnake db "Snake$"
    gameState db 0
    strEsc db "Press 'Esc' to return to main menu$"
    
    menuSelect db "Select a game below!$"
    
    gameLogo1 db "GGGGGGG                         $"
              db "GG    G                         $"
              db "GG      AAAAA EEEEE MMMMMM SSSSS$"
              db "GG      AA  A EE    MM M M SS   $"  ;33
              db "GG  GGG AA  A EEEE  MM M M SSSSS$"
              db "GG    G AAAAA EE    MM M M     S$"
              db "GG    G AA  A EE    MM   M     S$"
              db "GGGGGGG AA  A EEEEE MM   M SSSSS$"
                                                 
    gameLogo2 db "RRRRR                                 $"
              db "RR  RR                                $"
              db "RR  RR  EEEE   CCCCC   OOOOOO  N NNNN $"
              db "RR RR  EE  EE CCC  CC OOO  OOO NNNNNNN$"
              db "RRRR   EE  EE CC      OO    OO NN   NN$"
              db "RRRR   EEEEE  CC      OO    OO NN   NN$"
              db "RR RR  EE     CCC  CC OOO  OOO NN   NN$"
              db "RR  RR  EEEE   CCCCC   OOOOOO  NN   NN$"
              db "  G  A  M  E     L  I  B  R  A  R  Y  $"
              
                                                 
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
    
    mov si, 0
    mov cl, 2
    ShowGameLogo:
        mov dh, cl
        mov dl, 1
        mov bh, 0
        mov ah, 2
        int 10h    
    
        lea dx, gameLogo2[si]
        mov ah, 9
        int 21h
        
        inc cl
        add si, 39
        cmp cl, 10
        jle ShowGameLogo
    
    
    ; Show instruction
    mov dh, 13
    mov dl, 7
    mov bh, 0
    mov ah, 2
    int 10h
    
    lea dx, menuSelect
    mov ah, 9
    int 21h
    
    
    
    ; Show Tic-Tac-Toe button
    mov dh, 17
    mov dl, 16
    mov bh, 0
    mov ah, 2
    int 10h
        
    lea dx, btnTTT
    mov ah, 9
    int 21h
    
    ; Show snake button
    mov dh, 20
    mov dl, 16
    mov bh, 0
    mov ah, 2
    int 10h
    
    lea dx, btnSnake
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
        je UsingMouse
        
        
        ; update selection arrow
                    
        jmp Update
    
ends



UsingMouse:
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
    
    mov gameState, 1
    
    ; tictactoe button
    cmp dx, 104d    ; 68h
    jl ShowInfo
               
       
       
    ; errortrap: right-hand side of snake button
    cmp cx, 168d    ; a8h
    jg Update
    
    mov gameState, 2
    
    ; snake button
    cmp dx, 136d    ; 88h
    jge ShowInfo


    jmp Update

   
   
   
   
   
UsingKeyboard:
    ; if W key is pressed, tic-tac-toe button will be selected(focused)
    cmp al, 119
    je SelectTicTacToe
    
    ; if S key is pressed, snake button will be selected(focused)
    cmp al, 115
    je SelectSnake
    
    ; if enter key is pressed,
    cmp al, 13
    je ShowInfo 

    jmp Update


ShowInfo:
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
    
    ; display game description/features/controls/bugs here
    
    jmp InfoUpdate


InfoSnake:
    lea dx, btnSnake
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
    
    lea dx, strEsc
    mov ah, 9
    int 21h
              
    mov dl, 255
    mov ah, 6
    int 21h
    
    cmp al, 27
    je MainMenu 
    
    jmp InfoUpdate               
               
               
               
               
SelectTictactoe:
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
