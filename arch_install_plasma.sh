#!/bin/bash

# Минимальная установка:
# sddm, sddm-kcm - Загрузчик и настройщик загрузчика,
# plasma-desktop - Минимальная установка Plasma,
# kscreen - Утилита управления мониторами,
# powerdevil - Утилита управления питанием,
# plasma-pa - Апплет управления звуком,
# kinfocenter - Информация о системе,
# plasma-systemmonitor - Системный монитор,
# kinit - Ускорение запуска приложений KDE,
sudo pacman --noconfirm -S sddm sddm-kcm plasma-desktop kscreen powerdevil plasma-pa kinfocenter plasma-systemmonitor kinit
sudo systemctl enable sddm.service

# kde-gtk-config, breeze-gtk - Настройка тем GTK и тема GTK,
sudo pacman --noconfirm -S kde-gtk-config breeze-gtk

# konsole - Эмулятор терминала,
# kwrite - Простой текстовый редактор,
# kcalc - Калькулятор,
# dolphin dolphin-plugins - Файловый менеджер,
sudo pacman --noconfirm -S konsole kwrite kcalc dolphin dolphin-plugins

# plasma-browser-integration - Интеграция Plasma и популярных браузеров.
sudo pacman --noconfirm -S plasma-browser-integration

# gwenview, kimageformats, qt5-imageformats - Просмотрщик фото,
# okular, poppler-data - Просмотрщик текста.
sudo pacman --noconfirm -S gwenview kimageformats qt5-imageformats okular poppler-data

# Работа с архивами:
sudo pacman --noconfirm -S ark

# Мультимедиа:
# audacious - Аудиоплеер,
# mpv - Видеоплеер.
sudo pacman --noconfirm -S audacious mpv

# Вижет погоды (Удаляем города по умолчанию, добавлям нужный +OWM, Нужный город ищем на https://openweathermap.org):
sudo pacman --noconfirm -S plasma5-applets-weather-widget qt5-xmlpatterns

#-----------------------------------------------------------------

echo '>>>> Reboot your computer <<<<'
exit
