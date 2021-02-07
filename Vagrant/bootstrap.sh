#!/bin/bash

set -eu

echo "nameserver 8.8.8.8" > /etc/resolv.conf
chattr +i /etc/resolv.conf

# set timezone
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime


# patch config
cd /etc
    patch < /vagrant/makepkg.conf.patch
cd ..


echo 'Server = https://mirrors.cat.net/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
pacman -Syyu --noconfirm --needed \
    base base-devel wget git zsh gnupg \
    pbzip2 pigz tmux htop thefuck exa bat \
    docker{,-compose} ncdu lld clang go stack

systemctl enable docker


# gen locale for english and japanese UTF-8
echo -e "en_US.UTF-8 UTF-8\nja_JP.UTF-8 UTF-8" > /etc/locale.gen
locale-gen


# change default shell to zsh
chsh -s $(which zsh) vagrant


# let join user to docker group
usermod -aG docker vagrant


# run usermode bootstrap script
su vagrant -c "zsh /vagrant/bootstrap.user.sh"
