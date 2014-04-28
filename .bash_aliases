## .bashrc
##
## Linux system env
##
## $Id$
##

## TODO work in progress...
#if [ -e /usr/local/etc/bash_completion.d/subversion ]; then
#    . /usr/local/etc/bash_completion.d/subversion
#fi

## CLI prompt
PS1="[\u@\h \W]\\$ "

#export PS1="\e[0;35m[\u@\h \W]\$ \e[m"

#######################
## Simple aliases
#######################

# Grep colorize
export GREP_COLOR="1;33"
alias grep='grep --color=auto'

## Utility thingies
alias  'c=clear'
alias 'ls=ls -G'
alias 'l=ls -la'
alias 'lf=ls -CF'
alias 'lt=ls -lath'
alias 'rm=rm -i'
alias 'less=less -r'
alias 'more=less -r'
alias 'vi=vim'
alias 'vv=vi -u NONE ~/.vimrc'
alias 'v=vi -u NONE'
alias 'vis=sudo vim'
alias 'df=df -h'
alias 'awk=gawk'
alias 'untar=/usr/bin/tar -xzvf'
alias 'unjar=/usr/bin/jar -xvf'
alias 'vb=vi ~/.bash_aliases'
alias 'vp=vi ~/.bash_profile'
alias 'vs=vi ~/.ssh/config'
alias 'sb=source ~/.bash_profile'
alias 'h=history'
alias 'e=exit'
alias 'j=jobs'
alias 'u=uptime'
alias 'psm=ps -o pid,user,rss,vsize,%cpu,%mem,ucomm -C'
alias 'rg=rpm -qa | grep'
alias 'lgrep=netstat -nat | grep LISTEN'
alias 'mysql=mysql --auto-rehash'
alias 'sql=mysql -u root -p'
alias 't=tail -f'
alias 'top=top -o cpu -s 2'

## Network thingies
alias 'ftp=ncftp'
#alias 'xterm=/usr/X11R6/bin/xterm -sb -rv -title "$HOSTNAME" &'
alias 'xterm=xterm -bg black -fg "light grey" -sb -bc -cr "lime green" -ls -rightbar -bw 1 -title "$HOSTNAME" &'
alias 'dl=wget'
#alias 'whois=whois -h whois.networksolutions.com'

## Progamming thingies
alias 'pd=perldoc'
alias 'cho=cvs checkout'
alias 'cup=cvs -q update -dP'
alias 'cm=cvs commit'
alias 'ck=cvs -n -q update'
alias 'sk=svn status --show-updates'
alias 'cdh=cvs diff'
alias 'sup=svn update'
alias 'sm=svn commit'
alias 'cpan=perl -MCPAN -e shell'
alias 'mdc=make distclean;c'

## These only work on Mac OS X
#alias java7="export JAVA_HOME=$(/usr/libexec/java_home -v 1.7); echo JAVA_HOME=\$JAVA_HOME;"
#alias java6="export JAVA_HOME=$(/usr/libexec/java_home -v 1.6); echo JAVA_HOME=\$JAVA_HOME;"
                                                                                 
## Vagrant aliases                                                               
alias vup='vagrant up'                                                                    
alias vap='vagrant provision'                                                             
alias vh='vagrant halt'                                                                   
alias vd='vagrant destroy'                                                                
alias vsh='vagrant ssh' 

## Docker aliases
alias dip="docker inspect --format '{{ .NetworkSettings.IPAddress }}'"
drm() { docker rm $(docker ps -q -a); }
dri() { docker rmi $(docker images -q); }
alias dkd="docker run -d -P"
db() { docker build -t="$1" .; }
alias dki="docker images";
alias dkps="docker ps -a";
alias dks="docker images; docker ps -a";


## Web server thingies
alias 'webcf=sudo vim /etc/httpd/conf/httpd.conf'
alias 'webctl=sudo /etc/init.d/httpd'

###########################
## Less than simple aliases
###########################

## Usage: co folder/app/trunk app
function co()
{
    local src="https://replace/with/your/repo/$1"
    local dst="$2"
    svn co $src $dst
}

## Usage: psgrep <program_name>
psgrep()
{
    ps -ef | grep $1 | grep -v grep
}

## Usage: lsgrep <string>
lsgrep()
{
    ls | grep $1
}

## History grep
## Usage: hg <string>
hg()
{
    history | grep $1
}
    
## Usage: zap <program>
zap()
{
    local pid

    pid=$(ps -ef | grep $1 | grep -v grep | awk '{ print $2 }')
    echo -n "killing $1 (process $pid)..."
    kill -9 $pid
    echo "slaughtered."
}

## Usage: watch <filename>
watch()
{
    if [ $# -ne 1 ] ; then
        tail -f nohup.out
    else
        tail -f $1
    fi
}

## One step perm fixin' 
chmog()
{
    if [ $# -ne 4 ] ; then
        echo "usage: chmog mode owner group file"
        return 1
    else
        chmod $1 $4
        chown $2 $4
        chgrp $3 $4
    fi
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

## Function to connect to any EC2 instances protected by the specified pem file
ec2sh()
{
  local NAME=$1

  local pem_file="$HOME/.ssh/<my-ec2.pem>"

  local HOST=$(ec2-describe-instances | \
    awk 'BEGIN { FS="\t" } /INSTANCE/ { inst_id = $2; inst_ip=$4; } \
    /TAG/ { if( inst_id == $3 && $5 == "'$NAME'") {print inst_ip; nextfile;} }')

  if [ -n "$HOST" ]; then

    echo 'ec2 host: -' $HOST '-'
    echo "ssh ${HOST}"
    ssh ${HOST}

  else
    echo 'hostname not found for host: ' $NAME
    echo 'Available intances: '
    ec2-describe-instances | grep TAG | awk '{print $5;}'
  fi
}

