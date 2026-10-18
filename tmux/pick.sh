#!/bin/zsh
# Fuzzy-pick any tmux session/window and jump to it (bound to prefix f, runs in a popup)
target=$(tmux list-windows -a -F '#{session_name}:#{window_index}  #{window_name}  #{s|^'"$HOME"'|~|:pane_current_path}' |
  fzf --reverse --prompt='jump to ❯ ' --no-info | awk '{print $1}')
[[ -n $target ]] && tmux switch-client -t "$target"
exit 0
