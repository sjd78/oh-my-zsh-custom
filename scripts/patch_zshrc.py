#!/usr/bin/env python3
"""
patch_zshrc.py: Idempotently patch ~/.zshrc with preferred Oh My Zsh settings.
- Removes legacy source lines (~/.zsh-scott-rc, ~/.zsh-scott-prompt)
- Ensures plugins=(git git-prompt)
- Ensures ZSH_THEME="agnoster"
- Ensures COMPLETION_WAITING_DOTS="true"
"""

import sys
import re
import shutil
from datetime import datetime
from pathlib import Path

def patch_zshrc(zshrc_path: Path) -> bool:
    if not zshrc_path.exists():
        print(f"Error: {zshrc_path} does not exist.", file=sys.stderr)
        return False

    content = zshrc_path.read_text(encoding="utf-8")
    lines = content.splitlines()

    new_lines = []
    # 1. Remove legacy source lines
    for line in lines:
        stripped = line.strip()
        if stripped in ("source ~/.zsh-scott-rc", ". ~/.zsh-scott-rc"):
            continue
        if stripped in ("source ~/.zsh-scott-prompt", ". ~/.zsh-scott-prompt"):
            continue
        new_lines.append(line)

    text = "\n".join(new_lines)

    # 2. Ensure ZSH_THEME="agnoster"
    # Replace any ZSH_THEME=... line that is uncommented, or update it
    theme_pattern = re.compile(r'^(#\s*)?ZSH_THEME=.*$', re.MULTILINE)
    # Check if ZSH_THEME="agnoster" already present uncommented
    if not re.search(r'^ZSH_THEME=["\']agnoster["\']', text, re.MULTILINE):
        # Find first ZSH_THEME line and replace it
        m = theme_pattern.search(text)
        if m:
            text = text[:m.start()] + 'ZSH_THEME="agnoster"' + text[m.end():]
        else:
            # prepend or append before source oh-my-zsh
            text = 'ZSH_THEME="agnoster"\n' + text

    # 3. Ensure COMPLETION_WAITING_DOTS="true"
    if not re.search(r'^COMPLETION_WAITING_DOTS=["\']true["\']', text, re.MULTILINE):
        cwd_pat = re.compile(r'^(#\s*)?COMPLETION_WAITING_DOTS=.*$', re.MULTILINE)
        m = cwd_pat.search(text)
        if m:
            text = text[:m.start()] + 'COMPLETION_WAITING_DOTS="true"' + text[m.end():]
        else:
            text = 'COMPLETION_WAITING_DOTS="true"\n' + text

    # 4. Ensure plugins=(git git-prompt)
    # Check for existing plugins=(...)
    plugins_pattern = re.compile(r'^(#\s*)?plugins=\s*\(([^)]*)\)', re.MULTILINE | re.DOTALL)
    m = plugins_pattern.search(text)
    desired_plugins_line = "plugins=(\n  git\n  git-prompt\n)"
    if m:
        # replace the whole plugins block
        text = text[:m.start()] + desired_plugins_line + text[m.end():]
    else:
        # insert before source $ZSH/oh-my-zsh.sh
        omz_source = re.compile(r'^(source\s+["\']?\$ZSH/oh-my-zsh\.sh["\']?)', re.MULTILINE)
        m = omz_source.search(text)
        if m:
            text = text[:m.start()] + desired_plugins_line + "\n\n" + text[m.start():]
        else:
            text += "\n" + desired_plugins_line + "\n"

    # Normalize trailing newline
    if not text.endswith("\n"):
        text += "\n"

    if text == content:
        print(f"{zshrc_path} is already up to date.")
        return True

    # Backup before writing
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = zshrc_path.with_name(f"{zshrc_path.name}.bak.{ts}")
    shutil.copy2(zshrc_path, backup_path)
    print(f"Backed up {zshrc_path} -> {backup_path}")

    zshrc_path.write_text(text, encoding="utf-8")
    print(f"Successfully patched {zshrc_path}")
    return True

if __name__ == "__main__":
    target = Path.home() / ".zshrc"
    if len(sys.argv) > 1:
        target = Path(sys.argv[1]).expanduser().resolve()
    success = patch_zshrc(target)
    sys.exit(0 if success else 1)
