CSEG segment
assume cs:CSEG
assume ds:CSEG
assume es:CSEG

org 100h

start:
	jmp begin
	
int_2Fh_vector dd ?
old_09h dd ?	
flag db 0
mode db 0

new_09h proc far

	pushf
	push ax
		in al, 60h
		cmp al, 58h
		je hotkey
	pop ax
	popf
		jmp dword ptr cs:[old_09h]
		
	hotkey:
		
		sti
		in al, 61h
		or al, 80h
		out 61h, al
		and al, 7Fh
		out 61h, al
		
			push bx
			push cx
			push dx
			push ds
			
			push cs
			pop ds
		
		inc mode
		cmp mode, 08h
		jne s
		s:
		mov ah, 00h
		mov al, mode
		int 10h
		
			pop ds
			pop dx
			pop cx
			pop bx 
			
		cli
		mov al, 20h
		out 20h, al
		
	pop ax
	popf
	iret
new_09h endp
	
int_2Fh proc far

		cmp ah, 0C7h
		jne pass_2Fh
		cmp al, 00h
		je inst
		cmp al, 01h
		je unins
		jmp short Pass_2fh
	inst:
		mov al, 0FFh
		iret
	pass_2Fh:
		jmp dword ptr cs:[int_2Fh_vector]
	unins:
			push bx
			push cx
			push dx
			push es
		
		mov cx, cs
		cmp cx, 3509h
		int 21h
		
		mov dx, es
		cmp cx, dx
		jne not_remote
		
		cmp bx, offset cs:new_09h
		jne not_remote
		
		mov ax, 352Fh 
		int 21h
		
		mov dx, es
		cmp cx, dx
		jne not_remote
		
		cmp bx, offset cs:int_2Fh
		jne not_remote
	
	push ds 
			
		lds dx, cs:old_09h
	
		mov ax, 2509h
		int 21h
		
		lds dx, cs:int_2Fh_vector	
		mov ax, 252Fh
		int 21h
		
	pop ds
			
		mov es, cs:2Ch
		mov ah, 49h
		int 21h
		
		mov ax, cs
		mov es, ax
		mov ah, 49h
		int 21h
		
		mov al, 0Fh
		jmp short pop_ret
	
	not_remote:
		mov al, 0F0h
	pop_ret:
			pop es
			pop dx
			pop cx
			pop bx
			
		iret
int_2Fh endp

begin:
	mov cl, es:80h
	cmp cl, 0
	je check_install
	
	xor ch, ch
	cld
	mov di, 81h
	mov si, offset key
	mov al, ' '

repe	scasb
		dec di
		mov cx, 04h
repe	cmpsb

	jne check_install
	inc flag_off
	
check_install:
	mov ax, 0C700h
	int 2Fh
	cmp al, 0FFh
	je already_ins
	
	cmp flag_off, 1
	je xm_stranno
	
	mov ax, 352Fh
	int 21h
	
	mov word ptr int_2Fh_vector, bx
	mov word ptr int_2Fh_vector+2,es
	
	mov dx, offset int_2Fh
	mov ax, 252Fh
	int 21h
	
	mov ax, 3509h
	int 21h
	
	mov word ptr old_09h, bx
	mov word ptr old_09h+2, es
	mov dx, offset new_09h
	
	mov ax, 2509h
	int 21h
	
		mov dx, offset msg1
		call print
	
	mov dx, offset begin
	int 27h
	
already_ins: 

	cmp flag_off, 01h
	je uninstall
	lea dx, msg
	call print 
	int 20h
	
uninstall:

	mov ax, 0C701h
	int 2Fh
	cmp al, 0F0h
	je not_sucsess
	cmp al, 0Fh
	jne not_sucsess
	mov dx, offset msg2 
	call print 
	int 20h
	
not_sucsess:
	mov dx, offset msg3
	call print 
	int 20h
	
xm_stranno:
	mov dx, offset msg4
	call print 
	int 20h
	
key db '/off'
flag_off db 0
msg db 'already'
msg1 db 'installed',0Dh,0Ah,'$'
msg4 db 'just '
msg3 db 'not '
msg2 db 'uninstalled',0Dh,0Ah,'$'

print 	proc near
	mov ah, 09h
	int 21h
	ret
print endp	

CSEG ends
	end start
