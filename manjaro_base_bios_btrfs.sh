#!/bin/bash

# Настроим Pacman, пропишем вручную региональные зеркала репозитория и перечитаем репозитории:
sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 10/g' /etc/pacman.conf
echo -e '## Russia
Server = https://mirror.yandex.ru/mirrors/manjaro/stable/$repo/$arch
Server = https://mirror.truenetwork.ru/manjaro/stable/$repo/$arch' | \
tee /etc/pacman.d/mirrorlist
pacman -Syy

# Создаём один раздел на весь диск:
parted -s /dev/sda mktable msdos \
    mkpart primary btrfs 1M 100% \
set 1 boot on
# Форматируем раздел sda1 в Btrfs:
mkfs.btrfs -f /dev/sda1
# Примонтируем раздел sda1 в /mnt:
mount /dev/sda1 /mnt
# Создаем два подтома Btrfs @root и @home:
btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@home
# Отмонтируем раздел sda1:
umount /dev/sda1
# И примонтируем уже подтом @root в /mnt с доп. параметрам:
mount /dev/sda1 /mnt -o subvol=@root,noatime,nodiratime,compress=zstd:2,space_cache=v2,discard=async
# Создаем каталог /mnt/home:
mkdir /mnt/home
# Примонтируем подтом @home в /mnt/home с доп. параметрами:
mount /dev/sda1 /mnt/home -o subvol=@home,noatime,nodiratime,compress=zstd:2,space_cache=v2,discard=async

# Ставим систему со стандартным ядром:
# base, base-devel - Базовая система,
# linux514 linux514-headers - Ядро v5.14,
# nano - Простой консольный текстовый редактор,
# intel-ucode - Поддержка процессора Intel,
# btrfs-progs - Утилиты для btrfs,
# zsh - "Продвинутая" командная оболочка zsh.
basestrap /mnt base base-devel linux514 linux514-headers nano intel-ucode btrfs-progs zsh

# Генерируем fstab (Ключ -U генерирует список разделов по UUID):
fstabgen -U /mnt > /mnt/etc/fstab

# Проверяем fstab:
# Если вдруг, по какой-то причине, не сгенерировалось по UUID, то командой blkid смотрим UUID диска и прописываем его в fstab вместо /dev/sda1 - nano /mnt/etc/fstab.
cat /mnt/etc/fstab
