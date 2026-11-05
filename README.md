# dotfiles

My personal macOS dotfiles crafted with love.

<p align="center">
  <img src=".github/assets/rice-terminal.png" width="100%" alt="Riced Terminal Workspace">
</p>

## Structure

```
dotfiles/
├── install.sh             # one-step installer: clones the repo and runs setup/bootstrap.zsh
├── packages/
│   └── <pkg>/
│       ├── link/          # files to symlink (mirrored structure, optional)
│       ├── source/        # <pkg>.zsh sourced from ~/.config/zsh/source/ (optional)
│       ├── copy/          # files to copy (optional)
│       ├── hooks/         # pre-setup.zsh / post-setup.zsh run by sync.zsh, theme-changed.zsh run by theme (optional)
│       ├── templates/     # Mustache templates dots build-themes renders per scheme (optional)
│       └── setup.toml     # install conditions and copy/link target (optional)
└── setup/
    ├── _lib.zsh           # shared utilities (colors, logging)
    ├── Brewfile           # Homebrew formulae, casks, cargo crates, mas apps, and vscode extensions
    ├── bootstrap.zsh      # full machine setup
    ├── sync.zsh           # symlinks package files and copies assets
    ├── pull.zsh           # fast-forwards the repo from its remote, optionally syncing after
    ├── build-themes.zsh   # renders every theme's per-tool files from packages/theme/schemes
    ├── prune-symlinks.zsh # removes orphaned symlinks left by renamed/removed package files
    └── macos.zsh          # sensible macOS defaults
```

## New Machine Setup

> [!WARNING]
> Works on my machine! Review the installation scripts and package files before adopting.

Run the installer. It clones the repo to `~/.dotfiles` and starts the bootstrap:
```zsh
/bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/VasylRomanets/dotfiles/HEAD/install.sh)"
```

Prefer to read the scripts first? Clone the repo and run the bootstrap yourself:
```zsh
git clone https://github.com/vasylromanets/dotfiles.git ~/.dotfiles
~/.dotfiles/setup/bootstrap.zsh
```

<p align="center">
  <img src=".github/assets/bootstrap.webp" width="60%" alt="Bootstrap process">
</p>

This will:
- Install Xcode Command Line Tools
- Install Homebrew
- Install formulae, casks, cargo crates, App Store apps, and VS Code extensions from Brewfile
- Symlink package files and copy assets
- Configure Git and SSH
- Apply macOS defaults

You'll be prompted before each step. To skip the questions, pass `--yes` (to the installer after `install`, or to `setup/bootstrap.zsh`). App Store apps are then skipped and existing Git and SSH configs are kept; the Git identity and SSH key come from the environment:
```zsh
DOTS_GIT_NAME="Your Name" DOTS_GIT_EMAIL="you@example.com" DOTS_SSH_KEY="~/.ssh/id_ed25519" \
  /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/VasylRomanets/dotfiles/HEAD/install.sh)" install --yes
```

## Updating

Once the bootstrap has run, everything is available through the `dots` command (`dots help` lists it). After adding or modifying package files, apply them with:
```zsh
dots sync            # every package
dots sync atuin bat  # only these
dots sync -n         # preview what would change; -v also lists unchanged files
```

To keep some packages off a machine, list them in `~/.config/dots/sync.toml` (it isn't part of the repo), then remove any links they already have with `dots unsync <package>` (add `--keep` to leave a copy of each file):
```toml
deny = ["ghostty"]           # never sync these
allow = ["atuin", "bat"]     # or: sync only these (deny wins over allow)
```

To bring in changes made on another machine, run `dots pull` (fast-forward only, and it refuses on uncommitted changes). Add `--sync` to run `dots sync` right after, or `-n` to preview what would be pulled.

Renaming or removing a package file can leave a stale symlink behind. Run `dots prune-symlinks` occasionally to clean those up.

## Package Setup

Each package may optionally include a `setup.toml`. Packages without one are always processed, symlinking `link/` to `~` by default.

```toml
# Skip this package if the CLI tool/GUI app is not installed
[requires]
command = "bat" # checked via command -v
app = "Ghostty" # checked via /Applications/Ghostty.app

# Override symlink destination (defaults to ~)
[link]
target = "~"

# Copy files from copy/ to this directory
[copy]
target = "~/Library/..."
```

`[requires]` accepts `command`, `app`, or both. `[link]` is rarely needed since `~` is the default. `[copy]` is only used by packages that can't be symlinked because of macOS sandboxing (e.g. any app installed from the Mac App Store).

A package can also define `hooks/pre-setup.zsh` and/or `hooks/post-setup.zsh` for setup steps beyond symlinking/copying (e.g. resolving plugin dependencies). Both are optional and run only for packages that pass `[requires]`.

## Themes

`theme` switches the theme across Ghostty, bat, cava, delta, fzf, micro, vivid, yazi and `ls`/eza colors. Each theme is one scheme in `packages/theme/schemes` (its 16 terminal colors, UI colors and syntax colors in a small TOML file); `dots build-themes` renders the per-tool files from it and the results are committed, so a normal `dots sync` doesn't need to build anything.
