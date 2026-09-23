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
