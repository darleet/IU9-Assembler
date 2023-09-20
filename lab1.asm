assume CS:code,DS:data

data segment
a dw 1
b db 2
c dw 3
d db 4
data ends

code segment
start:
    mov AX, data
    mov DS, AX
calc:
    mov DX, a
    mov CL, 2
    shl DX, CL
    mov AL, b
    mov BL, d
    mul BL
    add DX, AX
    add DX, c
exit:
    mov AX,4C00h
    int 21h
code ends
end start