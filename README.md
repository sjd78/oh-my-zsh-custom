# Scott's Oh My Zsh Customizations

Portable, version-controlled customizations for [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh).

Conforms to the official [Oh My Zsh Customization Guide](https://github.com/ohmyzsh/ohmyzsh/wiki/Customization) by organizing themes, aliases, and environment configurations to be symlinked directly to `$ZSH_CUSTOM` (`~/.oh-my-zsh/custom`).

---

## What's Included

- **`themes/agnoster.zsh-theme`**: Custom Powerline-style agnoster theme that removes `prompt_git` from the left-hand prompt. Git status is displayed cleanly on the right via Oh My Zsh's built-in `git-prompt` plugin (`RPROMPT`).
- **`aliases.zsh`**: Personal shell aliases (e.g. `gf`, `gf-tags`).
- **`env.zsh`**: Shell environment settings, dynamic `$PATH` setup (`~/.local/bin`, `~/bin`), tool completions (`minikube`, `kubectl`, `crc`), `nvm`, Claude Vertex/GCP, and `bun`.
- **`Makefile`**: Simple management commands for installation, symlinking, and `.zshrc` patching.

---

## Quick Setup (This Machine)

From inside this repository:

```bash
make all
```

This will:
1. Safely back up existing `~/.oh-my-zsh/custom` and symlink `~/.oh-my-zsh/custom -> ~/.omz-custom`.
2. Back up `~/.zshrc` and patch it to enable `plugins=(git git-prompt)`, set `ZSH_THEME="agnoster"`, and remove legacy loose `source` commands.

Restart your shell or run:
```bash
exec zsh
```

---

## Portability (Setup on a New Machine)

To bring your shell configurations to any new workstation:

```bash
# 1. Install Oh My Zsh (if not already present)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 2. Clone your customizations repository
git clone <your-repo-url> ~/.omz-custom

# 3. Install and patch
cd ~/.omz-custom
make all

# 4. Reload shell
exec zsh
```

---

## Makefile Targets

| Target | Description |
| :--- | :--- |
| `make all` | Symlink repository to `~/.oh-my-zsh/custom` and patch `~/.zshrc` (default). |
| `make link` | Symlink repository to `~/.oh-my-zsh/custom` with automatic directory backup. |
| `make patch-zshrc` | Safely and idempotently patch `~/.zshrc` with required OMZ settings. |
| `make status` | Display current symlink target and active zshrc theme/plugin settings. |
| `make unlink` | Remove symlink and restore previous custom directory (if backed up). |
