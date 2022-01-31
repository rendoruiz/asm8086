;v4: Redefined Logic

;body length generation mechanism
;modify the trail accordingly to the length of snake
;by adding or subtracting the value of length
;to the x and y trails

data segment
    x_cpos db 40
    y_cpos db 13
    x_trail db 100 dup (0)
    y_trail db 100 dup (0)
    length_max db 2
    
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    
    ;sets video mode
    mov al, 03h
    mov ah, 0
    int 10h 

    ;hides blinking cursor
    mov ch, 32
    mov ah, 1
    int 10h
    

    xor cx, cx
    mov cl, length_max
   
    mov bp, 0    
    
    mov cl, x_cpos
    mov x_trail[bp], cl
    mov cl, y_cpos
    mov y_trail[bp], cl
    dec x_trail  
           
           
           
update:
    
    ;current position of the head
    mov dh, y_cpos
    mov dl, x_cpos
    mov bh, 0
    mov ah, 2
    int 10h
    
    ;draws the head
    mov ah, 2
    mov dl, 219
    int 21h    
    



    mov dh, y_trail[bp]
    mov dl, x_trail[bp]
    mov bh, 0
    mov ah, 2
    int 10h
        
    ;draws TAIL
    mov ah, 2
    mov dl, 176
    int 21h 
    
    
    ;accepts input without echo and stores it in al
    mov ah, 00h
    int 16h
      
    
    ;stores the current position of the head for erasure
    xor bx, bx
    mov bl, y_cpos
    mov y_trail[bp], bl
    mov bl, x_cpos  ;
    mov x_trail[bp], bl ;    
    
    
    inc bp
    ;updates cursor position based on the input key(al)
    cmp al, 'w'
    je up
    cmp al, 's'
    je down
    cmp al, 'a'
    je left
    cmp al, 'd'
    je right
    
    
    
    mov ax, 4c00h ; exit to operating system.
    int 21h




;moves the cursor position upward
;if y_axis is greater than 0    
up: 
    cmp y_cpos, 0
    jle update 
    
    dec y_cpos
    jmp update


;moves the cursor position downward    
down:
    inc y_cpos
    jmp update


;moves the cursor position to the left
;if x_axis is greater than 0    
left:
    cmp x_cpos, 0
    jle update
    
    dec x_cpos
    jmp update


;moves the cursor position to the right
right:
    inc x_cpos
    jmp update




ends



end start ; set entry point and stop the assembler.
