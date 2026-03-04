#!/bin/bash

echo "=== Создание загрузочной дискеты ==="
# Создаем образ дискеты
dd if=/dev/zero of=floppy.img bs=512 count=2880 2>/dev/null

# Записываем загрузчик
dd if=boot.bin of=floppy.img bs=512 count=1 conv=notrunc 2>/dev/null

# Записываем ядро (если есть)
if [ -f kernel.bin ]; then
    dd if=kernel.bin of=floppy.img bs=512 seek=1 conv=notrunc 2>/dev/null
fi

echo "=== Проверка загрузочной сигнатуры ==="
SIGNATURE=$(dd if=floppy.img bs=1 skip=510 count=2 2>/dev/null | xxd -p)
if [ "$SIGNATURE" = "55aa" ]; then
    echo "✓ Сигнатура 55AA найдена"
else
    echo "✗ Ошибка: сигнатура = $SIGNATURE"
    exit 1
fi

echo "=== Создание ISO ==="
# Создаем временную директорию
mkdir -p iso_temp

# Копируем образ дискеты
cp floppy.img iso_temp/

# Создаем ISO с правильными параметрами для дискеты
genisoimage -input-charset utf-8 \
    -b floppy.img \
    -c boot.cat \
    -f \
    -J \
    -r \
    -V "MYOS" \
    -o myos.iso \
    iso_temp/ 2>/dev/null

echo "=== Результат ==="
ls -la myos.iso

echo "=== Тест в QEMU ==="
qemu-system-i386 -cdrom myos.iso
