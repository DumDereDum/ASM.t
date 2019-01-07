;Программа заменяет в текстовом файле все цифры на символы нижнего регистра
;первого ряда клавиатуры, т.е. цифра+shift. Записывает файл на диск с другим именем,
;если оно не задано, то с тем же. Текст берется из файла заданного в командной
;строке. Если файл не задан, программа должна его запросить.


; ПРОБЛЕМА1: в выводе последнего куска выводит мусор
; РЕШЕНИЕ1: в конце программы переносится курсор в файле хотя он и так переносился командой
;
;
;
;

code_seg segment

; проверка допустимости каждого обращения к именной ячейке памяти 
; с учетом значения текущего сегмента регистра 
; с помощью директивы ASSUME
assume cs:code_seg				; директива дающая информацию о сегменте кода для того, чтобы установить выполняемую программу
assume ds:code_seg,ss:code_seg 	; директива дающая информацию к каким ячейкам памяти можно адресовываться в данный момент

org 100h						; выделение 256 байт для префикса сегмента программы (PSP) 

start:  
   
	mov ah, 9h
	mov dx, offset msg
	int 21h
	;
	;
	int 20h
	msg db "enter file name$"
                
	mov dx, offset fname 		; адрес имени файла
	mov ah, 0Ah					; 0Ah - функция ввода строки
	int 21h 					; 

	xor bh, bh					; логическая операция "не-или", или "не равно"
	mov bl, fname[1]			; присваивание bl номер первой строки в файле
	mov fname[bx+2],0  			; 
	mov ax, 3d00h   			; функция 3d00h - открыть файл для чтения
	mov dx, offset fname+2 		; 
	int 21h  					; 
	
	mov Handler, ax 			; сохранение дескриптора
	jnc noerror1  				;    ПЕРЕХОД ЕСЛИ ОШИБОК В НАПИСАНИИ ФАЙЛА НЕТ
	mov ah, 09h					; функция 09h - вывод строки символов
	mov dx, offset err1			;   
	int 21h  					; 	ЗДЕСЬ НУЖНО НАПИСАТЬ ВЫВОД ОШИБКИ
	int 20h 					; 

noerror1:  
	mov ah, 3Fh 				; функция 3Fh - читать файл через описатель
	mov bx, Handler 			; дескриптор (описатель)
	mov cx, 1999				; число списываемых байт
	mov dx, offset BufIn 		; адрес буфера для чтения
	int 21h 					; 
	
	jnc noerror2  				; 	ЕСЛИ ЗДЕСЬ ОШИБОК НЕТ ТО ПЕРЕХОД			*jnc - безусловный переход
	mov ah, 09h					; функция 09h - вывод строки символов
	mov dx, offset err1			; 
	int 21h						; 
	int 20h 					;

noerror2: 
	mov cx, ax					; 
	push ax 					; 
	mov ah, 02h					; функция 02h - вывод символа
	mov dx, 13					; 
	int 21h						; 
	mov ah, 02h					; функция 02h - вывод символа
	mov dx, 10					; 
	int 21h  					; 
	lea si, BufIn 				; 	ЗАПИСЫВАЕТ В si АДРЕС ВТОРОГО АПЕРАНДА
	mov di, cx					; 




; ИЗМЕНЕННЫЙ БЛОК С ЗАМЕНОЙ ИЗ МОЕЙ ЛАБЫ
; ----------------------------------------------------------------------------
cikl:

; сюда не смотри это чисто для себя 
; 0-) 1-! ; 2-@ ; 3-# ; 4-$ ; 5-% ; 6-^ ; 7-& ; 8-* ; 9-( 

	lodsb   					; загрузить искомый операнд в al
	
	cmp al, 48					
	je zamena0 					

	cmp al, 31h					
	je zamena1  				
	
	cmp al, 32h					
	je zamena2					
	
	cmp al, 33h					 
	je zamena3 					 
	
	cmp al, 34h					 
	je zamena4				 
	
	cmp al, 35h					
	je zamena5					
	
	cmp al, 36h					
	je zamena6					
	
	cmp al, 37h					 
	je zamena7

	cmp al, 38h					 
	je zamena8
	
	cmp al, 39h					 
	je zamena9	
	

pechat:
	mov ah, 02h					; функция 02h - вывод символа
	mov dl, al					; 
	mov dh, 0					; 
	int 21h 					; 
	mov ah, 0					; 
	mov bl, 80					; 
	div bl						; 		
	test ah, ah					; 
	jnz nokrat 					; 
	mov ah, 02h					; функция 02h - вывод символа
	mov dx, 13					; 
	int 21h						; 
	mov ah, 02h					; функция 02h - вывод символа
	mov dx, 10					; 
	int 21h						; 

nokrat:
	loop cikl					;  
	jmp press					; безусловный переход на press




; блок моей лабы который не используется в твоей 
;-------------------------------------------
;	zamena: 
;	mov ah, 02h					; функция 02h - вывод символа
;	mov dx, 20h					; замена знака на пробел 
;	int 21h 					; 
;	loop cikl 					; переход обратно к циклу если значение реистра CX больше 0
;-------------------------------------------

; сюда не смотри это чисто для себя 
; 0-) 1-! ; 2-@ ; 3-# ; 4-$ ; 5-% ; 6-^ ; 7-& ; 8-* ; 9-( 

zamena0: 
	mov ah, 02h					
	mov dx, 29h					
	int 21h 					 
	loop cikl 					
zamena1: 
	mov ah, 02h					
	mov dx, 21h					
	int 21h 					 
	loop cikl 
zamena2: 
	mov ah, 02h					
	mov dx, 40h					
	int 21h 					 
	loop cikl 
zamena3: 
	mov ah, 02h					
	mov dx, 23h					
	int 21h 					 
	loop cikl 
zamena4: 
	mov ah, 02h					
	mov dx, 24h					
	int 21h 					 
	loop cikl 
zamena5: 
	mov ah, 02h					
	mov dx, 25h					
	int 21h 					 
	loop cikl 
zamena6: 
	mov ah, 02h					
	mov dx, 5eh					
	int 21h 					 
	loop cikl 
zamena7: 
	mov ah, 02h					
	mov dx, 26h					
	int 21h 					 
	loop cikl 
zamena8: 
	mov ah, 02h					
	mov dx, 2ah					
	int 21h 					 
	loop cikl 
zamena9: 
	mov ah, 02h					
	mov dx, 28h					
	int 21h 					 
	loop cikl 
; ----------------------------------------------------------------------------



press:   
	cmp di, 1998 				; если значение di выше чем 1998 
	jna jumpi					; то прыжек на jumpi (т.е. int 20h)
	
	mov ah, 0h					; как работают эти две строчки я не ебу но вроде нажно ожидать следующее нажатую клавишу
	int 16h						; тоже хз что етто вызывает прерывание
	
	cmp ax, 1C0Dh				; если значение регистра ax НЕ равно 1С0Dh 
	jne press   				; то прыжек на press
	
	mov ax, 4201h				; 
	mov bx, Handler 			; 
	mov cx, 0					; 
	mov dx, 1999				; 
	int 21h						;  
	jmp noerror1 				; 
	
jumpi:
	int 20h						; прерывание

; data

fname db 15,0,15 dup()			; 
BufIn DB 2048 dup (1) 			; 
err1 db 13,10,'error','$'		; 
Handler DW ? 					; 
   
code_seg ends					; конец сегмента

end start						; 
