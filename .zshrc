# Check if runningon WSL
ONWSL=$(grep -c Microsoft /proc/sys/kernel/osrelease)

# Secure umask
# (before installing all zplug stuff to avoid "insecure files" issue...)
umask 022

# https://github.com/Microsoft/WSL/issues/1887
[[ "$ONWSL" == "1" ]] && unsetopt BG_NICE

# Install zplug if needed
if [[ ! -d ~/.zplug ]]; then
  git clone https://github.com/zplug/zplug ~/.zplug
  source ~/.zplug/init.zsh && zplug update
fi

# Essential
source ~/.zplug/init.zsh

# Make sure to use double quotes to prevent shell expansion
zplug "zsh-users/zsh-syntax-highlighting"

# Add a bunch more of your favorite packages!
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/colorize", from:oh-my-zsh
zplug "plugins/z", from:oh-my-zsh
zplug "zsh-users/zsh-completions"
zplug "robbyrussell/oh-my-zsh", use:"lib/*.zsh"
zplug "themes/robbyrussell", from:oh-my-zsh, as:theme
#zplug "dracula/zsh", from:github, as:theme

# Install packages that have not been installed yet
if ! zplug check --verbose; then
    echo; zplug install
fi

# Load all Zplug things
zplug load

# Required by GPG
export GPG_TTY=$(tty)

# Preferred editor for local and remote sessions
export VISUAL='nvim'
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR=$VISUAL
else
  export EDITOR=$VISUAL
fi

# Aliases
[[ -f ~/.aliases ]] && source ~/.aliases
LOCALALIASES=~/.aliases.local
[[ -f $LOCALALIASES ]] && source $LOCALALIASES

# On WSL connect to Docker over TCP as sockets won't work
[[ "$ONWSL" == "1" ]] && export DOCKER_HOST="tcp://0.0.0.0:2375"

# SSH Agent, according to some advices from
# http://rabexc.org/posts/pitfalls-of-ssh-agents
SSH_AGENT_CACHE_TTL="28800" # 8h, should be enough for a work dat
ssh-add -l &>/dev/null
if [[ "$?" == "2" ]]; then
  test -r ~/.ssh-agent && eval "$(<~/.ssh-agent)" >/dev/null
  ssh-add -l &>/dev/null
  if [[ "$?" == "2" ]]; then
    (umask 066; ssh-agent -t $SSH_AGENT_CACHE_TTL > ~/.ssh-agent)
    eval "$(<~/.ssh-agent)" >/dev/null
    ssh-add
  fi
fi

# Emulate ~/.bash_logout
#trap '. $HOME/.zsh_logout; exit' 0

# Setup direnv
eval "$(direnv hook zsh)"

# Local zshrc
LOCALZSHRC=~/.zshrc.local
[[ -f $LOCALZSHRC ]] && source $LOCALZSHRC

