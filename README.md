# ⚙️ Dotfiles Configuration

**Portable, modular, and Git-powered dotfiles** managed as a collection of submodules for maximum flexibility and synchronization across machines.

## 🎯 Philosophy

This configuration follows a **submodule-first architecture**:

- 🏗️ **Modular** - Each component is its own Git repository
- 🔄 **Syncable** - Easy to update individual components or everything at once
- 🌍 **Portable** - Works across macOS, Linux, BSD
- 🔐 **Secure** - Built-in encryption for sensitive files
- ⚡ **Fast** - Lazy loading, minimal overhead

## 📁 Structure

```
.config/
├── brew/                  # Homebrew packages & VSCode extensions
├── zsh/                   # Zsh shell configuration
│   ├── git-utils/        # Custom Git workflow utilities
│   ├── prompt/           # Git-aware prompt system
│   └── plugins/          # Zsh plugins (auto-managed)
├── git/                   # Git configuration
├── vscode/                # VSCode settings & snippets
├── claude/                # Claude Code configuration
├── docs/                  # Documentation & guides
└── CLAUDE.md              # AI assistant instructions
```

## 🚀 Quick Start

### Fresh Machine Setup

```bash
# 1. Clone this repository
git clone --recursive git@github.com:smnuman/dotfiles.git ~/.config

# 2. Initialize submodules (if not using --recursive)
cd ~/.config
git submodule update --init --recursive

# 3. Create essential symlinks
ln -sf ~/.config/zsh/my.zshenv ~/.zshenv
ln -sf ~/.config/git/gitconfig ~/.gitconfig

# 4. Install Homebrew packages
cd ~/.config/brew
brew bundle --file=Brewfile

# 5. Reload shell
exec zsh
```

### Update Everything

```bash
# Pull latest changes for all submodules
cd ~/.config
git pull --recurse-submodules

# Or use custom sync command (once zsh is loaded)
gsync-all "Update all configs"
```

## 📦 Components

### 🍺 [brew/](./brew/) - Homebrew Management
Package manager configuration for macOS/Linux:
- CLI tools (bat, eza, fzf, git, etc.)
- Development tools (Node.js, Neovim, Git utilities)
- Applications (VSCode, VLC, AltTab)
- Fonts (Geist, Nerd Fonts)
- VSCode extensions manifest

**[📖 Documentation](./brew/README.md)**

### 🐚 [zsh/](./zsh/) - Zsh Shell Configuration
Modular shell setup with custom workflows:
- Git-aware prompt system
- Custom Git utilities (`grepo`, `gsub`, `gsync`)
- Plugin management system
- Fast startup with lazy loading
- Cross-platform compatibility

**[📖 Documentation](./zsh/README.md)**

#### 🌀 [zsh/prompt/](./zsh/prompt/) - Prompt System
Minimal Git-aware prompt with:
- ✓/✗ Clean/dirty status
- ↑/↓ Sync indicators
- Virtual environment detection
- Root user warnings

**[📖 Documentation](./zsh/prompt/README.md)**

#### 🧰 [zsh/git-utils/](./zsh/git-utils/) - Git Workflow Utilities
Custom commands for dotfiles management:
- `grepo` - Create & push repos to GitHub/GitLab
- `gsub` - Add directories as submodules
- `gsync` - Sync submodules + parent repo
- `gsub-all` - Batch operations
- Automatic conflict resolution
- Git-crypt encryption support

**[📖 Documentation](./zsh/git-utils/README.md)**

### 📝 [vscode/](./vscode/) - VSCode Configuration
Editor settings, keybindings, and snippets.

### 🤖 [claude/](./claude/) - Claude Code Settings
AI assistant workspace configuration.

### 📚 [docs/](./docs/) - Documentation
Setup guides, development notes, and troubleshooting.

## 🔧 Custom Git Utilities

This dotfiles setup includes powerful custom Git commands:

| Command | Description |
|---------|-------------|
| `grepo [msg] [name]` | Initialize directory as Git repo and push to GitHub |
| `gsub <dir> [msg] [name]` | Add directory as Git submodule |
| `gunsub <dir>` | Remove submodule completely |
| `gsync [msg]` | Sync submodule + parent repo |
| `gsync-pull` | Pull updates for submodule and parent |
| `gsync-all [msg]` | Update all submodules recursively |
| `gsub-all [-L N] <msg>` | Batch-convert directories to submodules |
| `gencrypt_setup [dir]` | Setup git-crypt encryption |
| `gsecrets` | Scan for exposed secrets |

**Example workflow:**
```bash
# Create new config directory
mkdir ~/.config/mynewconfig

# Initialize as repo and push to GitHub
cd ~/.config/mynewconfig
grepo "Initial commit" mynewconfig

# Add as submodule to parent .config
cd ~/.config
gsub mynewconfig "Add mynewconfig submodule"

# Later: sync changes
cd ~/.config/mynewconfig
# ... make changes ...
gsync "Update mynewconfig"  # Syncs both submodule and parent
```

## 🔐 Security Features

### Git-Crypt Integration
Automatic encryption for sensitive files:

```bash
# Auto-detects and encrypts:
*.env, *.key, *.pem, *.token
*secret*, *credential*, *password*
.ssh/id_*, .gnupg/*.key
```

Custom patterns via `.gitkeys` file in each repo.

### Pre-Commit Hooks
Secret scanning prevents accidental commits:
- Detects API keys, tokens, passwords
- Blocks commits with exposed secrets
- Warns about unencrypted sensitive files

## 🔄 Synchronization

### Individual Component
```bash
cd ~/.config/zsh
git pull
git add . && git commit -m "Update zsh config"
git push
```

### All Submodules
```bash
cd ~/.config
gsync-all "Update all configs"
```

### New Machine
```bash
git clone --recursive git@github.com:smnuman/dotfiles.git ~/.config
cd ~/.config
gsync-pull  # Pull latest for all submodules
```

## 🛠️ Maintenance

### Update Submodule Pointers
```bash
cd ~/.config
git submodule update --remote --merge
git commit -am "Update submodule pointers"
git push
```

### Add New Submodule
```bash
cd ~/.config
gsub new-component/ "Add new component"
```

### Remove Submodule
```bash
cd ~/.config
gunsub component-name
```

### Regenerate Zsh Completions
```bash
rm -f ~/.config/zsh/.zcompdump*
exec zsh
```

## 🌍 Platform Support

| Platform | Support Level | Notes |
|----------|---------------|-------|
| **macOS** | ✅ Full | Primary development platform |
| **Linux** | ✅ Full | Tested on Ubuntu, Arch, Fedora |
| **BSD** | ⚠️ Partial | May need minor adjustments |
| **Windows** | ❌ No | Use WSL2 instead |

## 📋 Requirements

### Essential
- **Git** ≥ 2.30
- **Zsh** ≥ 5.8 (for shell config)
- **Homebrew** (for package management)

### Recommended
- **gh** or **glab** - GitHub/GitLab CLI (for `grepo`, `gsub`)
- **git-crypt** - File encryption
- **gnupg** - GPG signing
- **fzf** - Fuzzy finder
- **zoxide** - Smart directory navigation

Install via Homebrew:
```bash
brew install git zsh gh git-crypt gnupg fzf zoxide
```

## 🚨 Troubleshooting

### Submodules not updating?
```bash
git submodule update --init --recursive --remote
```

### Git commands not found?
```bash
# Ensure git-utils is in PATH
echo $PATH | grep git-utils
exec zsh  # Reload shell
```

### Homebrew packages not installing?
```bash
cd ~/.config/brew
brew bundle check --file=Brewfile  # Check status
brew bundle install --file=Brewfile  # Install missing
```

### Shell slow to start?
```bash
# Profile startup time
time zsh -i -c exit

# Check for large completion files
ls -lh ~/.config/zsh/.zcompdump*
```

## 📚 Documentation

- **Setup Guide:** [`docs/SETUP.md`](./docs/SETUP.md)
- **Development Notes:** [`docs/DEVELOPMENT_NOTES.md`](./docs/DEVELOPMENT_NOTES.md)
- **Maintenance Guide:** [`docs/MAINTENANCE.md`](./docs/MAINTENANCE.md)
- **Shell Structure:** [`docs/SHELL_STRUCTURE.md`](./docs/SHELL_STRUCTURE.md)

## 💡 Tips & Best Practices

### Use `.local` Files for Machine-Specific Config
```bash
# Create gitignored local overrides
echo "*.local" >> .gitignore
touch ~/.config/zsh/.zshrc.local
```

### Backup Before Major Changes
```bash
cd ~/.config
git checkout -b backup-$(date +%Y%m%d)
```

### Test Changes in Subshell
```bash
zsh -i  # Test without affecting current session
exit    # Exit when done
```

### Keep Submodules Shallow
```bash
# Clone with limited history for faster sync
git clone --depth=1 --recursive ...
```

## 🤝 Contributing

This is a personal dotfiles repo, but feel free to:
- Fork and adapt for your own use
- Submit issues for bugs
- Suggest improvements via discussions

## 📝 License

Personal configuration files. Use freely, modify as needed. No warranty provided.

## 🔗 Related Projects

- [smnuman/config-zsh](https://github.com/smnuman/config-zsh) - Zsh configuration
- [smnuman/config-brew](https://github.com/smnuman/config-brew) - Homebrew packages
- [smnuman/zsh-prompt](https://github.com/smnuman/zsh-prompt) - Prompt system

## 🙏 Credits

Configuration by **[@smnuman](https://github.com/smnuman)** with inspiration from:
- [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles)
- [thoughtbot dotfiles](https://github.com/thoughtbot/dotfiles)
- [holman/dotfiles](https://github.com/holman/dotfiles)

---

**Last Updated:** 2025-10-05
**Repository:** [github.com/smnuman/dotfiles](https://github.com/smnuman/dotfiles)

*Make your environment truly yours.* ✨
