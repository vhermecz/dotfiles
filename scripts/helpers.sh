#!/usr/bin/env bash

backup_file() {
    mv "$1" "$1.$(date '+%Y%m%d%H%M%S')"
}

dir_exists() {
    if [[ -d "$1" ]]; then
        return 0
    else
        return 1
    fi
}

file_exists() {
    if [[ -f "$1" ]]; then
        return 0
    else
        return 1
    fi
}

is_symlink() {
    if [[ -L "$1" ]]; then
        return 0
    else
        return 1
    fi
}
