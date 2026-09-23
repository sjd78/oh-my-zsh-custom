SHELL := /bin/bash
OMZ_DIR ?= $(HOME)/.oh-my-zsh
OMZ_CUSTOM ?= $(OMZ_DIR)/custom
ZSHRC ?= $(HOME)/.zshrc
REPO_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

.PHONY: all help link unlink patch-zshrc status test

all: link patch-zshrc
	@echo "==> omz-custom installation complete!"
	@echo "    Start a new shell or run: exec zsh"

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  all          Link custom repo to OMZ and patch ~/.zshrc (default)"
	@echo "  link         Symlink this repository to \$$ZSH/custom"
	@echo "  unlink       Remove symlink and restore previous custom directory (if backed up)"
	@echo "  patch-zshrc  Idempotently update ~/.zshrc with preferred settings"
	@echo "  status       Display current link status and zsh configuration summary"

link:
	@if [ ! -d "$(OMZ_DIR)" ]; then \
		echo "Error: Oh My Zsh directory '$(OMZ_DIR)' not found."; \
		exit 1; \
	fi
	@if [ -L "$(OMZ_CUSTOM)" ]; then \
		current_target=$$(readlink -f "$(OMZ_CUSTOM)"); \
		if [ "$$current_target" = "$(REPO_DIR)" ]; then \
			echo "==> $(OMZ_CUSTOM) already points to $(REPO_DIR)"; \
		else \
			echo "==> Updating existing symlink $(OMZ_CUSTOM) -> $(REPO_DIR)"; \
			ln -sfn "$(REPO_DIR)" "$(OMZ_CUSTOM)"; \
		fi; \
	elif [ -d "$(OMZ_CUSTOM)" ]; then \
		backup_dir="$(OMZ_CUSTOM).bak.$$(date +%Y%m%d_%H%M%S)"; \
		echo "==> Backing up existing custom directory to $$backup_dir"; \
		mv "$(OMZ_CUSTOM)" "$$backup_dir"; \
		echo "==> Creating symlink $(OMZ_CUSTOM) -> $(REPO_DIR)"; \
		ln -sfn "$(REPO_DIR)" "$(OMZ_CUSTOM)"; \
	else \
		echo "==> Creating symlink $(OMZ_CUSTOM) -> $(REPO_DIR)"; \
		ln -sfn "$(REPO_DIR)" "$(OMZ_CUSTOM)"; \
	fi

unlink:
	@if [ -L "$(OMZ_CUSTOM)" ]; then \
		echo "==> Removing symlink $(OMZ_CUSTOM)"; \
		rm "$(OMZ_CUSTOM)"; \
		latest_bak=$$(ls -td "$(OMZ_CUSTOM)".bak.* 2>/dev/null | head -n 1); \
		if [ -n "$$latest_bak" ] && [ -d "$$latest_bak" ]; then \
			echo "==> Restoring $$latest_bak to $(OMZ_CUSTOM)"; \
			mv "$$latest_bak" "$(OMZ_CUSTOM)"; \
		fi; \
	else \
		echo "==> $(OMZ_CUSTOM) is not a symlink. Nothing to unlink."; \
	fi

patch-zshrc:
	@echo "==> Patching $(ZSHRC)..."
	@python3 "$(REPO_DIR)/scripts/patch_zshrc.py" "$(ZSHRC)"

status:
	@echo "=== OMZ Custom Status ==="
	@echo "Repo directory : $(REPO_DIR)"
	@echo "OMZ directory  : $(OMZ_DIR)"
	@if [ -L "$(OMZ_CUSTOM)" ]; then \
		echo "Custom symlink : $(OMZ_CUSTOM) -> $$(readlink -f "$(OMZ_CUSTOM)")"; \
	elif [ -d "$(OMZ_CUSTOM)" ]; then \
		echo "Custom symlink : NOT LINKED ($(OMZ_CUSTOM) is a real directory)"; \
	else \
		echo "Custom symlink : NOT FOUND"; \
	fi
	@echo ""
	@echo "=== Active .zshrc Highlights ==="
	@grep -E '^(ZSH_THEME|plugins=)' "$(ZSHRC)" 2>/dev/null || echo "No settings found in $(ZSHRC)"
