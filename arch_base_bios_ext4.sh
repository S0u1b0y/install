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
# linux linux-headers - Ядро,
# linux-firmware - Драйвера,
# nano - Простой консольный текстовый редактор,
# intel-ucode - Поддержка процессора Intel.
basestrap /mnt base base-devel linux linux-headers linux-firmware nano

# Генерируем fstab (Ключ -U генерирует список разделов по UUID):
fstabgen -U /mnt > /mnt/etc/fstab

## Настроим параметры запуска системы на btrfs (Меняем udev на systemd):
sed -i 's/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base systemd autodetect modconf block filesystems keyboard fsck)/' /mnt/etc/mkinitcpio.conf

# Проверяем fstab:
cat /mnt/etc/fstab
