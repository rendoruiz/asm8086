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

data segment
    snake_body db 100 dup(0)
    snake_x db 100 dup(0) ; column | dl
    snake_y db 100 dup(0) ; row    | dh
    head_direction db 0     ; 1 - north, 2 - south, 3 - east, 4 - west
    head_x db 0
    head_y db 0
    
    snake_length db 1
    
    str_north db "North!$"
    str_south db "South!$"
    str_east db "East!$"
    str_west db "West!$"
    
    startposition_column db 39      
    startposition_row db 12
   
ends


code segment
start:
    mov ax, data
    mov ds, ax

    ; set video mode to 80x25
    mov al, 03h
    mov ah, 0
    int 10h 

    ; hide mouse pointer
    mov ax, 2
    int 33h
    
    ; snake head's starting position dh=12, dl=39 (center)
    mov dh, startposition_column
    mov dl, startposition_row
    mov bh, 0
    mov ah, 2
    int 10h    
    
; register starting position to snake head
;mov head_x, dh
;mov head_y, dl
    
    ; register s. p. to body head
    mov snake_x[0], dh
    mov snake_y[0], dl
    
;xor ax, ax
;mov al, snake_length
;mov si, cx

;mov snake_x[1], dh
;mov snake_y[1], dl
    
    
    
    ; set position of head on screen
    mov dh, snake_y[0]
    mov dl, snake_x[0] 
    mov bh, 0
    mov ah, 2
    int 10h  

    ; draw the head
    mov al, 219
    mov bh, 0
    mov bl, 9h
    mov cx, 1
    mov ah, 09h
    int 10h




    
Update:
    ; get keyboard input without buffer, skippable
    mov ah, 6
    mov dl, 255
    int 21h
    
    ; get keyboard input without buffer, unskippable
    ;mov ah, 00h                                    
    ;int 16h                                        
    
    
    cmp al, 119 ; W (north | up)
    je up 

    cmp al, 97  ; A (west | left)
    je left
    
    cmp al, 115 ; S (south | down)
    je down
    
    cmp al, 100 ; D (east | right)
    je right
       
       
       
       


    jmp Update
 
 
 
 
    
    
up: 
    call adjust_values
    dec snake_y[0]
    jmp Draw

down:
    call adjust_values
    inc snake_y[0]
    jmp Draw 
    
left:
    call adjust_values
    dec snake_x[0]
    jmp Draw
    
right:
    call adjust_values   
    inc snake_x[0]
    jmp Draw   
   
   

proc adjust_values
    xor ax, ax
    
    re_adjustvalues:
    
        mov al, snake_y[0]
        mov snake_y[1], al
        
        mov al, snake_x[0]
        mov snake_x[1], al
    
    
    ret    
endp adjust_values



Draw:
    ; mov snake head accordingly to x and y coordinates
    mov dh, snake_y[0]
    mov dl, snake_x[0] 
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
    
    ; position tail
    mov dh, snake_y[1]
    mov dl, snake_x[1] 
    mov bh, 0
    mov ah, 2
    int 10h 
    
    ; nullify tail
    mov al, 000
    mov bh, 0
    mov cx, 1
    mov ah, 0ah
    int 10h
    
    call adjust_values
    
    
    
    jmp Update
    
    
    
ends

end start
