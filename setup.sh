#!/usr/bin/env bash
#
# setup.sh: Standalone manager for Scott's Oh My Zsh customizations.
# Works with or without 'make' installed.
#

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OMZ_DIR="${OMZ_DIR:-$HOME/.oh-my-zsh}"
OMZ_CUSTOM="${OMZ_CUSTOM:-$OMZ_DIR/custom}"
ZSHRC="${ZSHRC:-$HOME/.zshrc}"

cmd_help() {
  cat <<EOF
Usage: ./setup.sh [command]

Commands:
  all          Link custom repo to OMZ and patch ~/.zshrc (default)
  link         Symlink this repository to \$ZSH/custom
  unlink       Remove symlink and restore previous custom directory (if backed up)
  patch-zshrc  Idempotently update ~/.zshrc with preferred settings
  status       Display current link status and zsh configuration summary
  help         Show this message
EOF
}

cmd_link() {
  if [ ! -d "$OMZ_DIR" ]; then
    echo "Error: Oh My Zsh directory '$OMZ_DIR' not found." >&2
    exit 1
  fi

  if [ -L "$OMZ_CUSTOM" ]; then
    local current_target
    current_target="$(readlink -f "$OMZ_CUSTOM")"
    if [ "$current_target" = "$REPO_DIR" ]; then
      echo "==> $OMZ_CUSTOM already points to $REPO_DIR"
      return 0
    else
      echo "==> Updating existing symlink $OMZ_CUSTOM -> $REPO_DIR"
      ln -sfn "$REPO_DIR" "$OMZ_CUSTOM"
    fi
  elif [ -d "$OMZ_CUSTOM" ]; then
    local backup_dir="${OMZ_CUSTOM}.bak.$(date +%Y%m%d_%H%M%S)"
    echo "==> Backing up existing custom directory to $backup_dir"
    mv "$OMZ_CUSTOM" "$backup_dir"
    echo "==> Creating symlink $OMZ_CUSTOM -> $REPO_DIR"
    ln -sfn "$REPO_DIR" "$OMZ_CUSTOM"
  else
    echo "==> Creating symlink $OMZ_CUSTOM -> $REPO_DIR"
    ln -sfn "$REPO_DIR" "$OMZ_CUSTOM"
  fi
  echo "==> Successfully linked $OMZ_CUSTOM -> $REPO_DIR"
}

cmd_unlink() {
  if [ -L "$OMZ_CUSTOM" ]; then
    echo "==> Removing symlink $OMZ_CUSTOM"
    rm "$OMZ_CUSTOM"
    local latest_bak
    latest_bak="$(ls -td "${OMZ_CUSTOM}".bak.* 2>/dev/null | head -n 1 || true)"
    if [ -n "$latest_bak" ] && [ -d "$latest_bak" ]; then
      echo "==> Restoring $latest_bak to $OMZ_CUSTOM"
      mv "$latest_bak" "$OMZ_CUSTOM"
    fi
    echo "==> Unlink complete."
  else
    echo "==> $OMZ_CUSTOM is not a symlink. Nothing to unlink."
  fi
}

cmd_patch_zshrc() {
  echo "==> Patching $ZSHRC..."
  python3 "$REPO_DIR/scripts/patch_zshrc.py" "$ZSHRC"
}

cmd_status() {
  echo "=== OMZ Custom Status ==="
  echo "Repo directory : $REPO_DIR"
  echo "OMZ directory  : $OMZ_DIR"
  if [ -L "$OMZ_CUSTOM" ]; then
    echo "Custom symlink : $OMZ_CUSTOM -> $(readlink -f "$OMZ_CUSTOM")"
  elif [ -d "$OMZ_CUSTOM" ]; then
    echo "Custom symlink : NOT LINKED ($OMZ_CUSTOM is a real directory)"
  else
    echo "Custom symlink : NOT FOUND"
  fi
  echo ""
  echo "=== Active .zshrc Highlights ==="
  grep -E '^(ZSH_THEME|plugins=)' "$ZSHRC" 2>/dev/null || echo "No settings found in $ZSHRC"
}

cmd_all() {
  cmd_link
  cmd_patch_zshrc
  echo ""
  echo "==> omz-custom installation complete!"
  echo "    Start a new shell or run: exec zsh"
}

action="${1:-all}"
case "$action" in
  all) cmd_all ;;
  link) cmd_link ;;
  unlink) cmd_unlink ;;
  patch-zshrc) cmd_patch_zshrc ;;
  status) cmd_status ;;
  help|-h|--help) cmd_help ;;
  *)
    echo "Unknown command: $action" >&2
    cmd_help
    exit 1
    ;;
esac
