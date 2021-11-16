#!/bin/bash

# Настроим Pacman, пропишем вручную региональные зеркала репозитория и перечитаем репозитории:
sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 10/g' /etc/pacman.conf
echo -e '## Russia
Server = https://mirror.yandex.ru/mirrors/manjaro/stable/$repo/$arch
Server = https://mirror.truenetwork.ru/manjaro/stable/$repo/$arch' | \
tee /etc/pacman.d/mirrorlist
pacman --noconfirm -Syy

# Создаем три раздела Root(40Gb-sda1), Home(Остальное-sda2) и EFI(300Mb-sda3):
parted -s /dev/sda -- mktable gpt \
    mkpart Root ext4 1M 40G \
    mkpart Home ext4 40G -300M \
    mkpart EFI fat32 -300M 100% \
set 3 esp on
# Форматируем разделы sda1 и sda2 в ext4, а раздел sda3 в fat32:
mkfs.ext4 -L Root /dev/sda1
mkfs.ext4 -L Home /dev/sda2
mkfs.fat -F32 /dev/sda3
# Примонтируем раздел sda1 в /mnt:
mount /dev/sda1 /mnt
# Создаем каталоги /mnt/home и /mnt/boot/efi:
mkdir -p /mnt/{home,boot/efi}
# Примонтируем раздел sda2 в /mnt/home:
mount /dev/sda2 /mnt/home
# Примонтируем раздел sda3 в /mnt/boot/efi:
mount /dev/sda3 /mnt/boot/efi

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
