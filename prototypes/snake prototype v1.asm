;head mechanism
;working on tail mechanism

data segment
    x_axis db 0
    y_axis db 0
    x_trail db 0
    y_trail db 0
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax

update:
    xor ax, ax


 
    
    
    ;current position of the head
    mov dh, y_axis
    mov dl, x_axis
    mov bh, 0
    mov ah, 2
    int 10h
    
    ;draws the head
    mov ah, 2
    mov dl, 176
    int 21h    
    
    
    
    ;last position of the head
    mov dh, y_trail
    mov dl, x_trail
    mov bh, 0
    mov ah, 2
    int 10h
        
    ;draws erasure
    mov ah, 2
    mov dl, 31
    int 21h
    
    
    
    ;for accuracy
    xor ax, ax
    
    ;hides blinking cursor
    mov ch, 32
    mov ah, 1
    int 10h
    
    ;accepts input without echo and stores it in al
    mov ah, 00h
    int 16h
      
    
    
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




    
up: 
    xor bx, bx
    cmp y_axis, 0
    jle update
    
    mov bl, y_axis
    mov y_trail, bl
    mov bl, x_axis  ;
    mov x_trail, bl ;
    
    dec y_axis
    jmp update
    
down:
    xor bx, bx
    mov bl, y_axis
    mov y_trail, bl
    mov bl, x_axis  ;
    mov x_trail, bl ;
    
    inc y_axis
    jmp update
    
left:
    xor bx, bx
    cmp x_axis, 0
    jle update
    
    mov bl, x_axis
    mov x_trail, bl
    mov bl, y_axis
    mov y_trail, bl
        
    dec x_axis
    jmp update

right:
    xor bx, bx
    mov bl, x_axis
    mov x_trail, bl
    mov bl, y_axis
    mov y_trail, bl
               
    inc x_axis
    jmp update


erasetrail:
    

ends



end start ; set entry point and stop the assembler.
