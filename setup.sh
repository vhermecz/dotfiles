#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# Get the path this script lives in so it'll work if called from another directory.
MY_DIR=$(cd -- "$(dirname "$0")" >/dev/null 2>&1; pwd -P)
cd "${MY_DIR}"

# Path to the sqlite database that stores user data.
DB="$MY_DIR/dotfiles.db"

# Don't prompt the user to update their data unless necessary or requested.
UPDATE=false

help() {
    printf "usage: setup.sh [-h] [-u]\n\n"
    printf "    -h  show this help\n"
    printf "    -u  update user data\n"
    exit
}

validate_prereqs() {
    # Make sure brew is installed.
    if ! brew --version &> /dev/null; then
        echo "Install brew and try again" >&2
        exit 1
    fi

    # Make sure oh-my-zsh is installed.
    if ! dir_exists "${HOME}/.oh-my-zsh"; then
        echo "Install oh-my-zsh and try again" >&2
        exit 1
    fi
}

# Create and populate the DB with example data.
create_db() {
    printf "\nCreating database\n\n"
    sqlite3 "${DB}" "
        CREATE TABLE userdata (
            id INTEGER,
            repo_dir TEXT,
            my_name TEXT,
            my_email TEXT,
            work_email TEXT,
            company TEXT,
            brew_home TEXT,
            brew_work TEXT);"
    sqlite3 "${DB}" "
        INSERT INTO userdata (id, repo_dir, my_name, my_email, work_email, company, brew_home, brew_work)
        VALUES (1, 'git', 'My Name', 'my@email', 'work@email', 'company-name', 'N', 'N');"
}

# Load user data from the DB
load_data() {
    REPO_DIR="$(sqlite3 "${DB}"   "SELECT repo_dir FROM userdata WHERE id = 1;")"
    MY_NAME="$(sqlite3 "${DB}"    "SELECT my_name FROM userdata WHERE id = 1;")"
    MY_EMAIL="$(sqlite3 "${DB}"   "SELECT my_email FROM userdata WHERE id = 1;")"
    WORK_EMAIL="$(sqlite3 "${DB}" "SELECT work_email FROM userdata WHERE id = 1;")"
    COMPANY="$(sqlite3 "${DB}"    "SELECT company FROM userdata WHERE id = 1;")"
    BREW_HOME="$(sqlite3 "${DB}"  "SELECT brew_home FROM userdata WHERE id = 1;")"
    BREW_WORK="$(sqlite3 "${DB}"  "SELECT brew_work FROM userdata WHERE id = 1;")"
}

# Prompt to update user data.
update_data() {
    printf "\nPress enter to keep the current values.\n"

    printf "\nBase dir for your repos. Will be created in \$HOME if it doesn't exist.\n"
    read -r -p "Repo Dir (${REPO_DIR}): " input
    REPO_DIR="${input:-$REPO_DIR}"

    printf "\nYour name is used in the global .gitconfig\n"
    read -r -p "Name (${MY_NAME}): " input
    MY_NAME="${input:-$MY_NAME}"

    printf "\nYour personal email used is in the global .gitconfig\n"
    read -r -p "Email (${MY_EMAIL}): " input
    MY_EMAIL="${input:-$MY_EMAIL}"

    printf "\nYour work email is used in the .gitconfig for your work repos\n"
    read -r -p "Email (${WORK_EMAIL}): " input
    WORK_EMAIL="${input:-$WORK_EMAIL}"

    printf "\nThe company name will be used to create a subdir under ~/%s\n" "${REPO_DIR}"
    read -r -p "Company Name (${COMPANY}): " input
    COMPANY=$(echo "${input:-$COMPANY}" | awk '{print tolower($0)}')

    printf "\nDo you want to install the components in Brewfile.home?\n"
    read -r -p "Install Brewfile.home (${BREW_HOME}): " input
    BREW_HOME=$(echo "${input:-$BREW_HOME}" | awk '{print toupper($0)}')

    printf "\nDo you want to install the components in Brewfile.work?\n"
    read -r -p "Install Brewfile.work (${BREW_WORK}): " input
    BREW_WORK=$(echo "${input:-$BREW_WORK}" | awk '{print toupper($0)}')

    # Update the DB with the data we just collected.
    sqlite3 "${DB}" "
        UPDATE userdata SET
            repo_dir = '${REPO_DIR}',
            my_name = '${MY_NAME}',
            my_email = '${MY_EMAIL}',
            work_email = '${WORK_EMAIL}',
            company = '${COMPANY}',
            brew_home = '${BREW_HOME}',
            brew_work = '${BREW_WORK}'
        WHERE id = 1;"
}

do_git_stuff() {
    local git_root=${HOME}/${REPO_DIR}

    local personal="${git_root}/personal"
    if ! dir_exists "${personal}"; then
        echo "Creating ${personal}"
        mkdir -p "${personal}"
    fi

    local public="${git_root}/public"
    if ! dir_exists "${public}"; then
        echo "Creating ${public}"
        mkdir -p "${public}"
    fi

    WORK_GIT="${git_root}/${COMPANY}"
    if ! dir_exists "${WORK_GIT}"; then
        echo "Creating ${WORK_GIT}"
        mkdir -p "${WORK_GIT}"
    fi

    # Some vars need to be exported to work with envsubst.
    export MY_NAME MY_EMAIL WORK_EMAIL WORK_GIT
    envsubst < "${MY_DIR}/git/.gitconfig.global" > "${HOME}/.gitconfig"
    envsubst < "${MY_DIR}/git/.gitconfig.work" > "${WORK_GIT}/.gitconfig"
}

do_zsh_stuff() {
    local zshrc=${HOME}/.zshrc
    if file_exists "${zshrc}" && ! is_symlink "${zshrc}"; then
        backup_file "${zshrc}"
    fi
    if ! file_exists "${zshrc}"; then
        echo "Creating symlink to my .zshrc file"
        ln -s "${MY_DIR}/zsh/.zshrc" "${zshrc}"
    fi

    local zshenv=${HOME}/.zshenv
    if file_exists "${zshenv}" && ! is_symlink "${zshenv}"; then
        backup_file "${zshenv}"
    fi
    if ! file_exists "${zshenv}"; then
        echo "Creating symlink to my .zshenv file"
        ln -s "${MY_DIR}/zsh/.zshenv" "${zshenv}"
    fi
}

do_omz_stuff() {
    local theme=${HOME}/.oh-my-zsh/themes/jjeffers.zsh-theme
    if file_exists "${theme}" && ! is_symlink "${theme}"; then
        backup_file "${theme}"
    fi
    if ! file_exists "${theme}"; then
        echo "Creating symlink to my oh-my-zsh theme"
        ln -s "${MY_DIR}/zsh/jjeffers.zsh-theme" "${theme}"
    fi
}

do_aws_stuff() {
    local awscfg=${HOME}/.aws/config
    if file_exists "${awscfg}" && ! is_symlink "${awscfg}"; then
        backup_file "${awscfg}"
    fi
    if ! file_exists "${awscfg}"; then
        echo "Creating symlink to my AWS config file"
        ln -s "${MY_DIR}/aws/config" "${awscfg}"
    fi
}

do_brew_stuff() {
    printf "\nInstalling Brewfile.base\n\n"
    brew bundle --file "${MY_DIR}/brew/Brewfile.base"
    if [[ "${BREW_HOME}" == 'Y' ]]; then
        printf "\n\nInstalling Brewfile.home\n\n"
        brew bundle --file "${MY_DIR}/brew/Brewfile.home"
    fi
    if [[ "${BREW_WORK}" == 'Y' ]]; then
        printf "\n\nInstalling Brewfile.work\n\n"
        brew bundle --file "${MY_DIR}/brew/Brewfile.work"
    fi
}

main() {
    # shellcheck disable=SC1091
    source "${MY_DIR}/scripts/helpers.sh"

    while getopts hu flag; do
        case "${flag}" in
            u) UPDATE=true;;
            h|*) help;;
        esac
    done

    validate_prereqs

    if ! file_exists "$DB"; then
        create_db
        # If we have to create the database, prompt the user to update.
        UPDATE=true
    fi

    load_data

    if [[ ${UPDATE} == true ]]; then
        update_data
    fi

    echo ""
    do_git_stuff
    do_zsh_stuff
    do_omz_stuff
    do_aws_stuff
    do_brew_stuff
}

main "$@"
