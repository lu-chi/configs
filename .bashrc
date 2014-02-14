#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#-------------------------#
# Bash configuration
#-------------------------#
shopt -s histappend
export HISTTIMEFORMAT="%F %T "
export HISTCONTROL=ignoredups:ignorespace:erasedups
export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTIGNORE="ls:la:l:ll:lla:[bf]g:clear:exit"
PS1='[\u@\h \W]\$ '
exists() {
    test -x "$(command -v "$1")"
}

# Enabled blocked forward incrmental search
# http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=383760
stty -ixon

#-------------------------#
# Aliases
#-------------------------#
alias df='df -h'
alias du='du -hs'
alias less='less'
alias free='free -m'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias p='sudo pacman'
alias pi='p -S'
alias pud='p -Sy'
alias pug='p -Syu'
alias pugf='pug'
alias pse='pacman -Ss'
alias pr='pacman -R'
alias psh='pacman -Si'
alias pshi='pacman -Qi'

alias halt='sudo shutdown -h now'
alias reboot='sudo reboot'
#Save session to disk and bind caps as escape on resume
# alias s2disk='dbus-send --system --dest="org.freedesktop.UPower" /org/freedesktop/UPower org.freedesktop.UPower.Hibernate && displays'
# alias s2ram='dbus-send --system --dest="org.freedesktop.UPower" /org/freedesktop/UPower org.freedesktop.UPower.Suspend && displays'
alias s2disk='sudo pm-hibernate && display.sh'
alias s2ram='sudo pm-suspend && display.sh'
alias s2both='sudo s2both && display.sh'

alias node='env NODE_NO_READLINE=1 rlwrap node'

alias mnt='udisksctl mount -b'
alias umnt='udisksctl unmount -b'

exists emacsclient && {
    alias e='emacsclient -n'
    alias ec='emacsclient -c'
    alias et='emacsclient -ct'
    alias ef='emacsclient -n -c'
}

exists vim && {
    alias vnew='vim --servername default'
}

alias eb='e ~/.bash_profile'
alias ez='e ~/.zshrc'
alias ev='e ~/.vimrc'
alias ee='e ~/.emacs'
#A pad to dump arbit data
alias ed='e /home/rohan/workspace/trash/dumppad.md'

alias ls='ls --color=yes'
alias l='ls'
alias la='ls -a'
alias ll='ls -l'
alias lla='ls -al'
# alias -g G='| grep'
# alias -g L='| less'

alias reb='exec bash'
alias ssh='TERM=linux;ssh'
alias cssh='TERM=linux;cssh'
alias screen='screen -U'

# Git aliases
git_branch () {
    git branch | grep "*" | cut -d " " -f 2
}
alias g="git"
alias ga="git add"
alias gc="git commit"
alias gca="git commit -a"
alias gst="git status"
alias gco="git checkout"
alias gl="git pull"
alias gp="git push"
alias gup="git fetch"
alias glg='git log --stat'
alias gcm='git checkout master'
alias gcd='git checkout develop'
alias ggpush='gp origin $(git_branch)'
alias ggprnp='gl origin $(git_branch) --rebase && ggpush'
alias gglr='gl origin $(git_branch) --rebase'

# MPC aliases
alias m="mpc"
alias mstatus="mpc -f '%artist% - %title%\n%album%' status"
alias mtog="mpc toggle"
#Search song from playlist and also get the song #
alias sose="mpc playlist | grep -in"

# Alters the mpd volume according to the sign and factor of 5
function _alter_mpd_vol(){
    num=$( echo "5*${2:-1}" | bc)
    mpc volume $1$num
}

#Increase Vol
function mup(){
    _alter_mpd_vol "+" $1
}
#Decrease Vol
function mdw(){
    _alter_mpd_vol "-" $1
}

alias entertain='mplayer "$(find "." -type f -regextype posix-egrep -regex ".*\.(avi|mkv|flv|mpg|mpeg|mp4|wmv|3gp|mov|divx)" | shuf -n1)"'
alias rand='tr -c "[:digit:]" " " < /dev/urandom | dd cbs=$COLUMNS conv=unblock | GREP_COLOR="1;32" grep --color "[^ ]"'

alias h='history'

function serve(){
    python3 -m http.server ${1:-8000}
}

#-------------------------#
# Completion
#-------------------------#

[[ -e /usr/share/bash-completion/completions/git ]] && {
    source /usr/share/bash-completion/completions/git
    complete -F _git g
}
[[ -e /usr/share/bash-completion/completions/mpc ]] && {
    source /usr/share/bash-completion/completions/mpc
    complete -F _mpc m
}
[[ -e /usr/share/bash-completion/completions/pacman ]] && {
    source /usr/share/bash-completion/completions/pacman
    complete -F _pacman p
}

#-------------------------#
# Prompt
#-------------------------#
_col() {
    if [[ -z "$2" ]]; then
        BOLD_STRING="0;"
    else
        BOLD_STRING="1;"
    fi
    echo "\[\033[$BOLD_STRING$1m\]"
}

prompt() {
    EXIT_STATUS="$?"

    history -a; history -c; history -r

    if git branch >/dev/null 2>/dev/null; then
        # This is a git repo
        VC_CHAR='±'
        VC_REF=$(git symbolic-ref HEAD | cut -d "/" -f 3-10) || {
            $(git rev-list --max-count=1 HEAD | cut -c 1-8)
        }
        if [[ -z "$(git status --porcelain)" ]]; then
            VC_STATUS=""
        else
            VC_STATUS="*"
        fi
        VC_INFO="$(_col 32 b) $VC_CHAR $(_col 36)($VC_REF$VC_STATUS)$(_col 34)"
    else
        VC_INFO=""
    fi

    if [[ $EXIT_STATUS != "0" ]]; then
        _PUSER_COLOR=31
        # EXIT_STRING="-[$(_col 31)$EXIT_STATUS$(_col 32)]$(_col 9)"
    else
        _PUSER_COLOR=32
    fi

    if [[ -n "$VIRTUAL_ENV" ]];then
        _PVENV=" $(_col 34)($(basename $VIRTUAL_ENV))"
    else
        _PVENV=""
    fi

    _PUSER="$(_col $_PUSER_COLOR b)\u$(_col 30)@$(_col 36)\h$(_col 34)"
    _PTIME="$(_col 33)\@$(_col 34)"
    _PDIR="$(_col 32)\W$(_col 34)"

    _L1="┌─[$_PUSER]-[$_PTIME]$VC_INFO$_PVENV"
    _L2="└─($_PDIR)->"

    PS1="$(_col 34)$_L1\n$(_col 34)$_L2 $(_col 0)"
}

PROMPT_DIRTRIM=2
PROMPT_COMMAND=prompt

exists virtualenvwrapper.sh && source `which virtualenvwrapper.sh`
# [[ -s "/etc/profile.d/autojump.sh" ]] && source "/etc/profile.d/autojump.sh"

#-------------------------#
# Functions
#-------------------------#
couchenv(){
    source $HOME/workspace/src/build-couchdb/build/env.sh
    export COUCH='http://admin:admin@localhost:5984'

    cguid(){
        echo $(curl -X GET $COUCH/_uuids 2> /dev/null G -o '\w\{32\}')
    }

    ccurl(){
        UUID=$(cguid)
        ABS_PATH=$(echo $1 | sed "s/UUID/$UUID/g")
        METHOD=${2:-GET}
        curl -X  $METHOD $COUCH/$ABS_PATH ${@:3}
    }

    ccurlv(){
        UUID=$(cguid)
        ABS_PATH=$(echo $1 | sed "s/UUID/$UUID/g")
        METHOD=${2:-GET}
        curl -vX  $METHOD $COUCH/$ABS_PATH ${@:3}
    }

}

dj(){
    cd ~/workspace/src/django && workon django
}

zlemma(){
    zlemma_parent=/home/rohan/workspace/zlemma

    export DJANGO_SETTINGS_MODULE=settings.local

    case $1 in
        re*)
            env='inscoring'
            project='recruiterservice'
            ;;
        sc*)
            env='inscoring'
            project='scoringservice'
            ;;
        *)
            env='zlemma'
            project='zlemma'
            ;;
    esac

    cd $zlemma_parent/$project
    export PYTHONPATH=$PWD:$PYTHONPATH
    workon $env
}

hr(){
    cd ~/workspace/is/ruby/hackerrank
    alias gpr='gl --rebase && gp'
}

s() {
    find . -iname "*$@*"
}

#Search for text in files
sg() {
    if [ $# -gt 1 ];then
        find . -iname "$1" | xargs grep "$2"
    else
        echo 'Input the file and grep patterns'
    fi
}
