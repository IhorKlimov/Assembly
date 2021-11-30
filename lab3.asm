TITLE ЛР_3
;------------------------------------------------------------------------------
;ЛР №1.3
;------------------------------------------------------------------------------
; Архітектура комп'ютера
; Завдання: ДОСЛІДЖЕННЯ МЕХАНІЗМІВ АДРЕСАЦІЇ АРХІТЕКТУРІ ІА-32 (Х86) У REAL ADRESS MODE
; ВУЗ: КНУУ "КПІ"
; Факультет: ФІОТ
; Курс: 1
; Група: ІТ-з01
;------------------------------------------------------------------------------
; Автори: Клімов І.С., Бардах (Івко) М., Ропаєва Д.І., Трущак О. І.
; Дата: 25/03/21
;------------------------------------------------------------------------------
;I.ЗАГОЛОВОК ПРОГРАМИ
IDEAL ; Директива - тип Асемблера tasm
MODEL small ; Директива - тип моделі пам’яті
STACK 256 ; Директива - розмір стеку
;II.МАКРОСИ
;III.ПОЧАТОК СЕГ arr_rnd1МЕНТУ ДАНИХ
DATASEG
;Оголошення двовимірного експериментального масиву 16х16
array2Db db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
         db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
         db 77, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
         db 0, 66, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
         db 0, 0, 73, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
         db 0, 0, 0, 75, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
         db 0, 0, 0, 0, 79, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
         db 0, 0, 0, 0, 0, 84, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
         db 0, 0, 0, 0, 0, 0, 68, 0, 0, 0, 0, 0, 0, 0, 0, 0
         db 0, 0, 0, 0, 0, 0, 0, 82, 0, 0, 0, 0, 0, 0, 0, 0
         db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
         db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
         db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
         db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
         db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
         db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

exCode db 0

;VI. ПОЧАТОК СЕГМЕНТУ КОДУ
CODESEG
Start:
;--------------------------------- 1. Ініціалізація DS и ES---------------------------------------
mov ax,@data; @data ідентифікатор, що створюються директивою model
mov ds, ax ; Завантаження початку сегменту даних в регістр ds
mov es, ax ; Завантаження початку сегменту даних в регістр es
;----------------------------------3. Операція зупинки програми, очікування натискання клавіш-----
mov ah,01h
; Завантаження числа 01h до регістру ah
; (Функція DOS 1h - команда очікування натискання клавіші...)
int 21h ; Виклик функції DOS 1h
; Завантаження числа 4ch до регістру ah
; (Функція DOS 4ch - виходу з програми)
;---------------------------------4. Вихід з програми---------------------------------------------
mov ah,4ch
mov al,[exCode] ; отримання коду виходу
int 21h ; виклик функції DOS 4ch
end Start