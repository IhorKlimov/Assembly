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
buff db 6, 7 dup(?)


case_one db "Case one", 10, 13, "$"
case_two db "Case two", 10, 13, "$"
case_three db "Case three", 10, 13, "$"
case_four db "Case four", 10, 13, "$"
error db "Incorrect number", 10, 13, "$"


CODESEG
Start:
;--------------------------------- 1. Ініціалізація DS и ES---------------------------------------
mov ax,@data; @data ідентифікатор, що створюються директивою model
mov ds, ax ; Завантаження початку сегменту даних в регістр ds
mov es, ax ; Завантаження початку сегменту даних в регістр es
;----------------------------------2. Операція виводу на консоль---------------------------------


push si
mov ax, 0
mov bx, 0
mov cx, 0
mov dx, 0
mov ah,0ah
xor di,di
mov dx,offset buff ; аддрес буфера
int 21h ; принимаем строку
mov dl,0ah
mov ah,02
int 21h ; выводим перевода строки

; обрабатываем содержимое буфера

mov si,offset buff+2 ; берем аддрес начала строки
mov al, buff+2;
cmp al, 2Dh ; если первый символ минус
jnz ii1
mov di,1  ; устанавливаем флаг
inc si    ; и пропускаем его

ii1:
    xor ax,ax
    mov bx, 10  ; основание сc

ii2:
    mov cl,[si] ; берем символ из буфера
    cmp cl,0dh  ; проверяем не последний ли он
    jz endin1

    ; если символ не последний, то проверяем его на правильность
    cmp cl,'0'  ; если введен неверный символ <0
    jb er1
    cmp cl,'9'  ; если введен неверный символ >9
    ja er1

    sub cl,'0' ; делаем из символа число
    mul bx     ; умножаем на 10
    add ax,cx  ; прибавляем к остальным
    inc si     ; указатель на следующий символ
    jmp ii2     ; повторяем

er1:   ; если была ошибка, то выводим сообщение об этом и выходим
    lea dx, error
    mov ah, 09h
    int 21h
    jmp @exit

endin1:
    cmp di,1 ; если установлен флаг, то
    jnz end_ask_for_number
    neg ax   ; делаем число отрицательным

end_ask_for_number:
    pop si
    ; все символы из буфера обработаны число находится в ax

mov [x], ax

push si
mov ax, 0
mov bx, 0
mov cx, 0
mov dx, 0
mov ah,0ah
xor di,di
mov dx,offset buff ; аддрес буфера
int 21h ; принимаем строку
mov dl,0ah
mov ah,02
int 21h ; выводим перевода строки

; обрабатываем содержимое буфера

mov si,offset buff+2 ; берем аддрес начала строки
mov al, buff+2;
cmp al, 2Dh ; если первый символ минус
jnz ii1_2
mov di,1  ; устанавливаем флаг
inc si    ; и пропускаем его

ii1_2:
    xor ax,ax
    mov bx, 10  ; основание сc

ii2_2:
    mov cl,[si] ; берем символ из буфера
    cmp cl,0dh  ; проверяем не последний ли он
    jz endin1_2

    ; если символ не последний, то проверяем его на правильность
    cmp cl,'0'  ; если введен неверный символ <0
    jb er1_2
    cmp cl,'9'  ; если введен неверный символ >9
    ja er1_2

    sub cl,'0' ; делаем из символа число
    mul bx     ; умножаем на 10
    add ax,cx  ; прибавляем к остальным
    inc si     ; указатель на следующий символ
    jmp ii2_2     ; повторяем

er1_2:   ; если была ошибка, то выводим сообщение об этом и выходим
    lea dx, [error]
    mov ah, 09h
    int 21h
    jmp @exit

endin1_2:
    cmp di,1 ; если установлен флаг, то
    jnz end_ask_for_number_2
    neg ax   ; делаем число отрицательным

end_ask_for_number_2:
    pop si
    ; все символы из буфера обработаны число находится в ax

mov [y], ax





cmp x, 10
jg @case_three_check_y

cmp [x], 0
jg @case_one_check_y
jl @case_two_check_y
je @case_four

@case_one_check_y:
    cmp [y], 0
    jg @case_one
    jng @case_four

@case_two_check_y:
    cmp [y], 0
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
    mov ax, [x]
    mov bx, [y]
    mul bx
    mov bx, ax ; save x * y
    mov ax, [x]
    add ax, [y] ; x + y
    mov [divider], bx
    div bx ; divide by (x * y)
    mov z, ax ; save result
    mov zr, dx
    jmp @post_calculation


@case_two:
    mov dx, offset case_two
    mov ah, 9
    int 21h
    mov ax, [y]
    mov bx, 25
    mul bx ; 25y
    mov [z], ax ; save result
    jmp @post_calculation

@case_three:
    mov dx, offset case_three
    mov ah, 9
    int 21h
    mov ax, [x]
    mov bx, 6
    mul bx ; 6x
    mov [z], ax ; save result
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
    mov [mybyte], 48
    lea dx, [mybyte]
    mov ah, 09
    int 21h
    jmp @check_floating_point

@print_minus:
    mov [mybyte], 45
    lea dx, [mybyte]
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
    mov [mybyte], 46
    lea dx, [mybyte]
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
        mov [mybyte], al
        lea dx, [mybyte]
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