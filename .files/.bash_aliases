# ruby
if [ -d "$HOME/.rbenv" ]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
fi

# python
export PYENV_ROOT="$HOME/.pyenv"
if [ -d "$PYENV_ROOT" ]; then
    export PATH="${PYENV_ROOT}/bin:$PATH"
    export PATH="$HOME/.local/bin:$PATH"
    eval "$(pyenv init -)"
fi

# nim
if [ -d "$HOME/.nimble" ]; then
    export PATH="$HOME/.nimble/bin:$PATH"
fi

# go
if [ -d "$HOME/.goenv" ]; then
    export PATH="$HOME/.goenv/shims:$PATH"
    eval "$(goenv init -)"
fi
export GO111MODULE=on

# rust
if [ -d "$HOME/.cargo" ]; then
    source "$HOME/.cargo/env"
fi

export PATH="/usr/src/docker/bin:$PATH"
