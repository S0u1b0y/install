#!/bin/bash

# Переменные:
swapfile=8192 # Размер файла подкачки 8Gb

# Пропишем в конфиги Pacman'а репозитории Archlinux и русские зеркала:
# (Для других стран можно сгенерировать тут: https://archlinux.org/mirrorlist/)
echo -e '[options]
HoldPkg = pacman glibc
Architecture = auto
Color
CheckSpace
VerbosePkgLists
ParallelDownloads = 10
SigLevel = Required DatabaseOptional
LocalFileSigLevel = Optional
[core]
Include = /etc/pacman.d/mirrorlist
[extra]
Include = /etc/pacman.d/mirrorlist
[community]
Include = /etc/pacman.d/mirrorlist
[multilib]
Include = /etc/pacman.d/mirrorlist' | tee /etc/pacman.conf
echo -e '## Russia
Server = http://mirror.yandex.ru/archlinux/$repo/os/$arch
Server = https://mirror.yandex.ru/archlinux/$repo/os/$arch
Server = http://mirror.truenetwork.ru/archlinux/$repo/os/$arch
Server = https://mirror.truenetwork.ru/archlinux/$repo/os/$arch
Server = http://mirror.rol.ru/archlinux/$repo/os/$arch
Server = https://mirror.rol.ru/archlinux/$repo/os/$arch
Server = http://mirror.surf/archlinux/$repo/os/$arch
Server = https://mirror.surf/archlinux/$repo/os/$arch
Server = http://mirror.nw-sys.ru/archlinux/$repo/os/$arch
Server = https://mirror.nw-sys.ru/archlinux/$repo/os/$arch
Server = http://mirrors.powernet.com.ru/archlinux/$repo/os/$arch
Server = http://archlinux.zepto.cloud/$repo/os/$arch' | tee /etc/pacman.d/mirrorlist
pacman --noconfirm -Syy

# Создаем два раздела Root(Остальное-sda1) и EFI(300Mb-sda2),
parted -s /dev/sda -- mktable gpt \
    mkpart Root btrfs 1M -300M \
    mkpart EFI fat32 -300M 100% \
set 2 esp on
# Форматируем раздел sda1 в Btrfs, а раздел sda2 в fat32:
mkfs.btrfs -f /dev/sda1
mkfs.fat -F32 /dev/sda2
# Примонтируем раздел sda1 в /mnt:
mount /dev/sda1 /mnt
# Создаем два подтома @root и @home:
btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@home
# Отмонтируем раздел sda1:
umount /dev/sda1
# И примонтируем уже подтом @root в /mnt с доп. параметрам:
mount /dev/sda1 /mnt -o subvol=@root,noatime,nodiratime,compress=zstd:2,space_cache=v2,discard=async
# Создаем каталоги /mnt/home и /mnt/boot/efi,
mkdir -p /mnt/{home,boot/efi}
# Примонтируем подтом @home в /mnt/home с доп. параметрами:
mount /dev/sda1 /mnt/home -o subvol=@home,noatime,nodiratime,compress=zstd:2,space_cache=v2,discard=async
# Примонтируем раздел sda2 в /mnt/boot/efi:
mount /dev/sda2 /mnt/boot/efi

# Ставим систему со стандартным ядром:
# base, base-devel - Базовая система,
# linux linux-headers - Ядро,
# linux-firmware - Драйвера,
# nano - Простой консольный текстовый редактор,
# btrfs-progs - Утилиты для btrfs.
basestrap /mnt base base-devel linux linux-headers linux-firmware nano btrfs-progs

# Генерируем fstab (Ключ -U генерирует список разделов по UUID):
fstabgen -U /mnt > /mnt/etc/fstab

## Настроим параметры запуска системы на btrfs (Меняем udev на systemd, fsck на keymap, добавляем btrfs):
sed -i 's/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base systemd autodetect modconf block btrfs filesystems keyboard keymap)/' /mnt/etc/mkinitcpio.conf

# Проверяем fstab:
cat /mnt/etc/fstab
