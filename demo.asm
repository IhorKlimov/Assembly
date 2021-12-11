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

case_one db "Case one", 10, 13, "$"
case_two db "Case two", 10, 13, "$"
case_three db "Case three", 10, 13, "$"
case_four db "Case four", 10, 13, "$"


CODESEG
Start:
;--------------------------------- 1. Ініціалізація DS и ES---------------------------------------
mov ax,@data; @data ідентифікатор, що створюються директивою model
mov ds, ax ; Завантаження початку сегменту даних в регістр ds
mov es, ax ; Завантаження початку сегменту даних в регістр es
;----------------------------------2. Операція виводу на консоль---------------------------------
mov ax, 1
sal ax, 1

@exit:
    mov ah,4ch
    mov al,[exCode]
    int 21h

end Start