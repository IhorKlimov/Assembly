STSEG SEGMENT PARA STACK "STACK"
DB 64 DUP ( "STACK" )
STSEG ENDS
DSEG SEGMENT PARA PUBLIC "DATA"
exCode db 0
mybyte db " $"
input db 7, 8 dup(?)
error db "Incorrect number", 10, 13, "$"
error_overflow db "Number overflow", 10, 13, "$"
DSEG ENDS
CSEG SEGMENT PARA PUBLIC "CODE"

MAIN PROC FAR
ASSUME CS: CSEG, DS: DSEG, SS: STSEG
; адреса повернення
PUSH DS
MOV AX, 0 ; або XOR AX, AX
PUSH AX
; ініціалізація DS
MOV AX, DSEG
MOV DS, AX

CALL ASK_FOR_NUMBER

sub ax, 32
jo print_overflow_2

@print:
    cmp ax, 0
    jl print_minus
    je print_zero
    jge pre_print

    print_zero: ; вивести 0
        mov mybyte, '0'
        lea dx, mybyte
        mov ah, 09h
        int 21h
        jmp number_print_end

    print_minus: ; вывести -
        push ax
        mov mybyte, '-'
        lea dx, mybyte
        mov ah, 09h
        int 21h
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
        mov dl, 10
        mov ah, 02h
        int 21h ; наступна строка

@exit:
    mov ah,4ch
    mov al,[exCode]
    int 21h

print_overflow_2:
    lea dx, error_overflow
    mov ah, 09h
    int 21h
    jmp @exit

RET
MAIN ENDP

ASK_FOR_NUMBER PROC NEAR
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
    lea dx, error
    mov ah, 09h
    int 21h
    jmp @exit

print_overflow:
    lea dx, error_overflow
    mov ah, 09h
    int 21h
    jmp @exit

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
RET
ASK_FOR_NUMBER ENDP

CSEG ENDS
END MAIN