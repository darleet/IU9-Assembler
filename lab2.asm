assume cs:code, ds:data

data segment
arr dw 5, 7, 2, 3, 8, 2, 0
len equ $ - arr
output db (len)*3 dup(0) ; len*3 т.к. нужно место для двузначных чисел и для пробелов
data ends

code segment
start:
    mov ax, data
    mov ds, ax
prepare:
    mov si, offset arr
    cld
    lodsw
    mov dx, ax
    mov cl, len - 2
readel:
    lodsw
    mov bx, ax
    add ax, dx
    mov dx, bx
    mov bl, 10
    getdigit:
        div bl
        add ah, 30h
        push ax
        inc ch
        xor ah, ah
        cmp al, 0
        jnz getdigit
    printdigit:
        pop ax
        mov output[di], ah
        inc di
        dec ch
        jnz printdigit
    mov output[di], ' '
    inc di
    sub cl, 2
    jnz readel
printend:
    mov output[di], '$'
    mov ah, 09h
    mov dx, offset output
    int 21h
exit:
    mov ax, 4C00h
    int 21h
code ends
end start