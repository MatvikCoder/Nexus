[org 0x7c00]

start:
	mov si, msg1
	call print
	mov si, welcome
	call print
main_loop:
	mov ah, 0x00
	int 0x16

	cmp al, 0x0d
	je enterr

	cmp al, 0x08
	je backsp
	
	mov ah, 0x0e
	int 0x10
	jmp main_loop

enterr:
    mov ah, 0x0e
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    jmp main_loop
backsp:
    mov ah, 0x0e
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp main_loop
print:
	mov ah, 0x0e
.loop:
	lodsb
	test al, al
	jz .done
	int 0x10
	jmp .loop
.done:
	ret

msg1 db "Loading...", 0x0D, 0x0A, 0 
welcome db "Welcome to NovaNexus", 0x0D, 0x0A, 0

times 510-($-$$) db 0
dw 0xAA55
