# General terminal and shell formatting
TIMEFMT=$'\n================\nCPU\t%P\nuser\t%*U\nsystem\t%*S\ntotal\t%*E'
PAGER='less'
LESS='-R --no-init'

# User binaries in PATH
bin_dirs=(
  "$HOME/.local/bin"
  "$HOME/bin"
)

for dir in "${bin_dirs[@]}"; do
  if [[ -d "$dir" ]]; then
    if [[ ":$PATH:" != *":$dir:"* ]]; then
      PATH="$dir:$PATH"
    fi
  fi
done

export PATH

# Preferred editor based on environment
if [[ $TERM_PROGRAM == 'vscode' ]]; then
  if command -v cursor >/dev/null 2>&1; then
    export EDITOR='cursor -w'
  else
    export EDITOR='code -w'
  fi
else
  export EDITOR=nano
fi

# Shell completions for developer tools
command -v minikube >/dev/null 2>&1 && source <(minikube completion zsh)
command -v kubectl >/dev/null 2>&1 && source <(kubectl completion zsh)
command -v crc >/dev/null 2>&1 && source <(crc completion zsh)

# Node Version Manager (NVM)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# Claude Code and Google Cloud / Vertex AI
[ -f "$HOME/.config/claude-code-vertex/env.sh" ] && . "$HOME/.config/claude-code-vertex/env.sh"

export GOOGLE_CLOUD_PROJECT=${ANTHROPIC_VERTEX_PROJECT_ID}
export GOOGLE_CLOUD_LOCATION=${CLOUD_ML_REGION}

# Bun JavaScript runtime
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

#
# Modular environment loader: sources all scripts in env.d/ in lexical order
#
load_env_d() {
  local env_d_dir="${1:-${${(%):-%x}:A:h}/env.d}"
  local env_file
  if [[ -d "$env_d_dir" ]]; then
    for env_file in "$env_d_dir"/*.zsh(N); do
      [[ -r "$env_file" ]] && source "$env_file"
    done
  fi
}

load_env_d
