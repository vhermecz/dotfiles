# dotfiles

Just some stuff to save me setup time when configuring a new mac.

This is very specific to my setup, and my way of doing things. I wouldn't recommend using it as-is, but it might be a good starting place to create your own custom scripts.

## Prerequisites

1. Install [brew](https://brew.sh).
    ```
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```
1. Install git.
    ```
    brew install git
    ```
1. Install [oh-my-zsh](http://ohmyz.sh).
    ```
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    ```
1. Log in to the App Store. Some of the things I'm installing with brew use the [mas](https://formulae.brew.sh/formula/mas) command.

## Instructions

1. Clone the repo, which you should be able to do because you installed Git in the prerequisite steps.
2. Run `./setup.sh`

## How it Works

The main purpose of the script is to save some of the tedious steps required when setting up a new machine. One of the nice side-effects is that it's also a single command you can run to update things. Since everything is installed with `brew`, you can rerun the script at any time to update all the software that was installed with `brew`.

When you first run the script, it'll create an extremely simple sqlite database to store some user data. It uses this data primarily to configure git.

You'll be prompted to customize this user data on the initial run, and you can update it any time by running `setup.sh -u`.

### Git Configuration

I like to drop all of my git repos into a top-level folder just under `$HOME`. I create subdirs there for public repos, personal projects, and work repos. I'll end up with something like this:

```
$HOME
└─ git
   ├─ .gitconfig  <-- global .gitconfig
   ├─ personal/
   ├─ public/
   └─ company-name/
      └─ .gitconfig  <-- work-specific .gitconfig
```

The separate `.gitconfig` files allow me to use my personal email in the global config, but use a different email address for commits to my work repos. See the script for details on how this is done.

### Symlinks to Dotfiles

Next, it'll drop symlinks to various dotfiles to configure `zsh`, `oh-my-zsh`, and `awscli`. If the files it's replacing already exist, it'll make a backup copy first.

### Install Software with Brew

Finally, it'll install all the software in the various Brewfiles.

I have the Brewfiles split up into `base`, `home`, and `work`. The `base` Brewfile is always installed, while the others are conditional based on your answers to the setup questions.
