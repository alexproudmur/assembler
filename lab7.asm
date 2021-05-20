;------------------------------------------------------------------------------
; Дисципліна: Архітектура комп'ютера
; НТУУ "КПІ"
; Факультет: ФІОТ
; Курс: 1
; Група: ІТ-03
;------------------------------------------------------------------------------
; Автор: Бублик, Дудченко, Цуканова
; Дата: 18.05.2021
;------------------------------------------------------------------------------

;--------------------------І. Заголовок програми-------------------------------
IDEAL
MODEL small
STACK 2048

;--------------------------ІІ. Макроси------------------------------------------
MACRO M_init		; Макрос для ініціалізації. Його початок
	mov ax, @data	; ax <- @data
	mov ds, ax		; ds <- ax
	mov es, ax		; es <- ax
ENDM M_init		; Кінець макросу


;---------------------ІІІ. Початок сегменту даних--------------------------------
DATASEG
;заносимо значення змінних
a1 EQU -2
a2 EQU 3
a3 EQU 1
a4 EQU 2
a5 EQU 3
;створюємо "консоль користувача"
user_interf db "########################", 13, 10
            db "#---Menu from Team 8---#",13,10
            db "#---Press c to count---#",13,10
            db "#---Press V to sound---#",13,10
            db "#---Press b to exit----#",13,10
            db "########################",13,10, '$'
;вивід після виходу з програми  
user_interf_end db "Goodbye from team 8",13,10, '$'
;формула для обчислення
equation db "((a1 - a2) + a3 )/ a4 * a5 =>",13,10
		 db "a1 = -2",13,10
		 db "a2 = 3",13,10
		 db "a3 = 1",13,10
		 db "a4 = 2",13,10
		 db "a5 = 3",13,10
		 db 13,10
		 db " => Result = ", '$'


exCode db 0

; Константи
frequency EQU 20
duration EQU 1500
;					IV. Початок сегменту коду
CODESEG
Start:
	M_init
	; -----------------------------------------
	; Ініціалізація таймера
	mov al,1
	out 42h, al
	; Виводимо меню у консоль
	call draw_user_interf

	ask_for_input:
	; Зчитуємо символ, введений із клавіатури (AL <- input)
	mov ah, 08h
	int 21h
	call draw_user_interf

	; Перевірка вводу
	cmp al, "c"
	je c_pressed
	cmp al, "V"
	je V_pressed
	cmp al, "b"
	je b_pressed
	jmp ask_for_input

	c_pressed:
	; Обчислення прикладу
	call calculation
	jmp ask_for_input

	V_pressed:
	; Пищання у колонки
	call sound
	jmp ask_for_input

	b_pressed:
	; Вихід із програми
	mov ah, 09h
	mov dx, offset user_interf_end
	int 21h
	; -----------------------------------------
	mov ah, 4ch
	mov al, [exCode]
	int 21h

	; =================================== Процедури ===================================
	; ----------------------------1. Виведення інтерфейсу -----------------------------
	; Призначення: вивід інтерфейсу
	; Вхід: ---
	; Вихід: ---
	; ---------------------------------------------------------------------------------
	PROC draw_user_interf
		push ax
		push dx

		; Очищаємо консоль
		mov ax,03h
		int 10h
		; Виводим текст у консоль
		mov ah, 09h
		mov dx, offset user_interf
		int 21h

		pop dx
		pop ax
		ret
		ENDP draw_user_interf

	; ----------------------------2. Обчислення результату -----------------------------
	; Призначення: обчислення виразу, та його виводу на екран
	; Вхід: ---
	; Вихід: ---
	; ----------------------------------------------------------------------------------
	PROC calculation

		; Підготовка декоративного тексту
		mov ah, 09h
		mov dx, offset equation
		int 21h
		mov ax, 0

		
	    xor dx, dx		; dx <- 0
	    mov ax, a1		; ax <- a1
	    mov bx, a2		; bx <- a2
	    sub ax, bx		; ax <- a1-a2


	    mov bx, a3 		; bx <- a3
	    add ax, bx 		; ax <- ax + bx
	
	    mov bx, a4		; bx <- a4
	    idiv bx			; ax <- ax/bx
	
        mov bx, a5		; bx <-a5
        imul bx		    ; ax <- ax*bx

        cmp al, 0
		jns number_printer
		;якщо результат від'ємний
		minus_printer:
			neg ax
			push ax

			mov dl, "-"
			mov ah, 02h
			int 21h

			pop ax

		; Вивід результату у консоль
		number_printer:
		; Конвертуємо результат у ASCII код нашого числа
		add al, 30h
		; Виводимо число у консоль
		mov dl, al
		mov ah, 02h
		int 21h
	    ret				; повертаємось з процедури
		
    ENDP calculation

	; ----------------------------3. Програвання звуку --------------------------------
	; Призначення: програвання звуку
	; Вхід:
	; frequency <- частота звуку
	; duration <- тривалість звуку
	; Вихід: звук
	; ---------------------------------------------------------------------------------
	PROC sound
		in al, 61h       ;одержуємо стан динаміка
        push ax          ;зберігаємо стан динаміка
        or al, 00000011B ;зміна стану на включений динамік
        out 61h, al      ;занесення стану
        mov al, FREQUENCY;виставляємо частоту
        out 42h, al      ;вмикаємо таймер, що буде подавати імпульси на динамік за заданою частотою
        call waiting     ;виклик процедури очікування
        pop ax           ;повернення стану динаміка
        and al, 11111100B;зміна стану на виключений динамік
        out 61h, al      ;занесення стану
        ret
    ENDP sound

	; ----------------------------4. Очікування --------------------------------
	; Призначення: очікування
	; Вхід: ---
	; Вихід: ---
	; ---------------------------------------------------------------------------------
	PROC waiting ;перебіг циклом два рази
		push cx
        mov cx, duration
        loop1:             	  
        PUSH cx	             
        MOV  cx,  duration
        loop2:
            LOOP loop2
        POP  cx
        LOOP loop1
        pop cx
        ret
    ENDP waiting


end Start