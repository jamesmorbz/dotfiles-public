#!/bin/zsh
# Claude Code status line: model · context used · session cost · folder (git branch)
# Wired up as "statusLine" in claude/settings.json. Claude Code pipes session JSON on stdin.
# Inside tmux the values go to the tmux bottom bar as pills (window options, see @claude_pills in
# .tmux.conf) and Claude's own line stays empty; elsewhere (VS Code, Terminal) it prints the line.
in=$(cat)
print -r -- "$in" > "${TMPDIR:-/tmp}/claude-statusline.json"   # last input, for debugging
IFS=$'\t' read -r model cwd cost pct <<< "$(print -r -- "$in" | jq -r '[.model.display_name // "", .workspace.current_dir // "", (.cost.total_cost_usd // "" | tostring), (.context_window.used_percentage // "" | tostring)] | @tsv')"
branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
p=${pct%.*}
[[ -n $cost ]] && cost=$(printf '$%.2f' $cost)

# Catppuccin Mocha: context green < 50%, yellow < 80%, red after
green='#a6e3a1' yellow='#f9e2af' red='#f38ba8'
if [[ -n $p ]]; then (( p < 50 )) && c=$green || { (( p < 80 )) && c=$yellow || c=$red; }; fi

if [[ -n $TMUX_PANE ]]; then
  where=${cwd:t}${branch:+ $'' $branch}
  T=(-w -t "$TMUX_PANE")
  tmux set $T @claude_model "$model" \; set $T @claude_ctx "${p:+$p%}" \; set $T @claude_ctx_fg "${c:-$green}" \
    \; set $T @claude_cost "$cost" \; set $T @claude_where "${where//\#/}" 2>/dev/null
  exit 0
fi

rgb() { printf '\e[38;2;%d;%d;%dm' 0x${1:1:2} 0x${1:3:2} 0x${1:5:2}; }
dim=$(rgb '#a6adc8') off=$'\e[0m'
out="$(rgb '#cba6f7')${model}${off}"
if [[ -n $p ]]; then
  filled=$(( p / 10 )); bar=${(l:$filled::█:)}${(l:$((10 - filled))::░:)}
  out+=" ${dim}·${off} $(rgb $c)${bar} ${p}%${off}"
fi
[[ -n $cost ]] && out+=" ${dim}·${off} $(rgb $yellow)${cost}${off}"
out+=" ${dim}·${off} $(rgb '#89b4fa')${cwd/#$HOME/~}${off}"
[[ -n $branch ]] && out+=" ${dim}(${branch})${off}"
print -r -- "$out"
