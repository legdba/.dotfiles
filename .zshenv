# enable en_US locale w/ UTF-8 encodings if not already configured
export LANG=en_US.UTF-8
export LANGUAGE=en
export LC_ALL="${LANG}"

# Add ~/.bin to PATH
if [ -d "$HOME/bin" ] ; then
  PATH="$PATH:$HOME/.bin"
fi

# Need to detect WSL as some stuff is missing (no systemd, no dockerd, etc.)
ONWSL="$(grep -c Microsoft /proc/sys/kernel/osrelease)"
if [[ "$ONWSL" == "1" ]] ; then
  # https://github.com/Microsoft/WSL/issues/1887
  unsetopt BG_NICE
fi
