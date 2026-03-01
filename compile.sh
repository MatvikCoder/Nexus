#!/bin/bash

echo "Компиляция загрузчика..."
nasm -f bin boot.asm -o boot.bin

echo "Компиляция ядра..."
nasm -f bin kernel.asm -o kernel.bin

echo "Создание образа..."
cat boot.bin kernel.bin > os.bin

# Дополняем до размера дискеты (1.44 MB)
dd if=/dev/zero of=os.bin bs=512 count=2880 2>/dev/null
dd if=boot.bin of=os.bin conv=notrunc 2>/dev/null
dd if=kernel.bin of=os.bin bs=512 seek=1 conv=notrunc 2>/dev/null

echo "Запуск QEMU..."
qemu-system-x86_64 -drive format=raw,file=os.bin
