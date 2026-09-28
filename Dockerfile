FROM nvidia/cuda:13.4.1-devel-ubuntu26.04

RUN apt-get update && apt-get install -y \
	git \
	curl \
	stow \
	cmake \
	build-essential \
	zsh \
	&& rm -rf /var/lib/apt/lists/*
	
RUN useradd --uid "10002" \
	    --create-home \
	    --shell /bin/bash \
	    --user-group \
	    pookie 
		   
WORKDIR /home/pookie

# I use brew to install my user packages
RUN useradd --uid "10001" \
	    --create-home \
	    --shell /bin/bash \
	    --user-group \
	    linuxbrew 

# brew needs a non-root user and home/linuxbrew dir to install
USER linuxbrew 
RUN NONINTERACTIVE=1 /bin/bash -c \
	"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# pookie needs to be able to use brew so make him owner
USER root 
RUN chown -R pookie:pookie /home/linuxbrew
USER pookie
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

RUN brew install \
	neovim \
	fzf \
	fd \
	ripgrep \
	tmux \
	pyenv \
	lazygit \
	lua-language-server \
	llvm \
	tree-sitter-cli

# Pi Coding agent
ENV NVM_DIR=/home/pookie/.nvm
RUN curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh \
       | PROFILE=/dev/null bash \
       && . "$HOME/.nvm/nvm.sh" \
       && nvm install 24 \
       && npm install -g --ignore-scripts @earendil-works/pi-coding-agent

# oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
	&& rm -f "$HOME/.zshrc"

# uv (for python dev)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

RUN uv tool install ty@latest \
	&& uv tool install ruff@latest \
	&& uv tool install debugpy@latest

ENV PATH="/home/pookie/.local/bin:$PATH"

# Dotfiles
RUN git clone https://github.com/vossenwout/pookie-dotfiles \
	&& cd pookie-dotfiles \
	&& stow tmux zshrc pi neovim

CMD ["zsh"]
