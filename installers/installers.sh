apt_install_quiet="sudo apt -qq -y -o Dpkg::Use-Pty=0 install"
SCRIPT_PATH=$(cd -P -- "$(dirname -- "$0")" && printf '%s\n' "$(pwd -P)/$(basename "$0")")
SCRIPT_DIR=$(dirname $SCRIPT_PATH)/
REPO_DIR=$(dirname $SCRIPT_DIR)/

source $SCRIPT_DIR/helpers.sh
source $SCRIPT_DIR/versions.sh

install_docker() {
	info "Installing Docker.\n"
	info "[docker] Adding Docker's official GPG key.\n"
	sudo apt update
	$apt_install_quiet ca-certificates
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc

	info "[docker] Add the repository to Apt sources.\n"
	echo \
		"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
		$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt update

	info "[docker] Installing Docker and friends.\n"
	$apt_install_quiet docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	
	info "[docker] Add current user to docker group.\n"
	sudo usermod -aG docker $USER
}


install_kmonad() {
	# Requires docker to be installed already.
	info "Installing Kmonad.\n"
	info "[kmonad] Compiling with docker.\n"
	sudo docker build -t kmonad-builder github.com/kmonad/kmonad.git
	sudo docker run --rm -it -v /tmp/kmonad:/host/ kmonad-builder bash -c 'cp -vp /root/.local/bin/kmonad /host/'
	sudo docker rmi kmonad-builder
	info "[kmonad] Move binary.\n"
	sudo mv /tmp/kmonad/kmonad /usr/local/bin
}


install_zsh() {
	info "Installing zsh.\n"
	$apt_install_quiet zsh
}

install_omz_and_plugins() {
	info "Installing oh-my-zsh and plugins.\n"
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" || true
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
	git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
	git clone https://github.com/sawadashota/go-task-completions.git ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/task
}

install_chrome() {
	info "Installing Google Chrome.\n"
	info "[chrome] Downloading Google Chrome.\n"
	pushd /tmp
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	info "[chrome] Installing Google Chrome.\n"
	sudo dpkg -i google-chrome-stable_current_amd64.deb || $apt_install_quiet -f
	popd
}

install_utils() {
	# Requires python to be installed already

	info "Installing utils.\n"
	info "[utils] Downloading some utils from apt.\n"
	# `xsel` for clipboard in neovim 
	# `fzf` for fuzzy finder
	$apt_install_quiet xsel fzf
	
	info "[utils] Downloading task.\n"
	sudo sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin

	info "[utils] Downloading nvm.\n"
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

	info "[utils] Downloading thefuck.\n"
	/home/ryan/.pyenv/versions/$GLOBAL_PYTHON_VER/bin/pip install thefuck
}

install_neovim() {
	info "Installing Neovim.\n"
	info "[neovim] Downloading neovim.\n"
	mkdir -p ~/apps
	pushd /tmp
	wget https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz
	info "[neovim] Unzipping neovim.\n"
	tar xzvf nvim-linux64.tar.gz
	info "[neovim] Moving neovim to apps dir.\n"
	mv nvim-linux64 ~/apps
	info "[neovim] Symlinking neovim.\n"
	sudo ln -s /home/ryan/apps/nvim-linux64/bin/nvim /usr/local/bin/nvim
	popd
}

install_fonts() {
	info "Installing fonts.\n"
	info "[fonts] Installing powerline fonts.\n"
	mkdir -p ~/.fonts/
	git clone https://github.com/powerline/fonts.git --depth=1 /tmp/fonts
	pushd /tmp/fonts
	./install.sh
	popd
	rm -rf /tmp/fonts

	info "[fonts] Installing nerd fonts.\n"
	git clone https://github.com/ryanoasis/nerd-fonts.git --depth=1 /tmp/fonts
	pushd /tmp/fonts
	./install.sh
	popd
	rm -rf /tmp/fonts
	fc-cache -vf
}

install_wayland_rofi_fork() {
	info "Installing wayland-supported rofi fork.\n"
	info "[rofi] Cloning repo.\n"
	git clone https://github.com/lbonn/rofi.git --depth=1 ~/tmp/rofi
	pushd ~/tmp/rofi
	info "[rofi] Installing build tools for rofi.\n"
	$apt_install_quiet meson cmake g++
	info "[rofi] Installing rofi deps.\n"
	$apt_install_quiet libglib2.0-dev libcairo-dev libpango1.0-dev libxkbcommon-dev libgdk-pixbuf2.0-dev libxcb-util-dev libxcb-xkb-dev libxkbcommon-x11-0 libxcb-ewmh-dev libxcb-icccm4-dev libxcb-randr0-dev libxcb-cursor-dev libxcb-xinerama0-dev libstartup-notification0-dev wayland-protocols libwayland-dev flex bison libmpdclient-dev libnl-3-dev libxkbcommon-x11-dev
	info "[rofi] Setting up build.\n"
	meson setup build/
	info "[rofi] Building.\n"
	ninja -C build 
	info "[rofi] Moving binary.\n"
	sudo mv ./build/rofi /usr/local/bin/
	popd

}

install_webstorm() {
	info "Installing WebStorm.\n"
	info "[webstorm] Downloading.\n"
	mkdir -p /tmp/webstorm
	wget https://download.jetbrains.com/webstorm/WebStorm-2023.3.3.tar.gz -P /tmp/webstorm
	wget https://download.jetbrains.com/webstorm/WebStorm-2023.3.3.tar.gz.sha256 -P /tmp/webstorm

	info "[webstorm] Checksum.\n"
	pushd /tmp/webstorm
	sha256sum -c WebStorm-2023.3.3.tar.gz.sha256

	info "[webstorm] Unzip.\n"
	mkdir -p ~/apps
	sudo tar xzf WebStorm-*.tar.gz -C ~/apps
	popd
	rm -rf /tmp/webstorm

	info "[webstorm] Symlink.\n"
	sudo ln -s ~/apps/WebStorm-233.14015.89/bin/webstorm.sh /usr/local/bin/webstorm
}

install_pycharm() {
	info "Installing PyCharm.\n"
	info "[pycharm] Downloading.\n"
	mkdir -p /tmp/pycharm
	wget https://download.jetbrains.com/python/pycharm-professional-2023.3.3.tar.gz -P /tmp/pycharm
	wget https://download.jetbrains.com/python/pycharm-professional-2023.3.3.tar.gz.sha256 -P /tmp/pycharm

	info "[pycharm] Checksum.\n"
	pushd /tmp/pycharm
	sha256sum -c pycharm-professional-2023.3.3.tar.gz.sha256

	info "[pycharm] Unzip.\n"
	mkdir -p ~/apps
	tar xzf pycharm-professional-*.tar.gz -C ~/apps
	popd
	rm -rf /tmp/pycharm

	info "[pycharm] Symlink.\n"
	sudo ln -s ~/apps/pycharm-2023.3.3/bin/pycharm.sh /usr/local/bin/pycharm
}


install_gnome_extensions() {
	info "Installing Gnome Extensions.\n"
	$apt_install_quiet gnome-tweaks gnome-shell-extensions chrome-gnome-shell
	warning "Gnome Extensions are not included here, remember to download them later.\n"
}


install_pyenv() {
	info "Installing pyenv.\n"
	info "[pyenv] Installing necessary deps for building python.\n"
	$apt_install_quiet --no-install-recommends make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev -y
	git clone https://github.com/pyenv/pyenv.git ~/.pyenv

	info "[pyenv] Installing Python $GLOBAL_PYTHON_VER and mark as global.\n"
	/home/ryan/.pyenv/bin/pyenv install $GLOBAL_PYTHON_VER
	/home/ryan/.pyenv/bin/pyenv global $GLOBAL_PYTHON_VER
}


install_kitty() {
	info "Installing kitty.\n"
	info "[kitty] Installing kitty.\n"
	curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
	sudo ln -s ~/.local/kitty.app/bin/kitty /usr/local/bin/kitty
	info "[kitty] Creating desktop entry.\n"
	cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
	sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
	sed -i "s|Exec=kitty|Exec=/home/$USER/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
}
