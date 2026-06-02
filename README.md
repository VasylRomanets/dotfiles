# dotfiles

> My personal dotfiles for macOS — version controlled, XDG-compliant, and Everforest-themed.

<p align="center">
  <img src=".github/assets/preview.png" width="100%" alt="Terminal Workspace">
</p>

## Structure

```
dotfiles/
├── .github/               # GitHub-specific repo configs
│   └── assets/            # media for documentation
├── apps/                  # GUI app configs that can't be symlinked
│   └── coteditor/
│       └── themes/
├── home/                  # mirrors ~/ — everything here gets symlinked
│   ├── .config/
|   |   ├── claude/
|   |   ├── fastfetch/
│   │   ├── ghostty/
│   │   ├── git/
│   │   ├── micro/
│   │   ├── ripgrep/
│   │   └── zsh/
│   ├── .ssh/
│   ├── .zshenv
│   └── .hushlogin
└── setup/
    ├── Brewfile           # all Homebrew packages
    ├── bootstrap.zsh      # full machine setup (run once on a new Mac)
    ├── install.zsh        # creates symlinks from home/ to ~/ and copies files
    └── macos.zsh          # sensible macOS defaults
```

## New Machine Setup

### Prerequisites

1. Clone the repo:
```zsh
git clone git@github.com:VasylRomanets/dotfiles.git ~/dev/projects/dotfiles
```

2. Run the bootstrap script:
```zsh
~/dev/projects/dotfiles/setup/bootstrap.zsh
```

This will:
- Install Xcode Command Line Tools
- Install Homebrew
- Install all packages from `Brewfile`
- Create symlinks from `home/` to `~/` and copy files

3. Apply macOS defaults (optional):
```zsh
~/dev/projects/dotfiles/setup/macos.zsh
```

### Manual Steps

These can't be automated and must be done manually on each machine:

**Git identity** — create `~/.config/git/config.local`:
```ini
[user]
    name = Your Name
    email = your.name@email.com
```

**SSH** — create `~/.ssh/config.local`:
```
Host github.com
  IdentityFile ~/.ssh/your_key
```

## Updating

After adding new files to the repo, re-run:
```zsh
~/dev/projects/dotfiles/setup/install.zsh
```

## Theme

Most of the tools are themed with [Everforest Dark Hard](https://github.com/sainnhe/everforest) by sainnhe:
- Ghostty terminal theme
- zsh syntax highlighting
- ripgrep output colors
- eza file listing colors
- micro editor theme

## License

[MIT](./LICENSE)
