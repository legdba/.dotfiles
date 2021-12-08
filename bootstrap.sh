#!/bin/bash

# Directory of .dotfile (hosting that script)
DOTFILES_DIR=$(dirname "$0" | xargs readlink -f)

# Files to ignore while LSing .dotfile/ for files to simlink into $HOME
LS_IGNORE='-I . -I .. -I *.md -I LICENSE -I NOTICE -I *.sh -I *.txt -I *.swp -I *.bak -I *.bkp -I *.old -I ~* -I *.tmp -I .gitignore -I .git -I .gnupg'

# Check if a logout is needed for applying changes
LOGOUTNEEDED="0"

# Need to detect WSL2 as docker deamon is installed on the host instead of the guest
ONWSL2="$(uname -r | grep -c WSL2)"


function die() {
  local rc=$1
  shift
  local msg=$*
  [ -z "$msg" ] || echo "$msg" >&2
  exit  "$rc"
}

# Install a set of packages
function installpkgs() {
    # Refuse to run as root as a couple of things (such as OMZ) would install on
    # the root account instead of current account.
    [ "$(whoami)" == "root" ] && die 1 "error: don't run as root; sudo is used where needed."

    printf "updating apt-sources ..."
    sudo apt-get update -y > /dev/null || die 1 # -q=2 does not disable enough output
    echo " success"
    printf "installing packages ..."
    sudo apt-get install -y \
        rng-tools \
        zsh \
        curl \
        dnsutils \
        wget \
        direnv \
        expect \
        zip unzip \
        jq \
        dos2unix \
        golang \
        python3 \
        python3-pip \
        python3-setuptools \
        tmux \
        vim \
        neovim \
        exuberant-ctags \
        make \
        automake \
        autoconf \
        cmake \
        graphviz \
        openjdk-11-jdk \
        gpg \
        gnupg2 \
        pinentry-tty \
        shellcheck \
        awscli \
        > /dev/null \
        || die 1
    echo " success"
}

# Default shell to ZSH
function defaulttozsh() {
    printf "setting zsh default shell ..."
    DEFAULT_SHELL=$(getent passwd "$LOGNAME" | cut -d: -f7)
    if [[ "$DEFAULT_SHELL" == "/usr/bin/zsh" ]]; then
        echo " success"
    else
        sudo chsh -s "$(which zsh)" "$USER" || die 1 # need sudo as chsh usually prompts for user's password. $USER is passed through sudo.
        echo " success"
    fi
}

# Install docker
# Installs docker.io instead of docker-ce. While is lags a bit behind upstream
# it's officially supported and tested on the OS. Unless bleeding edge features
# are needed docker.io is the way to go for me.
function installdocker() {
    printf "installing docker.io ..."
    sudo apt-get install -y docker.io > /dev/null || die 1
    sudo usermod -aG docker "$USER" || die 1 # -q=2 does not disable enough output
    echo " success"

    # Enable docker daemon only on true Linux, not WSL
    printf "enabling docker daemon ..."
    if [ "$ONWSL2" == "1" ]; then
	echo " skipping (WSL v2)"
    else
        # On a pure Linux
        sudo systemctl -q start docker || die 1
        sudo systemctl -q enable docker || die 1
        echo " success"
    fi
}

# Create a link $2 pointing to a file $1
# Does nothing if the link exist
# Replace any existing link to a different target
# Backup any file with $2 before linking
function linkfile() {
    local fn=$1 # the target file in .dotfiles/
    local ln=$2 # the link in $HOME/ pointing to $fn

    printf "linking %s -> %s ..." "$ln" "$fn"
    if [ -e "$ln" ]; then
        # $ln exists already
        if [ -L "$ln" ];then
            # it's a symlink
            if [ "$(readlink -f "$ln")" == "$(readlink --canonicalize "$fn")" ]; then
                # already linked to the right target
                echo " found"
            else
                # linked to a different target
                rm -f "$ln" || die 1
                ln -s "$fn" "$ln" || die 1
                echo " relinked"
            fi
        else
            # it's not a symlink, conflict
            mv "$ln" "$ln.pre_dotfiles" || die 1
            ln -s "$fn" "$ln" || die 1
            echo " updated"
        fi
    else
        # does not exist, link
        ln -s "$fn" "$ln" || die 1
        echo " success"
    fi
}

# Link all files in .dotfiles from $HOME
function setuplinks() {
    for fn in $(ls $LS_IGNORE -a "$DOTFILES_DIR") ; do
        fn="${DOTFILES_DIR}/${fn}"
        ln="${HOME}/$(basename "$fn")"
        linkfile "$fn" "$ln"
    done
}

# Install vim-plug for nvim
function installnvimplug() {
    printf "installing vim-plug for nvim ..."
    curl -sfLo "${HOME}/.local/share/nvim/site/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    echo " success"
    printf "installing nvim plugins ..."
    nvim +PlugInstall +qall
    echo " success"
}

function installlocalbins() {
    printf "creating %s/bin ..." "$HOME"
    if [ -d "${HOME}/.bin" ]; then
        echo " found"
    else
        mkdir -p "${HOME}/.bin" || die 1
        chmod 750 "${HOME}/.bin" || die 1
        echo " success"
    fi
}

function acquiresudo() {
    printf "acquiring sudo ..."
    if sudo -n true 2>/dev/null; then
        echo " success"
    else
        echo " failure"
        sudo touch /dev/null || die 1 # a noop only for prompting the user
    fi
}

function fixz {
    # Z install tends not to create ~/.z and complain on 1st directory change
    touch ~/.z
}


# Fix premissions on self, often messed up by the lack of a properly set umaks
# prior to running that script and loading out
function fixselfperms() {
    find "$DOTFILES_DIR" -type f -print0 | xargs -0 chmod 640 || die 1
    find "$DOTFILES_DIR" -type f -name "*.sh" -print0 | xargs -0 chmod 750 || die 1
    find "$DOTFILES_DIR" -type d -print0 | xargs -0 chmod 750 || die 1
}

function forcezpluginstall() {
    printf "changing shell to zsh ..."
    exec zsh -s <<EOF
echo " success";
printf "installing zplug ...";
source $HOME/.zshenv;
source $HOME/.zshrc;
echo " success";
[[ "$LOGOUTNEEDED" == "1" ]] && echo "LOGOUT NEEDED BY SOME CHANGES"
EOF
}

function gitdefaults() {
  printf "setting git config ..."

  # Forces newly cloned/inited repos to bet set with a local user name and
  # email, avoiding the default one to leak...
  git config --global user.useConfigOnly true || die 1

  # Keep credentials cached for 24h
  git config --global credentials.helper 'cache --timeout=86400' || die 1
  # unsecure: git config --global credentials.helper store

  # Auto-sign commits by default
  # need conditional includes: git config --global commit.gpgsign true || die 1

  echo " success"
}

# Check the distribution is supported
function checkdistro() {
  printf "checking distro ..."
  DISTRO=$(lsb_release -d | awk -F '\t' '{print $2}')
  if [ "$(echo "$DISTRO" | grep -c 'Ubuntu 20.')" == "1" ]; then
    echo " ok ($DISTRO)"
  else
    echo " unsupported ($DISTRO)"
    die 1 "error: requires Ubuntu 20.x, found $DISTRO"
  fi
}

# Link ~/.gnupg/gpg.conf to .dotfiles/.gnupg/gpg.conf
# Does not use the general linking mechanism as ~/.gnupg/ contains dynamic
# files that shall not be under .dotfiles/
function setgnupg() {
  printf "creating %s/.gnupg ..." "$HOME"
  if [ ! -d "${HOME}/.gnupg" ]; then
    mkdir -p "${HOME}/.gnupg" || die 1
    chmod 700 "${HOME}/.gnupg" || die 1
    echo " success"
  else
    echo " found"
  fi
  if [ "$(pgrep gpg-agent | wc -l)" == "1" ]; then
    # stop agent as it would prevent changes in ~/.gnupg
    # it will restart on its own when needed
    printf "stopping gpg-agent ..."
    pkill gpg-agent || die 1
    echo " success"
  fi
  linkfile "$DOTFILES_DIR/.gnupg/gpg.conf" "${HOME}/.gnupg/gpg.conf" || die 1
  linkfile "$DOTFILES_DIR/.gnupg/gpg-agent.conf" "${HOME}/.gnupg/gpg-agent.conf" || die 1
}

function createdotssh() {
  printf "creating %s ..." "$HOME/.ssh"
  if [ ! -d "$HOME/.ssh" ]; then
    mkdir -p "$HOME/.ssh" || die 1
    chmod 700 "$HOME/.ssh" || die 1
    echo " success"
  else
    echo " found"
  fi

  printf "configuring ssh key caching ..."
  if [ "$(grep -s AddKeysToAgent "${HOME}/.ssh/config" || echo doit)" == "doit" ]; then
    tee -a "${HOME}/.ssh/config" > /dev/null <<EOF || die 1
AddKeysToAgent yes
EOF
    echo " success"
  else
    echo " found"
  fi

}

function installpipenv() {
  printf "installing pipenv ..."
  pip3 -q install --user pipenv || die 1
  echo " success"
}

umask 022
checkdistro
acquiresudo
fixselfperms
installpkgs
defaulttozsh
installdocker
setuplinks
installnvimplug
installlocalbins
setgnupg
fixz
createdotssh
installpipenv
# DON'T ADD LINES BELOW HERE AS THE FUNCTION ABOVE CREATES A NEW SHELL
forcezpluginstall
[[ "$LOGOUTNEEDED" == "1" ]] && echo "LOGOUT NEEDED BY SOME CHANGES"

