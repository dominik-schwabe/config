FROM archlinux

ENV CONTAINERIZED=true
RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm base-devel
RUN pacman -S --noconfirm neovim git curl unzip wget zip zsh python base base-devel ripgrep fzf fd jq nodejs npm
WORKDIR /root
RUN git clone https://github.com/dominik-schwabe/config
RUN ./config/setup.sh
RUN zsh -i -c "install_completion"
COPY .customrc $HOME
