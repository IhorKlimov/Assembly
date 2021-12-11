IDEAL ; Директива - тип Асемблера tasm
MODEL small ; Директива - тип моделі пам’яті
STACK 256 ; Директива - розмір стеку

DATASEG
exCode db 0
mybyte db " $"
result dw 0
print_n db 0
buff db 6, 7 dup(?)
array dw 6 dup(0)
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


CODESEG
Start:
;--------------------------------- 1. Ініціалізація DS и ES---------------------------------------
mov ax,@data; @data ідентифікатор, що створюються директивою model
mov ds, ax ; Завантаження початку сегменту даних в регістр ds
mov es, ax ; Завантаження початку сегменту даних в регістр es
;----------------------------------2. Операція виводу на консоль---------------------------------

;---------------------------------- Number input from keyboard ----------------------------------

mov cx, 6

@ask_for_number:
    push si
    push cx

    mov ah,0ah
    xor di,di
    mov dx,offset buff ; аддрес буфера
    int 21h ; принимаем строку
    mov dl,0ah
    mov ah,02
    int 21h ; выводим перевода строки

    ; обрабатываем содержимое буфера
    mov si,offset buff+2 ; берем аддрес начала строки
    cmp [BYTE si], '-' ; если первый символ минус
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
    mov dx, offset error
    mov ah,09
    int 21h
    jmp @exit

    ; все символы из буфера обработаны число находится в ax

endin1:
    cmp di,1 ; если установлен флаг, то
    jnz @post_calculation
    neg ax   ; делаем число отрицательным

@post_calculation:
    pop cx

    ; Write a number to array
    push bx
    mov bx, 6
    sub bx, cx
    sal bx, 1
    mov array + bx, ax

    pop bx

    loop @ask_for_number

@print_array:
    mov ah, 9
    mov dx, offset msg_got_numbers
    int 21h

    mov cx, 6
@number_print:
        push cx
        ; Read a number to array
        push bx
        mov bx, 6
        sub bx, cx
        sal bx, 1
        mov ax, array + bx

        pop bx

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
        jmp @number_print_end

    @print_minus:
        push ax
        mov mybyte, 45
        lea dx, mybyte
        mov ah, 09
        int 21h
        pop ax
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
        je @number_print_end
        pop dx
        add dx,48
        mov ah,02h
        int 21h
        dec cx
        jmp @print

    @number_print_end:
        pop cx
        mov dl, 10
        mov ah, 02h
        int 21h ;new line feed
        loop @number_print




; --------------------------------- TASK 1 ------------------------------
@task_one:
    mov ah, 9
    mov dx, offset msg_sum_of_numbers
    int 21h

    mov cx, 6
    mov ax, 0
@calculate_sum:
     ; Read a number to array
     push bx
     mov bx, 6
     sub bx, cx
     sal bx, 1
     mov dx, array + bx
     add ax, dx

     pop bx

    loop @calculate_sum

mov bx, 0
mov cx, 0
mov dx, 0
; ------ PRINT --------
       cmp ax, 0
        jl @print_minus_1
        je @print_zero_1
        jge @pre_print_1

    @print_zero_1:
        mov mybyte, 48
        lea dx, mybyte
        mov ah, 09
        int 21h
        jmp @number_print_end_1

    @print_minus_1:
        push ax
        mov mybyte, 45
        lea dx, mybyte
        mov ah, 09
        int 21h
        pop ax
        neg ax
        mov cx,0
        mov dx,0

    @pre_print_1:
        cmp ax,0
        je @print_1
        mov bx,10
        div bx
        push dx
        inc cx
        xor dx,dx
        jmp @pre_print_1

    @print_1:
        cmp cx, 0
        je @number_print_end_1
        pop dx
        add dx,48
        mov ah,02h
        int 21h
        dec cx
        jmp @print_1

    @number_print_end_1:
        pop cx
        mov dl, 10
        mov ah, 02h
        int 21h ;new line feed





; --------------------------------- TASK 2 ------------------------------
@task_two:
    mov ah, 9
    mov dx, offset msg_largest_number
    int 21h

    mov cx, 6
    mov ax, 0
@calculate_max:
     ; Read a number to array
     push bx
     mov bx, 6
     sub bx, cx
     sal bx, 1
     mov dx, array + bx
     cmp dx, ax
     jl @calculate_max_2
     mov ax, dx

     @calculate_max_2:
     pop bx

    loop @calculate_max

mov bx, 0
mov cx, 0
mov dx, 0
; ------ PRINT --------
       cmp ax, 0
        jl @print_minus_2
        je @print_zero_2
        jge @pre_print_2

    @print_zero_2:
        mov mybyte, 48
        lea dx, mybyte
        mov ah, 09
        int 21h
        jmp @number_print_end_2

    @print_minus_2:
        push ax
        mov mybyte, 45
        lea dx, mybyte
        mov ah, 09
        int 21h
        pop ax
        neg ax
        mov cx,0
        mov dx,0

    @pre_print_2:
        cmp ax,0
        je @print_2
        mov bx,10
        div bx
        push dx
        inc cx
        xor dx,dx
        jmp @pre_print_2

    @print_2:
        cmp cx, 0
        je @number_print_end_2
        pop dx
        add dx,48
        mov ah,02h
        int 21h
        dec cx
        jmp @print_2

    @number_print_end_2:
        pop cx
        mov dl, 10
        mov ah, 02h
        int 21h ;new line feed






; --------------------------------- TASK 3 ------------------------------
@task_three:
    mov ah, 9
    mov dx, offset msg_sorted_array
    int 21h

    mov cx, 6
    mov ax, 0
@sort:
     ; Read a number to array
     push bx
     mov bx, 6
     sub bx, cx ; current index
     sal bx, 1  ; adjust index to word size
     mov dx, array + bx ; read a current value

     push cx
     mov cx, 6
     @sort_nested:
        cmp cx, 1
        jle @sort_nested_end
        mov bx, 6
        sub bx, cx ; current index
        sal bx, 1  ; adjust index to word size
        mov dx, array + bx ; read a current value
        mov ax, array + bx + 2 ; read the next value

        cmp dx, ax
        jle @sort_nested_end
        mov array + bx, ax
        mov array + bx + 2, dx

        @sort_nested_end:
        loop @sort_nested
     pop cx

     @sort_2:

    loop @sort

@print_array_3:
    mov cx, 6
@number_print_3:
        push cx
        ; Read a number to array
        push bx
        mov bx, 6
        sub bx, cx
        sal bx, 1
        mov ax, array + bx

        pop bx

        mov cx, 0
        mov dx, 0

        cmp ax, 0
        jl @print_minus_3
        je @print_zero_3
        jge @pre_print_3

    @print_zero_3:
        mov mybyte, 48
        lea dx, mybyte
        mov ah, 09
        int 21h
        jmp @number_print_end_3

    @print_minus_3:
        push ax
        mov mybyte, 45
        lea dx, mybyte
        mov ah, 09
        int 21h
        pop ax
        neg ax
        mov cx,0
        mov dx,0

    @pre_print_3:
        cmp ax,0
        je @print_3
        mov bx,10
        div bx
        push dx
        inc cx
        xor dx,dx
        jmp @pre_print_3

    @print_3:
        cmp cx, 0
        je @number_print_end_3
        pop dx
        add dx,48
        mov ah,02h
        int 21h
        dec cx
        jmp @print_3

    @number_print_end_3:
        pop cx
        mov dl, 10
        mov ah, 02h
        int 21h ;new line feed
        loop @number_print_3

mov bx, 0
mov cx, 0
mov dx, 0
; ------ PRINT --------







; --------------------------------- TASK 4 ------------------------------
@task_four:
    mov ah, 9
    mov dx, offset msg_enter_number_to_find
    int 21h

@ask_for_number_4:
    push si
    push cx

    mov ah,0ah
    xor di,di
    mov dx,offset buff ; аддрес буфера
    int 21h ; принимаем строку
    mov dl,0ah
    mov ah,02
    int 21h ; выводим перевода строки

    ; обрабатываем содержимое буфера
    mov si,offset buff+2 ; берем аддрес начала строки
    cmp [BYTE si], '-' ; если первый символ минус
    jnz ii1_4
    mov di,1  ; устанавливаем флаг
    inc si    ; и пропускаем его

ii1_4:
    xor ax,ax
    mov bx, 10  ; основание сc


ii2_4:
    mov cl,[si] ; берем символ из буфера
    cmp cl,0dh  ; проверяем не последний ли он
    jz endin1_4

    ; если символ не последний, то проверяем его на правильность
    cmp cl,'0'  ; если введен неверный символ <0
    jb er1_4
    cmp cl,'9'  ; если введен неверный символ >9
    ja er1_4

    sub cl,'0' ; делаем из символа число
    mul bx     ; умножаем на 10
    add ax,cx  ; прибавляем к остальным
    inc si     ; указатель на следующий символ
    jmp ii2_4     ; повторяем

er1_4:   ; если была ошибка, то выводим сообщение об этом и выходим
    mov dx, offset error
    mov ah,09
    int 21h
    jmp @exit

    ; все символы из буфера обработаны число находится в ax

endin1_4:
    cmp di,1 ; если установлен флаг, то
    jnz @post_calculation_4
    neg ax   ; делаем число отрицательным

@post_calculation_4:
    mov number_to_find, ax
    mov ah, 9
    mov dx, offset msg_looking_for_number
    int 21h

    mov ax, number_to_find
    mov bx, 0
    mov dx, 0
    mov cx, 0

@number_print_4:
        cmp ax, 0
        jl @print_minus_4
        je @print_zero_4
        jge @pre_print_4

    @print_zero_4:
        mov mybyte, 48
        lea dx, mybyte
        mov ah, 09
        int 21h
        jmp @number_print_end_4

    @print_minus_4:
        push ax
        mov mybyte, 45
        lea dx, mybyte
        mov ah, 09
        int 21h
        pop ax
        neg ax
        mov cx,0
        mov dx,0

    @pre_print_4:
        cmp ax,0
        je @print_4
        mov bx,10
        div bx
        push dx
        inc cx
        xor dx,dx
        jmp @pre_print_4

    @print_4:
        cmp cx, 0
        je @number_print_end_4
        pop dx
        add dx,48
        mov ah,02h
        int 21h
        dec cx
        jmp @print_4

    @number_print_end_4:
        pop cx
        mov dl, 10
        mov ah, 02h
        int 21h ;new line feed


mov ax, 0
mov bx, 0
mov cx, 0
mov dx, 0
; ------ PRINT --------



mov cx, 6
mov ax, 0
@found_coordinates:
     ; Read a number to array
     mov bx, 6
     sub bx, cx
     sal bx, 1
     mov dx, array + bx
     cmp dx, number_to_find
     jne @found_coordinates_4
     mov number_found, 1
     mov ah, 9
     mov dx, offset msg_found_coordinates
     int 21h

     mov dx, 0
     sar bx, 1 ; bring back index to a regular look
     mov ax, bx
     mov bl, 3 ; row length
     div bx

     add ax, 48
     add dx, 48
     mov bx, dx ; save col

     mov mybyte, al
     lea dx, mybyte
     mov ah, 09
     int 21h

     mov mybyte, 58
     lea dx, mybyte
     mov ah, 09
     int 21h

     mov dx, bx

     mov mybyte, dl
     lea dx, mybyte
     mov ah, 09
     int 21h

     @found_coordinates_4:

     loop @found_coordinates

     cmp number_found, 0
     jne @exit
     mov ah, 9
     mov dx, offset msg_number_not_found
     int 21h




@exit:
mov ah,4ch
mov al,[exCode]
int 21h

end Start