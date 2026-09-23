# Makefile: delegates to setup.sh for systems with make installed
SHELL := /bin/bash

.PHONY: all help link unlink patch-zshrc status

all:
	@./setup.sh all

help:
	@./setup.sh help

link:
	@./setup.sh link

unlink:
	@./setup.sh unlink

patch-zshrc:
	@./setup.sh patch-zshrc

status:
	@./setup.sh status
