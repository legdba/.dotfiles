# enable en_US locale w/ UTF-8 encodings if not already configured
export LANG=en_US.UTF-8
export LANGUAGE=en
export LC_ALL="${LANG}"

# Add ~/.bin to PATH
HOMEBIN=$HOME/.bin
if [ -d "$HOMEBIN" ] ; then
  PATH="$PATH:$HOMEBIN"
fi

# Add ~/.local/bin to PATH, in front of PATH, for pipenv to work
HOMELOCALBIN=$HOME/.local/bin
if [ -d "$HOMELOCALBIN" ] ; then
  PATH="$HOMELOCALBIN:$PATH"
fi

# Need to detect WSL as some stuff is missing (no systemd, no dockerd, etc.)
ONWSL="$(grep -c Microsoft /proc/sys/kernel/osrelease)"
if [[ "$ONWSL" == "1" ]] ; then
  # https://github.com/Microsoft/WSL/issues/1887
  unsetopt BG_NICE
fi
