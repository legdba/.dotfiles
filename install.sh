#!/bin/bash
git clone https://github.com/legdba/.dotfiles.git ~/.dotfiles || exit $?
~/.dotfiles/install.sh
