init_ds macro
    ;--------------------------------- 1. Ініціалізація DS и ES---------------------------------------
    mov ax,data; data ідентифікатор, що створюються директивою model
    mov ds, ax ; Завантаження початку сегменту даних в регістр ds
    mov es, ax ; Завантаження початку сегменту даних в регістр es
endm

ask_for_number macro
    local ii1, ii2, er1, endin1, end_ask_for_number

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
    print error
    jmp @exit

endin1:
    cmp di,1 ; если установлен флаг, то
    jnz end_ask_for_number
    neg ax   ; делаем число отрицательным

end_ask_for_number:
    pop si
    ; все символы из буфера обработаны число находится в ax
endm

next_line macro
    mov dl, 10
    mov ah, 02h
    int 21h ; наступна строка
endm

print_number_input_prompt macro index
    mov enter_number_message + 25, index ; Замініти символ % на індекс
    print enter_number_message
endm

print macro text
    lea dx, text
    mov ah, 09h
    int 21h
endm

exit_program macro
    mov ah,4ch
    mov al,[exCode]
    int 21h
endm

print_number macro ; печатає цифру, яка знаходиться у ax регістру
    local print_zero, print_minus, pre_print, print_post, number_print_end

    cmp ax, 0
    jl print_minus
    je print_zero
    jge pre_print

    print_zero:
        mov mybyte, 48
        print mybyte
        jmp number_print_end

    print_minus:
        push ax
        mov mybyte, 45
        print mybyte
        pop ax
        neg ax
        mov cx,0
        mov dx,0

    pre_print:
        cmp ax,0
        je print_post
        mov bx,10
        div bx
        push dx
        inc cx
        xor dx,dx
        jmp pre_print

    print_post:
        cmp cx, 0
        je number_print_end
        pop dx
        add dx,48
        mov ah,02h
        int 21h
        dec cx
        jmp print_post

    number_print_end:
        pop cx
        next_line    
endm

DATA SEGMENT PARA PUBLIC "DATA"
exCode db 0
mybyte db " $"
result dw 0
print_n db 0
buff db 12, 7 dup(?)
array dw 12 dup(0)
error db "Incorrect number", 10, 13, "$"
number_to_find dw 0
number_found dw 0


msg_got_numbers db "Got numbers:", 10, 13, "$"
msg_sum_of_numbers db "Sum of all elements: ", "$"
msg_largest_number db "Largest number: ", "$"
msg_sorted_array db "Sorted array: ", 10, 13, "$"
msg_enter_number_to_find db "Enter a number you want to find...", 10, 13, "$"
msg_looking_for_number db "Looking for number: ", "$"
msg_found_coordinates db "Found coordinates: ", "$"
msg_number_not_found db "Number not found",  10, 13, "$"
array_initialization_message db "Array initialization...",  10, 13, "$"
enter_number_message db "Please enter item number %...",  10, 13, "$"
DATA ENDS

STK SEGMENT STACK
DB 256 DUP ("?")
STK ENDS

CODE SEGMENT PARA PUBLIC "CODE"
ASSUME CS : CODE, DS : DATA, SS : STK

MAIN PROC
init_ds
print array_initialization_message
mov cx, 12

@array_initialization:
    mov ax, 13
    sub ax, cx
    add ax, 48
    print_number_input_prompt al
    push cx
    ask_for_number
    pop cx

    ; Write a number to array
    mov bx, 12
    sub bx, cx
    sal bx, 1
    mov array + bx, ax

    loop @array_initialization

@print_array:
    print msg_got_numbers
    mov cx, 12

@number_print:
    push cx
    ; Read a number to array
    push bx
    mov bx, 12
    sub bx, cx
    sal bx, 1
    mov ax, array + bx

    pop bx
    mov cx, 0
    mov dx, 0

    print_number
    loop @number_print

; --------------------------------- TASK 1 ------------------------------
@task_one:
    print msg_sum_of_numbers
    mov cx, 12
    mov ax, 0

@calculate_sum:
     ; Read a number to array
     push bx
     mov bx, 12
     sub bx, cx
     sal bx, 1
     mov dx, array + bx
     add ax, dx

     pop bx

    loop @calculate_sum

mov bx, 0
mov cx, 0
mov dx, 0
print_number

@exit:
exit_program

MAIN ENDP
CODE ENDS
END MAIN