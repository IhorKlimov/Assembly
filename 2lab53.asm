init_ds macro ; макрос ініціалізації DS та ES
    ;--------------------------------- 1. Ініціалізація DS и ES---------------------------------------
    mov ax,data; data ідентифікатор, що створюються директивою model
    mov ds, ax ; Завантаження початку сегменту даних в регістр ds
    mov es, ax ; Завантаження початку сегменту даних в регістр es
endm

ask_for_number macro ; Макрос, який запрошує користувача ввести число з клавіатури та конвертує його у word, та зберігає у ax регістрі
    local start_one, start_two, print_error, end_start, end_ask_for_number, error_overflow

    push si
    mov ax, 0
    mov ah,0ah
    xor di,di
    mov dx,offset input ; аддрес буфера
    int 21h ; принимаем строку
    mov dl,0ah
    mov ah,02
    int 21h ; выводим перевода строки

    ; обрабатываем содержимое буфера

    mov si,offset input+2 ; берем аддрес начала строки
    mov al, input+2;
    cmp al, 2Dh ; если первый символ минус
    jnz start_one
    mov di,1  ; устанавливаем флаг
    inc si    ; и пропускаем его

start_one:
    xor ax,ax
    mov bx, 10  ; основание сc

start_two:
    mov cl,[si] ; берем символ из буфера
    cmp cl,0dh  ; проверяем не последний ли он
    jz end_start

    ; если символ не последний, то проверяем его на правильность
    cmp cl,'0'  ; если введен неверный символ <0
    jb print_error
    cmp cl,'9'  ; если введен неверный символ >9
    ja print_error

    sub cl,'0' ; делаем из символа число
    imul bx     ; умножаем на 10
    jo error_overflow
    add ax,cx  ; прибавляем к остальным
    jo error_overflow
    inc si     ; указатель на следующий символ
    jmp start_two     ; повторяем

print_error:   ; если была ошибка, то выводим сообщение об этом и выходим
    print error
    jmp exit
    
error_overflow:
    print msg_error_overflow
    jmp exit

end_start:
    cmp di,1 ; если установлен флаг, то
    jnz end_ask_for_number
    neg ax   ; делаем число отрицательным

end_ask_for_number:
    ; все символы из буфера обработаны число находится в ax
endm

next_line macro ; Макрос, який переводить на наступну строку у консолі
    mov dl, 10
    mov ah, 02h
    int 21h ; наступна строка
endm

print macro text ; Макрос, який виводить строку у консоль
    lea dx, text
    mov ah, 09h
    int 21h
endm

exit_program macro ; Макрос, який завершує програму
    mov ah,4ch
    mov al,[exCode]
    int 21h
endm

DATA SEGMENT PARA PUBLIC "DATA"
exCode db 0
mybyte db " $"
error db "Incorrect number", 10, 13, "$"
msg_error_overflow db "Number overflow", 10, 13, "$"
x dw 106
y dw 22
z dw 0
zr dw 0
divider dw 0
input db 7, 8 dup(?)

msg_case_one db "Case one, result = ", "$"
msg_case_two db "Case two, result = ", "$"
msg_case_three db "Case three, result = ", "$"
msg_case_four db "Case four, result = ", "$"
enter_x_message db "Enter x...", 10, 13, "$"
enter_y_message db "Enter y...", 10, 13, "$"
DATA ENDS

STK SEGMENT STACK
DB 256 DUP ("?")
STK ENDS

CODE SEGMENT PARA PUBLIC "CODE"
ASSUME CS : CODE, DS : DATA, SS : STK

MAIN PROC
init_ds
print enter_x_message
ask_for_number
mov x, ax
print enter_y_message
ask_for_number
mov y, ax
mov ax, 0

cmp x, 10
jg case_three_check_y

cmp x, 0
jg case_one_check_y
jl case_two_check_y
je case_four

case_one_check_y:
    cmp y, 0
    jg case_one
    jng case_four

case_two_check_y:
    cmp y, 0
    jl case_two
    jnl case_four

case_three_check_y:
    cmp y, 0
    je case_three
    jne case_one_check_y

case_one:
    print msg_case_one
    mov ax, x
    mov bx, y
    mul bx
    jo error_overflow_3
    mov bx, ax ; save x * y
    mov ax, x
    add ax, y ; x + y
    jo error_overflow_3
    mov [divider], bx
    div bx ; divide by (x * y)
    mov z, ax ; save result
    mov zr, dx
    jmp post_calculation


case_two:
    print msg_case_two
    mov ax, y
    mov bx, 25
    mul bx ; 25y
    jo error_overflow_3
    mov z, ax ; save result
    jmp post_calculation

case_three:
    print msg_case_three
    mov ax, x
    mov bx, 6
    mul bx ; 6x
    jo error_overflow_3
    mov z, ax ; save result
    jmp post_calculation

case_four:
    print msg_case_four
    mov z, 1
    jmp post_calculation

error_overflow_3:
    print msg_error_overflow
    jmp exit

post_calculation:
    mov ax, z
    mov cx, 0
    mov dx, 0
    cmp ax, 0
    jl print_minus
    je print_zero
    jge pre_print

print_zero:
    mov mybyte, 48
    print mybyte
    jmp check_floating_point

print_minus:
    mov mybyte, 45
    print mybyte
    mov ax, z
    neg ax
    mov cx,0
    mov dx,0

pre_print:
    cmp ax,0
    je print_
    mov bx,10
    div bx
    push dx
    inc cx
    xor dx,dx
    jmp pre_print

print_:
    cmp cx, 0
    je check_floating_point
    pop dx
    add dx,48
    mov ah,02h
    int 21h
    dec cx
    jmp print_

check_floating_point:
    cmp zr, 0
    je exit
    jne print_floating_point

print_floating_point:
    mov mybyte, 46
    print mybyte
    mov dx, zr
    mov cx, 10 ; print 10 digits after a floating point max

    floating:
        mov ax, dx
        mov bx, 10
        mul bx
        jo error_overflow_2
        mov bx, [divider]
        mov dx, 0
        div bx
        add ax, 48
        push dx
        mov mybyte, al
        print mybyte
        pop dx
        cmp dx, 0
        je exit
        loop floating

    jmp exit

error_overflow_2:
    print msg_error_overflow
    jmp exit

exit:
    exit_program

MAIN ENDP
CODE ENDS
END MAIN