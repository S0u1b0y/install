#!/bin/bash

### XFCE ###
# Доп. информация о приложениях Manjaro XFCE - https://gitlab.manjaro.org/profiles-and-settings/iso-profiles/-/blob/master/manjaro/xfce/Packages-Desktop

## Минимальная установка:
# xorg-server - Иксы,
# xfce4 - Минимальная установка XFCE,
# lxdm - Загрузчик,
# pavucontrol - Панель управления звуком Pulseaudio,
# xfce4-xkb-plugin - Плагин раскладки клавиатуры,
# xfce4-pulseaudio-plugin - Плагин управления звуком,
# xfce4-clipman-plugin - Плагин расширенного буфера обмена,
# xfce4-weather-plugin - Плагин погоды,
# blueman - Поддержка Bluetooth,
# menulibre - Редактор меню.
sudo pacman --noconfirm -S xorg-server xfce4 lxdm pavucontrol xfce4-xkb-plugin xfce4-pulseaudio-plugin xfce4-clipman-plugin xfce4-weather-plugin menulibre
sudo systemctl enable lxdm.service
sudo pacman --noconfirm -Rs xfce4-terminal

# tilix - Тайлинговый эмулятор терминала,
# xed - Простой текстовый редактор X-Apps,
# galculator - Калькулятор,
sudo pacman --noconfirm -S tilix xed galculator

## Программы Manjaro:
sudo pacman --noconfirm -S manjaro-settings-manager manjaro-browser-settings manjaro-hotfixes pamac-gtk pamac-snap-plugin pamac-flatpak-plugin

## Просмотрщики:
# Фото - xviewer, xviewer-plugins,
# Текст - xreader.
sudo pacman --noconfirm -S xviewer xviewer-plugins xreader

## Работа с архивами:
sudo pacman --noconfirm -S file-roller thunar-archive-plugin

## Управление дисками:
sudo pacman --noconfirm -S gnome-disk-utility

## Мониторинг системы:
sudo pacman --noconfirm -S gnome-system-monitor
 
# firefox, firefox-i18n-ru - Браузер Firefox с русификацией,
# cherrytree - Программа для систематизации и ведения заметок,
sudo pacman --noconfirm -S firefox firefox-i18n-ru cherrytree

#-----------------------------------------------------------------

## Оформление ##

# Оформление QT5 в стиле GTK:
sudo pacman --noconfirm -S qt5ct qt6-base adwaita-qt
echo 'export QT_QPA_PLATFORMTHEME=qt5ct' | sudo tee -a /etc/profile

# No_Beep (Отключение, раздражающего звука, pc-спикера):
echo 'blacklist  pcspkr' | sudo tee /etc/modprobe.d/nobeep.conf

# Оформление Manjaro:
sudo pacman --noconfirm -S matcha-gtk-theme papirus-maia-icon-theme illyria-wallpaper

# Шрифты, иконки и курсоры:
sudo pacman --noconfirm -S ttf-ubuntu-font-family ttf-liberation ttf-dejavu ttf-droid ttf-hack noto-fonts ttf-meslo-nerd-font-powerlevel10k

#-----------------------------------------------------------------

#### Тонкая настройка ####

# Установим более низкий уровень использования файла подкачки
echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-swappiness.conf
# Уменьшение времени ожидания "зависших" приложений с 90 до 10 секунд
sudo sed -i 's/#DefaultTimeoutStopSec=90s/DefaultTimeoutStopSec=10s/' /etc/systemd/system.conf
# Задать максимальный размер systemd-журнала
sudo sed -i 's/#SystemMaxUse=/SystemMaxUse=50M/' /etc/systemd/journald.conf

#-----------------------------------------------------------------

echo '>>>> Reboot your computer <<<<'
