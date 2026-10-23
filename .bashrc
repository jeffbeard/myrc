# .bashrc
#
# Interactive shell setup. Read directly by non-login shells (Linux terminal
# emulators, `ssh host cmd`) and via .bash_profile by login shells.

# Source global definitions (RHEL/Fedora). Debian reads /etc/bash.bashrc on its own.
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Non-login shell that has not seen .bash_profile yet: load it. It sets the
# environment and then sources this file again, so stop here afterwards.
if [ -z "$MYRC_ENV_LOADED" ] && [ -f "$HOME/.bash_profile" ]; then
    . "$HOME/.bash_profile"
    return
fi

# Everything below is for interactive shells only.
case $- in
    *i*) ;;
    *) return ;;
esac

## nvm (Node version manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

## Aliases and functions
if [ -f "$HOME/.bash_aliases" ]; then
    . "$HOME/.bash_aliases"
fi

## Completion

# Complete ssh hostnames from ~/.ssh/config (skips wildcard patterns).
export COMP_WORDBREAKS=${COMP_WORDBREAKS/\:/}
_sshcomplete() {
    if [ -r "$HOME/.ssh/config" ]; then
        COMPREPLY=($(compgen -W "$(awk '/^Host / { for (i = 2; i <= NF; i++) if ($i !~ /[*?!]/) print $i }' "$HOME/.ssh/config")" -- "${COMP_WORDS[COMP_CWORD]}"))
    fi
    return 0
}
complete -o default -o nospace -F _sshcomplete ssh

if command -v terraform >/dev/null 2>&1; then
    complete -C "$(command -v terraform)" terraform
fi
if command -v kubectl >/dev/null 2>&1; then
    . <(kubectl completion bash 2>/dev/null)
    complete -o default -F __start_kubectl k 2>/dev/null
fi
