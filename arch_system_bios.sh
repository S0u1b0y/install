#!/bin/bash

# Переменные:
user=soulboy          # Имя пользователя
hostname=main         # Имя компьютера

## Настроим Pacman:
# Включаем "цветной" режим, раскоментируя параметр "Color",
sed -i 's/#Color/Color/g' /etc/pacman.conf
# Включаем параллельную загрузку пакетов, раскоментируя параметр "ParallelDownloads",
sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 10/g' /etc/pacman.conf
# Добавляем репозиторий 32х-битных библиотек Multilib,
echo -e '\n[multilib]\nInclude = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf
# Принудительно обновляем репозитории.
pacman -Syy

## Установим часовой пояс и время:
# Устанавливаем часовой пояс, в данном случае это Europe/Moscow.
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
# Устанавливаем время по UTC.
hwclock --systohc --utc

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

## Установим имя компьютера в сети:
echo "$hostname" > /etc/hostname
echo "127.0.0.1    localhost" > /etc/hosts
echo "::1          localhost" >> /etc/hosts
echo "127.0.1.1    virtual.localdomain virtual" >> /etc/hosts

## Введем пароль root:
echo '>>>> Enter root password <<<<'
passwd

## Добавляем пользователя и задаем ему пароль:
# Пропиcываем пользователя в группы: video,audio,games,lp,optical,power,storage,wheel
# И установим для него zsh в качестве командной оболочки по умолчанию (/bin/zsh).
useradd -m -g users -G video,audio,games,lp,optical,power,storage,wheel -s /bin/zsh $user
echo ">>>> Enter $user password <<<<"
passwd $user

## Установим GRUB:
# Устанавливаем grub в систему
pacman --noconfirm -S grub
# Устанавливаем grub на диск /dev/sda
grub-install --target=i386-pc /dev/sda
# Убираем загрузочное меню Grub, меняя GRUB_TIMEOUT с пяти секунд на ноль
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
# Генерируем файл конфигурации grub
grub-mkconfig -o /boot/grub/grub.cfg

## Настроим sudo:
# Убираем коментарий с группы %wheel.
pacman --noconfirm -S sudo
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers

## Установим и настроим Zswap:
# Устанавливаем
pacman --noconfirm -S systemd-swap
# Раскоментируем параметры в файле конфигурации
sed -i 's/#zram_/zram_/g' /etc/systemd/swap.conf
# Включим использование
sed -i 's/zram_enabled=0/zram_enabled=1/' /etc/systemd/swap.conf
# Отведем для zswap, вместо четверти, половину оперативной памяти
sed -i 's/RAM_SIZE \/ 4/RAM_SIZE \/ 2/' /etc/systemd/swap.conf
# Включаем загрузку при старте системы
systemctl enable systemd-swap.service

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

## Установим драйвера на видео:
# nvidia nvidia-utils lib32-nvidia-utils nvidia-settings - Драйвера для nVidia,
# gwe - утилита для разгона и мониторинга видеокарт nVidia (опционально),
# xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon - Драйвера для AMD,
# xf86-video-intel vulkan-intel lib32-vulkan-intel - Драйвера для Intel,
# xf86-video-vesa, virtualbox-guest-utils - Драйвера для VirtualBox.
pacman --noconfirm -S nvidia nvidia-utils lib32-nvidia-utils nvidia-settings

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
# neofetch - Информация о системе в консоли.
pacman --noconfirm -S git curl wget mc htop neofetch
