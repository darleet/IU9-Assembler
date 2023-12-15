assume cs:code, ds:data

data segment
notation dw 10
x db 15, 16 dup(0)
y db 15, 16 dup(0)
output db 17 dup(0)
error db "Incorrect input!$"
data ends

code segment

; cmpstr places the greater string on head of stack and
; the other string under the greater one and also lengths
; of both strings under the two strings, where al - max str, 
; ah - min str
; cmpstr proc
;     push bp
;     mov bp, sp

;     mov si, [bp+4]
;     inc si
;     mov al, [si]

;     mov si, [bp+6]
;     inc si
;     mov ah, [si]

;     cmp al, ah
;     jl secondgreater

;     firstgreater:
;         mov si, [bp+4]
;         mov di, [bp+6]
;         jmp retval
;     secondgreater:
;         mov si, [bp+6]
;         mov di, [bp+6]
;         xor al, ah
;         xor ah, al
;         xor al, ah ; changed order

;     retval:
;         add si, 2
;         add di, 2
;         pop bp
;         pop dx
;         push ax
;         push di
;         push si
;         push dx
;         push bp
;         ret
; cmpstr endp

uadd proc
    push bp
    mov bp, sp

    xor cx, cx
    xor ax, ax

    mov si, [bp+8]
    inc si
    mov cl, [si]
    add si, cx

    mov di, [bp+6]
    inc di
    mov al, [di]
    add di, ax
    mov ch, al

    xor ax, ax
    xor bx, bx ; bh - remainder, bl - num of digits

    mov dx, [bp+10] ; notation

    digitadd:
        mov al, [si]
        add al, [di]

        cmprem:
            cmp bh, 0
            jz getrem
            add al, bh
            xor bh, bh

        getrem:
            div dl
            mov bh, al ; bh - remainder
            push ax ; ah - digit
            inc bl ; bl - number of digits
            xor ax, ax

            dec si
            dec cl
            dec di
            dec ch
            jz sirem

            cmp cl, 0
            jz direm

            jmp digitadd
    
        sirem: ; if rem left in si
            cmp cl, 0
            jz saveres
            dec si
            dec cl
            mov al, [si]
            jmp cmprem
        direm: ; if rem left in di
            cmp ch, 0
            jz saveres
            dec di
            dec ch
            mov al, [di]
            jmp cmprem
    
    saveres:
        mov di, [bp+4]
        cmp bh, 0
        jz savedigit
        mov [di], bh
        inc di

        savedigit:
            pop ax
            mov [di], ah
            inc di
            dec bl
            jz retuadd
            jmp savedigit

    retuadd:
        mov [di], byte ptr '$'
        pop bp
        ret
uadd endp

; supports substraction from greater number
usub proc
    push bp
    mov bp, sp

    xor cx, cx
    xor ax, ax

    mov si, [bp+8]
    inc si
    mov cl, [si]
    add si, cx

    mov di, [bp+6]
    inc di
    mov al, [di]
    add di, ax
    mov ch, al

    xor ax, ax
    xor bx, bx ; bh - num of digits

    mov dx, [bp+10] ; notation

    digitsub:
        mov al, [si]
        add bl, [di] ; add is used to add to remainder if left in bl

        inc bh
        cmp al, bl
        jge savesub

        saverem:
            add al, dl
            sub al, bl
            push ax
            mov bl, 1
            jmp repsub
        savesub:
            sub al, bl
            push ax
            xor bl, bl
        repsub:
            dec si
            dec cl
            jz savesubproc
            dec di
            dec ch
            jnz digitsub
        subrem:
            inc bh
            mov al, [si]
            sub al, bl
            push ax
            restdigits:
                dec si
                dec cl
                jz savesubproc
                inc bh
                push [si]
                jmp restdigits

    savesubproc:
        mov di, [bp+4]
    savedigitsub:
        pop ax
        mov [di], al
        inc di
        dec bh
        jz retusub
        jmp savedigitsub

    retusub:
        mov [di], byte ptr '$'
        pop bp
        ret
usub endp



inputstr proc
    push bp
    mov bp, sp

    mov dx, [bp+4]
    mov ah, 0ah
    int 21h

    mov si, dx
    inc si
    mov cl, [si]

    mov dl, 10 ; print \n
    mov ah, 02h
    int 21h

    readsym:
        inc si
        mov al, [si]

        cmp al, 2dh ; if al == '-'
        je repeat
        cmp al, 30h
        jl errprint
        cmp al, 5ah ; supports only uppercase notation
        jg errprint
        cmp al, 41h
        jge letter
        cmp al, 3ah
        jl number
        jmp errprint

        letter:
            sub al, 37h
            mov [si], al
            jmp repeat

        number:
            sub al, 30h
            mov [si], al
        
        repeat:
            dec cl
            jz retstr
            jmp readsym
    
    errprint:
        mov dx, offset error
        mov ah, 09h
        int 21h

        mov ax, 4c00h
        int 21h

    retstr:
        pop bp
        ret
inputstr endp

printarr proc
    push bp
    mov bp, sp

    mov si, [bp+4]
    mov di, si

    cmp [di], byte ptr 0
    jne format
    removezeros:
        inc di
        cmp [di], byte ptr 0
        je removezeros
    dec di

    format:
        cmp [si], byte ptr '$'
        je printstr
        cmp [si], byte ptr 10
        jl addnum
        add [si], byte ptr 7h
        addnum:
            add [si], byte ptr 30h
        inc si
        jmp format
    
    printstr:
        mov dx, di
        mov ah, 09h
        int 21h

    pop bp
    ret
printarr endp

start:
    mov ax, data
    mov ds, ax

readstr:
    push notation

    push offset x
    call inputstr
    push offset y
    call inputstr

    push offset output

testadd:
    ; call uadd
    call usub
    call printarr

exit:
    mov ax, 4c00h
    int 21h
code ends
end start
