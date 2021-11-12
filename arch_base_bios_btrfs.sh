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

# Создаём один раздел на весь диск:
parted -s /dev/sda mktable msdos \
    mkpart primary btrfs 1M 100% \
set 1 boot on
# Форматируем раздел sda1 в Btrfs:
mkfs.btrfs -f /dev/sda1
# Примонтируем раздел sda1 в /mnt:
mount /dev/sda1 /mnt
# Создаем два подтома @root и @home:
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
# linux linux-headers - Ядро,
# nano - Простой консольный текстовый редактор,
# intel-ucode - Поддержка процессора Intel,
# btrfs-progs - Утилиты для btrfs,
# zsh - "Продвинутая" командная оболочка zsh.
basestrap /mnt base base-devel linux linux-headers nano intel-ucode btrfs-progs zsh

# Генерируем fstab (Ключ -U генерирует список разделов по UUID):
fstabgen -U /mnt > /mnt/etc/fstab

## Создадим файл подкачки (swapfile):
# Создаем подтом Btrfs: @swap
btrfs subvolume create /mnt/@swap
# Переходим в @swap
cd /mnt/@swap
# Создаём пустой файл подкачки
truncate -s 0 ./swapfile
# Отключаем копирование при записи для файла подкачки
chattr +C ./swapfile
# Отключаем сжатие файла подкачки
btrfs property set ./swapfile compression none
# Создаём файл нужного размера
dd if=/dev/zero of=./swapfile bs=1M count=$swapfile status=progress
# Разрешаем доступ к файлу подкачки только root-у
chmod 600 ./swapfile
# Инициализируем файл подкачки и включаем его
mkswap ./swapfile
swapon ./swapfile
# Прописываем в fstab, автомонтирование файла подкачки при загрузке системы
echo -e '# Swapfile\n/@swap/swapfile none swap sw 0 0' >> /mnt/etc/fstab

## Настроим параметры запуска системы на btrfs:
# Меняем udev на systemd и fsck на keymap.
sed -i 's/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base systemd autodetect modconf block filesystems keyboard keymap)/' /mnt/etc/mkinitcpio.conf

# Проверяем fstab:
cat /mnt/etc/fstab
