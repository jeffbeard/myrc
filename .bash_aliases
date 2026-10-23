## .bash_aliases
##
## Aliases and functions for interactive shells. Sourced from .bashrc.
## Portable across macOS and Linux: anything that differs is branched on
## MYRC_OS, and anything needing an optional tool is guarded.

: "${MYRC_OS:=$(uname -s)}"

## CLI prompt
PS1="[\u@\h \W]\\$ "
#export PS1="\e[0;35m[\u@\h \W]\$ \e[m"

#######################
## Simple aliases
#######################

# Grep colorize (GREP_COLOR is deprecated since GNU grep 3.8)
export GREP_COLORS="mt=1;33"
alias grep='grep --color=auto'

## ls: GNU takes --color, BSD/macOS takes -G (which on GNU means --no-group)
if ls --color=auto / >/dev/null 2>&1; then
    alias ls='ls --color=auto'
else
    alias ls='ls -G'
fi

## Utility thingies
alias c='clear'
alias l='ls -la'
alias lf='ls -CF'
alias lt='ls -lath'
alias rm='rm -i'
alias less='less -R'
alias more='less -R'
command -v vim >/dev/null 2>&1 && alias vi='vim'
alias vv='vi -u NONE ~/.vimrc'
alias v='vi -u NONE'
alias vis='sudo vim'
alias df='df -h'
command -v gawk >/dev/null 2>&1 && alias awk='gawk'
alias untar='tar -xvf'      # modern tar autodetects gz/bz2/xz
alias unjar='jar -xvf'
alias vb='vi ~/.bash_aliases'
alias vp='vi ~/.bash_profile'
alias vs='vi ~/.ssh/config'
alias sb='source ~/.bash_profile'
alias h='history'
alias e='exit'
alias j='jobs'
alias u='uptime'
alias mysql='mysql --auto-rehash'
alias sql='mysql -u root -p'
alias t='tail -f'
alias gw='chmod +x ./gradlew;./gradlew'
command -v rpm >/dev/null 2>&1 && alias rpmg='rpm -qa | grep'

## top: sort by CPU, refresh every 2s. Flags differ between macOS and procps.
if [ "$MYRC_OS" = Darwin ]; then
    alias top='top -o cpu -s 2'
else
    alias top='top -o %CPU -d 2'
fi

## Listening sockets: ss on modern Linux, netstat elsewhere
if command -v ss >/dev/null 2>&1; then
    alias lgrep='ss -ltn'
else
    alias lgrep='netstat -nat | grep LISTEN'
fi

## Network thingies
command -v ncftp >/dev/null 2>&1 && alias ftp='ncftp'
if command -v wget >/dev/null 2>&1; then
    alias dl='wget'
else
    alias dl='curl -LO'
fi
alias xterm='xterm -bg black -fg "light grey" -sb -bc -cr "lime green" -ls -rightbar -bw 1 -title "$HOSTNAME" &'
#alias whois='whois -h whois.networksolutions.com'

## Programming thingies
alias pd='perldoc'
alias cho='cvs checkout'
alias cup='cvs -q update -dP'
alias cm='cvs commit'
alias ck='cvs -n -q update'
alias cdh='cvs diff'
alias sk='svn status --show-updates'
alias sup='svn update'
alias sm='svn commit'
alias gs='git status'
alias gp='git pull'
alias gu='git push'
alias cpan='perl -MCPAN -e shell'
alias mdc='make distclean;c'

## k8s aliases
alias k='kubectl'

## Vagrant aliases
alias vup='vagrant up'
alias vap='vagrant provision'
alias vh='vagrant halt'
alias vd='vagrant destroy'
alias vsh='vagrant ssh'
alias vst='vagrant status'

## Terraform / Terragrunt aliases
alias tf='terraform'
alias tfs='terraform show'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tg='terragrunt'

## Docker aliases
alias dip="docker inspect --format '{{ .NetworkSettings.IPAddress }}'"
drm() { docker rm $(docker ps -q -a); }
dri() { docker rmi $(docker images -q); }
alias dkd='docker run -d -P'
db() { docker build -t "$1" .; }
alias dki='docker images'
alias dkps='docker ps -a'
alias dks='docker images; docker ps -a'

###########################
## Less than simple aliases
###########################

## Usage: psgrep <pattern>
psgrep()
{
    ps -ef | grep -- "$1" | grep -v grep
}

## Usage: psm <process-name>  (memory/cpu summary for every process with that exact name)
psm()
{
    local pids
    pids=$(pgrep -d, -x -- "$1")
    if [ -z "$pids" ]; then
        echo "psm: no process named '$1'"
        return 1
    fi
    ps -o pid,user,rss,vsz,%cpu,%mem,comm -p "$pids"
}

## Usage: lsgrep <string>
lsgrep()
{
    ls | grep -- "$1"
}

## History grep that narrows by every pattern given.
## Usage: hgrep <pattern> [<pattern> ...]
## (was `hg`, which shadowed Mercurial)
hgrep()
{
    local out pat
    out=$(history)
    for pat in "$@"; do
        out=$(printf '%s\n' "$out" | grep -- "$pat")
    done
    printf '%s\n' "$out"
}

## Usage: zap <pattern>   (kill -9 every process whose command line matches)
zap()
{
    local pids
    pids=$(pgrep -f -- "$1")
    if [ -z "$pids" ]; then
        echo "zap: no process matches '$1'"
        return 1
    fi
    echo -n "killing $1 (process $(echo $pids | tr '\n' ' '))..."
    kill -9 $pids && echo "slaughtered."
}

## Usage: tailf [<filename>]   (defaults to nohup.out)
## (was `watch`, which shadowed /usr/bin/watch on Linux)
tailf()
{
    if [ $# -ne 1 ] ; then
        tail -f nohup.out
    else
        tail -f "$1"
    fi
}

## One step perm fixin'
## Usage: chmog mode owner group file
chmog()
{
    if [ $# -ne 4 ] ; then
        echo "usage: chmog mode owner group file"
        return 1
    fi
    chmod "$1" "$4" && chown "$2:$3" "$4"
}

## Find the cpu hogs
tophog()
{
    ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10
}

## Find all the hogs
allhog()
{
    ps -eo pcpu,pid,user,args | sort -r -k1 | less
}

## ssh to a running EC2 instance by its Name tag (needs aws cli + credentials).
## User and key come from ~/.ssh/config.
## Usage: ec2sh <Name-tag>
ec2sh()
{
    local name=$1 host

    if [ -z "$name" ]; then
        echo "usage: ec2sh <Name-tag>"
        return 1
    fi

    host=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=$name" "Name=instance-state-name,Values=running" \
        --query 'Reservations[].Instances[].PublicIpAddress' --output text 2>/dev/null)

    if [ -n "$host" ] && [ "$host" != None ]; then
        echo "ec2 host: $host"
        ssh "$host"
    else
        echo "no running instance named '$name'. Available:"
        aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" \
            --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' --output text
    fi
}
