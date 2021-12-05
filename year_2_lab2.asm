IDEAL ; Директива - тип Асемблера tasm
MODEL small ; Директива - тип моделі пам’яті
STACK 256 ; Директива - розмір стеку

DATASEG
exCode db 0
maxlen db 3
len db 0
msg db 3 dup(?)
counter db 0
mybyte db " $"
result db 6
isnegativeinput db 0


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

mov bx, ax

cmp len, 1
je @printonedigitmessage
jg @printtwodigitmessage

@printonedigitmessage:
mov ax, bx
mov bx, 0
jmp @subtraction

@printtwodigitmessage:
mov ax, bx
mov bx, 0

@converttwodigitbytestoone:
mov ax, 0

cmp msg, 45
je @handlenegative
jne @nextone

@nextone:
cmp msg, 43
je @handlepositive
jne @continueconverttwodigitbytestoone

@handlenegative:
mov msg, 48
mov isnegativeinput, 1
jmp @continueconverttwodigitbytestoone

@handlepositive:
mov msg, 48
jmp @continueconverttwodigitbytestoone

@continueconverttwodigitbytestoone:
mov al, msg
sub al, 48
mov bl, 10
mul bl
mov dl, msg + 1
sub dl, 48
add al, dl

cmp isnegativeinput, 1
je @converttonegative
jne @subtraction

@converttonegative:
mov bl, al
sub al, bl
sub al, bl

@subtraction:
sub al, 32
mov result, al

@showtwodigits:
mov counter, 1
cmp result, 0
jl @printminus
jge @showtwodigitscontinue

@printminus:
mov mybyte, 45
lea dx, mybyte
mov ah, 09
int 21h
mov ax, 0
mov al, result
neg al


@showtwodigitscontinue:
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
mov ah,4ch
mov al,[exCode]
int 21h

end Start