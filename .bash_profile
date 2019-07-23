export EDITOR="emacs -nw"
export PATH=/sbin:/usr/sbin:$PATH

# lv
export LV='-Ou8 -c'

# golang
export GOPATH=$HOME/go
export PATH=/usr/local/go/bin:$GOPATH/bin:$PATH

# anyenv
if [ -d $HOME/.anyenv ]; then
    export ANYENV_HOME=$HOME/.anyenv
    export PATH=$ANYENV_HOME/bin:$PATH
    eval "$(anyenv init -)"
fi

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# VScode on osx
if [ -d "/Applications/Visual Studio Code.app/Contents/Resources/app/bin" ]; then
    PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
fi

# envsubst
if [ -d "/usr/local/opt/gettext/bin" ]; then
    PATH="/usr/local/opt/gettext/bin:$PATH"
fi

export PATH
