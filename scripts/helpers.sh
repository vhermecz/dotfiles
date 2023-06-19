#!/usr/bin/env bash

red="\033[1;31m"
green="\033[0;32m"
gray="\033[0;37m"
reset="\033[m"

error() {
    echo -e "${red}${1}${reset}" >&2
}

success() {
    echo -e "${green}${1}${reset}"
}

info() {
    echo -e "${gray}${1}${reset}"
}

backup_file() {
    mv "${1}" "${1}.$(date '+%Y%m%d%H%M%S')"
}

dir_exists() {
    if [[ -d "${1}" ]]; then
        return 0
    else
        return 1
    fi
}

file_exists() {
    if [[ -f "${1}" ]]; then
        return 0
    else
        return 1
    fi
}

is_symlink() {
    if [[ -L "${1}" ]]; then
        return 0
    else
        return 1
    fi
}
