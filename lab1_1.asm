assume CS:code,DS:data

; 4*a + b*d + c

data segment
a dw 4
b db 2
c dw 3
d db 4
result dw ?
output db 12 dup(0) ; 65535 max dec num, FFFF max hex num
data ends

code segment
start:
    mov AX, data
    mov DS, AX

calc:
    mov AX, a
    mov CL, 2
    shl AX, CL ; AX = 4*a
    mov result, AX
    mov AL, b
    mov BL, d
    mul BL ; AX = b*d
    add AX, c ; AX = b*d + c
    add result, AX

    mov BL, 10h ; BL - divider

prep:
    mov AX, result
    xor CL, CL
format:
    div BL
    push AX
    xor AH, AH
    inc CL

    cmp AL, 0 ; if digits left in num
    jnz format

    cmp BL, 10 ; if has already formed decimal repr
    je getdigit

    mov BL, 10 ; if has not formed decimal repr
    mov CH, CL
    jmp prep

getdigit:
    pop AX
    add AH, 30h
    cmp AH, 39h
    jle printdigit
    add AH, 7h
printdigit:
    mov output[si], AH
    inc si
    dec CL
    jnz getdigit
newline:
    cmp CH, 0
    jz cmd
    mov output[si], 13
    inc si
    mov output[si], 10
    inc si
    mov CL, CH
    xor CH, CH
    jmp getdigit

cmd:
    mov output[si], '$'
    mov AH, 09h
    mov DX, offset output
    int 21h
exit:
    mov AX, 4C00h
    int 21h
code ends
end start