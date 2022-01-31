; tic tac toe

data segment
    ; add your data here!
    pkey db "press any key...$"
    column db 0
    row db 0
    column_coord db 3,10,18
    row_coord db 2,15,27 
    
    o_sign db " OOOOO"
           db 10,13,"OO   OO"
           db 10,13,"O     O"
           db 10,13,"OO   OO"
           db 10,13," OOOOO$"
    x_sign db "XX   XX",10,13," XX XX",10,13,"  XXX",10,13," XX XX",10,13,"XX   XX$"

    
ends


code segment
start:
    mov ax, data
    mov ds, ax
    mov es, ax
    
    ; set video mode to 80x25
    mov al, 00h
    mov ah, 0
    int 10h
    
    ; display mouse cursor
    mov ax, 1
    int 33h
   

    call drawgrid

    
autocheck:
    ; gets mouse position
    mov ax, 3
    int 33h
    
    ; si = row
    ; di = column
    
    
    ; checks if left mouse button is clicked
    cmp bx, 00000001b
    je clicked
    
    jmp autocheck
       
       
           
          
    ; exit to operating system.
    mov ax, 4c00h
    int 21h    
ends


; row check pass
clicked:
    cmp dl, 64
    jl checkrow0  

    cmp dl, 128
    jl checkrow1 
     
    cmp dl, 136
    jg checkrow2
    
      
    ;jmp autocheck

  
  
; pass row value
checkrow0:
    mov si, 0
    jmp checkcolumn

checkrow1:
    mov si, 1
    jmp checkcolumn

checkrow2:
    mov si, 2
    jmp checkcolumn
      
      

; column check pass
checkcolumn:
    cmp cl, 104
    jl column0

    cmp cl, 200
    jl column1

    cmp cl, 208
    jg column2
             
             

; pass column value
column0:
    mov di, 0
    jmp draw_x

column1:
    mov di, 1
    jmp draw_x

column2:
    mov di, 2
    jmp draw_x
    
    

draw_x:
    mov bp 0
    mov dh, row_coord[di] + 1
    mov dl, column_coord[si]
    mov bh, 0
    mov ah, 2
    int 10h
        
    lea dx, x_sign
    mov ah, 9
    int 21h
    
    jmp autocheck

    

proc drawgrid  
    
    mov dh, 8 ; row
    mov dl, 2 ; column
    mov bh, 0
    mov ah, 2
    int 10h
    
    mov al, 35 ; ascii character
    mov bh, 0
    mov cx, 35 ; display amount
    mov ah, 0ah
    int 10h        


    mov dh, 16 ; row
    mov dl, 2 ; column
    mov bh, 0
    mov ah, 2
    int 10h
    
    mov al, 35 ; ascii character
    mov bh, 0
    mov cx, 35 ; display amount
    mov ah, 0ah
    int 10h 

         
    xor bx, bx
    mov si, 0    
    createvertical:
        inc si
        mov bx, si
             
        mov dh, bl ; row
        mov dl, 13 ; column
        mov bh, 0
        mov ah, 2
        int 10h
        
        mov al, 35 ; ascii character
        mov bh, 0
        mov cx, 1 ; display amount
        mov ah, 0ah
        int 10h 
    
    
        mov dh, bl ; row
        mov dl, 25 ; column
        mov bh, 0
        mov ah, 2
        int 10h
        
        mov al, 35 ; ascii character
        mov bh, 0
        mov cx, 1 ; display amount
        mov ah, 0ah
        int 10h
        
        cmp si, 23
        jl createvertical 

    ret
endp drawgrid


end start
