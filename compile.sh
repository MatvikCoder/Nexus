#!/bin/bash

# Компиляция загрузчика
nasm -f bin boot.asm -o boot.bin

# Компиляция ядра
nasm -f bin kernel.asm -o kernel.bin

# Объединение в один образ
cat boot.bin kernel.bin > os.bin

# Дополняем до размера дискеты (1.44 MB)
truncate -s 1474560 os.bin

# Запуск в QEMU
qemu-system-x86_64 -drive format=raw,file=os.bin
