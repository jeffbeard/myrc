# .bash_profile
export HISTTIMEFORMAT="[%D %T] "
export HISTSIZE=20000

export CATALINA_HOME=/usr/local/tomcat

export ANT_HOME=/usr/local/ant
export ANT_ARGS='-logger org.apache.tools.ant.listener.AnsiColorLogger'

## Poopy Mac JVM path
export JAVA_HOME="/Library/Java/JavaVirtualMachines/1.6.0_41-b02-445.jdk/Contents/Home"
export MAVEN_HOME=/usr/local/maven
export GRADLE_HOME=/usr/local/gradle
export MYSQL_HOME=/usr/local/mysql

export EDITOR=vi

## Some frameworks I play around with
export GRAILS_HOME=/usr/local/grails
export PLAY_HOME=/usr/local/play
export ROO_HOME=/usr/local/roo

export CLICOLOR=TRUE
export LSCOLORS=exfxbxdxcxegedabagacad
export LESSOPEN="|lesspipe.sh %s";

#export LESS_ADVANCED_PREPROCESSOR

## AWS related variables
export JETS3T_HOME=/usr/local/jets3t
export AWS_SNS_HOME=/usr/local/AWS/SNS
export EC2_HOME=/usr/local/AWS/EC2

## MongoDB
export MONGODB_HOME=/usr/local/mongodb

## Hadoop stuff
export HADOOP_HOME="/usr/local/hadoop"
export HIVE_HOME="/usr/local/hive"
export HIVE_PORT=10000

## Path
PATH=$JAVA_HOME/bin:$ANT_HOME/bin:$MYSQL_HOME/bin:$MAVEN_HOME/bin:$JETS3T_HOME/bin:$EC2_HOME/bin:$MONGODB_HOME/bin:$GRADLE_HOME/bin:$HOME/bin:$HADOOP_HOME/bin:$HIVE_HOME/bin:$GRAILS_HOME/bin:$PLAY_HOME:$ROO_HOME/bin

PATH=$PATH:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/X11R6/bin:/usr/local/go/bin:/Applications/Xcode.app/Contents/Developer/usr/bin/:/usr/local/sbt/bin

export PATH

## AWS CLI API tools credentials
export EC2_PRIVATE_KEY=~/.aws/aws-server.key
export EC2_CERT=~/.aws/aws-server.crt

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
   . ~/.bashrc
fi

if [ -f ~/.bash_aliases ]; then
   . ~/.bash_aliases
fi

unset USERNAME

# This make files 664 and dirs 775 
umask 0002 

## RVM allows control of multiple ruby version
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

## Bash completion support for ssh. Very handy
export COMP_WORDBREAKS=${COMP_WORDBREAKS/\:/}

_sshcomplete() {
    
    # parse all defined hosts from .ssh/config
    if [ -r $HOME/.ssh/config ]; then
        COMPREPLY=($(compgen -W "$(grep ^Host $HOME/.ssh/config | awk '{print $2}' )" -- ${COMP_WORDS[COMP_CWORD]}))
    fi

    return 0
}

complete -o default -o nospace -F _sshcomplete ssh

