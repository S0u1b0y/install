#!/bin/bash

# Параметры установки, если нужно меняйте на свои (G - Гигабайт, M - Мегабайт):
# disk     - Установочный диск
# bootpart - Размер boot-раздела (минус означает раздел в конце диска)
# kernel   - Версия ядра (linux510 - LTS-ядро, linux515 - Новая версия)
disk=/dev/sda
bootpart=-300M
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
    # Создаем два раздела Root(Остальное-sda1) и EFI(300Mb-sda2),
    parted -s $disk -- mktable gpt \
        mkpart Root btrfs 1M $bootpart \
        mkpart EFI fat32 $bootpart 100% \
    set 2 esp on
    # Форматируем раздел sda1 в Btrfs, а раздел sda2 в fat32:
    mkfs.btrfs -f $disk\1
    mkfs.fat -F32 $disk\2
    # Примонтируем раздел sda1 в /mnt:
    mount $disk\1 /mnt
    # Создаем два подтома @root и @home:
    btrfs subvolume create /mnt/@root
    btrfs subvolume create /mnt/@home
    # Отмонтируем раздел sda1:
    umount $disk\1
    # И примонтируем уже подтом @root в /mnt с доп. параметрам:
    mount $disk\1 /mnt -o subvol=@root,noatime,nodiratime,compress=zstd:2,space_cache=v2,discard=async
    # Создаем каталоги /mnt/home и /mnt/boot/efi,
    mkdir -p /mnt/{home,boot/efi}
    # Примонтируем подтом @home в /mnt/home с доп. параметрами:
    mount $disk\1 /mnt/home -o subvol=@home,noatime,nodiratime,compress=zstd:2,space_cache=v2,discard=async
    # Примонтируем раздел sda2 в /mnt/boot/efi:
    mount $disk\2 /mnt/boot/efi
    # Устанавливаем grub в систему
    basestrap /mnt grub efibootmgr
    # Устанавливаем grub на диск /dev/sda
    grub-install --target=x86_64-efi --root-directory=/mnt --bootloader-id=grub --efi-directory=/boot/efi
else
    ## Если BIOS:
    # Создаём один раздел на весь диск:
    parted -s $disk -- mktable msdos \
        mkpart primary btrfs 1M 100% \
    set 1 boot on
    # Форматируем раздел sda1 в Btrfs:
    mkfs.btrfs -f $disk\1
    # Примонтируем раздел sda1 в /mnt:
    mount $disk\1 /mnt
    # Создаем два подтома @root и @home:
    btrfs subvolume create /mnt/@root
    btrfs subvolume create /mnt/@home
    # Отмонтируем раздел sda1:
    umount $disk\1
    # И примонтируем уже подтом @root в /mnt с доп. параметрам:
    mount $disk\1 /mnt -o subvol=@root,noatime,nodiratime,compress=zstd:2,space_cache=v2,discard=async
    # Создаем каталог /mnt/home:
    mkdir /mnt/home
    # Примонтируем подтом @home в /mnt/home с доп. параметрами:
    mount $disk\1 /mnt/home -o subvol=@home,noatime,nodiratime,compress=zstd:2,space_cache=v2,discard=async
    # Устанавливаем grub в систему
    basestrap /mnt grub
    # Устанавливаем grub на диск /dev/sda
    grub-install --target=i386-pc --root-directory=/mnt $disk
fi

# Ставим систему со стандартным ядром:
# base, base-devel - Базовая система,
# $kernel $kernel\-headers - Ядро (см. переменную kernel),
# nano - Простой консольный текстовый редактор,
# btrfs-progs - Утилиты для btrfs.
basestrap /mnt base base-devel $kernel $kernel\-headers nano btrfs-progs

# Генерируем fstab (Ключ -U генерирует список разделов по UUID):
fstabgen -U /mnt >> /mnt/etc/fstab

## Настроим параметры запуска системы на btrfs (Меняем udev на systemd, fsck на keymap, добавляем btrfs):
sed -i 's/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base systemd autodetect modconf block btrfs filesystems keyboard keymap)/' /mnt/etc/mkinitcpio.conf

# Проверяем fstab:
cat /mnt/etc/fstab
