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
# linux linux-headers - Ядро,
# linux-firmware - Драйвера,
# nano - Простой консольный текстовый редактор,
# intel-ucode - Поддержка процессора Intel.
basestrap /mnt base base-devel linux linux-headers linux-firmware nano

# Генерируем fstab (Ключ -U генерирует список разделов по UUID):
fstabgen -U /mnt > /mnt/etc/fstab

## Создадим файл подкачки (swapfile):
# Переходим в mnt установленной системы
cd /mnt/mnt
# Создаём файл нужного размера
dd if=/dev/zero of=./swapfile bs=1M count=$swapfile status=progress
# Разрешаем доступ к файлу подкачки только root-у
chmod 600 ./swapfile
# Инициализируем файл подкачки и включаем его
mkswap ./swapfile
swapon ./swapfile
# Прописываем в fstab, автомонтирование файла подкачки при загрузке системы
echo -e '# Swapfile\n/mnt/swapfile none swap sw 0 0' >> /mnt/etc/fstab

## Настроим параметры запуска системы на btrfs (Меняем udev на systemd):
sed -i 's/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base systemd autodetect modconf block filesystems keyboard fsck)/' /mnt/etc/mkinitcpio.conf

# Проверяем fstab:
cat /mnt/etc/fstab
