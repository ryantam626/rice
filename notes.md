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

# Install Docker
## Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
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

# Install zsh and oh-my-zsh
sudo apt install zsh -y

## TODO: To be placed in another place - it asks for chsh answer and permission if so, blocking 
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" || true

## TODO: To be placed in another place - requires zsh to be already installed for this to make sense.
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/sawadashota/go-task-completions.git ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/task



# Install Kmonad A1 remap
sudo ln -s /home/ryan/rice/dotfiles/kmonad/kmonad-a1.service /etc/systemd/system
sudo systemctl enable kmonad-a1
sudo systemctl start kmonad-a1

# Download chrome  
pushd /tmp
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb || sudo apt install -f
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
sudo apt install -y libglib2.0-dev libcairo-dev libpango1.0-dev libxkbcommon-dev libgdk-pixbuf2.0-dev libxcb-util-dev libxcb-xkb-dev libxkbcommon-x11 libxcb-ewmh-dev libxcb-icccm4-dev libxcb-randr0-dev libxcb-cursor-dev libxcb-xinerama0-dev libstartup-notification0-dev wayland-protocols libwayland-dev flex bison
## Build rofi and move to bin
ninja -C build 
sudo mv ./build/rofi /usr/local/bin/
popd

# TMP
xset r rate 201 33 
