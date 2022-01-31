; v0.7 
; Added:
; > fixed game button position and hitboxes
; TODO:
; > learn file handling
; > put game descriptions to variable
; > refactor code
; > verify accuracy on button's hitboxes
 
 
data segment               
    menuGameLogo db "RRRRR                                 $"
                 db "RR  RR                                $"
                 db "RR  RR  EEEE   CCCCC   OOOOOO  N NNNN $"
                 db "RR RR  EE  EE CCC  CC OOO  OOO NNNNNNN$"
                 db "RRRR   EE  EE CC      OO    OO NN   NN$"
                 db "RRRR   EEEEE  CC      OO    OO NN   NN$"
                 db "RR RR  EE     CCC  CC OOO  OOO NN   NN$"
                 db "RR  RR  EEEE   CCCCC   OOOOOO  NN   NN$"
                 db 10,13,"   G  A  M  E     L  I  B  R  A  R  Y  $"
    
    menuSelect db "Select a game below!$"
    menuTTTButton db "TicTacToe$"
    menuSnakeButton db "Snake$"    
    
    menuReturn db "[Return to Main Menu]$" 
    menuTempDescription db "Game: version, goal/purpose, description, controls, known bugs/issues, etc.$"              
    menuPlayButton db "[ P L A Y   G A M E ]$"    
    gameState db 0
                    
    menuSnakeDescription db ""
    menuTictactoeDescription db ""
    
                    
    ; file-handling components
    filePath db "C:\ReconGL\",0
    fileName db "C:\ReconGL\playerName.txt",0
    fileHandle dw ?
    
    nameEnter db "Enter your name: $"
    nameGreet db "Hi! $"
    nameChangeButton db "[Change Name]$"    
    
    nameBuffer db 13 dup(' '), '$'
    nameSizeLimit db 12
    
                                                   
ends

code segment
start:
    mov ax, data
    mov ds, ax
        
        
LoadContent:
    ; set video mode to 40x25
    mov al, 00h
    mov ah, 0 
    int 10h
    
    ; hide text cursor
    mov ch, 32
    mov ah, 1
    int 10h

    ; open playername file
    mov al, 2
    mov dx, offset fileName
    mov ah, 3dh
    int 21h  
    mov fileHandle, ax
    
    LoadFileToBuffer:
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
    
    ; store file data to nameBuffer
    mov bx, fileHandle
    mov cx, si     
    mov dx, offset nameBuffer
    mov ah, 3fh
    int 21h
    
    ; close file
    mov bx, fileHandle
    mov ah, 3eh
    int 21h
    
    jmp MainMenu


proc CreatePlayerName
    ; if file doesnt exists, create a name
    cmp ax, 3
    je CreateName
    ret
    
    CreateName:
        ; set position of string
        mov dh, 11
        mov dl, 4
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
        ; remove enter key ascii code
        mov nameBuffer[si], 000
           
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


ChangePlayerName:
    ; reset display
    mov al, 00h
    mov ah, 0 
    int 10h
    
    ; delete file
    mov dx, offset fileName
    mov ah, 41h
    int 21h
    
    ; delete directory
    mov dx, offset filePath
    mov ah, 3ah
    int 21h
    
    ; reset nameBuffer
    xor cx, cx
    mov cl, nameSizeLimit
    mov si, cx
    ResetNameBuffer:
        mov nameBuffer[si], 000
        dec si
        cmp si, 0
        jge ResetNameBuffer
    
    mov ax, 3
    ; Create player name 
    jmp LoadFileToBuffer
        
        
; initialize components before Update    
MainMenu:
    ; set video mode to 40x25
    mov al, 00h
    mov ah, 0 
    int 10h
    
    ; hide text cursor
    mov ch, 32
    mov ah, 1
    int 10h
    
    ; TEMP SHOW CURSOR
    mov ax, 1
    int 33h

    ; display greetings
    lea dx, nameGreet
    mov ah, 9
    int 21h    
    
    ; display player name
    lea dx, nameBuffer
    mov ah, 9
    int 21h
           
    ; display game logo
    mov si, 0
    mov cl, 3
    ShowGameLogo:
        mov dh, cl
        mov dl, 1
        mov bh, 0
        mov ah, 2
        int 10h    
    
        lea dx, menuGameLogo[si]
        mov ah, 9
        int 21h
        
        inc cl
        add si, 39
        cmp cl, 11
        jle ShowGameLogo
    
    
    ; display instruction
    mov dh, 15
    mov dl, 10
    mov bh, 0
    mov ah, 2
    int 10h
    
    lea dx, menuSelect
    mov ah, 9
    int 21h
       
       
    ; display Tic-Tac-Toe button
    mov dh, 18
    mov dl, 16
    mov bh, 0
    mov ah, 2
    int 10h
        
    lea dx, menuTTTButton
    mov ah, 9
    int 21h
      
      
    ; display snake button
    mov dh, 21
    mov dl, 16
    mov bh, 0
    mov ah, 2
    int 10h
    
    lea dx, menuSnakeButton
    mov ah, 9
    int 21h
            
    
    ; display changename button
    mov dh, 1
    mov dl, 0
    mov bh, 0
    mov ah, 2
    int 10h
    
    lea dx, nameChangeButton
    mov ah, 9
    int 21h
    
            
    ; reset value of gameState
    mov gameState, 0
           
           
    Update:
        ; mouse inputs  
        ; get mouse position, stored in CX and DX 
        mov ax, 3
        int 33h  
         
        ; if left mouse button is pressed
        cmp bx, 00000001b
        je GameSelected
        
        call SelectionArrow
        ; update selection arrow
                    
        jmp Update
    
ends



GameSelected:
    cmp dx, 16d
    jg ButtonArea 
     
    cmp dx, 8d
    jl Update
     
    cmp cx, 104d
    jl ChangePlayerName
    
    
ButtonArea:    
    ; errortrap: higher than tic-tac-toe button
    cmp dx, 144d    ; 90h
    jl Update
    
    ; errortrap: lower than snake button
    cmp dx, 176d    ; b0h
    jg Update 

    ; errortrap: left-hand side of the buttons
    cmp cx, 128d    ; 80h
    jl Update   
    
    ; errortrap: right-hand side of tictactoe button
    cmp cx, 199d    ; c7h
    jg Update
    
    ; if tictactoe button is clicked
    cmp dx, 152d
    jle ShowGameInfo
    
    ; if snake button is clicked
    cmp dx, 168d
    jge ShowGameInfo

    jmp Update

   
   
   
proc SelectionArrow
    ; errortrap: higher than tic-tac-toe button
    cmp dx, 144d    ; 90h
    jl Update
    
    ; errortrap: lower than snake button
    cmp dx, 176d    ; b0h
    jg Update 

    ; errortrap: left-hand side of the buttons
    cmp cx, 128d    ; 80h
    jl Update   
    
    ; errortrap: right-hand side of tictactoe button
    cmp cx, 199d    ; c7h
    jg Update    
    
    
    ; display selection arrow to the left side of tictactoe button
    cmp dx, 152d
    jle SelectTictactoe
    
    ; display selection arrow to the left side of snake button
    cmp dx, 168d
    jge SelectSnake
     
     
    ret      
          
    SelectTictactoe:
        ; do nothing if already selected
        cmp gameState, 1
        je Update
        
        ; removes the selection arrow from snake button
        mov dh, 21
        mov dl, 14
        mov bh, 0
        mov ah, 2
        int 10h    
        
        mov al, 000
        mov bh, 0
        mov cx, 1
        mov ah, 0ah
        int 10h
               
        ; displays the selection arrow to the tic-tac-toe button       
        mov dh, 18
        mov dl, 14
        mov bh, 0
        mov ah, 2
        int 10h    
        
        mov al, 26
        mov bh, 0
        mov cx, 1
        mov ah, 0ah
        int 10h    
        
        mov gameState, 1
        ret
    
    
    SelectSnake:
        ; do nothing if already selected
        cmp gameState, 2
        je Update
        
        ; removes the selection arrow from tic-tac-toe button
        mov dh, 18
        mov dl, 14
        mov bh, 0
        mov ah, 2
        int 10h    
        
        mov al, 000
        mov bh, 0
        mov cx, 1
        mov ah, 0ah
        int 10h  
    
        ; displays the selection arrow to the snake button
        mov dh, 21
        mov dl, 14
        mov bh, 0
        mov ah, 2
        int 10h    
        
        mov al, 26
        mov bh, 0
        mov cx, 1
        mov ah, 0ah
        int 10h             
        
        mov gameState, 2
        ret    
    
endp SelectionArrow


ShowGameInfo:
    ; reset value of bx
    xor bx, bx
    
    ; set video mode to 80x25
    mov al, 03h
    mov ah, 0 
    int 10h    
    
    ; display return to main menu button
    mov dh, 0
    mov dl, 58
    mov bh, 0
    mov ah, 2
    int 10h     
    
    lea dx, menuReturn
    mov ah, 9
    int 21h
    
    
    ; [TEMPORARY] display description
    mov dh, 3 
    mov dl, 2
    mov bh, 0
    mov ah, 2
    int 10h
    
    lea dx, menuTempDescription
    mov ah, 9
    int 21h
    
    
    ; display play button
    mov dh, 21
    mov dl, 30
    mov bh, 0
    mov ah, 2
    int 10h
    
    lea dx, menuPlayButton
    mov ah, 9
    int 21h
    
    
    ; reset cursor position to 0,0
    mov dh, 0
    mov dl, 0
    mov bh, 0
    mov ah, 2
    int 10h     
    
    
    cmp gameState, 1
    je InfoTictactoe
    
    cmp gameState, 2
    je InfoSnake
    
    jmp MainMenu  


InfoTictactoe:
    lea dx, menuTTTButton
    mov ah, 9
    int 21h
    
    ; display game description/features/controls/bugs here
    
    jmp InfoUpdate


InfoSnake:
    lea dx, menuSnakeButton
    mov ah, 9
    int 21h
    
    ; display game description/features/controls/bugs here
    
    jmp InfoUpdate

               
InfoUpdate:
    ; get mouse position
    mov ax, 3
    int 33h
    
    ; continue if left mouse button is clicked
    cmp bx, 00000001b
    je InfoUpdateButtonPressed  
    
        
    jmp InfoUpdate               
        
               
InfoUpdateButtonPressed:
    ; errortrap: below the play button
    cmp dx, 176d    ; b0h
    jg InfoUpdate
    
    ; play button row
    cmp dx, 168d    ; a8h
    jge InfoPlayButton 
    
    ; main menu row
    cmp dx, 8d      ; 08h 
    jle InfoMainMenuButton
    
    
    jmp InfoUpdate
    
    InfoPlayButton:
        ; errortrap: right side of play button
        cmp cx, 407d    ; 0197h
        jg InfoUpdate
        
        ; errortrap: left side of play button
        cmp cx, 240d    ; f0h
        jl InfoUpdate
    
        jmp PlayButtonPressed
    
    
    InfoMainMenuButton:
        cmp cx, 464d    ; 01d0h
        jl InfoUpdate
        
        jmp MainMenu               
               
PlayButtonPressed:
    ;cmp gameState, 1
    ;je InitializeTictactoe
    
    ;cmp gameState, 2
    ;je InitializeSnake
    
    jmp MainMenu
                       


end start
