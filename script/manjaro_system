#!/bin/bash

#-----------------------------------------------------------------

### Персонализация ###

# Определение переменных с персональными данными для дальнейшей установки, поменяйте на свои:
username=user
hostname=virt
timezone=Europe/Moscow

## Пропишем имя компьютера в сети (virtual - поменять на своё):
echo "$hostname" > /etc/hostname
echo "127.0.0.1    localhost" > /etc/hosts
echo "::1          localhost" >> /etc/hosts
echo "127.0.1.1    $hostname.localdomain $hostname" >> /etc/hosts

## Добавляем пользователя и задаем ему пароль (user - поменять на своё):
useradd -m -g users -G video,audio,games,lp,optical,power,storage,wheel -s /bin/bash $username
echo ">>>> Enter $username password <<<<"
passwd $username

## Установим часовой пояс и время по UTC (Europe/Moscow - поменять на своё):
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
hwclock --systohc --utc

#-----------------------------------------------------------------

## Введем пароль root:
echo '>>>> Enter root password <<<<'
passwd

## Настроим Pacman:
# Включаем "цветной" режим, раскоментируя параметр "Color",
sed -i 's/#Color/Color/g' /etc/pacman.conf
# Включаем параллельную загрузку пакетов, раскоментируя параметр "ParallelDownloads",
sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 10/g' /etc/pacman.conf
# Принудительно обновляем репозитории.
pacman -Syy

## Настроим GRUB:
# Убираем загрузочное меню Grub, меняя GRUB_TIMEOUT с пяти секунд на ноль
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
# Что бы небыло ошибки (error: sparse file not allowed):
sed -i 's/GRUB_DEFAULT=saved/GRUB_DEFAULT=0/g' /etc/default/grub
sed -i 's/GRUB_SAVEDEFAULT=true/GRUB_SAVEDEFAULT=false/g' /etc/default/grub
# Генерируем файл конфигурации grub
grub-mkconfig -o /boot/grub/grub.cfg

## Локализуем систему и консоль:
# Раскоментируем локали en_US и ru_RU в файле locale.gen
sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
sed -i 's/#ru_RU.UTF-8/ru_RU.UTF-8/g' /etc/locale.gen
# Добавляем язык будущей системы в файл locale.conf
echo 'LANG=ru_RU.UTF-8' > /etc/locale.conf
# Русифицируем консоль, прописываем локаль и шрифт в файл vconsole.conf
echo -e 'KEYMAP=ru\nFONT=cyr-sun16' > /etc/vconsole.conf
# И генерируем локали
locale-gen

## Настроим sudo:
# Убираем коментарий с группы %wheel.
pacman --noconfirm -S sudo
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers

## Настроим сеть:
# Устанавливаем демон (службу) dhcpcd
pacman --noconfirm -S dhcpcd
# Включаем загрузку при старте системы
systemctl enable dhcpcd.service

## Включим синхронизацию времени:
# Устанавливаем демон (службу) ntp
pacman --noconfirm -S ntp
# Включаем загрузку при старте системы
systemctl enable ntpd.service

## SSH:
# Устанавливаем ssh
pacman --noconfirm -S openssh
# Включаем загрузку при старте системы
systemctl enable sshd.service

## Микрокод процессора:
# GenuineIntel - Intel, AuthenticAMD - AMD
if [ $(LC_ALL=C lscpu | grep -oP 'Vendor ID:\s*\K.+') = GenuineIntel ]; then
    pacman --noconfirm -S intel-ucode
else
    pacman --noconfirm -S amd-ucode
fi

## Установим драйвера на звук:
# pipewire - Современный сервер для мультимедийной маршрутизации на замену Pulseaudio, Alsa и Jack,
# pipewire-alsa pipewire-pulse pipewire-jack - Плагины для совместимости с программами написанными под Pulseaudio, Alsa и Jack,
# gst-plugin-pipewire - Плагин для GStreamer,
pacman --noconfirm -S pipewire pipewire-alsa pipewire-pulse pipewire-jack gst-plugin-pipewire

## Установим архиваторы и поддержку некоторых сетевых протоколов и ФС:
# p7zip unrar unace lrzip - Работа с архивами,
# cifs-utils - Поддержка подключения к Samba,
# davfs2 - Поддержка WebDAV (например для Yandex Disk),
# gvfs gvfs-smb gvfs-nfs - Поддержка сетевых дисков и отображение их в файловых менеджерах,
pacman --noconfirm -S p7zip unrar unace lrzip cifs-utils davfs2 gvfs gvfs-smb gvfs-nfs nfs-utils

## Установим некоторые утилиты:
# git - Работа с GitHub и Gitlab,
# curl wget - Консольные загрузчики,
# mc - Консольный файловый менеджер Midnight Comander,
# htop - Мониторинг параметров системы из консоли,
# neofetch - Информация о системе в консоли,
# Менеджер aur-пакетов - yay.
pacman --noconfirm -S git curl wget mc htop neofetch yay

# Шрифты:
sudo pacman --noconfirm -S ttf-ubuntu-font-family ttf-liberation ttf-dejavu ttf-droid ttf-hack ttf-roboto ttf-roboto-mono noto-fonts ttf-meslo-nerd-font-powerlevel10k
