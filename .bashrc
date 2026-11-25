#! /usr/bin/env bash
# Interactive-shell setup.  Aliases are in .bash_aliases, functions in
# .bash_functions; this file just wires everything together.

# if non-interactive, don't write any output
if [[ -z "$PS1" ]]; then return; fi
# guard against being sourced twice in one shell (return, not exit: this file
# is sourced, so `exit` would close the whole terminal)
if [[ "$BASH_VERSION" != "" && "$BASHRC" == "YES" ]]; then return; fi
export BASHRC=YES
echo 'Starting in .bashrc'

# --- prompt / completion ------------------------------------------------------
if [[ -r ${HOME}/bin/bash-powerline.sh ]]
then
# shellcheck source=/Users/stevebeaty/bin/bash-powerline.sh
    source "${HOME}"/bin/bash-powerline.sh
fi

if [[ -r /etc/bash_completion ]]
then
# shellcheck source=/etc/bash_completion
    source /etc/bash_completion
fi

if [[ -r /usr/local/etc/bash_completion ]]
then
# shellcheck source=/usr/local/etc/bash_completion
    source /usr/local/etc/bash_completion
fi

# --- aliases and functions ----------------------------------------------------
if [[ -r ${HOME}/.bash_aliases ]]
then
# shellcheck source=/Users/stevebeaty/.bash_aliases
    source "${HOME}"/.bash_aliases
fi

if [[ -r ${HOME}/.bash_functions ]]
then
# shellcheck source=/Users/stevebeaty/.bash_functions
    source "${HOME}"/.bash_functions
fi

# --- machine-local overrides (not in the repo) --------------------------------
if [[ -r ${HOME}/.bashrc_private ]]
then
# shellcheck source=/Users/stevebeaty/.bashrc_private
    source "${HOME}"/.bashrc_private
fi

# --- environment --------------------------------------------------------------
export EDITOR=vi
export PYTHONSTARTUP=~/.pythonrc

# --- tool initialisation ------------------------------------------------------
if [[ -x "$(command -v rbenv)" ]]
then
    eval "$(rbenv init -)"
fi

# added by travis gem
# shellcheck source=/Users/beatys/.travis/travis.sh
[ -f /Users/beatys/.travis/travis.sh ] && source /Users/beatys/.travis/travis.sh

export NVM_DIR="$HOME/.nvm"
# shellcheck source=/Users/stevebeaty/.nvm/nvm.sh
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
# shellcheck source=/Users/stevebeaty/.nvm/bash_completion
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# vim: wm=0
echo "Done with .bashrc"
