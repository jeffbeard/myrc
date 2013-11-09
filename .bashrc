# .bashrc

# User specific aliases and functions

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

## These were apparently automatically added for me

## RVM is a tool to manage ruby installations
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

# Cascading Lingual - Concurrent, Inc.
# http://cascading.org/lingual

export LINGUAL_HOME=/Users/beardj/.lingual-client

# add lingual tool to PATH
export PATH=$PATH:$LINGUAL_HOME/bin

