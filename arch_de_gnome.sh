#!/bin/bash

# xorg-server - Иксы,
# xfce4 - XFCE,
# lxdm - Загрузчик,
# pavucontrol - Панель управления звуком Pulseaudio,
# menulibre - Редактор меню.
sudo pacman --noconfirm -S xorg-server xfce4 lxdm pavucontrol
sudo systemctl enable lxdm.service

# xfce4-xkb-plugin - Плагин раскладки клавиатуры,
# xfce4-pulseaudio-plugin - Плагин управления звуком,
# xfce4-clipman-plugin - Плагин расширенного буфера обмена,
# xfce4-whiskermenu-plugin - Современное меню,
# xfce4-weather-plugin - Плагин погоды,
sudo pacman --noconfirm -S xfce4-xkb-plugin xfce4-pulseaudio-plugin xfce4-clipman-plugin xfce4-whiskermenu-plugin xfce4-weather-plugin

# Удалим xfce4-terminal, т. к. вместо него установим tilix.
sudo pacman --noconfirm -Rs xfce4-terminal

# tilix - Тайлинговый эмулятор терминала,
# gedit - Простой текстовый редактор,
# gnome-calculator - Калькулятор,
sudo pacman --noconfirm -S tilix gedit gnome-calculator

# eog - Просмотр фото,
# evince - Просмотр документов.
# foliate - Читалка книг.
sudo pacman --noconfirm -S eog evince foliate

# Работа с архивами:
sudo pacman --noconfirm -S file-roller thunar-archive-plugin

# Управление дисками:
sudo pacman --noconfirm -S gnome-disk-utility

# Мониторинг системы:
sudo pacman --noconfirm -S gnome-system-monitor

#-----------------------------------------------------------------

## Настройка ##

#-----------------------------------------------------------------

echo '>>>> Reboot your computer <<<<'
