#!/usr/bin/env bash
# I don't use bash much, but if I need to, let's have a nice looking prompt.

# MacOS warns you if you're using bash. Turn that off.
export BASH_SILENCE_DEPRECATION_WARNING=1

# Set some colors, using tput so we're not limited to the basics.
c_warn=$(tput setaf 202)
c_user=$(tput setaf 240)
c_dir=$(tput setaf 32)
c_git=$(tput setaf 75)
c_reset=$(tput sgr0)

# Get the bash version, without the superfluous stuff we get from $BASH_VERSION.
bash_ver=${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}.${BASH_VERSINFO[2]}

# if we're in a git repo, get the branch name.
git_branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/')

# Set up kube-ps1
source "/opt/homebrew/opt/kube-ps1/share/kube-ps1.sh"
KUBE_PS1_PREFIX=[
KUBE_PS1_DIVIDER=" "
KUBE_PS1_SUFFIX=]
KUBE_PS1_SYMBOL_ENABLE=false
KUBE_PS1_PREFIX_COLOR=75
KUBE_PS1_CTX_COLOR=75
KUBE_PS1_NS_COLOR=75
KUBE_PS1_SUFFIX_COLOR=75

# Build the prompt using all the stuff above.
export PS1="${c_warn}bash \${bash_ver}${c_reset} ${c_user}\u${c_reset} ${c_dir}\w${c_reset}${c_git}\${git_branch}${c_reset} \$(kube_ps1)
\$ "
