[org 0x7c00]

start:
  ; Очистка экрана
  mov ax, 0003h
  int 0x10
  
  ; Вывод сообщения о загрузке
  mov si, loading_msg
  call print_string
  
  ; Загрузка ядра со второго сектора
  mov ah, 0x02        ; Функция чтения диска
  mov al, 0x14        ; Читаем 20 секторов (достаточно для ядра)
  mov ch, 0x00        ; Цилиндр 0
  mov cl, 0x02        ; Начинаем со второго сектора
  mov dh, 0x00        ; Головка 0
  mov dl, 0x80        ; Первый жесткий диск (для USB/флоппи используй 0x00)
  mov bx, 0x1000      ; Сегмент для загрузки ядра
  mov es, bx
  xor bx, bx          ; Адрес 0x1000:0x0000
  int 0x13
  
  jc disk_error       ; Ошибка чтения
  
  ; Переход на загруженное ядро
  mov si, success_msg
  call print_string
  
  jmp 0x1000:0x0000   ; Прыгаем в ядро

disk_error:
  mov si, error_msg
  call print_string
  mov ah, 0x00
  int 0x16            ; Ждем нажатия клавиши
  int 0x19            ; Перезагрузка

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

loading_msg db "Loading NovaNexus kernel...", 0x0D, 0x0A, 0
success_msg db "Kernel loaded, starting...", 0x0D, 0x0A, 0
error_msg db "Disk error! Press any key to reboot...", 0x0D, 0x0A, 0

times 510-($-$$) db 0
dw 0xAA55

; Заполняем оставшееся место до конца сектора нулями
times 512-($-$$) db 0
