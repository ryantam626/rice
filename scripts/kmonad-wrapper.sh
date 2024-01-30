#!/bin/bash

KBDCFG=$(envsubst < /home/ryan/rice/dotfiles/kmonad/config.kbd)

kmonad <(echo "$KBDCFG")
