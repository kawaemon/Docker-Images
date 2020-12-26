#!/bin/bash

set -eu

echo "Server = https://mirrors.cat.net/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
pacman -Syyu --noconfirm --needed \
    base base-devel wget git zsh gnupg \
    pbzip2 pigz tmux htop go 


# patch makepkg.conf for faster `makepkg`
cd /etc
patch < /vagrant/makepkg.conf.patch


# gen locale for english and japanese UTF-8
echo -e "en_US.UTF-8 UTF-8\nja_JP.UTF-8 UTF-8" > /etc/locale.gen
locale-gen


# change default shell to zsh
chsh -s $(which zsh) vagrant


# run usermode bootstrap script
su vagrant -c "zsh /vagrant/bootstrap.user.sh"
