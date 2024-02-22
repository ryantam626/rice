#!/bin/bash

set -e

SCRIPT_PATH=$(cd -P -- "$(dirname -- "$0")" && printf '%s\n' "$(pwd -P)/$(basename "$0")")
SCRIPT_DIR=$(dirname $SCRIPT_PATH)/

source $SCRIPT_DIR/helpers.sh
source $SCRIPT_DIR/installers.sh

install_docker
install_kmonad
install_zsh
install_chrome
install_neovim
install_fonts
install_wayland_rofi_fork
install_webstorm
install_pycharm
install_idea
install_gnome_extensions
install_pyenv
install_kitty
install_utils
install_gcloud
# Placed last because it requires user input
install_omz_and_plugins

success "All done."
