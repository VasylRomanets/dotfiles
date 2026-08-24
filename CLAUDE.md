# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal, macOS-only dotfiles repo — shell scripts and config files, applied to the live system via a small custom package manager (not GNU Stow or a framework). `require_macos` in `setup/_lib.zsh` hard-exits on any non-Darwin `uname`.

The owner intends to try a Linux distro at some undetermined future point, and if that happens, the plan is to extend this single repo (matching how `chezmoi`/`yadm` handle multi-OS) rather than fork a separate one — not to maintain two repos. No Linux work is planned right now, and don't start any unprompted. What this means day to day: most of `packages/*/source` and `packages/*/link` content has no OS dependency and should stay that way where it's free to do so; the genuinely macOS-only chokepoints are `setup/macos.zsh`, the Homebrew `cask`/`mas`/`vscode` sections of `Brewfile`, and the `/Applications/*.app` checks in `sync.zsh`.

## Commands

No build, lint, or test suite exists in this repo — there's nothing to "run tests" for. The relevant commands apply configuration to the actual machine:

```zsh
make bootstrap       # ./setup/bootstrap.zsh — full fresh-machine setup (interactive, prompts before each step)
make sync            # ./setup/sync.zsh — re-symlink/copy after adding or editing package files; the command you run after most changes
make prune-symlinks  # ./setup/prune-symlinks.zsh — remove orphaned symlinks left by renamed/removed package files (not run by sync; occasional manual cleanup)
make macos           # ./setup/macos.zsh — apply macOS `defaults write` settings only
```

`sync.zsh` is idempotent and safe to re-run repeatedly — it processes every package each time (there's no "sync just one package" flag). It requires `toml2json` and `jq` (installed by `bootstrap.zsh`); it exits early with an error if they're missing.

## Architecture

### Package structure

Each `packages/<pkg>/` directory is independent and can contain any of:

- `link/` — files mirrored via symlink into the target (default `~`), preserving relative path structure under `link/`.
- `source/*.zsh` — symlinked into `$ZDOTDIR/source/` (i.e. `~/.config/zsh/source/`) and sourced by `.zshrc`'s loop over that directory. This is how a package hooks into the interactive shell (aliases, `eval "$(tool init zsh)"`, env vars).
- `copy/` — files copied (not symlinked) into `[copy].target`. Only used when symlinking is impossible, e.g. a macOS-sandboxed Mac App Store app that resolves symlinks outside its container.
- `hooks/pre-setup.zsh` / `hooks/post-setup.zsh` — arbitrary setup steps beyond linking/copying (e.g. `yazi`'s `post-setup.zsh` runs `ya pkg install` to resolve plugins). Both run inside `sync.zsh`, only for packages that pass `[requires]`.
- `setup.toml` — optional. Packages without one are always processed. Schema:
  ```toml
  [requires]
  command = "bat"  # gate on `command -v` — package skipped entirely if absent
  app = "Ghostty"  # gate on /Applications/Ghostty.app (or ~/Applications)

  [link]
  target = "~"     # default; rarely overridden

  [copy]
  target = "~/Library/..."
  ```

### `sync.zsh` per-package order

For each `packages/*/`: check `[requires]` (skip package entirely if command/app missing) → run `pre-setup` hook → symlink `link/**` and `source/*.zsh` → copy `copy/**` → run `post-setup` hook. `link` and `source` are independent and a package can have either, both, or neither.

### Local-override pattern for secrets/machine-specific values

Committed config files `include`/reference a sibling `*.local` file that is gitignored (`.gitignore`: `config.local`, `settings.local.json`) and never committed. `bootstrap.zsh` generates these interactively (git identity → `~/.config/git/config.local`, SSH key path → `~/.ssh/config.local`). Follow this pattern for any new secret or per-machine value instead of hardcoding it into a committed file.

### Shell startup chain

`.zshenv` (`packages/zsh/link/.zshenv`) sets XDG_* dirs and `ZDOTDIR`, and is sourced for *every* zsh invocation (interactive, scripts, subshells) — keep it limited to genuinely global env vars. `.zprofile` (`packages/zsh/link/.zprofile`) loads next, for login shells only, and is where `PATH` is set instead of `.zshenv` — macOS's `path_helper` runs between the two, re-prepending system dirs ahead of anything `.zshenv` already exported, so a `PATH` entry only actually ends up in front of the system dirs if it's set in `.zprofile`. `.zshrc` sources the core config files, then `zsh-autosuggestions`/`zsh-syntax-highlighting`, then every `$ZDOTDIR/source/*.zsh` file — which is how each package's own `source/*.zsh` actually gets loaded into a real shell session.

## Conventions

- **Guarding a package that might not be installed**: in `.zsh` files (anything under `source/` or a zsh `hooks/*.zsh`), use zsh's native `(( $+commands[name] ))` — see `packages/fzf/source/fzf-core.zsh` (guards `fd`, `eza`, `bat`, `atuin`, each with a fallback) and `packages/cowsay/source/cowsay.zsh`. In POSIX `.sh` scripts (e.g. Claude Code hook scripts under `packages/claude/link/.config/claude/hooks/`), use `command -v name` instead, since these aren't zsh and must stay portable to whatever shell actually invokes them. Skip guarding tools confirmed to always be present (macOS system binaries, or the package's own binary in its own `source/*.zsh` — that file is only symlinked in if the package itself was set up).
- **Invoking a script from a non-interactive/external-tool context** (a hook `"command"` in JSON config, etc.): use an absolute path (`/bin/sh`, not bare `sh`) and prefer resolving directories through whatever env var already governs them, with a fallback to the tool's real unconfigured default — e.g. `${CLAUDE_CONFIG_DIR:-$HOME/.claude}` rather than hardcoding `~/.config/claude`. Don't rely on `~` inside a shell parameter-expansion default (`${VAR:-~/path}`) — tilde does not expand there; use `$HOME` instead.
- **macOS defaults (`setup/macos.zsh`)**: organized into `# --- Label ---...---` (80-char) section headers by feature area, one `defaults write` (or small group) per comment explaining *why*, not what. Settings that were deliberately considered but left off are kept as commented-out lines rather than deleted, so the option stays visible for later. Preserve this style when adding entries.
- **Comment style**:
  - *Section headers* (`# --- Label ---...---`, used in `setup/Brewfile`, `setup/macos.zsh`, and the zsh package's own files): always plain ASCII dashes — not Unicode box-drawing (`─`), which is reserved for actual visual art (the starship prompt, the fastfetch logo, README's directory tree) — always Title Case, exactly 80 characters wide, and followed directly by content with no blank line after the header. A blank line goes above a header when it isn't the first line of the file (separating it from the previous section); no blank line above it if it opens the file.
  - *Trailing/inline comments* (same line as code, Brewfile-alignment style, e.g. `brew "yazi"  # file manager`): lowercase start, fragment style, no period required — unless the first word is inherently capitalized on its own merits (a proper noun, a product/file name, an env var like `PATH`/`HOME`).
  - *Standalone comments* (their own line(s) above a command, `export`, function, etc.): follow PEP 8's block-comment rule — first word capitalized (same identifier exception as above), a complete sentence, ending in a period, even when it's a single short sentence — PEP 8 makes no brevity exception. A short bare category/step label (e.g. `# Errors`, `# Step 1`) isn't prose and is exempt from the period. A blank line separates a standalone comment (plus the line(s) it explains, as one semantic unit) from unrelated preceding code.
  - *File-top docblocks* (a prose description right after a shebang) are optional, and when present also follow PEP 8 (capitalized, complete sentences, periods).
  - Every file starting with a shebang gets a blank line right after it, before anything else.
