#!/usr/bin/env bash

# Set up the shell for brew.
eval "$(/opt/homebrew/bin/brew shellenv)"

# Get the directory of the symlink target.
# Otherwise it looks for the functions dir in $HOME.
zprofile_dir="$(dirname $(readlink -f ${HOME}/.zprofile))"

# Load all the scripts in the functions directory.
for f in "${zprofile_dir}"/functions/*.sh; do source "${f}"; done
