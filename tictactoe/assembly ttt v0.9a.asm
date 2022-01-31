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

; Tic Tac Toe
; Alpha v0.9: Code Overhaul #2

; [Queued] Score board

; [Queued] Clear Function: 
;       Resets: scored
;               circle_(line)
;               cross_(line)
;               row0,1,2
;               count_completion
;               mouse_input

; [Queued] Reset Function:
;       Clear Function including point_element/player         





data segment
    
    str_menu db " [Restart]  [Clear]  Auto-Clear: $"
    str_autoclear db "[Off]", "[On]"
    autoclear db 0  ; 0 - Off / 1 - On
    
    column db 0
    row db 0
    
    ;str_x db "(x) Column: $"
    ;str_y db " | (y) Row: $"
    
    
    ;circle_completion db 8 dup(0)  ;horizontal/vertical/diagonal
    circle_horizontal db 3 dup(0)
    circle_vertical db 3 dup(0)
    circle_diagonal db 3 dup(0) 
    
    ;cross_completion db 8 dup(0)  ;horizontal/vertical/diagonal
    cross_horizontal db 3 dup(0)
    cross_vertical db 3 dup(0)
    cross_diagonal db 3 dup(0)          
              
              
    ;boardrow(num)          
    row0 db 3 dup(0)
    row1 db 3 dup(0)
    row2 db 3 dup(0)
     
    
    count_circle db 0    
    count_cross db 0
    
    count_completion db 0
           
    str_circle db "O: $"
    str_cross db " | X: $"       
    point_circle db 48
    point_cross db 48       
     
     
    scored db 0 
     
    ;str_status db "Loading . . .$", "Restarting . . .$", "Clearing . . .$"
    str_loading db "Loading . . .$"
    str_restarting db "Restarting . . .$"
    str_clearing db "Clearing . . .$"       
               
    ;pixelcoordinates_xy db 2 dup(0) ;column/row           
    position_column db 0
    position_row db 0
               
    ;draw_circle db "  OOOOO  $", " OO   OO $", "OO     OO$"
    circle_a db "  OOOOO  $"
    circle_b db " OO   OO $"
    circle_c db "OO     OO$"
             
    ;draw_cross db "XXX   XXX$", " XXX XXX $", "  XXXXX  $"
    cross_a db "XXX   XXX$"
    cross_b db " XXX XXX $"    
    cross_c db "  XXXXX  $"
    
    mouse_input db 0                              
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
    
    ; displays a load warning on top
    lea dx, str_loading
    mov ah, 9
    int 21h
    
    ; shows the 9x9 grid
    call drawgrid
 
    
    call menubar
 
update:
    ; get mouse positionn in pixels
    mov ax, 3
    int 33h

    ; if left mouse button is pressed
    mov mouse_input, 1
    cmp bx, 00000001b
    je verifyinputposition 
    
    ; if right mouse button is pressed
    mov mouse_input, 2    
    cmp bx, 00000010b
    je verifyinputposition    
    
    
    jmp update
                 
                 
    endprogram:             
    ; exit to operating system.
    mov ax, 4c00h 
    int 21h    
ends




proc menubar
    
    ; horizontal bar   
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
    
    
    ; menu buttons: restart & clear
    mov dh, 0
    mov dl, 0
    mov bh, 0
    mov ah, 2
    int 10h
    
    lea dx, str_menu
    mov ah, 9
    int 21h
    
    
    ; x & y position counter
    ;mov dh, 0
    ;mov dl, 53
    ;mov bh, 0
    ;mov ah, 2
    ;int 10h
    
    ;lea dx, str_x
    ;mov ah, 9
    ;int 21h
    
    ;add column, 48
    ;mov dl, column
    ;mov ah, 2    
    ;int 21h
    
    ;lea dx, str_y
    ;mov ah, 9
    ;int 21h
    
    ;add row, 48
    ;mov dl, row
    ;mov ah, 2  
    ;int 21h
       
            
            
            
    ; O & X Point Counter
    mov dh, 0
    mov dl, 30
    mov bh, 0
    mov ah, 2
    int 10h    
    
    lea dx, str_circle
    mov ah, 9
    int 21h
    
    mov dl, point_circle
    mov ah, 2
    int 21h
    
    lea dx, str_cross
    mov ah, 9
    int 21h
    
    mov dl, point_cross
    mov ah, 2
    int 21h
            
    ret
endp menubar




verifyinputposition:



; menu bar components
    cmp dx, 8
    jg verifyinputpositioncont
    
    ;98h = 152d
    cmp cx, 152
    jg update
    
    ;07h = 7d
    cmp cx, 7
    jl update 
     
     
    ;60h = 96d
    cmp cx, 96
    jg clear
    
    ;50h = 80d
    cmp cx, 80
    jl restart
    
    





    
    verifyinputpositioncont:
; ignores any input if a player has scored unless the board is cleared or restarted
    cmp scored, 0
    jne update    
    
    
        
; error trap: mouse click outside of 9x9 grid
    ; 00c8h = 200d
    cmp cx, 200
    jl update

    ; 01afh = 431d    
    cmp cx, 431 
    jg update

    ; 0018h - 24d
    cmp dx, 24
    jl update
    
    ; 00b8h = 184d
    cmp dx, 184
    jg update 
    
    
    
; game logic: there cannot be same consecutive inputs
    cmp mouse_input, 2
    je verifyinputcont
    
    ; prevents circle to be displayed 2 times consecutively
    inc count_circle
    cmp count_circle, 1
    jg update
    mov count_cross, 0
    
    jmp checkrow
     
     
    verifyinputcont:
    
    ; prevents cross to be displayed 2 times consecutively
    inc count_cross
    cmp count_cross, 1
    jg update
    mov count_circle, 0
               
    jmp checkrow




    
clear:
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
    
    lea dx, str_clearing
    mov ah, 9
    int 21h
    
    ;clear 3 rows using 0ah | int 10h
    
    
    call menubar

    jmp update

restart:
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
    
    lea dx, str_restarting
    mov ah, 9
    int 21h
    
    call menubar
    
    jmp update
    
    
    

checkrow:
; 0088h = 136d
mov si, 2
    mov position_row, 17 
    mov row, 2
    cmp dx, 136
    jg checkcolumn
  
; 0050h = 80d
mov si, 1
    mov position_row, 10  
    mov row, 1
    cmp dx, 80
    jg checkcolumn
    
; 0018h = 24d
mov si, 0
    mov position_row, 3 
    mov row, 0
    cmp dx, 24
    jg checkcolumn

      
      
      
checkcolumn:
; 0167h = 359d
mov di, 2
    mov position_column, 45
    mov column, 2
    cmp cx, 359
    jg checkgrid 

; 0117h = 279d
mov di, 1
    mov position_column, 35
    mov column, 1
    cmp cx, 279
    jg checkgrid

; 00c8h = 200d
mov di, 0
    mov position_column, 25
    mov column, 0
    cmp cx, 200
    jg checkgrid




; Game Logic: an input musn't be overwritten, box must be empty
; Game Logic: Diagonal Inputs
checkgrid:
    cmp row, 0
    je checkrow0
    
    cmp row, 1
    je checkrow1

    cmp row, 2
    je checkrow2


    checkrow0:
        cmp row0[di], 1
        je checkgrid_adjust
        
        mov row0[di], 1
        
        call checkgrid_input
        
        
        ;diagonal
        jmp row0diagonal
        endrow0diagonal:    
        
        jmp draw
        
        
        row0diagonal:
            cmp mouse_input, 1
            jne rerow0diagonal    
            
            cmp di, 0
            jne re0diagonal
            inc circle_diagonal[0]
            jmp endrow0diagonal
            
            re0diagonal:
            cmp di, 2
            jne endrow0diagonal
            inc circle_diagonal[1]
            
            jmp endrow0diagonal
        
        rerow0diagonal:
            cmp di, 0
            jne re0diagonal2:
            inc cross_diagonal[0]
            jmp endrow0diagonal
            
            re0diagonal2:
            cmp di, 2
            jne endrow0diagonal
            inc cross_diagonal[1]
            
            jmp endrow0diagonal    
    
          
          
    checkrow1:
        cmp row1[di], 1
        je checkgrid_adjust    
        
        mov row1[di], 1
        
        call checkgrid_input
        
        
        ;diagonal
        jmp row1diagonal
        endrow1diagonal:        
        
        
        jmp draw
      
      
        row1diagonal:
            cmp mouse_input, 1
            jne rerow1diagonal    
            
            cmp di, 1
            jne endrow0diagonal
            inc circle_diagonal[0]
            inc circle_diagonal[1]
            jmp endrow1diagonal
        
        rerow1diagonal:
            cmp di, 1
            jne endrow0diagonal    
            inc cross_diagonal[0]
            inc cross_diagonal[1]
            jmp endrow0diagonal      
      
      
      
      
      
      
          
          
    checkrow2:
        cmp row2[di], 1
        je checkgrid_adjust    
        
        mov row2[di], 1
        
        call checkgrid_input
        
        
        ;diagonal
        jmp row2diagonal
        endrow2diagonal:        
        
        
        jmp draw
        
        
        
        row2diagonal:
            cmp mouse_input, 1
            jne rerow2diagonal    
            
            cmp di, 0
            jne re2diagonal
            inc circle_diagonal[1]
            jmp endrow2diagonal
            
            re2diagonal:
            cmp di, 2
            jne endrow2diagonal
            inc circle_diagonal[0]
            
            jmp endrow2diagonal
        
        rerow2diagonal:
            cmp di, 0
            jne re2diagonal2:
            inc cross_diagonal[1]
            jmp endrow2diagonal
            
            re2diagonal2:
            cmp di, 2
            jne endrow2diagonal
            inc cross_diagonal[0]
            
            jmp endrow2diagonal          
        
        
        
        
        
        
        

; fixes next mouse input    
checkgrid_adjust:
    cmp mouse_input, 1
    jne checkgrid_adustcont:
    dec count_circle
    jmp update
    
    checkgrid_adustcont:
    dec count_cross
    
    jmp update
      
      
; adds value to the elements for completion checking    
proc checkgrid_input
    
    cmp mouse_input, 1
    jne checkgrid_inputcont
    inc circle_horizontal[si]
    inc circle_vertical[di]
    ret
    
    checkgrid_inputcont:
    inc cross_horizontal[si]
    inc cross_vertical[di]
    ret
endp checkgrid_input

      
 
   
   
   
   
   

draw:
    ; adjustment to display the right ascii character
    add column, 48
    add row, 48
    
    
    call menubar
    
    ; draws circle if left mouse button is clicked    
    cmp mouse_input, 1    
    je drawcircle
    
    ; draws cross if right mouse button is clicked
    cmp mouse_input, 2    
    je drawcross    
           
    ; next point after drawing circle or cross
    redraw:       
    
    ; checks if either players has completed a line
    call checkcompletion
    
    
    
    jmp update
    



; Game Logic: a player wins after completing a line
proc checkcompletion
    mov si, 0
    checkvalues:
        cmp circle_horizontal[si], 3
        je endcircle
        
        cmp circle_vertical[si], 3
        je endcircle
        
        cmp circle_diagonal[si], 3
        je endcircle
        
        cmp cross_horizontal[si], 3
        je endcross
        
        cmp cross_vertical[si], 3
        je endcross
        
        cmp cross_diagonal[si], 3
        je endcross
        
    inc si
    cmp si, 3
    jne checkvalues
    
    ret
    
    
    ;currently displays the score on the menu bar
    endcircle:
        inc point_circle
        inc scored
        call menubar                                   
        
        ;freeze game/disable further inputs to the grid
    ret
    
    endcross:
        inc point_cross
        inc scored
        call menubar
        
        ;freeze game/disable further inputs to the grid
    ret    
    
                         
endp checkcompletion 



          


           
           
           
drawcircle:
    xor cx, cx
    mov cl, position_row
    
    call drawcircle_a
    inc cl
    call drawcircle_b
    inc cl
    call drawcircle_c
    inc cl       
    call drawcircle_c
    inc cl
    call drawcircle_b
    inc cl        
    call drawcircle_a
    
    jmp redraw  
          
          
proc drawcircle_a
    mov dh, cl
    mov dl, position_column
    mov bh, 0
    mov ah, 2
    int 10h

    lea dx, circle_a
    mov ah, 9
    int 21h

    ret
endp drawcircle_a    
                                    
                    
proc drawcircle_b
    mov dh, cl
    mov dl, position_column
    mov bh, 0
    mov ah, 2
    int 10h

    lea dx, circle_b
    mov ah, 9
    int 21h

    ret
endp drawcircle_b 
                
        
proc drawcircle_c
    mov dh, cl
    mov dl, position_column
    mov bh, 0
    mov ah, 2
    int 10h

    lea dx, circle_c
    mov ah, 9
    int 21h
    
    ret
endp drawcircle_c   
   


   
   
drawcross:
    
    xor cx, cx
    mov cl, position_row

    call drawcross_a
    inc cl
    call drawcross_b
    inc cl
    call drawcross_c
    inc cl       
    call drawcross_c
    inc cl
    call drawcross_b
    inc cl        
    call drawcross_a

    jmp redraw
    
    
proc drawcross_a
    mov dh, cl
    mov dl, position_column
    mov bh, 0
    mov ah, 2
    int 10h

    lea dx, cross_a
    mov ah, 9
    int 21h

    ret
endp drawcross_a    
                                    
                    
proc drawcross_b
    mov dh, cl
    mov dl, position_column
    mov bh, 0
    mov ah, 2
    int 10h

    lea dx, cross_b
    mov ah, 9
    int 21h

    ret
endp drawcross_b 
                
        
proc drawcross_c
    mov dh, cl
    mov dl, position_column
    mov bh, 0
    mov ah, 2
    int 10h

    lea dx, cross_c
    mov ah, 9
    int 21h
    
    ret
endp drawcross_c 
   
   
   
   
   
   
    

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
