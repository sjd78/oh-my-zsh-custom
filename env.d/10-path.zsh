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
