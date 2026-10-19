# dotfiles

zsh, tmux, Starship, Ghostty and git config. Works on macOS and Linux, needs no sudo, and skips any tool that isn't installed.

```sh
git clone https://github.com/jamesmorbz/dotfiles-public ~/dev/dotfiles
bash ~/dev/dotfiles/install.sh
```

The configs expect the repo at `~/dev/dotfiles`. `install.sh` symlinks the files below, clones the pinned tmux plugins, and lists any missing tools. Put your git name and email in `~/.gitconfig.local`, which it creates for you.

| File | Linked to | What it does |
|---|---|---|
| `.zshrc`, `.zprofile` | `~/.zshrc`, `~/.zprofile` | history, completion, starship, fzf, zoxide, aliases (`ll`/`tree` via eza, `cat` via bat, `lg` lazygit, `t` tmux), `mkvenv`, `scratch` (fresh /tmp folder), `cr` (resume a Claude session); Ghostty windows auto-attach tmux |
| `starship.toml` | `~/.config/starship.toml` | one-line prompt: `[time the command ran]` folder, git, language versions, slow commands |
| `.tmux.conf`, `tmux/` | `~/.tmux.conf` | Catppuccin Mocha pills, prefix hint strip, popups, vi copy to clipboard (OSC 52 over SSH), session save/restore |
| `ghostty/config` | `~/.config/ghostty/config` (macOS, link by hand) | Catppuccin Mocha, ⌘B as the tmux prefix, ⌘⌥ arrows move panes |
| `.gitconfig`, `git/` | `~/.gitconfig`, `~/.gitconfig.os` | global hooks and ignores; per-OS settings (macOS: gh credentials, delta) |
| `git-hooks/` | `core.hooksPath` | pre-commit runs gitleaks (if installed), then the repo's own hooks |
| `mise/config.toml` | `~/.config/mise/config.toml` | Node LTS, Python, Go, pnpm, Rust (only if mise is installed) |
| `claude/` | Claude Code hooks / status line | optional: Claude's model, context %, cost and a busy/waiting/free light on the tmux pills |

## tmux keys

Prefix is Ctrl-b (⌘B in Ghostty). Press it and a strip at the bottom shows the main keys; `prefix ?` opens the full cheatsheet (`tmux/cheatsheet.md`).

| Keys | Does |
|---|---|
| `c`, `1`–`9` | new window, switch window |
| `\|`, `-` | split side by side, stacked |
| `h j k l`, `H J K L`, `z` | move between panes, resize, zoom |
| `g`, `f`, `t` | popups: lazygit, jump to any session/window, scratch shell |
| `[` then `v` … `y` | copy to the clipboard |
| `d` | detach |
| Ctrl-s / Ctrl-r | save / restore sessions (also automatic every 15 min) |

## Claude Code (optional)

To get the pills, add this to `~/.claude/settings.json`:

```json
{
  "statusLine": { "type": "command", "command": "zsh ~/dev/dotfiles/claude/statusline.sh" },
  "hooks": {
    "SessionStart":      [{ "hooks": [{ "type": "command", "command": "zsh ~/dev/dotfiles/claude/tmux-state.sh free" }] }],
    "UserPromptSubmit":  [{ "hooks": [{ "type": "command", "command": "zsh ~/dev/dotfiles/claude/tmux-state.sh busy" }] }],
    "PreToolUse":        [{ "matcher": "AskUserQuestion", "hooks": [{ "type": "command", "command": "zsh ~/dev/dotfiles/claude/tmux-state.sh waiting" }] }],
    "PostToolUse":       [{ "hooks": [{ "type": "command", "command": "zsh ~/dev/dotfiles/claude/tmux-state.sh busy" }] }],
    "PermissionRequest": [{ "hooks": [{ "type": "command", "command": "zsh ~/dev/dotfiles/claude/tmux-state.sh waiting" }] }],
    "Notification":      [{ "hooks": [{ "type": "command", "command": "zsh ~/dev/dotfiles/claude/tmux-state.sh notify" }] }],
    "Stop":              [{ "hooks": [{ "type": "command", "command": "zsh ~/dev/dotfiles/claude/tmux-state.sh free" }] }],
    "SessionEnd":        [{ "hooks": [{ "type": "command", "command": "zsh ~/dev/dotfiles/claude/tmux-state.sh end" }] }]
  }
}
```

Needs `jq`. Red = busy, yellow = waiting for you, green = free; the pill reads "folder: session title" (the title Claude Code gives the session).

`.zshrc` also adds `cr <session-id>`: resumes a Claude Code session from any folder (it `cd`s to where the session started first).
