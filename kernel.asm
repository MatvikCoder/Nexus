[org 0x0000]     

start:
  ; Настраиваем сегменты
  mov ax, 0x1000      ; Сегмент данных как у кода
  mov ds, ax
  mov es, ax
  mov ss, ax
  mov sp, 0xFFFE      ; Стек
  
  ; Очистка экрана
  mov ax, 0003h
  int 0x10
  
  ; Вывод приветствия
  mov si, welcome
  call print_string
  mov si, prompt
  call print_string
  
  ; Инициализация буфера
  mov byte [buffer_pos], 0
  
kernel_main:
  ; Ожидание нажатия клавиши
  mov ah, 0x00
  int 0x16

  cmp al, 0x0d        ; Enter
  je process_command
  
  cmp al, 0x08        ; Backspace
  je backspace_handler
  
  ; Проверка переполнения буфера
  cmp byte [buffer_pos], 63
  jge kernel_main
  
  ; Сохраняем символ
  movzx bx, byte [buffer_pos]
  mov [buffer + bx], al
  inc byte [buffer_pos]
  
  ; Выводим символ
  mov ah, 0x0e
  int 0x10
  jmp kernel_main

backspace_handler:
  cmp byte [buffer_pos], 0
  je kernel_main
  dec byte [buffer_pos]
  
  mov ah, 0x0e
  mov al, 0x08
  int 0x10
  mov al, ' '
  int 0x10
  mov al, 0x08
  int 0x10
  jmp kernel_main

process_command:
  ; Новая строка
  mov ah, 0x0e
  mov al, 0x0D
  int 0x10
  mov al, 0x0A
  int 0x10
  
  ; Добавляем нуль-терминатор
  movzx bx, byte [buffer_pos]
  mov byte [buffer + bx], 0
  
  ; Проверка пустой команды
  cmp byte [buffer_pos], 0
  je show_prompt
  
  ; Парсим команду
  mov si, buffer
  call parse_command
  
show_prompt:
  ; Сброс буфера
  mov byte [buffer_pos], 0
  
  ; Вывод приглашения
  mov si, prompt
  call print_string
  jmp kernel_main

parse_command:
  ; clear
  mov di, cmd_clear
  call string_compare
  jc do_clear
  
  ; help
  mov di, cmd_help
  call string_compare
  jc do_help
  
  ; ver
  mov di, cmd_ver
  call string_compare
  jc do_ver
  
  ; reboot
  mov di, cmd_reboot
  call string_compare
  jc do_reboot
  
  ; Неизвестная команда
  mov si, unknown_cmd
  call print_string
  ret

do_clear:
  mov ax, 0003h
  int 0x10
  ret

do_help:
  mov si, help_text
  call print_string
  ret

do_ver:
  mov si, version_text
  call print_string
  ret

do_reboot:
  mov si, reboot_msg
  call print_string
  mov ah, 0x00
  int 0x16
  jmp 0xFFFF:0x0000

; Функция сравнения строк
string_compare:
  push si
  push di
  push ax
  
.loop:
  mov al, [si]
  mov ah, [di]
  cmp al, ah
  jne .not_equal
  test al, al
  jz .equal
  inc si
  inc di
  jmp .loop
  
.not_equal:
  clc
  jmp .done
  
.equal:
  stc
  
.done:
  pop ax
  pop di
  pop si
  ret

; Функция вывода строки
print_string:
  mov ah, 0x0e
.loop:
  lodsb
  test al, al
  jz .done
  int 0x10
  jmp .loop
.done:
  ret

; Данные
welcome db "Welcome to NovaNexus OS", 0x0D, 0x0A, 0
prompt db "Nova> ", 0

buffer times 64 db 0
buffer_pos db 0

cmd_clear db "clear", 0
cmd_help db "help", 0
cmd_ver db "ver", 0
cmd_reboot db "reboot", 0

unknown_cmd db "Unknown command. Type 'help' for available commands.", 0x0D, 0x0A, 0
help_text db "Available commands:", 0x0D, 0x0A
         db "  clear  - Clear screen", 0x0D, 0x0A
         db "  help   - Show this help", 0x0D, 0x0A
         db "  ver    - Show version", 0x0D, 0x0A
         db "  reboot - Reboot system", 0x0D, 0x0A, 0
version_text db "NovaNexus OS version 1.0", 0x0D, 0x0A, 0
reboot_msg db "Press any key to reboot...", 0x0D, 0x0A, 0
