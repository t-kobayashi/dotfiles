autoload -Uz compinit
compinit
### Added by Zplugin's installer
source "$HOME/.zplugin/bin/zplugin.zsh"
autoload -Uz zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin
### End of Zplugin installer's chunk
zplugin load zsh-users/zsh-syntax-highlighting
zplugin load zsh-users/zsh-completions
zplugin light sindresorhus/pure

source <(kubectl completion zsh)
