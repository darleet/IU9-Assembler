delete_words macro src, strsize, dest, symbol
    mov si, src
    mov cx, strsize
    mov di, dest
    mov bl, symbol

    cmp [si], bl
    je skipword

    checkprefix:
        write_letter si, di
        dec cx
        jz stoploop

        cmp [si], bl
        je skipword

        cmp [si], byte ptr ' '
        je checkprefix

    writeword:
        write_letter si, di
        dec cx
        jz stoploop

        cmp [si], byte ptr ' '
        je checkprefix
        jmp writeword

    skipword:
        cmp [si], byte ptr ' '
        je checkprefix
        inc si
        mov [di], byte ptr ' '
        inc di
        dec cx
        jz stoploop
        jmp skipword

    stoploop:
        mov [di], byte ptr '$'
endm

write_letter macro lsrc, ldest
    mov al, [lsrc]
    mov [ldest], al
    inc lsrc
    inc ldest
endm