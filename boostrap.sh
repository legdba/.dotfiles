#!/bin/bash

# Directory of .dotfile (hosting that script)
DOTFILES_DIR=$(dirname $0)

# Files to ignore while LSing .dotfile/ for files to simlink into $HOME
LS_IGNORE='-I . -I .. -I *.md -I LICENSE -I NOTICE -I *.sh -I *.txt -I *.swp -I *.bak -I *.bkp -I *.old -I ~* -I *.tmp -I .gitignore -I .git'

# Check if a logout is needed for applying changes
LOGOUTNEEDED="0"

# Need to detect WSL as some stuff is missing (no systemd, no dockerd
ONWSL="$(grep -c Microsoft /proc/sys/kernel/osrelease)"

function die() {
  local rc=$1
  shift
  local msg=$*
  [ -z "$msg" ] || echo $msg >&2
  exit  $rc
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
        zsh \
        curl \
        dnsutils \
        wget \
        direnv \
        zip unzip \
        jq \
        dos2unix \
        golang \
        python3 \
        vim \
        neovim \
        make \
        automake \
        autoconf \
        cmake \
        graphviz \
        openjdk-11-jdk \
        > /dev/null \
        || die 1
    echo " success"
}

# Default shell to ZSH
function defaulttozsh() {
    printf "setting zsh default shell ..."
    DEFAULT_SHELL=$(getent passwd $LOGNAME | cut -d: -f7)
    if [[ "$DEFAULT_SHELL" == "/usr/bin/zsh" ]]; then
        echo " success"
    else
        sudo chsh -s $(which zsh) $USER || die 1 # need sudo as chsh usually prompts for user's password. $USER is passed through sudo.
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
    sudo usermod -aG docker $USER || die 1 # -q=2 does not disable enough output
    echo " success"

    # Enable docker daemon only on true Linux, not WSL
    printf "enabling docker daemon ..."
    if [ "$ONWSL" == "1" ]; then
        # On WSL
        echo " skipping (WSL)"
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

    printf "linking $ln -> $fn ..."
    if [ -e $ln ]; then
        # $ln exists already
        if [ -L $ln ];then
            # it's a symlink
            if [ "$(readlink -f $ln)" == "$(readlink --canonicalize $fn)" ]; then
                # already linked to the right target
                echo " found"
            else
                # linked to a different target
                rm -f $ln || die 1
                ln -s $fn $ln || die 1
                echo " relinked"
            fi
        else
            # it's not a symlink, conflict
            mv $ln $ln.pre_dotfiles || die 1
            ln -s $fn $ln || die 1
            echo " updated"
        fi
    else
        # does not exist, link
        ln -s $fn $ln || die 1
        echo " success"
    fi
}

# Link all files in .dotfiles from $HOME
function setuplinks() {
    for fn in $(ls $LS_IGNORE -a $DOTFILES_DIR) ; do
        fn="${DOTFILES_DIR}/${fn}"
        ln=${HOME}/$(basename $fn)
        linkfile $fn $ln
    done
}

# Install vim-plug for nvim
function installnvimplug() {
    printf "installing vim-plug for nvim ..."
    curl -sfLo ${HOME}/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    echo " success"
    printf "installing nvim plugins ..."
    nvim +PlugInstall +qall
    echo " success"
}

function installlocalbins() {
    printf "creating ${HOME}/bin"
    if [ -d "${HOME}/.bin" ]; then
        echo " found"
    else
        mkdir -p ${HOME}/.bin || die 1
        chmod 750 ${HOME}/.bin || die 1
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

function fixwslmount() {
  printf "updating /mnt/c to /c ..."
  if [[ -f /etc/wsl.conf ]]; then
    echo " skip (/etc/wsl.conf already exists)"
  else
    echo | sudo tee /etc/wsl.conf > /dev/null <<EOF
[automount]
enabled = true
root = /
options = "metadata,umask=22,fmask=11"
mountFsTab = false
EOF
    LOGOUTNEEDED="1"
    echo " done"
  fi
}

# Fix premissions on self, often messed up by the lack of a properly set umaks
# prior to running that script and loading out
function fixselfperms() {
    find $DOTFILES_DIR -type f | xargs chmod 640 || die 1
    find $DOTFILES_DIR -type f -name "*.sh" | xargs chmod 750 || die 1
    find $DOTFILES_DIR -type d | xargs chmod 750 || die 1
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
  if [ "$(echo $DISTRO | grep -c 'Ubuntu 18.')" == "1" ]; then
    echo " ok ($DISTRO)"
  elif [ "$(echo $DISTRO | grep -c 'Debian GNU/Linux 9.')" == "1" ]; then
    echo " ok ($DISTRO)"
  else
    echo " unsupported ($DISTRO)"
    die 1 "error: require Ubuntu 18.x or Debian 9.5, found $DISTRO"
  fi
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
fixz
[[ "$ONWSL" ]] && fixwslmount
forcezpluginstall
[[ "$LOGOUTNEEDED" == "1" ]] && echo "LOGOUT NEEDED BY SOME CHANGES"
