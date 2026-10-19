# ~/.zshrc — lives in ~/dev/dotfiles, symlinked by setup.sh
# Secrets and machine-specific settings go in ~/.zshrc.local (not in git)

# Homebrew
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# PATH: personal scripts, native Claude Code, VS Code's `code`
typeset -U path
path=("$HOME/dev/scripts" "$HOME/.local/bin" $path "/Applications/Visual Studio Code.app/Contents/Resources/app/bin")

# mise: node, python, go, pnpm
command -v mise >/dev/null && eval "$(mise activate zsh)"

# History and completion
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE
# Completions: full check/rebuild of ~/.zcompdump at most once a day, otherwise load it as-is (-C)
autoload -Uz compinit
() { setopt local_options extended_glob; if [[ -n ~/.zcompdump(#qN.mh+24) || ! -f ~/.zcompdump ]]; then compinit; else compinit -C; fi }

# Prompt: starship (config in ~/dev/dotfiles/starship.toml), plain fallback
PROMPT='%F{cyan}%~%f %# '
command -v starship >/dev/null && eval "$(starship init zsh)"

# Redraw the prompt as Enter is pressed, so its [time] is when the command ran (not when the prompt appeared)
_prompt_time_on_enter() { zle reset-prompt; zle .accept-line }
zle -N accept-line _prompt_time_on_enter

# fzf: Ctrl-R history, Ctrl-T files, Alt-C cd. zoxide: `z <part of path>`
[[ -t 0 && -t 1 ]] && command -v fzf >/dev/null && source <(fzf --zsh)   # needs a terminal
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# New interactive shells that open in ~ start in ~/dev
[[ -o interactive && $PWD == $HOME && -d $HOME/dev ]] && cd ~/dev

# Aliases
alias t='tmux new-session -A -s main -c ~/dev'
alias dev='cd ~/dev'
alias lg='lazygit'
# plain `ls` stays the system ls (so -lrt etc. work), in colour
unalias ls 2>/dev/null   # clears the old eza alias when re-sourcing in an existing shell
if [[ $OSTYPE == darwin* ]]; then export CLICOLOR=1; else alias ls='ls --color=auto'; fi
if command -v eza >/dev/null; then
  alias ll='eza -lah --git --icons --group-directories-first'
  alias tree='eza --tree --git-ignore --icons'
else
  alias ll='ls -lah'
fi
command -v bat >/dev/null || { command -v batcat >/dev/null && alias bat=batcat; }   # Debian/Ubuntu name
(( $+commands[bat] || $+aliases[bat] )) && alias cat='bat --paging=never --style=plain'

# Python venvs: `mkvenv` in a project creates and activates .venv
alias mkvenv='python3 -m venv .venv && source .venv/bin/activate'
alias activate='source .venv/bin/activate'

# Save dotfiles (incl. Claude memory) to GitHub; dotsync-public updates the public subset repo
[[ -f ~/dev/dotfiles/claude/dotsync.sh ]] && dotsync() { zsh ~/dev/dotfiles/claude/dotsync.sh "$@"; }
[[ -f ~/dev/dotfiles/public/export.sh ]] && dotsync-public() { zsh ~/dev/dotfiles/public/export.sh "$@"; }

# Resume a Claude Code session by ID (or the start of one) from anywhere: cd to the folder it was
# started in first, since `claude --resume <id>` only finds that folder's sessions. No ID: the picker.
cr() {
  [[ -z $1 ]] && { claude --resume; return; }
  local f=(~/.claude/projects/*/$1*.jsonl(N))
  (( $#f == 1 )) || { echo "cr: $#f sessions match '$1'"; return 1; }
  local dir=$(jq -r 'select(.cwd) | .cwd' "$f[1]" 2>/dev/null | head -1)
  [[ -d $dir ]] && cd "$dir"
  claude --resume "${f[1]:t:r}"
}

# Quick system check (macOS)
if [[ $OSTYPE == darwin* ]]; then
  machealth() {
    echo "== $(scutil --get ComputerName) · macOS $(sw_vers -productVersion) =="
    uptime | sed 's/^ *//'
    df -h / | awk 'NR==2 {print "Disk:    " $4 " free of " $2 " (" $5 " used)"}'
    memory_pressure 2>/dev/null | awk -F': ' '/free percentage/ {print "Memory:  " $2 " free"}'
    pmset -g batt | awk -F'; ' 'NR==2 {sub(/.*\t/, "", $1); print "Battery: " $1 ", " $2}'
    echo "Brew:    $(brew outdated --quiet 2>/dev/null | wc -l | tr -d ' ') outdated"
    if docker info >/dev/null 2>&1; then echo "Docker:  running"; else echo "Docker:  not running"; fi
  }
fi

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# zsh plugins (syntax highlighting must load last)
# (Homebrew on macOS; distro packages or ~/.local/share on Linux)
for p in zsh-autosuggestions/zsh-autosuggestions.zsh zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
  for d in ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share} /usr/share /usr/local/share ~/.local/share; do
    [[ -f $d/$p ]] && { source "$d/$p"; break; }
  done
done

# Ghostty windows start inside tmux: the first attaches session `main`, later ones get their own,
# which ends when that window closes (only `main` persists). Only in Ghostty (not VS Code/Terminal/
# scripts). Detach with ⌘B d to get a plain shell back.
if [[ -o interactive && -z $TMUX && -n $GHOSTTY_RESOURCES_DIR ]] && command -v tmux >/dev/null; then
  if [[ -n "$(tmux list-clients -t main 2>/dev/null)" ]]; then
    tmux new-session -c ~/dev \; set-option destroy-unattached on
  else
    tmux new-session -A -s main -c ~/dev
  fi
fi
