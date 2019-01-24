; Ввести текст из файла и вывести на экран только латинские буквы, вместо других
; символов выводить пробел. Выводить на экран (на экране 25 строк и 80столбцов)
; первую порцию, т.е. 25 строк, затем программа ждет нажатия Enter и распечатывает
; следующую порцию информации из файла. Текст выводится из файла, заданного в
; командной строке. Если файл не задан, программа должна запросить его.
;


code_seg segment ;начало сегмента

assume cs: code_seg
assume ds: code_seg, ss: code_seg

org 100h

start:

	mov ah, 09h ;вывод строки
	mov dx, offset vvod
	int 21h

	mov dx, offset filename
	mov ah, 0Ah ; 0Ah -  ввод строки в буфер, как я понял, в DX закладывается то что введу в строке
	int 21h
	
	; нужна для выебонов |xor bh,bh| ; xor - функция "не или", в данном применении не понимаю зачем оно надо так как это обычное обнуление регистра BH 
	mov bh,0 ; обнуление по пацански
	mov bl, filename[1] ; ПОКА ХЗ
	mov filename[bx+2],0 ; ПОКА ХЗ
	mov al,0 ; обнуление AL иначе там мусор появляется
	mov ah, 3Dh ; 3Dh - открытие файла
	mov dx, offset filename+2 ; ПОКА ХЗ
	int 21h
	
	mov Handler, ax
	jnc noerror1 ; переход если нет ошибок то есть CF=0
	mov ah,09h ; если есть ошибка, по печатется сообщение об ошибке
	mov dx, offset errorletter
	int 21h
	int 20h
	
noerror1:
	
	mov ah, 3Fh ; 3Fh - читать файл через описатель
	mov bx, Handler
	mov cx, 0800h ;0800h 7CF=1999 просто число списываемыч байт(символов) 25х80=2000
	mov dx, offset BufIn
	int 21h
	
	jnc noerror2 ; переход если нет ошибок то есть CF=0
	mov dx, offset errorletter
	int 21h
	int 20h
	
noerror2:
	
	mov cx,ax ; ПОКА ХЗ
	push ax ; ПОКА ХЗ, но империческим путем выяснил что без нее не выходит из цикла
	; скорее всего это нужно чтобы запомнить значение AX для цикла
	
	mov ah, 02h
	mov dx, 0Dh ; D=13 ; команда обозначающая продолжение печати с начала текущей строчки(не с новой)
	int 21h
	
	mov ah, 02h
	mov dx, 0Ah ; A=10 ; ну тупо перекидывает на новую строчку и всио... ; как я понял, ждет Enter, а потом перекидывает
	int 21h
	
	lea si, BufIn ; ПОКА ХЗ
	mov di, cx ; ПОКА ХЗ
	
cycle: ; тут пошла проверка символов
	
	lodsb ; считать байт по адресу DS:(E)SI в AL
	
	cmp al, 41h ;  сравнение кода AL и 40h
	jb exchange ; если < то прыжек на exchange
	
	cmp al, 5Bh ; сравнение AL и 5Bh
	je exchange ; если = то прыжек на exchange
	
	cmp al, 5Ch ; сравнение AL и 5Ch
	je exchange ; если = то прыжек на exchange
	
	cmp al, 5Dh ; сравнение AL и 5Dh
	je exchange ; если = то прыжек на exchange

	cmp al, 5Eh ; сравнение AL и 5Eh
	je exchange ; если = то прыжек на exchange

	cmp al, 5Fh ; сравнение AL и 5Fh
	je exchange ; если = то прыжек на exchange
	
	cmp al, 60h ; сравнение AL и 60h
	je exchange ; если = то прыжек на exchange
	
	cmp al, 7Ah ; сравнение AL и 7Ah 
	ja exchange ; если > то прыжек на exchange	
	
print:
	
	mov ah, 02h
	mov dx,0 ; обнуление, чисто на всякий, вдруг каким то хуем туда мусор попадет, и все... пиздец...
	mov dl, al
	int 21h
	
	mov ah, 0 ; ХЗ зачем, без этого код тоже норм работает
	mov bl, 50h
	div bl ; какого то хрена мы делим AL на BL, а остаток от деления идет в AH и потом сравнивается
	test ah,ah ; опять же не вижу в этом смысла потому что ZF всегда равна нулю только если AH != 0
	jnz nokrat ; переход при ZF=0

w_ent:	
	mov ah,01h
	int 21h
	cmp al, 0Dh ;  ожидает Ентер
	je nokrat
	cmp al, 20h ; нажать spase для выхода
	je off
	
	
	mov ah,09h
	mov dx, offset let_ent
	int 21h
	
	jmp w_ent
	
nokrat:
	
	loop cycle
	jmp print
	
exchange:
	
	mov ah, 02h
	mov dx,20h ; замена на " " (т.е. spase)
	int 21h
	loop cycle ; возвращение к циклу

press:
	
	cmp di, 07FFh ; 07ffh   07CE=1998 ну сравнивает счетчик операции с 1998, возможно это надо для проверки кол-ва проверенных знаков
	jna off ; CF=1 или ZF=1 тогда будет прыжек
	
	; если все четко то тут закончится работа, а если нет, то все начинается заново
	
	mov ah,0 ; обнуление так как туда сейчас запишется скан-код клавиши
	int 16h ; ну тип запись в AH скан кода
	
	cmp ax, 1C0Dh ; 1C0D = 7181
	jne press ; при ZF=0 прыжек, там еще операция "не нуль"
	
	mov ax, 4201h
	mov bx, Handler
	mov cx, 0
	mov dx, 1999
	int 21h
	jmp noerror1


off:
	int 20h

let_ent db "Press Enter, please...$"
	
vvod db "enter file name: $" ; db - выделение памяти под 1 байт

filename db 15,0,15 dup() ; dup() - в скобках указывается чем нужно заполнить 
; 15 - максимальная длина ввода 
; 0 - дефствительная длина (до ввода она равна 0)
; 15 dum() - 15 'коробочек' забиваются хуй пойми чем 

errorletter db "error, please reload program... $"

Handler DW ?

BufIn DB 2048 dup(1) ; как я понял:
; DB - показывает что создаются символы
; 2048 - кол-во символов, почему столько я хз
; dup(1) - заполнить 2048 единицами

code_seg ends ;конец сегмента

end start 	
	

