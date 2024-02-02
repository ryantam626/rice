# ===== Require user input =====
# Add user to sudo
## Change user 
su -
## Add `ryan` into sudo group
sudo adduser ryan sudo
## Relogin

# Installing nvidia driver
## Adding non-free to source
sudo sed -i '/^deb/s/ main/ main non-free contrib/' /etc/apt/sources.list
sudo apt update
## Install nvidia-detect which help us decide what to install
sudo apt install nvidia-detect -y
## Run nvidia-detect
sudo nvidia-detect
## Read the output here and decide what to do (it's probably just telling you to install `nvidia-driver`)

## Install linux header such that NVIDIA driver can build
sudo apt install linux-headers-amd64 -y
## Actually install the drivers
sudo apt install nvidia-driver -y

# Generate SSH key
ssh-keygen
# Configure github to read this SSH key.

# ===== No longer require (much) user input =====
git clone git@github.com:ryantam626/rice.git rice

# TODO: Below should be changed to use some sort of installer?

# Install Docker
## Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl git -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

## Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

## Actually install docker and friends
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

## Add current user to docker group
sudo usermod -aG docker $USER


# Install kmonad
## Compile Kmonad
sudo docker build -t kmonad-builder github.com/kmonad/kmonad.git
sudo docker run --rm -it -v /tmp/kmonad:/host/ kmonad-builder bash -c 'cp -vp /root/.local/bin/kmonad /host/'
sudo docker rmi kmonad-builder
## Move kmonad binary
sudo mv /tmp/kmonad/kmonad /usr/local/bin

# Install zsh  ONLY
sudo apt install zsh -y



# Download chrome  
pushd /tmp
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb || sudo apt install -f -y
popd

# Install utils
## `xsel` for clipboard in neovim 
sudo apt install -y xsel

# Install neovim
mkdir -p ~/apps
pushd /tmp
wget https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz
tar xzvf nvim-linux64.tar.gz
mv nvim-linux64 ~/apps
sudo ln -s /home/ryan/apps/nvim-linux64/bin/nvim /usr/local/bin/nvim
popd

# Install fonts and refresh cache
## Install powerline fonts
mkdir -p ~/.fonts/
git clone https://github.com/powerline/fonts.git --depth=1 /tmp/fonts
pushd /tmp/fonts
./install.sh
popd
rm -rf /tmp/fonts
fc-cache -vf

## Install nerd fonts
git clone https://github.com/ryanoasis/nerd-fonts.git --depth=1 /tmp/fonts
pushd /tmp/fonts
./install.sh
popd
rm -rf /tmp/fonts
fc-cache -vf

# Install wayland-supported rofi fork
## Clone
git clone https://github.com/lbonn/rofi.git --depth=1 ~/tmp/rofi
pushd ~/tmp/rofi
## Installing build tools for rofi rofk
sudo apt install meson cmake g++ -y
## Installing rofi fork's deps 
sudo apt install -y libglib2.0-dev libcairo-dev libpango1.0-dev libxkbcommon-dev libgdk-pixbuf2.0-dev libxcb-util-dev libxcb-xkb-dev libxkbcommon-x11-0 libxcb-ewmh-dev libxcb-icccm4-dev libxcb-randr0-dev libxcb-cursor-dev libxcb-xinerama0-dev libstartup-notification0-dev wayland-protocols libwayland-dev flex bison libmpdclient-dev libnl-3-dev libxkbcommon-x11-dev
## Build rofi and move to bin
meson setup build/
ninja -C build 
sudo mv ./build/rofi /usr/local/bin/
popd

# Pick up zsh plugins and oh my zsh - will require user input
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" || true
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/sawadashota/go-task-completions.git ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/task

# Install Kmonad A1 remap
sudo ln -s /home/ryan/rice/dotfiles/kmonad/kmonad-a1.service /etc/systemd/system
sudo systemctl enable kmonad-a1
sudo systemctl start kmonad-a1

# TMP
xset r rate 201 33 



# === WIP after above worked ===

# Install utils
sudo apt install fzf -y

# Install task

sudo sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin


# Download and install webstorm
```bash
mkdir -p /tmp/webstorm
wget https://download.jetbrains.com/webstorm/WebStorm-2023.3.3.tar.gz -P /tmp/webstorm
wget https://download.jetbrains.com/webstorm/WebStorm-2023.3.3.tar.gz.sha256 -P /tmp/webstorm

pushd /tmp/webstorm
sha256sum -c WebStorm-2023.3.3.tar.gz.sha256
mkdir -p ~/apps
sudo tar xzf WebStorm-*.tar.gz -C ~/apps
popd
rm -rf /tmp/webstorm
sudo ln -s ~/apps/WebStorm-233.14015.89/bin/webstorm.sh /usr/local/bin/webstorm
```

# Download and install pycharm
```bash
mkdir -p /tmp/pycharm
wget https://download.jetbrains.com/python/pycharm-professional-2023.3.3.tar.gz -P /tmp/pycharm
wget https://download.jetbrains.com/python/pycharm-professional-2023.3.3.tar.gz.sha256 -P /tmp/pycharm

pushd /tmp/pycharm
sha256sum -c pycharm-professional-2023.3.3.tar.gz.sha256
tar xzf pycharm-professional-*.tar.gz -C ~/apps
popd
rm -rf /tmp/pycharm
sudo ln -s ~/apps/pycharm-2023.3.3/bin/pycharm.sh /usr/local/bin/pycharm
```
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Gnome extensions
sudo apt install gnome-tweaks gnome-shell-extensions -y
sudo apt install chrome-gnome-shell -y


# Install python and pyenv
GLOBAL_PYTHON_VER="3.10.8"
sudo apt install -y python3-pip

sudo apt-get install --no-install-recommends make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev -y
git clone https://github.com/pyenv/pyenv.git ~/.pyenv

/home/ryan/.pyenv/bin/pyenv install $GLOBAL_PYTHON_VER
/home/ryan/.pyenv/bin/pyenv global $GLOBAL_PYTHON_VER

/home/ryan/.pyenv/versions/$GLOBAL_PYTHON_VER/bin/pip install thefuck

# Install utils
sudo pip3 install thefuck

## https://extensions.gnome.org/extension/1460/vitals/
## https://extensions.gnome.org/extension/4290/disable-workspace-switch-animation-for-gnome-40/
## https://extensions.gnome.org/extension/4356/top-bar-organizer/
## https://extensions.gnome.org/extension/4412/advanced-alttab-window-switcher/
## https://extensions.gnome.org/extension/4451/logo-menu/
## https://extensions.gnome.org/extension/4627/focus-changer/
## https://extensions.gnome.org/extension/5090/space-bar/
## https://extensions.gnome.org/extension/744/hide-activities-button/
