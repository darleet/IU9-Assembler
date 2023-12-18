assume cs:code, ds:data

data segment
notation dw 10
x db 15, 16 dup(0)
y db 15, 16 dup(0)
output db 17 dup(0)
error db "Incorrect input!$"
data ends

code segment

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
        cmp [si], byte ptr 2dh
        je direm
        cmp [di], byte ptr 2dh
        je sirem

        mov al, [si]
        add al, [di]

        cmprem:
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
            cmp [si], byte ptr 2dh
            je saveres
            cmp cl, 0
            jz saveres
            mov al, [si]
            add al, bh
            xor bh, bh
            div dl
            mov bh, al ; bh - remainder
            push ax ; ah - digit
            inc bl ; bl - number of digits
            xor ax, ax
            dec si
            dec cl
            jmp sirem
        direm: ; if rem left in di
            cmp [di], byte ptr 2dh
            je saveres
            cmp ch, 0
            jz saveres
            mov al, [di]
            add al, bh
            xor bh, bh
            div dl
            mov bh, al ; bh - remainder
            push ax ; ah - digit
            inc bl ; bl - number of digits
            xor ax, ax
            dec di
            dec ch
            jmp direm
    
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
        inc bh
        mov al, [si]

        cmp [di], byte ptr 2dh
        je savesub

        add bl, [di] ; add is used to add to remainder if left in bl

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

iadd proc
    push bp
    mov bp, sp

    xor cx, cx

    mov si, [bp+8]
    inc si
    mov cl, [si]
    inc si

    mov di, [bp+6]
    inc di
    mov ch, [di]
    inc di

    cmp cl, ch
    jne lencheck

    cmpstr:
        dec cl
        jz swapstr
        dec ch
        jz swapstr
        mov al, [di]
        cmp [si], al
        jl swapstr
        inc si
        inc di
        jmp cmpstr

    lencheck:
        cmp cl, ch
        jg negcheck

    swapstr:
        xor si, di
        xor di, si
        xor si, di
    
    negcheck:
        mov si, [bp+8]
        add si, 2

        mov di, [bp+6]
        add di, 2

        cmp [si], byte ptr 2dh
        je othercheck
        cmp [di], byte ptr 2dh
        je oneneg
        jmp bothpos
    
    othercheck:
        cmp [di], byte ptr 2dh
        je bothneg

    oneneg:
        push [bp+10]
        push [bp+8]
        push [bp+6]
        push [bp+4]
        call usub
        pop di
        jmp retiadd

    bothneg:
        push [bp+10]
        push [bp+8]
        push [bp+6]

        mov di, [bp+4]
        inc di
        push di

        call uadd

        pop di
        dec di
        mov [di], byte ptr 2dh

        jmp retiadd
    
    bothpos:
        push [bp+10]
        push [bp+8]
        push [bp+6]
        push [bp+4]
        call uadd
        pop di

    retiadd:
        pop di
        pop di
        pop di
        pop bp
        ret
iadd endp

umult proc
    push bp
    mov bp, sp

    retumult:
        pop bp
        ret
umult endp

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
    xor dl, dl

    cmp [di], byte ptr 2dh
    jne formatzeros
    inc di
    mov dl, 1

    formatzeros:
        cmp [di], byte ptr 0
        jne addminus
        removezeros:
            inc di
            cmp [di], byte ptr 0
            je removezeros
            cmp [di], byte ptr '$'
            jne addminus
            dec di
            jmp format
        addminus:
            cmp dl, 1
            jne format
            dec di
            mov [di], byte ptr 2dh

    format:
        cmp [si], byte ptr '$'
        je printstr
        cmp [si], byte ptr 2dh
        je repformat
        cmp [si], byte ptr 10
        jl addnum
        add [si], byte ptr 7h
        addnum:
            add [si], byte ptr 30h
        repformat:
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
    ; call usub
    ; call umult
    call iadd
    ; call imult
    call printarr

exit:
    mov ax, 4c00h
    int 21h
code ends
end start
