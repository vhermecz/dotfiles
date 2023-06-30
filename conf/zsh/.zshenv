#!/usr/bin/env bash

# Get the directory of the symlink target.
# Otherwise it looks for the functions dir in $HOME.
zshenv_dir="$(dirname $(readlink -f ${HOME}/.zshenv))"

# Load all the scripts in the functions directory.
for f in "${zshenv_dir}"/functions/*.sh; do source "${f}"; done
