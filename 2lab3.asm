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
x dw 0
y dw 0
z dw 0
zr dw 0
divider dw 0
buff db 6, 7 dup(?)


case_one db "Case one", 10, 13, "$"
case_two db "Case two", 10, 13, "$"
case_three db "Case three", 10, 13, "$"
case_four db "Case four", 10, 13, "$"
error db "Incorrect number", 10, 13, "$"
error_overflow db "Number overflow", 10, 13, "$"


CODESEG
Start:
;--------------------------------- 1. Ініціалізація DS и ES---------------------------------------
mov ax,data; data ідентифікатор, що створюються директивою model
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
mov dx,offset buff ; адреса буфера
int 21h ; приймаємо рядок
mov dl,0ah
mov ah,02
int 21h ; виводимо переклад рядка

; обробляємо вміст буфера

mov si,offset buff+2 ; берем аддрес начала строки
mov al, buff+2
cmp al, 2Dh ; якщо перший символ мінус
jnz start_one
mov di,1  ; встановлюємо прапор
inc si    ; і пропускаємо його

start_one:
    xor ax,ax
    mov bx, 10  ; основание сc

start_two:
    mov cl,[si] ; беремо символ із буфера
    cmp cl,0dh  ; перевіряємо чи не останній він
    jz end_one

    ; перевіряємо чи не останній він
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
    jmp start_two     ; повторяемо

print_error:   ; якщо була помилка, то виводимо повідомлення про це та виходимо
    lea dx, error
    mov ah, 09h
    int 21h
    jmp exit

print_overflow: ; якщо було переповнення - то виводимо повідомлення про це та виходимо
    lea dx, error_overflow
    mov ah, 09h
    int 21h
    jmp exit

end_one:
    cmp di,1 ; якщо встановлено прапор, то
    jnz end_ask_for_number
    neg ax   ; робимо число негативним

end_ask_for_number:
    pop si
    ; всі символи з буфера оброблені число знаходиться в ax

mov [x], ax ; Сохраняємо результат конвертації у x

push si
; відновити регістри
mov ax, 0
mov bx, 0
mov cx, 0
mov dx, 0

mov ah,0ah
xor di,di
mov dx,offset buff ; адреса буфера
int 21h ; приймаємо рядок
mov dl,0ah
mov ah,02
int 21h ; виводимо переклад рядка

; обробляємо вміст буфера

mov si,offset buff+2 ; беремо адресу початку рядка
mov al, buff+2;
cmp al, 2Dh ; якщо перший символ мінус
jnz start_one_2
mov di,1  ; встановлюємо прапор
inc si    ; і пропускаємо його

start_one_2:
    xor ax,ax
    mov bx, 10  ; основа сc

start_two_2:
    mov cl,[si] ; беремо символ із буфера
    cmp cl,0dh  ; перевіряємо чи не останній він
    jz end_one_2

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
    jmp start_two_2     ; повторяемо

end_one_2:
    cmp di,1 ; якщо встановлено прапор, то
    jnz end_ask_for_number_2
    neg ax   ; робимо число негативним

end_ask_for_number_2:
    pop si
    ; всі символи з буфера оброблені число знаходиться в ax

mov [y], ax ; Сохраняємо результат конвертації у y


; Основна частина завдання

cmp x, 10  ; перевіряємо чи x більший за 10
jg case_three_check_y

cmp [x], 0; перевіряємо чи x дорівнюється 0
jg case_one_check_y
jl case_two_check_y
je case_four

case_one_check_y:
    cmp [y], 0 ; перевіряємо чи y дорівнюється 0
    jg case_one
    jng case_four

case_two_check_y:
    cmp [y], 0  ; перевіряємо чи y дорівнюється 0
    jl case_two
    jnl case_four

case_three_check_y:
    cmp y, 0 ; перевіряємо чи y дорівнюється 0
    je case_three
    jne case_one_check_y


case_one: ; випадок 1 (x + y) (x / y)
    mov dx, offset case_one
    mov ah, 9
    int 21h
    mov ax, [x]
    mov bx, [y]
    mul bx
    mov bx, ax ; сохраняємо x * y
    mov ax, [x]
    add ax, [y] ; x + y
    mov [divider], bx
    div bx ; розділити на (x * y)
    mov z, ax ; сохранити результат
    mov zr, dx
    jmp post_calculation


case_two: ; випадок 2 (25y)
    mov dx, offset case_two
    mov ah, 9
    int 21h
    mov ax, [y]
    mov bx, 25
    mul bx ; 25y
    mov [z], ax ; сохранити результат
    jmp post_calculation

case_three: ; випадок 3 (6x)
    mov dx, offset case_three
    mov ah, 9
    int 21h
    mov ax, [x]
    mov bx, 6
    mul bx ; 6x
    mov [z], ax ; сохранити результат
    jmp post_calculation

case_four: ; випадок 4 (1)
    mov dx, offset case_four
    mov ah, 9
    int 21h
    mov z, 1
    jmp post_calculation

post_calculation:
    mov ax, z
    mov cx, 0
    mov dx, 0

    cmp ax, 0
    jl print_minus
    je print_zero
    jge pre_print

print_zero:  ; вивести 0
    mov [mybyte], 48
    lea dx, [mybyte]
    mov ah, 09
    int 21h
    jmp check_floating_point

print_minus: ; вивести -
    mov [mybyte], 45
    lea dx, [mybyte]
    mov ah, 09
    int 21h
    mov ax, z
    neg ax
    mov cx,0
    mov dx,0

pre_print:
    cmp ax,0
    je print
    mov bx,10
    div bx
    push dx
    inc cx
    xor dx,dx
    jmp pre_print

print:
    cmp cx, 0
    je check_floating_point ; якщо є залишок - треба його вивести після точки
    pop dx
    add dx,48
    mov ah,02h
    int 21h
    dec cx
    jmp print

check_floating_point:
    cmp zr, 0
    je exit
    jne print_floating_point

print_floating_point:
    mov [mybyte], 46
    lea dx, [mybyte]
    mov ah, 09
    int 21h

    mov dx, zr
    mov cx, 10 ; вивести тільки перші 10 цифр пілся точки максимум

    floating:
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
        je exit
        loop floating

    jmp exit

exit:
    mov ah,4ch
    mov al,[exCode]
    int 21h

end Start