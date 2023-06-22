#!/usr/bin/env bash

C_GRAY=$(tput setaf 248)
C_GREEN=$(tput setaf 2)
C_RED=$(tput setaf 202)
C_RESET=$(tput sgr0)
C_YELLOW=$(tput setaf 228)
export C_GRAY C_GREEN C_RED C_RESET C_YELLOW

error()   { echo -e "${C_RED}${1}${C_RESET}" >&2; }
success() { echo -e "${C_GREEN}${1}${C_RESET}"; }
info()    { echo -e "${C_GRAY}${1}${C_RESET}"; }

backup_file() { mv "${1}" "${1}.$(date '+%Y%m%d%H%M%S')"; }

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
