IDEAL ; Директива - тип Асемблера tasm
MODEL small ; Директива - тип моделі пам’яті
STACK 256 ; Директива - розмір стеку

DATASEG
exCode db 0
maxlen db 3
len db 0
msg db 3 dup(?)
mybyte db " $"
result dw 6
isnegativeinput db 0
x dw 106
y dw 22
z dw 0
zr dw 0
divider dw 0

case_one db "Case one", 10, 13, "$"
case_two db "Case two", 10, 13, "$"
case_three db "Case three", 10, 13, "$"
case_four db "Case four", 10, 13, "$"


CODESEG
Start:
;--------------------------------- 1. Ініціалізація DS и ES---------------------------------------
mov ax,@data; @data ідентифікатор, що створюються директивою model
mov ds, ax ; Завантаження початку сегменту даних в регістр ds
mov es, ax ; Завантаження початку сегменту даних в регістр es
;----------------------------------2. Операція виводу на консоль---------------------------------
cmp x, 10
jg @case_three_check_y

cmp x, 0
jg @case_one_check_y
jl @case_two_check_y
je @case_four

@case_one_check_y:
    cmp y, 0
    jg @case_one
    jng @case_four

@case_two_check_y:
    cmp y, 0
    jl @case_two
    jnl @case_four

@case_three_check_y:
    cmp y, 0
    je @case_three
    jne @case_one_check_y


@case_one:
    mov dx, offset case_one
    mov ah, 9
    int 21h
    mov ax, x
    mov bx, y
    mul bx
    mov bx, ax ; save x * y
    mov ax, x
    add ax, y ; x + y
    mov [divider], bx
    div bx ; divide by (x * y)
    mov z, ax ; save result
    mov zr, dx
    jmp @post_calculation


@case_two:
    mov dx, offset case_two
    mov ah, 9
    int 21h
    mov ax, y
    mov bx, 25
    mul bx ; 25y
    mov z, ax ; save result
    jmp @post_calculation

@case_three:
    mov dx, offset case_three
    mov ah, 9
    int 21h
    mov ax, x
    mov bx, 6
    mul bx ; 6x
    mov z, ax ; save result
    jmp @post_calculation

@case_four:
    mov dx, offset case_four
    mov ah, 9
    int 21h
    mov z, 1
    jmp @post_calculation

@post_calculation:
    mov ax, z
    mov cx, 0
    mov dx, 0

    cmp ax, 0
    jl @print_minus
    je @print_zero
    jge @pre_print

@print_zero:
    mov mybyte, 48
    lea dx, mybyte
    mov ah, 09
    int 21h
    jmp @check_floating_point

@print_minus:
    mov mybyte, 45
    lea dx, mybyte
    mov ah, 09
    int 21h
    mov ax, z
    neg ax
    mov cx,0
    mov dx,0

@pre_print:
    cmp ax,0
    je @print
    mov bx,10
    div bx
    push dx
    inc cx
    xor dx,dx
    jmp @pre_print

@print:
    cmp cx, 0
    je @check_floating_point
    pop dx
    add dx,48
    mov ah,02h
    int 21h
    dec cx
    jmp @print

@check_floating_point:
    cmp zr, 0
    je @exit
    jne @print_floating_point

@print_floating_point:
    mov mybyte, 46
    lea dx, mybyte
    mov ah, 09
    int 21h

    mov dx, zr
    mov cx, 10 ; print 10 digits after a floating point max

    @floating:
        mov ax, dx
        mov bx, 10
        mul bx
        mov bx, [divider]
        mov dx, 0
        div bx
        add ax, 48
        push dx
        mov mybyte, al
        lea dx, mybyte
        mov ah, 09
        int 21h
        pop dx
        cmp dx, 0
        je @exit
        loop @floating

    jmp @exit

@exit:
    mov ah,4ch
    mov al,[exCode]
    int 21h

end Start