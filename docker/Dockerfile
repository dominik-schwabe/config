FROM archlinux

ENV CONTAINERIZED=true
ENV TERM=xterm-256color
WORKDIR /root
RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm base-devel
RUN pacman -S --noconfirm neovim git curl unzip wget zip zsh base base-devel \
                          ripgrep fzf fd jq nodejs npm python python-pip cuda
RUN chsh --shell /bin/zsh
RUN git clone https://github.com/dominik-schwabe/config
RUN ./config/setup.sh
COPY setup_nvim.py .
RUN zsh -i -c "install_completion"
RUN ./setup_nvim.py
RUN pip install transformers[torch] numpy pandas ipython ipdb pynvim sentencepiece protobuf==3.20

CMD zsh
