IDEAL ; Директива - тип Асемблера tasm
MODEL small ; Директива - тип моделі пам’яті
STACK 256 ; Директива - розмір стеку

DATASEG
exCode db 0
mybyte db " $"
result dw 0
print_n db 0
input db 12, 7 dup(?)
array dw 12 dup(0)
error db "Incorrect number", 10, 13, "$"
error_overflow db "Number overflow", 10, 13, "$"
number_to_find dw 0
number_found dw 0


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

; Ініціалізуємо масив
mov cx, 12 ; потрібно ввести 12 цифр з клавіатури

ask_for_number: ; запрошуємо користувача ввести число з клавіатури
    push si
    push cx

    mov ah,0ah
    xor di,di
    mov dx,offset input ; адреса буфера
    int 21h ; приймаємо рядок
    mov dl,0ah
    mov ah,02
    int 21h ; виводимо переклад рядка

    ; обробляємо вміст буфера
    mov si,offset input+2 ; беремо адресу початку рядка
    cmp [BYTE si], '-' ; якщо перший символ мінус
    jnz start_one
    mov di,1  ; встановлюємо прапор
    inc si    ; і пропускаємо його

start_one:
    xor ax,ax
    mov bx, 10  ; основа сc


start_two:
    mov cl,[si] ; беремо символ із буфера
    cmp cl,0dh  ; перевіряємо чи не останній він
    jz end_one

    ; якщо символ не останній, то перевіряємо його на правильність
    cmp cl,'0'  ; якщо введено неправильний символ < 0
    jb print_error
    cmp cl,'9'  ; якщо введено неправильний символ > 9
    ja print_error

    sub cl,'0' ; робимо із символу число
    imul bx     ; множимо на 10
    jo print_overflow
    add ax,cx  ; додаємо до інших
    jo print_overflow
    inc si     ; вказівник на наступний символ
    jmp start_two     ; повторюємо

print_error:   ; якщо була помилка, то виводимо повідомлення про це та виходимо
    mov dx, offset error
    mov ah,09
    int 21h
    jmp exit

print_overflow: ; якщо було переповнення - то виводимо повідомлення про це та виходимо
    lea dx, error_overflow
    mov ah, 09h
    int 21h
    jmp exit

end_one:
    cmp di,1 ; якщо встановлено прапор, то
    jnz post_calculation
    neg ax   ; робимо число негативним

post_calculation:
    pop cx

    ; Записуємо число до масиву
    push bx
    mov bx, 12
    sub bx, cx
    sal bx, 1
    mov [array + bx], ax
    pop bx
    loop ask_for_number




; --------------------------------- TASK 1 ------------------------------
task_one:
    mov ah, 9
    mov dx, offset msg_sum_of_numbers ; Виводимо заголовок первого завдання у консоль
    int 21h

    mov cx, 12  ; цикл з 12-ти елементів
    mov ax, 0

calculate_sum: ; Підсчитату сумму усіх елементів
     ; Зчитуємо усі цифри з масиву
     push bx
     mov bx, 12
     sub bx, cx
     sal bx, 1
     mov dx, [array + bx]
     add ax, dx ; додаємо цисло до суми
     jo print_overflow

     pop bx

    loop calculate_sum ; цикл до наступного елемента масиву

mov bx, 0
mov cx, 0
mov dx, 0

; ------ Виводиму суму усіх елементів у консоль --------
cmp ax, 0
jl print_minus_1
je print_zero_1
jge pre_print_1

print_zero_1:
    mov [mybyte], 48
    lea dx, [mybyte]
    mov ah, 09
    int 21h
    jmp number_print_end_1

print_minus_1:
    push ax
    mov [mybyte], 45
    lea dx, [mybyte]
    mov ah, 09
    int 21h
    pop ax
    neg ax
    mov cx,0
    mov dx,0

pre_print_1:
    cmp ax,0
    je print_1
    mov bx,10
    div bx
    push dx
    inc cx
    xor dx,dx
    jmp pre_print_1

print_1:
    cmp cx, 0
    je number_print_end_1
    pop dx
    add dx,48
    mov ah,02h
    int 21h
    dec cx
    jmp print_1

number_print_end_1:
    pop cx
    mov dl, 10
    mov ah, 02h
    int 21h ;new line feed





; --------------------------------- TASK 2 ------------------------------
task_two:
    mov ah, 9
    mov dx, offset msg_largest_number  ; Виводимо заголовок другого завдання у консоль
    int 21h

    mov cx, 12
    mov ax, 0
calculate_max: ; Знаходимо максимальний елемент
     ; Зчитати елементи з масиву
     push bx
     mov bx, 12
     sub bx, cx
     sal bx, 1
     mov dx, [array + bx]
     cmp bx, 0
     je save_largest
     cmp dx, ax
     jl calculate_max_2
     
save_largest:
     mov ax, dx

calculate_max_2:
    pop bx

    loop calculate_max

mov bx, 0
mov cx, 0
mov dx, 0
; ------ Виводимо максимальний елемент у консоль --------
cmp ax, 0
jl print_minus_2
je print_zero_2
jge pre_print_2

print_zero_2:
    mov [mybyte], 48
    lea dx, [mybyte]
    mov ah, 09
    int 21h
    jmp number_print_end_2

print_minus_2:
    push ax
    mov [mybyte], 45
    lea dx, [mybyte]
    mov ah, 09
    int 21h
    pop ax
    neg ax
    mov cx,0
    mov dx,0

pre_print_2:
    cmp ax,0
    je print_2
    mov bx,10
    div bx
    push dx
    inc cx
    xor dx,dx
    jmp pre_print_2

print_2:
    cmp cx, 0
    je number_print_end_2
    pop dx
    add dx,48
    mov ah,02h
    int 21h
    dec cx
    jmp print_2

number_print_end_2:
    pop cx
    mov dl, 10
    mov ah, 02h
    int 21h ;new line feed






; --------------------------------- TASK 3 ------------------------------
task_three:
    mov ah, 9
    mov dx, offset msg_sorted_array
    int 21h

    mov cx, 12
    mov ax, 0
sort: ; Сортуємо масив алгоритмом бульбашки
     ; Зчитуємо елемент з масиву
     push bx
     mov bx, 12
     sub bx, cx ; поточний індекс
     sal bx, 1  ; налаштувати індекс до розміру слова
     mov dx, [array + bx] ; прочитати поточне значення

     push cx
     mov cx, 12
sort_nested:
    cmp cx, 1
    jle sort_nested_end
    mov bx, 12 ; цикл з 12-ти елементів
    sub bx, cx ; поточний індекс
    sal bx, 1  ; налаштувати індекс до розміру слова
    mov dx, [array + bx] ; прочитати поточне значення
    mov ax, [array + bx + 2] ; прочитати наступне значення

    cmp dx, ax ; перевіряємо чи елементи стоять у правільних позиціях
    jle sort_nested_end ; якщо так - йдемо до наступного елементу
    mov [array + bx], ax      ; ні - тоді замінюємо іх один на другий
    mov [array + bx + 2], dx  ; ні - тоді замінюємо іх один на другий

sort_nested_end:
    loop sort_nested ; йдемо до наступного елементу
    pop cx

sort_2:
    loop sort

print_array_3: ; Виводимо відсортований масив у консоль
    mov cx, 12
number_print_3:
    push cx
    ; Зчитуємо елемент з масива
    push bx
    mov bx, 12
    sub bx, cx
    sal bx, 1
    mov ax, [array + bx]

    pop bx

    mov cx, 0
    mov dx, 0

    cmp ax, 0
    jl print_minus_3
    je print_zero_3
    jge pre_print_3

print_zero_3:
    mov [mybyte], 48
    lea dx, [mybyte]
    mov ah, 09
    int 21h
    jmp number_print_end_3

print_minus_3:
    push ax
    mov [mybyte], 45
    lea dx, [mybyte]
    mov ah, 09
    int 21h
    pop ax
    neg ax
    mov cx,0
    mov dx,0

pre_print_3:
    cmp ax,0
    je print_3
    mov bx,10
    div bx
    push dx
    inc cx
    xor dx,dx
    jmp pre_print_3

print_3:
    cmp cx, 0
    je number_print_end_3
    pop dx
    add dx,48
    mov ah,02h
    int 21h
    dec cx
    jmp print_3

number_print_end_3:
    pop cx
    mov dl, 10
    mov ah, 02h
    int 21h ;new line feed
    loop number_print_3

mov bx, 0
mov cx, 0
mov dx, 0



; --------------------------------- TASK 4 ------------------------------
task_four:
    mov ah, 9
    mov dx, offset msg_enter_number_to_find
    int 21h

ask_for_number_4: ; Запитати користувача яке число він хоче знайти у масиві
    push si
    push cx

    mov ah,0ah
    xor di,di
    mov dx,offset input ; адреса буфера
    int 21h ; приймаємо рядок
    mov dl,0ah
    mov ah,02
    int 21h ; виводимо переклад рядка

    ; обробляємо вміст буфера
    mov si,offset input+2 ; беремо адресу початку рядка
    cmp [BYTE si], '-' ; якщо перший символ мінус
    jnz start_one_4
    mov di,1  ; встановлюємо прапор
    inc si    ; і пропускаємо його

start_one_4:
    xor ax,ax
    mov bx, 10  ; основа сc

start_two_4:
    mov cl,[si] ; беремо символ із буфера
    cmp cl,0dh  ; перевіряємо чи не останній він
    jz end_one_4

    ; якщо символ не останній, то перевіряємо його на правильність
    cmp cl,'0'  ; якщо введено неправильний символ < 0
    jb print_error_4
    cmp cl,'9'  ; якщо введено неправильний символ > 9
    ja print_error_4

    sub cl,'0' ; робимо із символу число
    imul bx     ; множимо на 10
    jo print_overflow_2
    add ax,cx  ; додаємо до інших
    jo print_overflow_2
    inc si     ; указатель на следующий символ
    jmp start_two_4     ; повторюємо

print_error_4:   ; якщо була помилка, то виводимо повідомлення про це та виходимо
    mov dx, offset error
    mov ah,09
    int 21h
    jmp exit

print_overflow_2: ; якщо було переповнення - то виводимо повідомлення про це та виходимо
    lea dx, error_overflow
    mov ah, 09h
    int 21h
    jmp exit

end_one_4:
    cmp di,1 ; якщо встановлено прапор, то
    jnz post_calculation_4
    neg ax   ; робимо число негативним

post_calculation_4:
    mov number_to_find, ax
    mov ah, 9
    mov dx, offset msg_looking_for_number
    int 21h

    mov ax, number_to_find
    mov bx, 0
    mov dx, 0
    mov cx, 0

number_print_4:
    cmp ax, 0
    jl print_minus_4
    je print_zero_4
    jge pre_print_4

print_zero_4:
    mov [mybyte], 48
    lea dx, [mybyte]
    mov ah, 09
    int 21h
    jmp number_print_end_4

print_minus_4:
    push ax
    mov [mybyte], 45
    lea dx, [mybyte]
    mov ah, 09
    int 21h
    pop ax
    neg ax
    mov cx,0
    mov dx,0

pre_print_4:
    cmp ax,0
    je print_4
    mov bx,10
    div bx
    push dx
    inc cx
    xor dx,dx
    jmp pre_print_4

print_4:
    cmp cx, 0
    je number_print_end_4
    pop dx
    add dx,48
    mov ah,02h
    int 21h
    dec cx
    jmp print_4

number_print_end_4:
    pop cx
    mov dl, 10
    mov ah, 02h
    int 21h ;new line feed


mov ax, 0
mov bx, 0
mov cx, 0
mov dx, 0



mov cx, 12
mov ax, 0
found_coordinates:  ; Шукаємо число
     ; Считуємо число з масиву
     mov bx, 12
     sub bx, cx
     sal bx, 1
     mov dx, [array + bx]
     cmp dx, [number_to_find]   ; перевіряємо чи число є тим, що ми шукаємо
     jne found_coordinates_4 ; якщо ні - йдемо но наступного елементу
     mov [number_found], 1
     mov ah, 9
     mov dx, offset msg_found_coordinates ; Виводим у консоль що ми знайшли число
     int 21h

     mov dx, 0
     sar bx, 1 ; повернути індекс до звичайного вигляду
     mov ax, bx
     mov bl, 6 ; длина рядка
     div bx

     add ax, 48
     add dx, 48
     mov bx, dx ; сохранити індекс колонку

     mov [mybyte], al
     lea dx, [mybyte]
     mov ah, 09
     int 21h

     mov [mybyte], 58
     lea dx, [mybyte]
     mov ah, 09
     int 21h

     mov dx, bx

     mov [mybyte], dl
     lea dx, [mybyte]
     mov ah, 09
     int 21h
     mov dl, 10
     mov ah, 02h
     int 21h ; наступна строка


found_coordinates_4:
     loop found_coordinates

     cmp number_found, 0
     jne exit
     mov ah, 9
     mov dx, offset msg_number_not_found   ; Виводимо у консоль, що ми не знайшли число
     int 21h


exit:
    mov ah,4ch
    mov al,[exCode]
    int 21h

end Start