assume cs:code, ds:data

data segment
output db 3 dup(0)
buffer db 100, 101 dup(0)
symbolSet db 100, 101 dup(0)
data ends

code segment
strspn proc
    push bp
    mov bp, sp

    mov si, [bp+6] ; buffer max len
    inc si
    mov cl, [si] ; buffer de-facto len
    inc si
    cld

    xor dl, dl

    resetcnt:
        xor dh, dh
    getletter:
        ; checking counter in the beginning
        ; to be safe in null input cases
        cmp cl, 0
        jz retval
        dec cl

        lodsb

        mov di, [bp+4] ; symbolSet max len
        inc di
        mov ch, [di] ; symbolSet de-facto len
        inc di ; symbolSet

        getsymbol:
            cmp ch, 0
            jz resetcnt
            dec ch

            mov bl, [di]
            inc di

            cmp al, bl
            jne getsymbol
        
        inc dh
        cmp dh, dl
        jng getletter
        mov dl, dh
        jmp getletter

    retval:
        pop bp
        pop bx
        xor dh, dh
        push dx ; push answer
        push bx
        ret
strspn endp

start:
    mov ax, data
    mov ds, ax

readstr:
    mov dx, offset buffer
    mov ah, 0ah
    int 21h
    push dx

    mov dl, 10 ; print \n
    mov ah, 02h
    int 21h

    mov dx, offset symbolSet
    mov ah, 0ah
    int 21h
    push dx

    mov dl, 10 ; print \n
    mov ah, 02h
    int 21h

process:
    call strspn
    pop ax ; ax = answer
    mov bl, 10
    mov di, offset output
    xor cl, cl
getdigit:
    div bl
    add ah, '0'
    push ax
    inc cl
    xor ah, ah
    cmp al, 0
    jnz getdigit
writedigit:
    pop ax
    mov [di], ah
    inc di
    dec cl
    jnz writedigit

printstr:
    mov [di], byte ptr '$'
    mov dx, offset output
    mov ah, 09h
    int 21h

exit:
    mov ax, 4c00h
    int 21h
code ends
end start