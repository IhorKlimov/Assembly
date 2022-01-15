init_ds macro ; макрос ініціалізації DS та ES
    ;--------------------------------- 1. Ініціалізація DS и ES---------------------------------------
    mov ax,data; data ідентифікатор, що створюються директивою model
    mov ds, ax ; Завантаження початку сегменту даних в регістр ds
    mov es, ax ; Завантаження початку сегменту даних в регістр es
endm

ask_for_number macro ; Макрос, який запрошує користувача ввести число з клавіатури та конвертує його у word, та зберігає у ax регістрі
    push si
    mov ah,0ah
    xor di,di
    mov dx, offset input ; аддрес буфера
    int 21h ; принимаем строку
    mov dl,0ah
    mov ah,02
    int 21h ; виводимо переклад рядка

    ; обробити вміст буфера

    mov si,offset input+2 ; берем аддрес начала строки
    mov al, input+2;
    cmp al, 2Dh ; якщо перший символ мінус
    jnz step_1
    mov di,1  ; ми встановлюємо прапор
    inc si    ; і пропустити його

    step_1:
        xor ax,ax
        mov bx, 10  ; фундація sc

    step_2:
        mov cl,[si] ; прочитав символ з буфера
        cmp cl,0dh  ; перевіряємо чи він останній
        jz end_negative

        ; якщо символ не останній, перевіряємо його на правильність
        cmp cl,'0'  ; якщо введено неправильний символ <0
        jb print_error
        cmp cl,'9'  ; якщо введено неправильний символ> 9
        ja print_error

        sub cl, '0' ; ми працюємо з числа символів
        imul bx     ; множимо на 10
        jo print_overflow
        add ax, cx  ; додати до решти
        jo print_overflow
        inc si     ; покажчик на наступний символ
        jmp step_2  ; повторюємо

    print_error:
        print error
        jmp exit

    print_overflow:
        print error_overflow
        jmp exit

    end_negative:
        cmp di,1 ; якщо прапор встановлений, то
        jnz end_ask_for_number
        neg ax   ; робимо число від’ємним

    end_ask_for_number:
        pop si
        ; всі символи з буфера обробляються числом в ax

    mov bx, 0
    mov cx, 0
    mov dx, 0
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

print_number macro ; Макрос, який виводить значення регістру ax у консоль
    cmp ax, 0
    jl print_minus
    je print_zero
    jge pre_print

    print_zero: ; вивести 0
        mov mybyte, '0'
        print mybyte
        jmp number_print_end

    print_minus: ; вывести -
        push ax
        mov mybyte, '-'
        print mybyte
        pop ax
        neg ax
        mov cx,0
        mov dx,0

    pre_print:
        cmp ax, 0
        je print_post
        mov bx, 10
        div bx
        push dx
        inc cx
        xor dx, dx
        jmp pre_print

    print_post:
        cmp cx, 0 ; виводимо число
        je number_print_end
        pop dx
        add dx, '0'
        mov ah, 02h
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
input db 7, 8 dup(?)
error db "Incorrect number", 10, 13, "$"
error_overflow db "Number overflow", 10, 13, "$"
DATA ENDS

STK SEGMENT STACK
DB 256 DUP ("?")
STK ENDS

CODE SEGMENT PARA PUBLIC "CODE"
ASSUME CS : CODE, DS : DATA, SS : STK

MAIN PROC
init_ds
ask_for_number  ; Визиваємо макрос, який запросить число у користувача з клавіатури
sub ax, 32 ; Вичитаємо 32
print_number ; Виводимо результат ax у консоль

exit:
    mov ah,4ch
    mov al,[exCode]
    int 21h

MAIN ENDP
CODE ENDS
END MAIN