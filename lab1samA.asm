; Ввести текст из файла и вывести на экран только латинские буквы, вместо других
; символов выводить пробел. Выводить на экран (на экране 25 строк и 80столбцов)
; первую порцию, т.е. 25 строк, затем программа ждет нажатия Enter и распечатывает
; следующую порцию информации из файла. Текст выводится из файла, заданного в
; командной строке. Если файл не задан, программа должна запросить его.


CSEG segment 
assume cs: CSEG
assume ds: CSEG
assume ss: CSEG

org 100h


start:
	
	jmp press_button1

begin:

	mov dx, offset msg_write_name
	call print
	
	mov ah, 0Ah ; функция которая записывает в буфер то что ввели в строчке
	mov dx, offset filename
	int 21h
	
	xor bh, bh
	mov bl, filename[1]
	mov filename[bx+2], 0
	mov ax, 3D00h
	mov dx, offset filename+2
	int 21h
	jc error1
	
	mov handle, ax	
a:	
	mov bx, handle
	mov ah, 3Fh
	mov cx, 80
	mov dx, offset buffer
	int 21h
	jc error2
	
	
    mov cx, 80
	mov si, offset buffer
	mov di, cx
	
cycle:
	lodsb
	call change_and_print
	loop cycle
	
	jmp press_button2

continue:
	
	cmp di, 79
	jna off
	mov ax, 4201h
	mov bx, handle
	mov cx, 0
	mov dx, 2
	int 21h

	jmp a
	
	jmp off
	
press_button1:

	call print_ECS_Space
	
	call press_button
	
	cmp al, 20h	
	je begin
	
	cmp al, 1Bh 
	je off
	
	jmp start
	
press_button2:	

	push ax
	push dx
	
	call print_ECS_Space
	
	call press_button
	
	cmp al, 20h	
	je continue
	
	cmp al, 1Bh 
	je off
	
	jmp press_button2
	
	push ax
	push dx
error1:
	push ax
	push dx
	
	mov dx, offset msg_error_file
	call print 
	
	push ax
	push dx
	
	jmp begin
	
error2:

	push ax
	push dx
	
	mov dx, offset msg_error_buffer
	call print 
	
	pop dx
	pop ax
	jmp begin
	
off:
	int 20h

;----------Пoдпрограммы----------

print_ECS_Space proc
	
	mov dx, offset msg_press_ESC
	call print 
	mov dx, offset msg_press_Space
	call print 
	
	ret
print_ECS_Space endp

print proc
	mov ah,09h
	int 21h
	ret
print endp

press_button proc
	mov ah, 10h
	int 16h
	ret
press_button endp	

change_and_print proc

	cmp al, 41h 
	jb exchange 
	
	cmp al, 5Bh 
	je exchange 
	
	cmp al, 5Ch 
	je exchange 
	
	cmp al, 5Dh 
	je exchange 

	cmp al, 5Eh 
	je exchange 

	cmp al, 5Fh 
	je exchange 
	
	cmp al, 60h 
	je exchange 
	
	cmp al, 7Ah 
	ja exchange 
	
	jmp printt
	
exchange: 
	mov al, 20h

printt: 
	push ax
	push dx
	mov ah, 02h
	mov dl, al
	int 21h
	pop dx
	pop ax
	ret
change_and_print endp

;----------Данные----------
	filename db 40 dup (' ')
	buffer dw 80 dup(' ')
	handle dw 0
;----------Сообщения---------	
	msg_error_file db ' Error: file is not found', 0Ah, 0Dh, '$'
	msg_error_buffer db ' Error: can not read file', 0Ah, 0Dh, '$'
	msg_press_ESC db 'Press ESC for exit', 0Ah, 0Dh, '$'
	msg_press_Space db 'Press Space for continue', 0Ah, 0Dh, '$'
	msg_write_name db 'Write a filename', 0Ah, 0Dh, '$'

CSEG ends
end start
