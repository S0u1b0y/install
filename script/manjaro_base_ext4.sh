#!/bin/bash

# Параметры установки, если нужно меняйте на свои:
# disk     - Установочный диск
# rootpart - Размер root-раздела (G - Гигабайт, M - Мегабайт)
# bootpart - Размер boot-раздела (G - Гигабайт, M - Мегабайт)
# kernel   - Версия ядра (linux510 - LTS-ядро, linux515 - Новая версия)
disk=/dev/sda
rootpart=40G
bootpart=300M
kernel=linux515

# Настроим Pacman, пропишем вручную региональные зеркала репозитория и перечитаем репозитории:
sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 10/g' /etc/pacman.conf
echo -e '## Russia
Server = https://mirror.yandex.ru/mirrors/manjaro/stable/$repo/$arch
Server = https://mirror.truenetwork.ru/manjaro/stable/$repo/$arch' | \
tee /etc/pacman.d/mirrorlist
pacman --noconfirm -Syy

# Определяем UEFI или BIOS на компьютере:
if [ -d /sys/firmware/efi ]; then
    ## Если UEFI:
    # Создаем три раздела Root(40Gb-sda1), Home(Остальное-sda2) и EFI(300Mb-sda3):
    parted -s $disk -- mktable gpt \
        mkpart Root ext4 1M $rootpart \
        mkpart Home ext4 $rootpart \-$bootpart \
        mkpart EFI fat32 \-$bootpart 100% \
    set 3 esp on
    # Форматируем разделы sda1 и sda2 в ext4, а раздел sda3 в fat32:
    mkfs.ext4 -L Root $disk\1
    mkfs.ext4 -L Home $disk\2
    mkfs.fat -F32 $disk\3
    # Примонтируем раздел sda1 в /mnt:
    mount $disk\1 /mnt
    # Создаем каталоги /mnt/home и /mnt/boot/efi:
    mkdir -p /mnt/{home,boot/efi}
    # Примонтируем раздел sda2 в /mnt/home:
    mount $disk\2 /mnt/home
    # Примонтируем раздел sda3 в /mnt/boot/efi:
    mount $disk\3 /mnt/boot/efi
    # Устанавливаем grub в систему
    basestrap /mnt grub efibootmgr
    # Устанавливаем grub на диск /dev/sda
    grub-install --target=x86_64-efi --root-directory=/mnt --bootloader-id=grub --efi-directory=/boot/efi
else
    ## Если BIOS:
    # Создаем два раздела Root(40Gb-sda1) и Home(Остальное-sda2):
    parted -s $disk -- mktable msdos \
        mkpart primary ext4 1M $rootpart \
        mkpart primary ext4 $rootpart 100% \
    set 1 boot on
    # Форматируем разделы в ext4 с метками Root и Home соответственно:
    mkfs.ext4 -L Root $disk\1
    mkfs.ext4 -L Home $disk\2
    # Примонтируем раздел sda1 в /mnt:
    mount $disk\1 /mnt
    # Создаем каталог /mnt/home:
    mkdir -p /mnt/home
    # Примонтируем раздел sda2 в /mnt/home,
    mount $disk\2 /mnt/home
    # Устанавливаем grub в систему
    basestrap /mnt grub
    # Устанавливаем grub на диск /dev/sda
    grub-install --target=i386-pc --root-directory=/mnt $disk
fi

# Ставим систему со стандартным ядром:
# base, base-devel - Базовая система,
# $kernel $kernel\-headers - Ядро (см. переменную kernel),
# nano - Простой консольный текстовый редактор.
basestrap /mnt base base-devel $kernel $kernel\-headers nano

# Генерируем fstab (Ключ -U генерирует список разделов по UUID):
fstabgen -U /mnt >> /mnt/etc/fstab

## Настроим параметры запуска системы на ext4 (Меняем udev на systemd):
sed -i 's/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base systemd autodetect modconf block filesystems keyboard fsck)/' /mnt/etc/mkinitcpio.conf

# Проверяем fstab:
cat /mnt/etc/fstab
