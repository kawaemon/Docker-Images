#!/bin/zsh

### Configurations ###
USE_SCCACHE_MONGODB=true
SCCACHE_MONGODB_URL="mongodb://192.168.0.35"
XSERVER_IP="192.168.0.32"

set -eu
cd /home/vagrant


# copy zshrc
cp /vagrant/zshrc /home/vagrant/.zshrc

echo "export DISPLAY=\"${XSERVER_IP}:0.0\"
export LIBGL_ALWAYS_INDIRECT=1" >> ~/.zshrc


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
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm


# install yay
wget https://aur.archlinux.org/cgit/aur.git/snapshot/yay.tar.gz
tar xf yay.tar.gz
rm yay.tar.gz
cd yay
    makepkg -sri --noconfirm
cd ../
rm -rf yay


# install AUR package
yay -S --noconfirm lazy{git,docker} {neovim,duf}-git ngrok google-cloud-sdk


# setup Node.js
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | zsh
source ~/.zshrc
nvm install node
npm i -g yarn pnpm
pnpm i -g commitizen create-{react,next}-app
cat /vagrant/nvm-shell-hook.stub.zshrc >> ~/.zshrc


# setup Rust
mkdir -p $HOME/.cargo
cp /vagrant/cargo_config.toml $HOME/.cargo/config.toml

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
echo 'source $HOME/.cargo/env' >> ~/.zshrc
source $HOME/.cargo/env

rustup install nightly

if [ "$USE_SCCACHE_MONGODB" = true ] ; then
    cargo install --git https://github.com/kawaemon/sccache.git --branch mongodb-support --bin sccache --features all
    echo "export SCCACHE_MONGODB=\"${SCCACHE_MONGODB_URL}\"" >> ~/.zshrc
    export SCCACHE_MONGODB=${SCCACHE_MONGODB_URL}
else
    sudo pacman -S --noconfirm sccache
fi

echo 'export RUSTC_WRAPPER="sccache"' >> ~/.zshrc

export RUSTC_WRAPPER="sccache"

cargo install cargo-{asm,edit,expand,outdated,watch} starship git-delta
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

