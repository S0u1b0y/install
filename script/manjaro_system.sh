#!/bin/bash

## Настроим Pacman:
# Включаем "цветной" режим, раскоментируя параметр "Color",
sed -i 's/#Color/Color/g' /etc/pacman.conf
# Включаем параллельную загрузку пакетов, раскоментируя параметр "ParallelDownloads",
sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 10/g' /etc/pacman.conf
# Принудительно обновляем репозитории.
pacman -Syy

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

## Введем пароль root:
echo '>>>> Enter root password <<<<'
passwd

## Установим GRUB:
# Определяем UEFI или BIOS на компьютере:
if [ -d /sys/firmware/efi ]; then
    ## Если UEFI:
    # Устанавливаем grub в систему
    pacman --noconfirm -S grub efibootmgr
    # Устанавливаем grub на диск /dev/sda
    grub-install --target=x86_64-efi --bootloader-id=grub --efi-directory=/boot/efi
else
    ## Если BIOS:
    # Устанавливаем grub в систему
    pacman --noconfirm -S grub
    # Устанавливаем grub на диск /dev/sda
    grub-install --target=i386-pc /dev/sda
fi
# Убираем загрузочное меню Grub, меняя GRUB_TIMEOUT с пяти секунд на ноль
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
# Что бы небыло ошибки (error: sparse file not allowed):
sed -i 's/GRUB_DEFAULT=saved/GRUB_DEFAULT=0/g' /etc/default/grub
sed -i 's/GRUB_SAVEDEFAULT=true/GRUB_SAVEDEFAULT=false/g' /etc/default/grub
# Генерируем файл конфигурации grub
grub-mkconfig -o /boot/grub/grub.cfg

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
sudo pacman --noconfirm -S ttf-ubuntu-font-family ttf-liberation ttf-dejavu ttf-droid ttf-hack ttf-roboto ttf-roboto-mono noto-fonts
