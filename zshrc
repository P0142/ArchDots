# Return if not running interactively
[[ $- != *i* ]] && return

# ====== Environment Variables ======
# Python virtualenv
export WORKON_HOME=$HOME/.local/python/virtualenvs
source /usr/bin/virtualenvwrapper_lazy.sh

# Go
export GOPATH=$HOME/.local/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

# Rust
export RUSTBIN=$HOME/.cargo/bin
export PATH=$PATH:$RUSTBIN

# Ruby
export PATH=$PATH:$HOME/.local/share/gem/ruby/3.3.0/bin

# Java
export AWT_TOOLKIT=MToolkit
export _JAVA_AWT_WM_NONREPARENTING=1

# Additional PATH entries
export PATH=$PATH:$HOME/.local/bin:$HOME/.local/scripts

# ====== Prompt Configuration ======
PROMPT='%B%F{magenta}%2~%f%b -> '
RPROMPT='%B%F{cyan}触发%f%b@%B%F{magenta}%m%f%b'

# ====== History Settings ======
HISTFILE=$HOME/.histfile
HISTSIZE=5000
SAVEHIST=2000

setopt append_history       # Append to history file
setopt share_history        # Share history between sessions
setopt extended_history     # Save timestamp and duration
setopt inc_append_history   # Add commands immediately
setopt histignorespace      # Ignore commands starting with space
setopt no_nomatch           # Don't error on failed globs

# ====== Directory and Navigation ======
setopt auto_cd              # cd by typing directory name
setopt auto_pushd           # Push directories to stack
setopt pushd_ignore_dups    # Don't push duplicates
setopt complete_in_word     # Complete inside words
setopt glob_complete        # Complete globs
setopt extended_glob        # Enhanced globbing

# ====== Completion System ======
autoload -Uz compinit
zmodload zsh/complist

# Completion cache
typeset -g comppath=$HOME/.cache
typeset -g compfile=$comppath/.zcompdump
[[ -d $comppath ]] || mkdir -p $comppath
[[ -w $compfile ]] || rm -f $compfile

compinit -u -d $compfile

# Completion styles
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $comppath
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# ====== Key Bindings ======
bindkey -e  # Emacs keybindings

# Navigation
# These functions search history for lines matching the current input
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Arrow keys - history search based on current input
bindkey '^[[A' up-line-or-beginning-search    # Up arrow
bindkey '^[[B' down-line-or-beginning-search  # Down arrow

bindkey '^P' up-history		# (Ctrl+P) - Search backward through history regardless of current input
bindkey '^N' down-history	# (Ctrl+N) - Search forward through history regardless of current input
bindkey '^E' end-of-line	# (Ctrl+E) - Move cursor to End of line
bindkey '^A' beginning-of-line	# (Ctrl+A) - Move cursor to Beginning of line

# Enhanced Ctrl+Arrow navigation
move-5chars-left() {
	zle backward-char -n 5
}

move-5chars-right() {
	zle forward-char -n 5
}

move-10chars-left() {
	zle backward-char -n 10
}

move-10chars-right() {
	zle forward-char -n 10
}

# Register the widgets
zle -N move-5chars-left
zle -N move-5chars-right
zle -N move-10chars-left
zle -N move-10chars-right

# Bind keys (using terminfo where available)
if [[ -n "$terminfo[kLFT5]" ]]; then
	bindkey "$terminfo[kLFT5]" move-5chars-left     # Ctrl+Left
	bindkey "$terminfo[kRIT5]" move-5chars-right	# Ctrl+Right
	bindkey "$terminfo[kUP5]" move-10chars-left     # Ctrl+Up
	bindkey "$terminfo[kDN5]" move-10chars-right    # Ctrl+Down
else
	# Fallback bindings for most terminals
	bindkey '^[[1;5D' move-5chars-left	    # Ctrl+Left
	bindkey '^[[1;5C' move-5chars-right	    # Ctrl+Right
	bindkey '^[[1;5A' move-10chars-left	    # Ctrl+Up
	bindkey '^[[1;5B' move-10chars-right	# Ctrl+Down
fi

# ====== Aliases ======
# Core utilities
alias cd..='cd ..'
alias ls='ls --color=auto'
alias la='ls -lah --color=auto'
alias ll='ls -lh --color=auto'
alias grep='grep --color=auto'
alias ip='ip -color=auto'

# Clipboard
alias cb='xclip -selection clipboard'
alias cbpng='xclip -selection clipboard -t image/png'

# Applications
alias zath='zathura'
alias ft='faketime'

# Directory listings
alias lsd='ls -d */'
alias lss='ls -l *(s,S,t)'  # suid/sgid/sticky
alias lsl='ls -l *(@)'      # symlinks
alias lsx='ls -l *(*)'      # executables

# ====== Functions ======
# Smart cd that can handle files
cd() {
    if (( $# == 1 )) && [[ -f $1 ]]; then
        [[ ! -e ${1:h} ]] && return 1
        print "Correcting $1 to ${1:h}"
        builtin cd ${1:h}
    else
        builtin cd "$@"
    fi
}

# Make directory and cd into it
mkcd() {
    (( $# != 1 )) && print "Usage: mkcd <dir>" && return 1
    [[ ! -d $1 ]] && command mkdir -p $1
    builtin cd $1
}

# Create faketime shell session with time from remote host
ftsh() {
    if (( $# != 1 )); then
        echo "Usage: ftsh IP_ADDRESS"
        return 1
    fi
    local ip=$1
    local time_format
    # Get time from remote host and format it
    if ! time_format=$(rdate -n "$ip" -p 2>/dev/null | awk '{print $2, $3, $4}' | date -f - "+%Y-%m-%d %H:%M:%S" 2>/dev/null); then
        echo "Error: Could not get time from $ip" >&2
        return 1
    fi
    # Launch faketime shell
    faketime "$time_format" zsh
}

# Launch ffuf to fuzz for subdomains/vhosts 
fuzz_dns() {
    ffuf -w /opt/SecLists/Discovery/DNS/subdomains-top1million-20000.txt -H "Host: FUZZ.$1" -u http://$1 -ac
}

# Launch ffuf to fuzz web directories with quickhits
fuzz_dir() {
    ffuf -w /opt/SecLists/Discovery/Web-Content/quickhits.txt -u http://$1/FUZZ -ac
}

# ====== Plugins ======
# Syntax highlighting (must be at the end)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
