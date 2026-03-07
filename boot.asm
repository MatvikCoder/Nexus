[org 0x7c00]

start:
  ; Сохраняем номер загрузочного диска
  mov [boot_drive], dl

  ; Очистка экрана
  mov ax, 0003h
  int 0x10

  ; Вывод сообщения о загрузке
  mov si, loading_msg
  call print_string

  ; Сброс дисковой системы (на всякий случай)
  mov ah, 0x00
  mov dl, [boot_drive]
  int 0x13

  ; Загрузка ядра с повторными попытками
  mov si, 0x03        ; 3 попытки загрузки

.retry:
  push si

  mov ah, 0x02        ; Функция чтения
  mov al, 0x20        ; Читаем 32 сектора (16KB)
  mov ch, 0x00        ; Цилиндр 0
  mov cl, 0x02        ; Сектор 2
  mov dh, 0x00        ; Головка 0
  mov dl, [boot_drive] ; Используем сохраненный диск
  mov bx, 0x1000      ; Сегмент
  mov es, bx
  xor bx, bx          ; es:bx = 0x1000:0x0000
  int 0x13

  pop si
  jnc .success        ; Успешно?

  ; Ошибка - уменьшаем счетчик попыток
  dec si
  jz disk_error       ; Попытки кончились

  ; Сброс диска перед следующей попыткой
  mov ah, 0x00
  mov dl, [boot_drive]
  int 0x13

  ; Небольшая задержка (можно убрать)
  mov cx, 0xFFFF
.delay:
  loop .delay

  jmp .retry          ; Еще попытка

.success:
  mov si, success_msg
  call print_string

  ; Переход в защищенный режим (если нужно) или прямой прыжок
  jmp 0x1000:0x0000

disk_error:
  mov si, error_msg
  call print_string

  ; Ждем нажатия клавиши
  mov ah, 0x00
  int 0x16

  ; Перезагрузка через BIOS
  int 0x19

print_string:
  pusha
  mov ah, 0x0e
.loop:
  lodsb
  test al, al
  jz .done
  int 0x10
  jmp .loop
.done:
  popa
  ret

; Данные
boot_drive  db 0
loading_msg db "NovaNexus: Loading kernel...", 0x0D, 0x0A, 0
success_msg db "NovaNexus: Kernel loaded, starting...", 0x0D, 0x0A, 0
error_msg   db "NovaNexus: Disk error - system halted", 0x0D, 0x0A, 0

; Заполнение до 510 байт и сигнатура
times 510-($-$$) db 0
dw 0xAA55
