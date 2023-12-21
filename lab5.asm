assume cs:code, ds:data

; Вариант 10

include \bmstu\format.asm

data segment
    input db 64, 65 dup(0)
    output db 64 dup(0)
    symbol db ?

    path1 db "\BMSTU\LAB5_IN.TXT", 0
    path2 db "\BMSTU\LAB5_OUT.TXT", 0

    file1 dw ?
    file2 dw ?

    filesize dw 27
data ends


code segment
start:
    mov ax, data
    mov ds, ax

    ; read symbol
    mov ah, 01h
    int 21h
    mov symbol, al

    ; open file for input
    xor al, al
    mov ah, 3dh
    mov dx, offset path1
    int 21h
    mov file1, ax

    ; open file for output
    xor cx, cx
    mov al, 1
    mov ah, 3ch
    mov dx, offset path2
    int 21h
    mov file2, ax

    ; read from file
    mov ah, 3fh
    mov bx, file1
    mov cx, filesize
    mov dx, offset input
    int 21h

    ; process data
    mov si, offset input
    mov di, offset output
    mov cx, filesize
    mov al, symbol
    delete_words si, di, cx, al
    
    ; write to file
    mov ah, 40h
    mov bx, file2
    mov cx, filesize
    mov dx, offset output
    int 21h
    
    ; close files
    mov bx, file1
    mov ah, 3eh
    int 21h
    mov bx, file2
    mov ah, 3eh
    int 21h

exit:
    mov ax, 4c00h
    int 21h
code ends
end start
