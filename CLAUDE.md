# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles for macOS (zsh, Emacs, tmux). Files here are meant to be symlinked or copied to `$HOME`.

## Deployment

No build system. To apply changes, symlink or copy individual files to `$HOME`:

```sh
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.zshenv ~/.zshenv
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf
# etc.
```

For Emacs, reload config inside Emacs with `M-x load-file RET ~/.emacs.d/init.el`.
For tmux, reload with `prefix + C-r` (bound in `.tmux.conf`).

## Architecture

### Shell (zsh)

- `.zshenv` — PATH setup only; evaluated for all shell types. Uses `(N-/)` glob qualifier to safely skip non-existent paths.
- `.zshrc` — Interactive shell config: zinit plugin manager, peco-based interactive selectors, aliases, tool integrations (nvm, Deno, pnpm, Docker, kubectl, starship).

Key keybindings defined in `.zshrc`:
- `C-]` — `peco-src`: fuzzy navigate to ghq-managed repos
- `C-x f` — `peco-directories`: insert a directory path at cursor
- `C-x C-f` — `peco-files`: insert a file path at cursor

### Emacs (`.emacs.d/`)

- Package manager: **el-get** (as a git submodule in `.emacs.d/el-get`)
- `init.el` — Bootstraps el-get, installs packages, sets `el-get-user-package-directory` to `inits/`
- `inits/` — Per-package init files loaded by **init-loader**; named `NN_topic.el` or `init-pkgname.el`
- Versioned package dirs: el-get and ELPA packages are stored under `.emacs.d/<emacs-version>/` (e.g., `29.4/`, `30.1/`) so multiple Emacs versions coexist without conflict

Installed packages: auto-complete, migemo (Japanese search), magit, ddskk (Japanese input), mew (email), go-mode, php-mode, cperl-mode, ruby-mode, yaml-mode, flycheck, editorconfig, markdown-mode.

### tmux (`.tmux.conf`)

- Prefix key: `C-z` (replaces default `C-b`)
- Claude Code-specific settings: `history-limit 50000`, `mouse on`, `escape-time 10`, `focus-events on`, `default-terminal screen-256color` with RGB overrides

### Homebrew (`.Brewfile`)

Used with `brew bundle --file=~/.Brewfile` to restore packages. Key tools: emacs, gh, ghq, peco, ripgrep, starship, tmux, cmigemo, HackGen Nerd fonts.

## Key Tools

| Tool | Purpose |
|------|---------|
| zinit | Zsh plugin manager |
| peco | Interactive filtering (fuzzy select) |
| ghq | Repository manager (used with peco) |
| starship | Shell prompt (falls back to pure if unavailable) |
| el-get | Emacs package manager |
