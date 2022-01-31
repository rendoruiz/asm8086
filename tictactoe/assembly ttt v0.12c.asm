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
; Beta v0.13: Code Simplification

; To Do: 
; [Queued] Proper Code Documentation

; Instructions:
; > Left mouse click on the 9x9 board will display a circle
; > Right mouse click on the 9x9 board will display a cross
; > You cannot use the same mouse click(input) twice in a row
; > Forming a straight horizontal/vertical/diagonal line will pause the game
;   to continue playing, [Clear] must be pressed if auto-clear is turned off

; > Clicking on [Restart] will reset all elements on the game
; > Clicking on [Clear] will reset all elements on the game except for player score
; > Clicking on [Auto-Clear..] will toggle between on and off
; > When auto-clear is set to "on", the game will be [Clear]ed when a player scores



data segment
    
    str_status db "Loading . . .$", "Restarting . . .$", "Clearing . . .$" ;[0] - load | [14] - restart | [31] - clear 
    
    str_menu db " [Restart]  [Clear]  [Auto-Clear:$"
    
    
    str_autoclear db " Off]$", "  On]$" ;[0] - off | [6] - on
    str_clearing db "Clearing in $"
    countdown_autoclear db 0
    
    autocleartoggle db 1  ; 0 - Off / 1 - On 
    
    clear_row db 0
    clear_column db 0 
    
    mouse_input db 0
    
    consecutive_circle db 0
    consecutive_cross db 0
    
    hasscored db 0
    
    coordinate_row db 0
    coordinate_column db 0 
    
    
    boardrow0 db 3 dup(0)
    boardrow1 db 3 dup(0)
    boardrow2 db 3 dup(0)
    
    
    circle_horizontal db 3 dup(0)
    circle_vertical db 3 dup(0)
    circle_diagonal db 3 dup(0)
    
    cross_horizontal db 3 dup(0)
    cross_vertical db 3 dup(0)
    cross_diagonal db 3 dup(0)    
    
    
    score_circle db 48
    score_cross db 48
    
    
    circle db "  OOOOO  $", " OO   OO $", "OO     OO$"
    cross db "XXX   XXX$", " XXX XXX $", "  XXXXX  $"
    
    ; [0], [12], [24], [36] 
    scoreboard_circle db "   00000   $", "  0000000  $", " 000   000 $", "000     000$"
    scoreboard_cross db "XXX     XXX$", " XXX   XXX $", "  XXX XXX  $", "   XXXXX   $"
    str_score db "Score: $"
    
    
    pcRow db 0
    pcCol db 0
    pcAsc db 0
    pcAmt db 0
    pcStr db ""
ends


code segment
start:
    mov ax, data
    mov ds, ax
      
      
Initialize_TicTacToe:

    ; set video mode to 80x25
    mov al, 03h
    mov ah, 0
    int 10h

    ; display mouse cursor
    mov ax, 1
    int 33h

    ; displays a "loading" message on top
    lea dx, str_status[0]
    mov ah, 9
    int 21h

    ; shows the 9x9 grid
    call drawgrid
    
    ; shows the score board
    call scoreboard
    call update_score
    
    ; shows the menubar
    call menubar            
              
Update:
    ; get mouse position (in pixels, 1 character = 8 pixels)
    mov ax, 3
    int 33h    

    ; left mouse button is clicked
    mov mouse_input, 1
    cmp bx, 00000001b
    je verifyinput 
    
    ; right mouse button is clicked
    mov mouse_input, 2    
    cmp bx, 00000010b
    je verifyinput  


    jmp Update
    
ends
              
              
verifyinput:

; menu bar components
    cmp dx, 8
    jg re_verifyinput
    
    cmp cx, 303
    jg Update
    
    cmp cx, 7
    jl Update 
    
    ; auto-clear toggle
    cmp cx, 167
    jg btn_autoclear 
                   
    ; restart function
    cmp cx, 80
    jl btn_restart                   
    
    cmp cx, 151
    jg Update
                   
    ; clear function 
    cmp cx, 95
    jg btn_clear
    

        
re_verifyinput:
; any input on the board is ignored after a player scores, board must be clear to continue
    cmp hasscored, 0
    jne Update               
        
        
; error trap: ignores any mouse click outside of 9x9 board grid
    cmp cx, 200
    jl Update

    cmp cx, 431 
    jg Update

    cmp dx, 24
    jl Update
    
    cmp dx, 184
    jg Update 
           
           
; game logic: there cannot be same consecutive inputs
    cmp mouse_input, 2
    je verifymouseinput
    
    ; prevents circle to be displayed 2 times consecutively
    inc consecutive_circle
    cmp consecutive_circle, 1
    jg Update
    
    mov consecutive_cross, 0
    jmp check_row
     
    ; prevents cross to be displayed 2 times consecutively 
    verifymouseinput:
    inc consecutive_cross
    cmp consecutive_cross, 1
    jg Update
    
    mov consecutive_circle, 0           
    jmp check_row
   
           
   
   
check_row:   
    mov si, 2
        mov coordinate_row, 17 
        cmp dx, 136
        jg check_column
      
    mov si, 1
        mov coordinate_row, 10  
        cmp dx, 80
        jg check_column
        
    mov si, 0
        mov coordinate_row, 3 
        cmp dx, 24
        jg check_column


check_column:
    mov di, 2
        mov coordinate_column, 45
        cmp cx, 359
        jg check_grid 

    mov di, 1
        mov coordinate_column, 35
        cmp cx, 279
        jg check_grid
    
    mov di, 0
        mov coordinate_column, 25
        cmp cx, 200
        jg check_grid  
 
    
    
; game logic: an input musn't be overwritten, box must be empty
; game logic: Diagonal Inputs    
check_grid: 
    cmp si, 0
    je check_boardrow0
    
    cmp si, 1
    je check_boardrow1

    cmp si, 2
    je check_boardrow2 
 
 
    check_boardrow0:
        cmp boardrow0[di], 1
        je adjust_mouseinput
 
        mov boardrow0[di], 1
        call add_horiverticalpoint
        
        jmp boardrow0_diagonalpoint
        endrow0:
        
        jmp Draw
          
          
    check_boardrow1:
        cmp boardrow1[di], 1
        je adjust_mouseinput
        
        mov boardrow1[di], 1
        call add_horiverticalpoint
        
        jmp boardrow1_diagonalpoint
        endrow1:
        
        jmp Draw
    
    
    check_boardrow2:
        cmp boardrow2[di], 1
        je adjust_mouseinput
        
        mov boardrow2[di], 1
        call add_horiverticalpoint
        
        jmp boardrow2_diagonalpoint
        endrow2:
        
        jmp Draw









; boardrow0 - circle point adjustment
boardrow0_diagonalpoint:
    cmp mouse_input, 1
    jne re_boardrow0_diagonal
    
    cmp di, 0
    jne row0_diagonal1
    
    inc circle_diagonal[0]
    jmp endrow0
    
    row0_diagonal1:
        cmp di, 2
        jne endrow0
        
        inc circle_diagonal[1]
        jmp endrow0
    
    ; boardrow0 - cross point adjustment
    re_boardrow0_diagonal:
        cmp di, 0
        jne row0_diagonal2
            
        inc cross_diagonal[0]
        jmp endrow0
        
        row0_diagonal2:
        cmp di, 2
        jne endrow0
        
        inc cross_diagonal[1]
        jmp endrow0
        
    
    
    
; boardrow1 - circle point adjustment    
boardrow1_diagonalpoint:
    cmp mouse_input, 1
    jne re_boardrow1_diagonal

    cmp di, 1
    jne endrow1
    
    inc circle_diagonal[0]
    inc circle_diagonal[1]
    jmp endrow1

    ; boardrow1 - cross point adjustment
    re_boardrow1_diagonal:
        cmp di, 1
        jne endrow1
        
        inc cross_diagonal[0]
        inc cross_diagonal[1]
        jmp endrow1

         
         
         
; boardrow2 - circle point adjustment          
boardrow2_diagonalpoint:
    cmp mouse_input, 1
    jne re_boardrow2_diagonal
    
    cmp di, 0
    jne row2_diagonal1
    
    inc circle_diagonal[1]
    jmp endrow2
    
    row2_diagonal1:
        cmp di, 2
        jne endrow2
        
        inc circle_diagonal[0]
        jmp endrow2

    ; boardrow2 - cross point adjustment
    re_boardrow2_diagonal:
        cmp di, 0
        jne row2_diagonal2
        
        inc cross_diagonal[1]
        jmp endrow2
        
        row2_diagonal2:
            cmp di, 2
            jne endrow2
            
            inc cross_diagonal[0]
            jmp endrow2


 
      
adjust_mouseinput:
    cmp mouse_input, 1 
    jne re_adjust_mouseinput
    
    dec consecutive_circle
    jmp update
    
    re_adjust_mouseinput:
        dec consecutive_cross
        jmp update      
      
      
      
proc add_horiverticalpoint
    cmp mouse_input, 1
    jne re_add_horiverticalpoint
    
    inc circle_horizontal[si]
    inc circle_vertical[di]
    ret
    
    re_add_horiverticalpoint:
        inc cross_horizontal[si]
        inc cross_vertical[di]   
        ret
endp add_horiverticalpoint      
 
 
 
 
 
Draw:
    call menubar
    
    cmp mouse_input, 1
    je draw_circle
    
    cmp mouse_input, 2
    je draw_cross 
 
    ret_draw:
    call check_completion
    
    jmp Update
    
    



proc check_completion
    mov si, 0
    re_checkvalues:
        cmp circle_horizontal[si], 3
        je addpoint_circle
        
        cmp circle_vertical[si], 3
        je addpoint_circle
        
        cmp circle_diagonal[si], 3
        je addpoint_circle
        
        cmp cross_horizontal[si], 3
        je addpoint_cross
        
        cmp cross_vertical[si], 3
        je addpoint_cross
        
        cmp cross_diagonal[si], 3
        je addpoint_cross

    inc si
    cmp si, 3
    jne re_checkvalues
    ret
              
       
    addpoint_circle:       
        inc score_circle
        inc hasscored
        call update_score
        call autoclear
        ret       
                  
    addpoint_cross:
        inc score_cross
        inc hasscored
        call update_score
        call autoclear          
        ret

endp checkcompletion

            
            
            
            
            
            
            
            


  
           
           
           
           
           
           
           
           
           
           
           
           
           
draw_circle:
    mov si, 0
    xor cx, cx
    mov cl, coordinate_row
    
    drawcircle_upper:
        mov dh, cl
        mov dl, coordinate_column
        mov bh, 0
        mov ah, 2
        int 10h    
        
        lea dx, circle[si]
        mov ah, 9
        int 21h       
        
        add si, 10
        inc cl
        
        cmp si, 20
        jle drawcircle_upper
        sub si, 10
    
    drawcircle_lower:
        mov dh, cl
        mov dl, coordinate_column
        mov bh, 0
        mov ah, 2
        int 10h     
    
        lea dx, circle[si]
        mov ah, 9
        int 21h    
        
        sub si, 10
        inc cl
        
        cmp si, 0
        jge drawcircle_lower
        
    jmp ret_draw

  
    
draw_cross:
    mov si, 0
    xor cx, cx
    mov cl, coordinate_row
    
    drawcross_upper:
        mov dh, cl
        mov dl, coordinate_column
        mov bh, 0
        mov ah, 2
        int 10h    
        
        lea dx, cross[si]
        mov ah, 9
        int 21h       
        
        add si, 10
        inc cl
        
        cmp si, 20
        jle drawcross_upper
        sub si, 10
    
    drawcross_lower:
        mov dh, cl
        mov dl, coordinate_column
        mov bh, 0
        mov ah, 2
        int 10h     
    
        lea dx, cross[si]
        mov ah, 9
        int 21h    
        
        sub si, 10
        inc cl
        
        cmp si, 0
        jge drawcross_lower
        
    jmp ret_draw    
    
    
    
    
 


; auto clear toggle button
proc toggle_autoclear
    cmp autocleartoggle, 0
    jne showontoggle
    
    lea dx, str_autoclear[0]
    mov ah, 9
    int 21h
    ret
    
    showontoggle:
    lea dx, str_autoclear[6]
    mov ah, 9
    int 21h
    ret
endp toggle_autoclear
   
      
      


  
  
  
     
btn_restart:
    ; positions cursor to uppermost-left corner
    
    mov dh, 0
    mov dl, 0
    mov bh, 0
    mov ah, 2
    int 10h
    
    ; clears the menu bar
    mov al, 000
    mov bh, 0
    mov cx, 79
    mov ah, 0ah
    int 10h
    
    ; displays "restart" message in menu bar
    lea dx, str_status[14]
    mov ah, 9
    int 21h
    
            
    mov score_circle, 48
    mov score_cross, 48
    
    call update_score        
    
    ; jumps to clear function
    jmp restart
        
        
btn_autoclear:
    call btn_autocleartoggle
    call menubar
    jmp Update
       
       
proc btn_autocleartoggle
    cmp autocleartoggle, 0
    jne toggleoff
    mov autocleartoggle, 1
    ret

    toggleoff:
    mov autocleartoggle, 0    
    ret
endp btn_autocleartoggle
              
              
proc autoclear
    cmp autocleartoggle, 0
    je skip_autoclear 
    mov countdown_autoclear, 57
    mov si, 9
    update_autoclear:
    
        mov dh, 0
        mov dl, 45
        mov bh, 0
        mov ah, 2
        int 10h    
        
        lea dx, str_clearing
        mov ah, 9
        int 21h    
        
        mov dl, countdown_autoclear
        mov ah, 2
        int 21h
        
        dec countdown_autoclear
        dec si
        
        cmp si, 0
        jge update_autoclear
        
    jmp btn_clear
    skip_autoclear:        
    ret    
endp autoclear

  
  
  
  
  
  



















btn_clear:
    ; clears menu bar
    mov pcRow, 0
    mov pcCol, 0
    mov pcAsc, 000
    mov pcAmt, 79
    call printAscii
    
    ; displays "clear" message in menu bar
    lea dx, str_status[31]
    mov ah, 9
    int 21h
    
    
restart:    
    ; resets all variables except for score
    mov hasscored, 0
    mov mouse_input, 0
    mov consecutive_circle, 0
    mov consecutive_cross, 0
    
    mov si, 0
    re_clear:
        mov boardrow0[si], 0
        mov boardrow1[si], 0
        mov boardrow2[si], 0
        
        mov circle_horizontal[si], 0
        mov circle_vertical[si], 0
        mov circle_diagonal[si], 0
        
        mov cross_horizontal[si], 0
        mov cross_vertical[si], 0
        mov cross_diagonal[si], 0
        
        inc si
        cmp si, 2
        jle re_clear
        
       
    ; clears the whole board
    mov clear_row, 3 
    mov clear_column, 25
    
    clear_boardrow1:
        call clear_area ;clear_column +10, after call
        call clear_area
        call clear_area
        
        sub clear_column, 30        
            
        inc clear_row   
        cmp clear_row, 9
        jne clear_boardrow1
        
        inc clear_row
        
    clear_boardrow2:
        call clear_area
        call clear_area
        call clear_area
        
        sub clear_column, 30     
            
        inc clear_row    
        cmp clear_row, 16         
        jne clear_boardrow2
        
        inc clear_row
        
    clear_boardrow3:
        call clear_area
        call clear_area
        call clear_area
        
        sub clear_column, 30     
            
        inc clear_row    
        cmp clear_row, 23         
        jne clear_boardrow3              
    
    
    call menubar
    jmp Update
     
proc clear_area
    mov dh, clear_row
    mov dl, clear_column
    mov bh, 0
    mov ah, 2
    int 10h         
         
    mov al, 000
    mov bh, 0
    mov cx, 9
    mov ah, 0ah
    int 10h
    
    add clear_column, 10
    ret    
endp clear_area


  
  
  
  
          
          
          
          
          
          
          
          
          
          
          
         
          
          
proc update_score
    mov pcRow, 16
    mov pcCol, 15
    call setPosition
    
    mov dl, score_circle
    mov ah, 2
    int 21h
    
    mov pcCol, 71
    call setPosition    
    
    mov dl, score_cross
    mov ah, 2
    int 21h
    
    ret
endp update_score







proc scoreboard
    mov si, 0
    mov pcRow, 7
    
    scoreboard_up:
        mov pcCol, 6 
        call setPosition
        
        lea dx, scoreboard_circle[si]
        mov ah, 9
        int 21h
        
        mov pcCol, 62
        call setPosition
        
        lea dx, scoreboard_cross[si]
        mov ah, 9
        int 21h
        
        add si, 12
        inc pcRow
        
        cmp si, 36
        jle scoreboard_up
        sub si, 12
    
    scoreboard_low:
        mov pcCol, 6 
        call setPosition    
    
        lea dx, scoreboard_circle[si]
        mov ah, 9
        int 21h    

        mov pcCol, 62
        call setPosition      
        
        lea dx, scoreboard_cross[si]
        mov ah, 9
        int 21h 
        
        sub si, 12
        inc pcRow
        
        cmp si, 0
        jge scoreboard_low
           
    ; "Score: " 
    mov pcRow, 16 
    mov pcCol, 7     
    strscore:
        call setPosition       
        
        lea dx, str_score
        mov ah, 9
        int 21h
        
        add pcCol, 56
        cmp pcCol, 63
        je strscore 
                
    ret    
endp scoreboard            
          
          
          
  
  
  
proc menubar
    ; displays horizontal bar 
    mov pcRow, 1
    mov pcCol, 0
    mov pcAsc, 205
    mov pcAmt, 80 
    call printAscii
    
    ; displays menu buttons: restart, clear, & auto-clear toggle
    mov pcRow, 0
    mov pcCol, 0
    call setPosition
    
    lea dx, str_menu
    mov ah, 9
    int 21h
    
    call toggle_autoclear
            
    ret
endp menubar  
  
  
   
   
proc drawgrid
    mov pcRow, 3 
    mov pcAsc, 179
    mov pcAmt, 1
    createvertical:
        ; left vertical line generation
        mov pcCol, 34
        call printAscii
        
        ;right vertical line generation
        mov pcCol, 44
        call printAscii        
        
        inc pcRow
        cmp pcRow, 23
        jl createvertical
        
        
    ; upper horizontal line generation
    mov pcRow, 9
    mov pcCol, 25
    mov pcAsc, 196
    mov pcAmt, 29 
    call printAscii
    
    ; lower horizontal line generation
    mov pcRow, 16
    call printAscii 
    
    ret
endp drawgrid   
   

 

 

proc setPosition
    mov dh, pcRow ; row
    mov dl, pcCol ; column
    mov bh, 0
    mov ah, 2
    int 10h
    
    ret
endp setPosition    
           
           
proc printAscii
    xor ax, ax
    mov al, pcAmt
    mov bp, ax

    mov dh, pcRow ; row
    mov dl, pcCol ; column
    mov bh, 0
    mov ah, 2
    int 10h
            
    mov al, pcAsc ; ascii character
    mov bh, 0
    mov cx, bp ; display amount
    mov ah, 0ah
    int 10h  
    
    ret    
endp printAscii
           

          
end start 
