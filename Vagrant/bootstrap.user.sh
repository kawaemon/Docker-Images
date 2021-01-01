#!/bin/zsh
set -eu 
cd /home/vagrant


# copy zshrc
cp /vagrant/zshrc /home/vagrant/.zshrc


# Setup GPG key
gpg --import < /vagrant/private/secret.pgp

echo "enable-ssh-support" >> ~/.gnupg/gpg-agent.conf
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


# install yay
wget https://aur.archlinux.org/cgit/aur.git/snapshot/yay.tar.gz
tar xf yay.tar.gz
rm yay.tar.gz
cd yay
    makepkg -sri --noconfirm
cd ../
rm -rf yay


# install AUR package
yay -S --noconfirm lazygit neovim-git ngrok google-cloud-sdk


# setup Node.js
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | zsh
source ~/.zshrc
nvm install node
npm i -g yarn pnpm
pnpm i -g commitizen create-{react,next}-app
echo 'export PATH="$PATH:$(npm bin):$(yarn bin):$(pnpm bin)"' >> ~/.zshrc
cat /vagrant/nvm-shell-hook.stub.zshrc >> ~/.zshrc


# setup Rust
mkdir -p $HOME/.cargo
cp /vagrant/cargo_config.toml $HOME/.cargo/config.toml

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
echo 'source $HOME/.cargo/env' >> ~/.zshrc
source $HOME/.cargo/env

rustup install nightly

cargo install cargo-{asm,edit,expand,watch} starship
echo 'eval "$(starship init zsh)"' >> ~/.zshrc


# setup Haskell
stack setup
stack install stylish-haskell hlint

git clone https://github.com/haskell/haskell-language-server --recurse-submodules
cd haskell-language-server
    stack ./install.hs hls
cd ../
rm -rf haskell-language-server
echo 'export PATH="$PATH:/home/vagrant/.local/bin/"' >> ~/.zshrc
