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
    prompt_x db "(x) Column: $"
    prompt_y db 10,13,"(y) Row:    $"
    column db 0
    row db 0
ends

code segment
start:
    mov ax, data
    mov ds, ax

    ; set video mode to 80x25
    mov al, 03h
    mov ah, 0
    int 10h
    
    ; display mouse cursor
    mov ax, 1
    int 33h
    
    ; shows the 9x9 grid
    call drawgrid
 
 
 
autocheck:
    ; get mouse positionn in pixels
    mov ax, 3
    int 33h

    ; if left mouse button is pressed
    cmp bx, 00000001b
    je checkrow
    
    

    jmp autocheck
                 
                 
                 
    ; exit to operating system.
    mov ax, 4c00h 
    int 21h    
ends





checkrow:
; error trap: mouse click outside of 9x9 grid
    ; 00c8h = 200d
    cmp cx, 200
    jl autocheck

    ; 01afh = 431d    
    cmp cx, 431 
    jg autocheck

    ; 0018h - 24d
    cmp dx, 24
    jl autocheck
    
    ; 00b8h = 184d
    cmp dx, 184
    jg autocheck 

         
         
; 0088h = 136d
    mov row, 2
    cmp dx, 136
    jg checkcolumn
  
; 0050h = 80d
    mov row, 1
    cmp dx, 80
    jg checkcolumn
    
; 0018h = 24d
    mov row, 0
    cmp dx, 24
    jg checkcolumn

      
      
      
checkcolumn:
; 0167h = 359d
    mov column, 2
    cmp cx, 359
    jg draw 

; 0117h = 279d
    mov column, 1
    cmp cx, 279
    jg draw

; 00c8h = 200d
    mov column, 0
    cmp cx, 200
    jg draw




draw:
    mov dh, 0 ; row
    mov dl, 0 ; column
    mov bh, 0
    mov ah, 2
    int 10h
    
    lea dx, prompt_x
    mov ah, 9
    int 21h
    
    add column, 48
    mov dl, column
    mov ah, 2    
    int 21h
    
    lea dx, prompt_y
    mov ah, 9
    int 21h
    
    add row, 48
    mov dl, row
    mov ah, 2  
    int 21h
    
    jmp autocheck
    
    
    
    
    

proc drawgrid
    xor bx, bx
    mov si, 2    
    createvertical:
        inc si
        mov bx, si
             
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
        jl createvertical     
    
    
    
    
    
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
endp drawgrid





end start 
