; multi-segment executable file template.

data segment
    ; file-handling components
    filePath db "C:\ReconGL\",0
    fileName db "C:\ReconGL\playerName.txt",0
    fileHandle dw ?
    
    nameBuffer db 10 dup(' '), '$'
    nameSizeLimit db 10
    
    nameEnter db "Enter your name: $"   
                                              
ends


code segment
start:
    mov ax, data
    mov ds, ax         
    
    ; set video mode to 40x25
    mov al, 00h
    mov ah, 0 
    int 10h
    
    

    ; open playername file
    mov al, 2
    mov dx, offset fileName
    mov ah, 3dh
    int 21h  
    mov fileHandle, ax
    
    ; make a name, will skip if file exists          
    call CreatePlayerName
                   
    ; specify / SEEK character position in file 
    mov al, 0
    mov bx, fileHandle
    mov cx, 0
    mov dx, 0
    mov ah, 42h
    int 21h
    
    ; read from file
    xor cx, cx
    mov cl, nameSizeLimit
    mov si, cx
    
    mov bx, fileHandle
    mov cx, si     
    mov dx, offset nameBuffer
    mov ah, 3fh
    int 21h
    
    lea dx, nameBuffer
    mov ah, 9
    int 21h
    
    ; exit
    int 20h 
          
   
ends
 

 
proc CreatePlayerName
    ; if file doesnt exists, create a name
    cmp ax, 3
    je CreateName
    ret
    
    CreateName:
        ; set position of string
        mov dh, 11
        mov dl, 5
        mov bh, 0
        mov ah, 2
        int 10h
        
        ; display string "enter name"
        lea dx, nameEnter
        mov ah, 9
        int 21h    
    
        xor cx, cx
        mov cl, nameSizeLimit
        mov di, cx
        mov si, 0
        InputName:
            ; erases character when backspace key is pressed
            mov al, 000
            mov bh, 0
            mov cx, 1
            mov ah, 0ah
            int 10h  
            
            ; accepts single keyboard input
            mov ah, 1
            int 21h
            
            ; stores keyboard input in the buffer
            mov nameBuffer[si], al
            
            ; end the input if enter key is pressed
            cmp al, 13
            je NameEntered
            
            ; adjust value if backspace key is presed
            cmp al, 8
            je AdjustName
            
            ; end the input if exceed character limit
            inc si
            cmp si, di
            jle InputName
            
            ; gets current cursor position
            mov bh, 0
            mov ah, 03h
            int 10h
             
            ; decrements cursor position's column value 
            dec dl
            mov ah, 2
            int 10h
            
            ; goes back to input
            dec si
            jmp InputName
        
    
    NameEntered:
        ; add dollar sign at the end for displaying purposes
        mov nameBuffer[si], '$'
        
        ; create folder/directory
        mov dx, offset filePath
        mov ah, 39h
        int 21h
        
        ; create and open file
        mov cx, 0
        mov dx, offset fileName
        mov ah, 3ch
        int 21h
        
        mov fileHandle, ax
        
        ; write name into file
        inc si
        mov bx, fileHandle
        mov cx, si
        mov dx, offset nameBuffer
        mov ah, 40h
        int 21h 
        
        ret
    
    AdjustName:
        ; don't adjust value if nameBuffer is empty
        cmp si, 0
        je InputName
        
        dec si
        jmp InputName
                    
endp CreatePlayerName



end start
