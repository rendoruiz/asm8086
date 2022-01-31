

data segment                   
    MENU_strButtons db "Tic-Tac-Toe$", "Snake$"
    temp db 4 dup (0)
ends

start:
    mov ax, data
    mov ds, ax

    
    ; display mouse cursor
    mov ax, 1
    int 33h
    
    ; initialize menu components
    call MENU_Initialize
    


    MENU_Update:
    
        ; get mouse position (in pixels, 1 character = 8 pixels)
        mov ax, 3
        int 33h        
    
    
    
    jmp MENU_Update

    

ends





proc MENU_Initialize 

    ; set video mode to 40x25
    mov al, 00h
    mov ah, 0
    int 10h    
    
    xor cx, cx
    
    
    ; Button Names
    mov ch, 10
    mov cl, 14
    mov si, 0
    MENU_Initialize_1:
        mov dh, ch ; row
        mov dl, cl ; column
        mov bh, 0
        mov ah, 2
        int 10h     
        
        lea dx, MENU_strButtons[si]
        mov ah, 9
        int 21h
        
        mov ch, 17
        mov cl, 17
        add si, 12
        
        cmp si, 12
        jle MENU_Initialize_1
        
     
        
    ; Vertical Lines
    mov bl, 9
    mov si, 0 
    mov di, 3
    createvertical:

        
        ; left vertical line generation      
        mov dh, bl ; row
        mov dl, 11 ; column
        mov bh, 0
        mov ah, 2
        int 10h
        
        mov al, 179 ; ascii character
        mov bh, 0
        mov cx, 1 ; display amount
        mov ah, 0ah
        int 10h
           
           
        ; right vertical line generation 
        mov dh, bl ; row
        mov dl, 27 ; column
        mov bh, 0
        mov ah, 2
        int 10h
        
        mov al, 179 ; ascii character
        mov bh, 0
        mov cx, 1 ; display amount
        mov ah, 0ah
        int 10h
        
        inc si
        inc bl
        cmp si, di
        jl createvertical
        
        add bl, 4
        mov si, 0
        cmp bl, 17
        jl createvertical 
       
    
    ; Horizontal Lines
    ; upper horizontal line generation
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
    ret
endp MENU_Initialize


end start
