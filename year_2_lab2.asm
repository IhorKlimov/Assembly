IDEAL ; Директива - тип Асемблера tasm
MODEL small ; Директива - тип моделі пам’яті
STACK 256 ; Директива - розмір стеку

DATASEG
number db -1
result db 0, "$"
exCode db 0
maxlen db 3
len db 0
msg db 3 dup(?)
counter db 0
mybyte db " $"



CODESEG
Start:
;--------------------------------- 1. Ініціалізація DS и ES---------------------------------------
mov ax,@data; @data ідентифікатор, що створюються директивою model
mov ds, ax ; Завантаження початку сегменту даних в регістр ds
mov es, ax ; Завантаження початку сегменту даних в регістр es
;----------------------------------2. Операція виводу на консоль---------------------------------

mov ah, 0ah
mov dx, offset maxlen
int 21h ; keyboard input

mov dl, 10
mov ah, 02h
int 21h ;new line feed

mov ax, 0
mov al, msg
sub al, 48 ; subtract 32 from the number

mov result, al ; save result to memory

sub ax, 4

@showtwodigits:
mov counter, 1
mov bl, 10
div bl
add al, 48
add ah, 48
mov cl, al  ; whole
mov ch, ah  ; remainder
mov mybyte, cl
jmp @print

@seconddigit:
mov mybyte, ch
inc counter
jmp @print

@print:
lea dx, mybyte
mov ah, 09
int 21h
cmp counter, 2
je @exit
jl @seconddigit

@exit:
mov ah, 4ch
int 21h

end Start