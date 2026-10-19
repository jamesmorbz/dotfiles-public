#!/usr/bin/env bash
# Links the shell, tmux, starship and git configs (Linux or macOS). No sudo, installs nothing system-wide,
# safe to re-run. Configs expect the repo at ~/dev/dotfiles.
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
[ "$DIR" = "$HOME/dev/dotfiles" ] || echo "warning: configs expect ~/dev/dotfiles (this copy is in $DIR)"

# Symlink $DIR/<src> to <dest>, backing up a real file that is in the way
link() {
  local src="$DIR/$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.backup.$(date +%Y%m%d-%H%M%S)"
    echo "backed up old ${dest/#$HOME/~}"
  fi
  ln -sfn "$src" "$dest"
}

link .zshrc              "$HOME/.zshrc"
link .zprofile           "$HOME/.zprofile"
link .tmux.conf          "$HOME/.tmux.conf"
link .gitconfig          "$HOME/.gitconfig"
if [ "$(uname)" = Darwin ]; then link git/macos.gitconfig "$HOME/.gitconfig.os"; else link git/linux.gitconfig "$HOME/.gitconfig.os"; fi
link starship.toml       "$HOME/.config/starship.toml"
command -v mise >/dev/null && link mise/config.toml "$HOME/.config/mise/config.toml"
mkdir -p "$HOME/dev/scratch"
echo "linked: .zshrc .zprofile .tmux.conf .gitconfig starship.toml"

# tmux plugins, pinned versions
TP="$HOME/.config/tmux/plugins"
clone() { [ -d "$TP/$2" ] || git clone -q -c advice.detachedHead=false --depth 1 --branch "$3" "https://github.com/$1" "$TP/$2"; }
clone catppuccin/tmux catppuccin/tmux v2.3.1
clone tmux-plugins/tmux-resurrect tmux-resurrect v4.0.0
clone tmux-plugins/tmux-continuum tmux-continuum v3.1.0
echo "tmux plugins ready"

# Machine-only git settings (e.g. work email) go in ~/.gitconfig.local
[ -e "$HOME/.gitconfig.local" ] || printf '# Your git identity and machine-only settings (not in the dotfiles repo)\n[user]\n#\tname = Your Name\n#\temail = you@example.com\n' > "$HOME/.gitconfig.local"

echo
missing=""
for t in zsh tmux starship fzf zoxide eza bat lazygit gitleaks jq; do
  command -v "$t" >/dev/null || { [ "$t" = bat ] && command -v batcat >/dev/null; } || missing="$missing $t"
done
[ -n "$missing" ] && echo "Not installed (configs skip what's missing):$missing"
echo "  starship without sudo: curl -sS https://starship.rs/install.sh | sh -s -- -y -b ~/.local/bin"
echo "  tmux 3.3+ recommended (popups, pills); check with: tmux -V"
[ "$(basename "${SHELL:-}")" = zsh ] || echo "Default shell is ${SHELL:-unknown}: run 'chsh -s \$(command -v zsh)' if allowed, or add 'exec zsh' at the end of ~/.bashrc"
echo "Set your git name/email in ~/.gitconfig.local"
