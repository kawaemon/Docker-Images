#!/bin/zsh
set -eu 

cd $HOME


# copy zshrc
cp /vagrant/zshrc /home/vagrant/.zshrc


# install node version manager
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | zsh
source ~/.zshrc


# install Node.js via nvm
# `node` is alias for the latest version of Node.js
nvm install node


# install yarn and pnpm
npm i -g yarn pnpm


# import PGP key
gpg --import < /vagrant/private/secret.pgp


# use PGP key to ssh
echo "enable-ssh-support" >> ~/.gnupg/gpg-agent.conf
# keygrip
echo "B3CBA953EEC3DDAF5A1D72133182ECD78FAF7861" >> ~/.gnupg/sshcontrol
echo 'export GPG_TTY=$(tty)
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent' >> ~/.zshrc


# import dotfiles
mkdir dev
cd dev
    git clone https://github.com/kawaemon/dotfiles.git
    cd dotfiles
        # ensure symlink.sh links neovim configurations
        mkdir -p ~/.config
        set +eu
            ./symlink.sh
        set -eu
cd ../../


# install tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm --depth=1
~/.tmux/plugins/tpm/bin/install_plugins


# install yay
wget https://aur.archlinux.org/cgit/aur.git/snapshot/yay.tar.gz
tar xf yay.tar.gz
rm yay.tar.gz
cd yay
    makepkg -sri --noconfirm
cd ../
rm -rf yay


# install AUR package
yay -S --noconfirm lazygit neovim-git ngrok


# install rustup + rust stable & nightly
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

echo "source $HOME/.cargo/env" >> ~/.zshrc
source $HOME/.cargo/env

rustup install nightly


# install cargo packages
cargo install cargo-{asm,edit,watch} starship
echo 'eval "$(starship init zsh)"' >> ~/.zshrc

