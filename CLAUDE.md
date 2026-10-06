# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal, macOS-only dotfiles repo — shell scripts and config files, applied to the live system via a small custom package manager (not GNU Stow or a framework). `require_macos` in `setup/_lib.zsh` hard-exits on any non-Darwin `uname`.

The owner intends to try a Linux distro at some undetermined future point, and if that happens, the plan is to extend this single repo (matching how `chezmoi`/`yadm` handle multi-OS) rather than fork a separate one — not to maintain two repos. No Linux work is planned right now, and don't start any unprompted. What this means day to day: most of `packages/*/source` and `packages/*/link` content has no OS dependency and should stay that way where it's free to do so; the genuinely macOS-only chokepoints are `setup/macos.zsh`, the Homebrew `cask`/`mas`/`vscode` sections of `Brewfile`, and the `/Applications/*.app` checks in `sync.zsh`.

## Commands

No build, lint, or test suite exists in this repo — there's nothing to "run tests" for. The relevant commands apply configuration to the actual machine:

```zsh
dots bootstrap          # ./setup/bootstrap.zsh — full fresh-machine setup (interactive, prompts before each step)
dots sync [package...]  # ./setup/sync.zsh — re-symlink/copy after adding or editing package files; the command you run after most changes. Names limit it to those packages
dots prune-symlinks     # ./setup/prune-symlinks.zsh — remove orphaned symlinks left by renamed/removed package files (not run by sync; occasional manual cleanup)
dots setup-macos        # ./setup/macos.zsh — apply macOS `defaults write` settings only (bootstrap runs it too)
dots build-themes       # ./setup/build-themes.zsh — regenerate every per-theme file from the schemes (needs only `python3`; see Theming)
```

`dots` (`packages/bin/link/.local/bin/dots`) runs these scripts from any directory. It finds the repo through `$DOTFILES`, which `.zshenv` derives from its own symlink into the repo, and passes extra arguments on (`dots sync -v`). On a fresh machine `dots` doesn't exist until the first sync, so the first run is `./setup/bootstrap.zsh`.

`sync.zsh` prints one section per package and hides a hook's output unless it fails; run `dots sync -v` to see it. `dots sync atuin bat` syncs only those (named packages ignore the config file below). An optional per-machine `~/.config/dots/sync.toml` (not in the repo) can hold `allow = ["atuin", "bat"]` (sync only these) and `deny = ["ghostty"]` (never sync these; deny wins over allow); a name that isn't a package is reported as a warning. It is idempotent and safe to re-run repeatedly — it processes every package each time (there's no "sync just one package" flag). It requires `toml2json` and `jq` (installed by `bootstrap.zsh`); it exits early with an error if they're missing.

## Architecture

### Package structure

Each `packages/<pkg>/` directory is independent and can contain any of:

- `link/` — files mirrored via symlink into the target (default `~`), preserving relative path structure under `link/`.
- `source/*.zsh` — symlinked into `$ZDOTDIR/source/` (i.e. `~/.config/zsh/source/`) and sourced by `.zshrc`'s loop over that directory. This is how a package hooks into the interactive shell (aliases, `eval "$(tool init zsh)"`, env vars).
- `copy/` — files copied (not symlinked) into `[copy].target`. Only used when symlinking is impossible, e.g. a macOS-sandboxed Mac App Store app that resolves symlinks outside its container.
- `hooks/pre-setup.zsh` / `hooks/post-setup.zsh` — arbitrary setup steps beyond linking/copying (e.g. `yazi`'s `post-setup.zsh` runs `ya pkg install` to resolve plugins). Both run inside `sync.zsh`, only for packages that pass `[requires]`.
- `hooks/theme-changed.zsh` — the package's reaction to `theme`; `sync.zsh` symlinks it to `~/.local/share/theme/hooks.d/<pkg>.zsh` (see Theming).
- `templates/` — inputs to `dots build-themes` (see Theming): the Mustache templates and their `config.toml`; `sync.zsh` ignores it.
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

### Theming

`theme` (`packages/theme/link/.local/bin/theme`) picks a theme slug, writes it to `~/.local/state/theme/current-theme.txt`, and runs every `~/.local/share/theme/hooks.d/*.zsh` with the slug — in parallel, so hooks must not depend on each other, and under a lock (`~/.local/state/theme/lock`) so an overlapping run stops with an error instead of waiting. Each theme-aware package reacts through its own `hooks/theme-changed.zsh` — `theme` doesn't know the packages exist. The hooks point each tool at the new theme without relying on shell reactivity: `current` symlinks (bat's `current.tmTheme`, micro's `current.micro`, cava's `themes/current`, which also gets a `SIGUSR1` so a running cava reloads its config; `SIGUSR2` would leave the old background), small generated files under `~/.local/state/theme/generated/` (fzf options, delta's `[delta]` block, vivid's `LS_COLORS`), or a rewritten `theme.toml` plus `ya emit-to 0 app:theme` (yazi). The themes `theme` offers are the `colors/<slug>.env` files `dots build-themes` exports. `theme light`, `theme dark` and `theme toggle` jump to the current theme's counterpart, as listed by hand in `packages/theme/link/.local/share/theme/pairs.txt` (one pair of slugs per line; themes without a line have no counterpart).

**Source of truth.** One scheme per theme: `packages/theme/schemes/<slug>.toml`, a small subset of TOML (`[section]` headers and `key = "string"` lines). It has `name`, `variant` (`dark` or `light`) and `url` (the theme's homepage, required) on top, then three sections of `#rrggbb` colors: `[ansi]` (the terminal's 16 colors: `black`, `red` … `white`, then the same eight as `bright-*`, in ANSI order), `[ui]` (background, foreground, accent, selection, cursor, border, gutter, chrome and status colors) and `[syntax]` (105 keys named like TextMate scopes, each listed explicitly with no inheritance). Everything else per theme is *generated* by `dots build-themes` (`setup/build-themes.zsh`, which runs `packages/theme/tools/render-themes.py` for every package that has `templates/config.toml`) and committed — don't edit those files by hand, edit the scheme or the template and rebuild. Generated: bat `.tmTheme` (in `themes/<slug>-generated.tmTheme`, unless a theme has its own, see below; also copied into each generated yazi flavor as `tmtheme.xml`), micro colorscheme, cava gradient, vivid theme, fzf options, yazi `flavor.toml` (in `flavors/<slug>-generated.yazi`), and `colors/<slug>.env` (values the hooks and `theme-preview` read, including `ANSI_0` to `ANSI_15`).

**Templates.** `templates/config.toml` has one section per template file (`[tmtheme]` renders `tmtheme.mustache`) with an `output` path relative to the package, where `{{slug}}` is the scheme's file name. A template is plain text with `{{section.key}}` placeholders (`{{ui.accent}}`, `{{ansi.bright-red}}`, `{{syntax.constant.numeric}}`, `{{name}}`, `{{variant}}`); `{{ui.accent|nohash}}` drops the `#`. There are no sections or loops. A placeholder with no value, or a color that isn't `#rrggbb`, stops the build with the file and line.

**What a scheme can't express** is handled outside it, in templates and hooks: delta's added/removed tints are blended in `packages/git/hooks/theme-changed.zsh`, file-type colors are chosen in the vivid template, and bold/italic/underline are fixed in the bat template.

**Hand-written bat themes.** A `.tmTheme` names any scope, while a scheme has only 105 syntax keys, so a theme with an upstream `.tmTheme` can use it directly: put it in `packages/bat/link/.config/bat/themes/<slug>.tmTheme`. Generated themes are named `<slug>-generated.tmTheme`, so the two sit side by side and the build never touches a hand-written one. The bat hook, the delta hook and `theme-preview` use `<slug>` when that file exists, else `<slug>-generated`, and yazi's previews get the same file as `tmtheme.xml`. `dots build-themes` deletes a generated theme that a hand-written one shadows. Today the hand-written ones are Catppuccin, Tokyo Night, Nord, Noctis, the Nightfox family and Coppernight. The scheme still carries its own approximate syntax colors, which micro uses. To hand a theme back to its scheme, delete its hand-written file.

**Hand-written yazi flavors.** Generated flavors live in `flavors/<slug>-generated.yazi`, so a flavor written by a theme's author can sit next to them as `flavors/<slug>.yazi` and the build never touches it. The yazi hook uses `<slug>.yazi` when it has a `flavor.toml`, else the generated one, and `dots build-themes` deletes a generated flavor that a hand-written one shadows. To hand a theme back to its scheme, delete its hand-written directory; to take one over, add the directory.

**Adding a theme:** write `packages/theme/schemes/<slug>.toml` (copy a similar one, or `packages/theme/tools/tmtheme-to-scheme.py <slug> <file.tmTheme> <ghostty-theme-file>` to extract one; its output is the whole scheme), add `packages/bat/link/.config/bat/themes/<slug>.tmTheme` if it has an upstream one, run `dots build-themes`, `dots sync` and `bat cache --build`. Ghostty is separate: a built-in theme named like the title-cased slug works as is (Nightfox, Rose Pine Moon, ...); otherwise add `packages/ghostty/link/.config/ghostty/themes/<slug>.ghostty` — a local file named after the slug is picked up by the hook automatically (and wins over a built-in of the same name). A built-in whose name isn't the title-cased slug (TokyoNight) needs a line in `packages/ghostty/hooks/theme-changed.zsh`.

### Local-override pattern for secrets/machine-specific values

Committed config files `include`/reference a sibling `*.local` file that is gitignored (`.gitignore`: `config.local`, `settings.local.json`) and never committed. `bootstrap.zsh` generates these interactively (git identity → `~/.config/git/config.local`, SSH key path → `~/.ssh/config.local`). Follow this pattern for any new secret or per-machine value instead of hardcoding it into a committed file.

### Shell startup chain

`.zshenv` (`packages/zsh/link/.zshenv`) sets `DOTFILES`, XDG_* dirs and `ZDOTDIR`, and is sourced for *every* zsh invocation (interactive, scripts, subshells) — keep it limited to genuinely global env vars. `.zprofile` (`packages/zsh/link/.zprofile`) loads next, for login shells only, and is where `PATH` is set instead of `.zshenv` — macOS's `path_helper` runs between the two, re-prepending system dirs ahead of anything `.zshenv` already exported, so a `PATH` entry only actually ends up in front of the system dirs if it's set in `.zprofile`. `.zshrc` sources the core config files, then `zsh-autosuggestions`/`zsh-syntax-highlighting`, then every `$ZDOTDIR/source/*.zsh` file — which is how each package's own `source/*.zsh` actually gets loaded into a real shell session.

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
