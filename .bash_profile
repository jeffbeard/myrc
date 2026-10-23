# .bash_profile
#
# Environment and PATH. Read by login shells (macOS Terminal, ssh login,
# `bash -l`). Non-login interactive shells (most Linux terminal emulators)
# read .bashrc, which pulls this file in once if it has not run yet.
#
# Works on macOS (Intel + Apple silicon) and Linux. Anything OS- or
# tool-specific is guarded so a missing tool costs nothing.

MYRC_OS=$(uname -s)
export MYRC_ENV_LOADED=1

# Add a directory to the front of PATH, only if it exists and is not there yet.
pathadd() {
    [ -d "$1" ] || return 0
    case ":$PATH:" in
        *":$1:"*) ;;
        *) PATH="$1:$PATH" ;;
    esac
}

# Bash normally skips ~/.profile when ~/.bash_profile exists. Keep it honored.
[ -f "$HOME/.profile" ] && . "$HOME/.profile"

## History
export HISTTIMEFORMAT="[%D %T] "
export HISTSIZE=20000
export HISTFILESIZE=40000
export HISTCONTROL=ignoredups
export HISTIGNORE="ls:ls *:l:lt:cat *:*AWS*:*SECRET*:*KEY*:*TOKEN*"

export EDITOR=vi

## Homebrew (macOS). Sets PATH, MANPATH, HOMEBREW_* for either prefix.
if [ "$MYRC_OS" = Darwin ]; then
    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv bash)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv bash)"
    fi
fi

## Java. Prefer the OS-provided locator, then a Homebrew openjdk, then javac.
if [ -x /usr/libexec/java_home ] && /usr/libexec/java_home >/dev/null 2>&1; then
    export JAVA_HOME=$(/usr/libexec/java_home)
elif [ -n "$HOMEBREW_PREFIX" ] && ls -d "$HOMEBREW_PREFIX"/opt/openjdk*/libexec/openjdk.jdk/Contents/Home >/dev/null 2>&1; then
    export JAVA_HOME=$(ls -d "$HOMEBREW_PREFIX"/opt/openjdk*/libexec/openjdk.jdk/Contents/Home | sort -V | tail -1)
elif command -v javac >/dev/null 2>&1; then
    export JAVA_HOME=$(dirname "$(dirname "$(readlink -f "$(command -v javac)")")")
fi
[ -n "$JAVA_HOME" ] && pathadd "$JAVA_HOME/bin"

## JVM build tools. Only exported if installed at the conventional spot.
for _tool in tomcat:CATALINA_HOME ant:ANT_HOME maven:MAVEN_HOME gradle:GRADLE_HOME mysql:MYSQL_HOME; do
    _dir=/usr/local/${_tool%%:*}
    if [ -d "$_dir" ]; then
        export "${_tool##*:}=$_dir"
        pathadd "$_dir/bin"
    fi
done
unset _tool _dir
export ANT_ARGS='-logger org.apache.tools.ant.listener.AnsiColorLogger'

## Go. GOROOT is set by the go binary itself; only GOPATH/bin needs PATH.
export GOPATH=$HOME/go
pathadd /usr/local/go/bin
pathadd "$GOPATH/bin"

## Rust
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

## uv / pipx style user tools
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
pathadd "$HOME/.local/bin"

## Personal bin
pathadd "$HOME/bin"

# Drop duplicate PATH entries (path_helper, brew shellenv and inherited PATH overlap)
PATH=$(printf '%s' "$PATH" | awk -v RS=: -v ORS=: '!seen[$0]++' | sed 's/:$//')
export PATH

## less: pipe archives, PDFs, etc. through a filter when one is installed.
if command -v lesspipe.sh >/dev/null 2>&1; then
    export LESSOPEN="|lesspipe.sh %s"          # Fedora/RHEL, Homebrew
elif command -v lesspipe >/dev/null 2>&1; then
    eval "$(SHELL=/bin/sh lesspipe)"           # Debian/Ubuntu
fi

## ls colors
if [ "$MYRC_OS" = Darwin ]; then
    export CLICOLOR=TRUE
    export LSCOLORS=exfxbxdxcxegedabagacad
elif command -v dircolors >/dev/null 2>&1; then
    eval "$(dircolors -b)"
fi

unset USERNAME

# Files 664, directories 775
umask 0002

# Interactive setup (aliases, completion) lives in .bashrc
if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi
