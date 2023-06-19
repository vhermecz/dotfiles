#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# Get the path this script lives in so it'll work if called from another directory.
MY_DIR=$(cd -- "$(dirname "$0")" >/dev/null 2>&1; pwd -P)
cd "${MY_DIR}"

# Path to the sqlite database that stores user data.
DB="$MY_DIR/dotfiles.db"

# Don't prompt to update user data unless necessary or requested.
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
        error "\nInstall brew and try again\n"
        exit 1
    fi

    # Make sure oh-my-zsh is installed.
    if ! dir_exists "${HOME}/.oh-my-zsh"; then
        error "\nInstall oh-my-zsh and try again\n"
        exit 1
    fi
}

# Create and populate the DB with example data.
create_db() {
    info "\nCreating database"
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

    info "\nBase dir for your repos. Will be created in \$HOME if it doesn't exist."
    read -r -p "Repo Dir (${REPO_DIR}): " input
    REPO_DIR="${input:-$REPO_DIR}"

    info "\nYour name is used in the global .gitconfig"
    read -r -p "Name (${MY_NAME}): " input
    MY_NAME="${input:-$MY_NAME}"

    info "\nYour personal email used is in the global .gitconfig"
    read -r -p "Email (${MY_EMAIL}): " input
    MY_EMAIL="${input:-$MY_EMAIL}"

    info "\nYour work email is used in the .gitconfig for your work repos"
    read -r -p "Email (${WORK_EMAIL}): " input
    WORK_EMAIL="${input:-$WORK_EMAIL}"

    info "\nThe company name will be used to create a subdir under ~/${REPO_DIR}"
    read -r -p "Company Name (${COMPANY}): " input
    COMPANY=$(echo "${input:-$COMPANY}" | awk '{print tolower($0)}')

    info "\nDo you want to install the components in Brewfile.home?"
    read -r -p "Install Brewfile.home (${BREW_HOME}): " input
    BREW_HOME=$(echo "${input:-$BREW_HOME}" | awk '{print toupper($0)}')

    info "\nDo you want to install the components in Brewfile.work?"
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
        info "Creating ${personal}"
        mkdir -p "${personal}"
    fi

    local public="${git_root}/public"
    if ! dir_exists "${public}"; then
        info "Creating ${public}"
        mkdir -p "${public}"
    fi

    WORK_GIT="${git_root}/${COMPANY}"
    if ! dir_exists "${WORK_GIT}"; then
        info "Creating ${WORK_GIT}"
        mkdir -p "${WORK_GIT}"
    fi

    # Some vars need to be exported to work with envsubst.
    export MY_NAME MY_EMAIL WORK_EMAIL WORK_GIT
    envsubst < "${MY_DIR}/git/.gitconfig.global" > "${HOME}/.gitconfig"
    envsubst < "${MY_DIR}/git/.gitconfig.work" > "${WORK_GIT}/.gitconfig"

    success "Configured git"
}

do_bash_stuff() {
    local bashrc=${HOME}/.bashrc
    if file_exists "${bashrc}" && ! is_symlink "${bashrc}"; then
        backup_file "${bashrc}"
    fi
    if ! file_exists "${bashrc}"; then
        info "Creating symlink for ~/.bashrc"
        ln -s -f "${MY_DIR}/bash/.bashrc" "${bashrc}"
    fi

    success "Configured bash"
}

do_zsh_stuff() {
    local zshrc=${HOME}/.zshrc
    if file_exists "${zshrc}" && ! is_symlink "${zshrc}"; then
        backup_file "${zshrc}"
    fi
    if ! file_exists "${zshrc}"; then
        info "Creating symlink for ~/.zshrc"
        ln -s "${MY_DIR}/zsh/.zshrc" "${zshrc}"
    fi

    local zshenv=${HOME}/.zshenv
    if file_exists "${zshenv}" && ! is_symlink "${zshenv}"; then
        backup_file "${zshenv}"
    fi
    if ! file_exists "${zshenv}"; then
        info "Creating symlink for ~/.zshenv"
        ln -s "${MY_DIR}/zsh/.zshenv" "${zshenv}"
    fi

    success "Configured zsh"
}

do_omz_stuff() {
    local theme=${HOME}/.oh-my-zsh/themes/jjeffers.zsh-theme
    if file_exists "${theme}" && ! is_symlink "${theme}"; then
        backup_file "${theme}"
    fi
    if ! file_exists "${theme}"; then
        info "Creating symlink for oh-my-zsh theme"
        ln -s "${MY_DIR}/zsh/jjeffers.zsh-theme" "${theme}"
    fi

    success "Configured oh-my-zsh"
}

do_aws_stuff() {
    local awscfg=${HOME}/.aws/config
    if file_exists "${awscfg}" && ! is_symlink "${awscfg}"; then
        backup_file "${awscfg}"
    fi
    if ! file_exists "${awscfg}"; then
        info "Creating symlink for ~/.aws/config"
        ln -s "${MY_DIR}/aws/config" "${awscfg}"
    fi

    success "Configured awscli"
}

do_iterm_stuff() {
    if dir_exists "/Applications/iTerm.app"; then
        defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$MY_DIR/iterm"
        defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
        success "Configured iterm"
    else
        error "iTerm not found"
    fi
}

do_brew_stuff() {
    info "\nInstalling Brewfile.base"
    brew bundle --file "${MY_DIR}/brew/Brewfile.base"
    if [[ "${BREW_HOME}" == 'Y' ]]; then
        info "\nInstalling Brewfile.home"
        brew bundle --file "${MY_DIR}/brew/Brewfile.home"
    fi
    if [[ "${BREW_WORK}" == 'Y' ]]; then
        info "\nInstalling Brewfile.work"
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
    do_bash_stuff
    do_zsh_stuff
    do_omz_stuff
    do_aws_stuff
    do_iterm_stuff
    do_brew_stuff

    success "\nDone!"
}

main "$@"