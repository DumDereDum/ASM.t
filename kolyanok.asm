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
	
	mov ah, 0Ah 
	mov dx, offset filename
	int 21h
	
	call read_filename

	jc error1
	
	mov handle, ax
	


	mov bx, handle
	mov ah, 3Fh
	mov cx, 2048
	mov dx, offset buffer
	int 21h
	jc error2
	
	cmp ax,0
	je off
	mov cx, ax
	
	mov si, offset buffer
	
cycle:
	lodsb
	call find_max_len
	loop cycle

	mov dx,max_len
	call print

	jmp off
	
press_button1:

	call print_ECS_Space
	
	call press_button
	
	cmp al, 20h	
	je begin
	
	cmp al, 1Bh 
	je off
	
	jmp start
	
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

read_filename proc

	xor bh, bh
	mov bl, filename[1]
	mov filename[bx+2], 0
	mov ax, 3D00h
	mov dx, offset filename+2
	int 21h
	
	ret
read_filename endp

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

find_max_len proc
	cmp al, 20h
	je zero_len
	inc len
	cmp al, 10h
	je decrice 
	cmp al, 13h
	je decrice
	
	jmp offproc 
	
	decrice:
	dec len
	
	zero_len: 
	push bx 
	mov bx, max_len
	cmp bx, len  
	jl exh
	mov len, 0
	jmp offproc
	
	exh: 
	mov bx, len
	mov max_len,bx
	mov len,0
	pop bx   
	
	offproc:
	ret
find_max_len endp

press_button proc
	mov ah, 10h
	int 16h
	ret
press_button endp	

;----------Данные----------
	filename db 40 dup (' ')
	buffer dw 65534 dup(' ')
	handle dw 0
	reg dw 0
	max_len dw 0
	len dw 0
;----------Сообщения---------	
	msg_error_file db ' Error: file is not found', 0Ah, 0Dh, '$'
	msg_error_buffer db ' Error: can not read file', 0Ah, 0Dh, '$'
	msg_press_ESC db 'Press ESC for exit', 0Ah, 0Dh, '$'
	msg_press_Space db 'Press Space for continue', 0Ah, 0Dh, '$'
	msg_write_name db 'Write a filename', 0Ah, 0Dh, '$'

CSEG ends
end start
