#!/bin/bash

# gnome-shell - Минимальная установка Gnome,
# gnome-control-center - Панель настроек Gnome,
# gnome-tweak-tool - Дополнительные настройки Gnome,
# nautilus - Файловый менеджер,
# gdm - Загрузчик.
sudo pacman --noconfirm -S gnome-shell gnome-control-center gnome-tweak-tool nautilus gdm
sudo systemctl enable gdm.service

# Удалим cheese.
sudo pacman --noconfirm -R cheese

# tilix - Тайлинговый эмулятор терминала,
# gedit - Простой текстовый редактор,
# gnome-calculator - Калькулятор,
sudo pacman --noconfirm -S tilix gedit gnome-calculator

# eog - Просмотр фото,
# evince - Просмотр документов.
# foliate - Читалка книг.
sudo pacman --noconfirm -S eog evince foliate

# Работа с архивами:
sudo pacman --noconfirm -S file-roller

# Управление дисками:
sudo pacman --noconfirm -S gnome-disk-utility

# Мониторинг системы:
sudo pacman --noconfirm -S gnome-system-monitor
