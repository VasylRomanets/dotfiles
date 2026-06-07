# dotfiles

> My personal dotfiles for macOS — version-controlled, XDG-compliant, and Everforest-themed.

<p align="center">
  <img src=".github/assets/preview.png" width="100%" alt="Everforest Terminal Workspace">
</p>

## Structure

> [!NOTE]
> **Real talk about XDG compliance:** This setup is as XDG-compliant as macOS allows. However, a few stubborn tools (e.g. `SSH`, `.zshenv`) hardcode their paths and refuse to leave the `$HOME` folder.

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
│   ├── .hammerspoon/
│   ├── .local/
│   │   └── bin/           # CLI utilities and custom executable scripts
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

> [!WARNING]
> Works on my machine! But remember, these configs are highly opinionated and hardcoded for macOS. Give the installation scripts a quick review before running them so you don't accidentally overwrite your own favorite settings.

### Prerequisites

1. Clone the repo:
```zsh
git clone https://github.com/VasylRomanets/dotfiles.git ~/dev/dotfiles
```

2. Run the bootstrap script:
```zsh
~/dev/dotfiles/setup/bootstrap.zsh
```

This will:
- Install Xcode Command Line Tools
- Install Homebrew
- Install all packages from `Brewfile`
- Create symlinks from `home/` to `~/`
- Copy CotEditor themes

3. Apply macOS defaults (optional):
```zsh
~/dev/dotfiles/setup/macos.zsh
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
~/dev/dotfiles/setup/install.zsh
```

## Appearance

* **Theme:** Most tools are themed with [Everforest Dark Hard](https://github.com/sainnhe/everforest) for a warm, low-fatigue aesthetic.
* **Font:** The terminal and editors use [Meslo LG Nerd Font Mono](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/Meslo), a beautiful font optimized for prompting and coding.

## Inspiration

Many thanks to the dotfiles community for sharing their insights and configurations over the years.

## License

[MIT](./LICENSE)
