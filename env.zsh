# Scott's shell configurations - mostly zsh, but probably also regular bash

TIMEFMT=$'\n================\nCPU\t%P\nuser\t%*U\nsystem\t%*S\ntotal\t%*E'

# Add some paths if not already there
bin_dirs=(
    "$HOME/.local/bin"
    "$HOME/bin"
)

for dir in "${bin_dirs[@]}"; do
    # Check if the directory exists and is a directory (optional but recommended)
    if [[ -d "$dir" ]]; then
        # Safely check if the directory is NOT already in the PATH
        if [[ ":$PATH:" != *":$dir:"* ]]; then
            PATH="$dir:$PATH"
        fi
    fi
done

export PATH

# Other configs
PAGER='less'
LESS='-R --no-init'

if [[ $TERM_PROGRAM == 'vscode' ]]; then
  if command -v cursor >/dev/null 2>&1; then
    export EDITOR='cursor -w'
  else
    export EDITOR='code -w'
  fi
else
  export EDITOR=nano
fi

#
# minikube and kubectl and crc completion
#
command -v minikube >/dev/null 2>&1 && source <(minikube completion zsh)
command -v kubectl >/dev/null 2>&1 && source <(kubectl completion zsh)
command -v crc >/dev/null 2>&1 && source <(crc completion zsh)

#
# nvm and nvm completions
#
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

#
# claude code via google vertex api
#
[ -f "$HOME/.config/claude-code-vertex/env.sh" ] && . "$HOME/.config/claude-code-vertex/env.sh"

#
# omp (and others) Google Vertex -- auth happens with gcloud cli
#
export GOOGLE_CLOUD_PROJECT=${ANTHROPIC_VERTEX_PROJECT_ID}
export GOOGLE_CLOUD_LOCATION=${CLOUD_ML_REGION}

#
# bun
#
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
