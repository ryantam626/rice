#!/bin/bash

SCRIPT_PATH=$(cd -P -- "$(dirname -- "$0")" && printf '%s\n' "$(pwd -P)/$(basename "$0")")
SCRIPT_DIR=$(dirname $SCRIPT_PATH)/
REPO_DIR=$(dirname $SCRIPT_DIR)/

source $SCRIPT_DIR/helpers.sh
source $SCRIPT_DIR/versions.sh

kmonad_dir="$REPO_DIR/dotfiles/kmonad"
services=($(find "$kmonad_dir" -type f -name '*.service' -printf "%f\n" | sort))

if [ ${#services[@]} -eq 0 ]; then
    echo "No services found in the kmonad directory."
    exit 1
fi

selected_services=$(printf '%s\n' "${services[@]}" | fzf -m --preview "cat $kmonad_dir/{}")

if [ -z "$selected_services" ]; then
    echo "No services selected. Exiting."
    exit 1
fi

for service in $selected_services; do
    full_path="$kmonad_dir/$service"
    echo "Installing $service..."
    
    sudo ln -s "$full_path" "/etc/systemd/system"
    sudo systemctl enable "${service%.service}"
    sudo systemctl start "${service%.service}"
    
    echo "$service installed and started."
done

echo "All selected services installed and started."

