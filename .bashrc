#! /usr/bin/env bash
# Interactive-shell setup.  Aliases are in .bash_aliases, functions in
# .bash_functions; this file just wires everything together.

# if non-interactive, don't write any output
if [[ -z "$PS1" ]]; then return; fi
# guard against being sourced twice in one shell (return, not exit: this file
# is sourced, so `exit` would close the whole terminal)
if [[ "$BASH_VERSION" != "" && "$BASHRC" == "YES" ]]; then return; fi
export BASHRC=YES
echo "Starting in $(basename "${BASH_SOURCE[0]}")"

# VS Code shell integration
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path bash)"

# --- prompt / completion ------------------------------------------------------
# Source whichever of these exist: the powerline prompt plus bash completion in
# the various places Linux / macOS / Homebrew install it.
SOURCES=(
    "${HOME}/bin/bash-powerline.sh"
    /etc/bash_completion
    /opt/homebrew/etc/bash_completion
    /usr/local/etc/bash_completion
)
for f in "${SOURCES[@]}"
do
    # shellcheck source=/dev/null
    [[ -r "$f" ]] && source "$f"
done

# --- aliases and functions ----------------------------------------------------
SOURCES=(
    "${HOME}/.bash_aliases"
    "${HOME}/.bash_functions"
)
for f in "${SOURCES[@]}"
do
    # shellcheck source=/dev/null
    [[ -r "$f" ]] && source "$f"
done

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

export NVM_DIR="$HOME/.nvm"
# shellcheck source=/Users/stevebeaty/.nvm/nvm.sh
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
# shellcheck source=/Users/stevebeaty/.nvm/bash_completion
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# rust / cargo
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# pipx
export PATH="$PATH:$HOME/.local/bin"

# OpenClaw completion
[ -f "$HOME/.openclaw/completions/openclaw.bash" ] && source "$HOME/.openclaw/completions/openclaw.bash"

# vim: wm=0
echo "Done with $(basename "${BASH_SOURCE[0]}")"
