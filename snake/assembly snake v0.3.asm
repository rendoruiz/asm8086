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

; Snake (Alpha v0.3): auto-movement
 
data segment
    ;snake_body db 100 dup(0)
    snake_x db 100 dup(0) ; column | dl
    snake_y db 100 dup(0) ; row    | dh
    snake_length db 4                    
    
    head_direction db 0     ; 1 - north, 2 - south, 3 - east, 4 - west    
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

;initialize snake body
    call initialize_snakebody
    
Update:
    ; get keyboard input without buffer, skippable
    mov ah, 6
    mov dl, 255
    int 21h
    
    cmp al, 119 ; W (north | up)
    je up 

    cmp al, 97  ; A (west | left)
    je left
    
    cmp al, 115 ; S (south | down)
    je down
    
    cmp al, 100 ; D (east | right)
    je right
               
               
    jmp autoupdate
    
    ;cmp mouse pos is food
    
    jmp Update
 
autoupdate:
    cmp head_direction, 0
    je Update
    
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
    jmp Draw

down:
    mov head_direction, 2
    call adjust_values
    inc snake_y[0]
    jmp Draw 
    
left:
    mov head_direction, 3
    call adjust_values
    dec snake_x[0]
    jmp Draw
    
right:
    mov head_direction, 4
    call adjust_values   
    inc snake_x[0]
    jmp Draw   
   
   

proc adjust_values
; adjust head and body loop, using snake_length as last val
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

     
Draw:

; mov head and body loop, using snake_length as last val
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
    
    jmp Update
    
    
ends


proc initialize_snakebody
; draw head only
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
        
        cmp snake_length, 2
        jl Update
        
        cmp si, di
        jl re_initialize_snakebody

    ret
endp initialize_snakebody 

end start
