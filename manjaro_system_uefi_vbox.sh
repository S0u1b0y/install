#!/bin/bash

# Переменные:
netface=enp0s3          # Имя сетевого интерфейса (можно узнать командой - ip a)
ipaddr=192.168.0.50     # Статический IP-адрес компьютера
gateway=192.168.0.100   # Сетевой шлюз он же роутер

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
# Устанавливаем grub в систему
pacman --noconfirm -S grub efibootmgr
# Устанавливаем grub на диск /dev/sda
grub-install --target=x86_64-efi --bootloader-id=grub --efi-directory=/boot/efi
# Убираем загрузочное меню Grub, меняя GRUB_TIMEOUT с пяти секунд на ноль
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
# Что бы небыло ошибки (error: sparse file not allowed):
#sed -i 's/GRUB_DEFAULT=saved/GRUB_DEFAULT=0/g' /etc/default/grub
#sed -i 's/GRUB_SAVEDEFAULT=true/GRUB_SAVEDEFAULT=false/g' /etc/default/grub
# Генерируем файл конфигурации grub
grub-mkconfig -o /boot/grub/grub.cfg

## Настроим sudo:
# Убираем коментарий с группы %wheel.
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

## Настроим сеть (StaticIP):
# Устанавливаем демон (службу) dhcpcd
pacman --noconfirm -S dhcpcd
# Включаем загрузку при старте системы
systemctl enable dhcpcd.service
# Делаем резервную копию файла настроек, на всякий случай
cp /etc/dhcpcd.conf /etc/dhcpcd.conf.bak
# Прописываем, в файл конфигурации, параметры настройки сети
echo -e "interface $netface" > /etc/dhcpcd.conf
echo -e "static ip_address=$ipaddr/24" >> /etc/dhcpcd.conf
echo -e "static routers=$gateway" >> /etc/dhcpcd.conf
echo -e "static domain_name_servers=$gateway" >> /etc/dhcpcd.conf

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
