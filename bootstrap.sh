#!/bin/bash

# Directory of .dotfile (hosting that script)
DOTFILES_DIR=$(dirname "$0" | xargs readlink -f)

# Files to ignore while LSing .dotfile/ for files to simlink into $HOME
LS_IGNORE='-I . -I .. -I *.md -I LICENSE -I NOTICE -I *.sh -I *.txt -I *.swp -I *.bak -I *.bkp -I *.old -I ~* -I *.tmp -I .gitignore -I .git -I .gnupg'

# Check if a logout is needed for applying changes
LOGOUTNEEDED="0"

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

    echo "################"
    echo "installing packages ..."
    sudo dnf install -y \
        zsh \
        curl \
        wget \
        jq \
        dos2unix \
        || die 1
    echo "installing packages ... success"
}

# Setup ZSH
function setupzsh() {
    echo "################"
    echo "setting zsh shell ..."
    DEFAULT_SHELL=$(getent passwd "$LOGNAME" | cut -d: -f7)
    if [[ "$DEFAULT_SHELL" == "/usr/bin/zsh" ]]; then
        echo "default shell already zsh"
    else
        sudo chsh -s "$(which zsh)" "$USER" || die 1 # need sudo as chsh usually prompts for user's password. $USER is passed through sudo.
    fi

    echo "setting zsh shell ... success"
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
    echo "########################"
    echo "Symlinks creating/verification ... "
    for i in $(ls -a $DOTFILES_DIR/.*.symlink) ; do
        fn=$(realpath ${i})
        ln=~/$(basename $fn | sed 's/\(.*\)\.symlink/\1/g' )
        echo link "$ln" "==>" "$fn"
        linkfile "$fn" "$ln"
    done
    echo "Symlinks creating/verification ... ok"
}

# Fix premissions on self, often messed up by the lack of a properly set umaks
# prior to running that script and loading out
function fixselfperms() {
    echo "################"
    echo "fixing permissions ..."
    find "$DOTFILES_DIR" -type f -print0 | xargs -0 chmod 640 || die 1
    find "$DOTFILES_DIR" -type f -name "*.sh" -print0 | xargs -0 chmod 750 || die 1
    find "$DOTFILES_DIR" -type d -print0 | xargs -0 chmod 750 || die 1
    echo "fixing permissions ... success"
}

function forcezpluginstall() {
    echo "################"
    printf "changing shell to zsh ..."
    exec zsh -s <<EOF
echo " success";
echo "installing zplug ...";
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
  echo "################"
  printf "checking distro ..."
  DISTRO=$(lsb_release -d | awk -F '\t' '{print $2}')
  if [ "$(echo "$DISTRO" | grep -c 'Fedora Linux 42')" == "1" ]; then
    echo " ok ($DISTRO)"
  else
    echo " unsupported ($DISTRO)"
    die 1 "error: requires Fedora Linux 42, found $DISTRO"
  fi
}

function createdotssh() {
  echo "################"
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

umask 022
checkdistro
fixselfperms
installpkgs
setuplinks
setupzsh
createdotssh
forcezpluginstall
# DON'T ADD LINES BELOW HERE AS THE FUNCTION ABOVE CREATES A NEW SHELL
[[ "$LOGOUTNEEDED" == "1" ]] && echo "LOGOUT NEEDED BY SOME CHANGES"

