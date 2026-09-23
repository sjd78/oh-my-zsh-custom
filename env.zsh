#
# Modular environment loader: sources all scripts in env.d/ in lexical order
#
ENV_D_DIR="${0:A:h}/env.d"

if [[ -d "$ENV_D_DIR" ]]; then
  for env_file in "$ENV_D_DIR"/*.zsh(N); do
    [[ -r "$env_file" ]] && source "$env_file"
  done
  unset env_file
fi

unset ENV_D_DIR
