#!/bin/bash

# Настроим Pacman, пропишем вручную региональные зеркала репозитория и перечитаем репозитории:
sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 10/g' /etc/pacman.conf
echo -e '## Russia
Server = https://mirror.yandex.ru/mirrors/manjaro/stable/$repo/$arch
Server = https://mirror.truenetwork.ru/manjaro/stable/$repo/$arch' | \
tee /etc/pacman.d/mirrorlist
pacman --noconfirm -Syy

# Создаем два раздела Root(40Gb-sda1) и Home(Остальное-sda2):
parted -s /dev/sda -- mktable msdos \
    mkpart primary ext4 1M 43G \
    mkpart primary ext4 43G 100% \
    set 1 boot on
fdisk -l /dev/sda
# Форматируем разделы в ext4 с метками Root и Home соответственно:
mkfs.ext4 -L Root /dev/sda1
mkfs.ext4 -L Home /dev/sda2
# Примонтируем раздел sda1 в /mnt:
mount /dev/sda1 /mnt
# Создаем каталог /mnt/home:
mkdir -p /mnt/home
# Примонтируем раздел sda2 в /mnt/home,
mount /dev/sda2 /mnt/home

# Ставим систему со стандартным ядром:
# base, base-devel - Базовая система,
# linux515 linux515-headers - Ядро,
# linux-firmware - Драйвера,
# nano - Простой консольный текстовый редактор,
# btrfs-progs - Утилиты для btrfs.
basestrap /mnt base base-devel linux515 linux515-headers nano btrfs-progs

# Генерируем fstab (Ключ -U генерирует список разделов по UUID):
fstabgen -U /mnt >> /mnt/etc/fstab

## Настроим параметры запуска системы на btrfs (Меняем udev на systemd):
sed -i 's/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base systemd autodetect modconf block filesystems keyboard fsck)/' /mnt/etc/mkinitcpio.conf

# Проверяем fstab:
cat /mnt/etc/fstab
