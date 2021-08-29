# Dotfiles

My dotfiles setup.

THIS IS ONLY FOR PERSONAL USE ON MY DEVELOPMENT ENVIRONMENTS. NOT TESTED
BESIDE MY OWN ENVS. ONLY SUPPORTS UBUNTU 20 BOTH ON NATIVE
LINUX AND WSL. USE AT YOUR OWN RISKS. YOU'VE BEEN WARNED.

If you're looking for a base dotfiles repo you should have a look at the
excelents [holman](https://github.com/holman/dotfiles/) or
[thoughtbot](https://github.com/thoughtbot/dotfiles) repos instead.


## How To Use It?

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/legdba/.dotfiles/master/install.sh)"
```

It will:

1. Clone the repo into `$HOME/.dotfiles` and call ` ~/.dotfiles/bootstrap.sh`
1. Install all common dev tools I need (curl, make, python, etc.) plus Docker.
1. Change default shell to zsh
1. Link all dotfiles from $HOME (any existing file will be silently renamed)
   for `.zshrc`, `.zshenv`, neovim, etc.
1. Set sane GIT default (i.e. for any newly cloned/created repo to be set with
   explicit local user.name and user.email in order to avoid multi-account
   mistakes when using global default...)
1. Handle WSL special cases:
  1. `/mnt/c` is re-mounted to `/c` for Docker mount to work
  2. set Docker client to connect to the Deamon with TCP instead of sockets;
     [until Docker for Win supports AF_UNIX](https://github.com/docker/for-win/issues/1954)
1. Change the current shell to ZSH, install Zplug stuff
1. Returns on a configured ZSH prompt, ready to go. (note that the 1st install
   on WSL will require a logout for the C: mount change to take effect)

To re-run simply do

```shell
~/.dotfiles/bootstrap.sh
```

The `boostrap.sh` script is idempotent: it can be re-run at anytime to reset the
system.


## TODO

* Maybe migrate to GNU stow for simlinks management


## Key Mapping

TMUX

| Keys                 | Action                                               |
|----------------------|------------------------------------------------------|
| Ctrl-h/j/k/l         | Move to plane/split in tmux/vi                       |
| Ctrl-b Ctrl-h/j/k/l  | Resize planes in tmux                                |
| Ctrl-b [             | Edit mode                                            |


## Fonts

Best fonts:

1. _DejaVu Sans Mono_: nice font with wiiide support for utf8 chars often used
   as shell promp markers. It has a dotted zero instead of a slashed one.
2. _Consolas_: very nice commercial font installed with MS Win and Office; lacks
   wide utf8 support (if it had it woul dbe better than DejaVu).
3. _Incolsolata_: very nice free font, good both on screen and paper, but as for
   Consolas it does not have a wide utf8 support.


## Extended glyphs

DejaVu has a whide utf8 support for most glyphs shell prompts and CLI uses.
Consolas and Incolsolata don't however and could typically require substitution
characters to be defined into the console SW.


## Terminal Integration

* _Cmder_: set the _Solarized (Luke Maciak)_ theme.


## License

This software is under Apache 2.0 license.
```
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
```

