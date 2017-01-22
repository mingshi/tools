#enables colorin the terminal bash shell export

export CLICOLOR=1

#sets up thecolor scheme for list export

export LSCOLORS=gxfxcxdxbxegedabagacad

#sets up theprompt color (currently a green similar to linux terminal)

export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;36m\]\w\[\033[00m\]\$ '

#enables colorfor iTerm

# ssh function

function md 
{
    ssh -t 206 "source .profile;ssh $1"
}

export TERM=xterm-color

export PATH="$(brew --prefix php54)/bin:$PATH"
export PATH="/opt/local/bin:$PATH"
#export JAVA_HOME=`/usr/libexec/java_home`
export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
export RSENSE_HOME='/Users/mingshi/opt/rsense-0.3'
source ~/.profile

alias ll='ls -l'
alias uwsgi='/usr/local/share/python/uwsgi'
alias python='/usr/local/bin/python'
source ~/.git-completion.bash

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

alias dbydf="ssh -L 3306:localhost:3306 ydf@121.40.172.197"
alias dbxiaoqu="ssh -L 3306:localhost:3306 xiaoqu@121.41.45.104"
alias dbdevxiaoqu="ssh -L 3306:localhost:3306 dev@121.40.180.111"
alias dbdevredis="ssh -L 6379:localhost:6379 dev@121.40.180.111"
alias dbugoche="ssh -L 3306:localhost:3306 ugoche@121.41.44.80"
alias pycm="python -m py_compile"

export NVM_DIR="/Users/mingshi/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
