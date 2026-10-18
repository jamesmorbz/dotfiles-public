#!/bin/zsh
# Claude Code → its tmux window pill: traffic light + "folder: task" (see .tmux.conf @claude_*).
# Called by hooks in claude/settings.json with $1 = busy | waiting | free | notify | end; hook JSON on stdin.
#   red = busy, yellow = waiting for you, green = free. Rings the bell when it needs you or finishes.
[[ -n $TMUX_PANE ]] || exit 0
in=$(cat)
j() { print -r -- "$in" | jq -r "$1 // empty" 2>/dev/null }
opt() { tmux set -w -t "$TMUX_PANE" "$@" 2>/dev/null }
bell() { local tty=$(tmux display -p -t "$TMUX_PANE" '#{pane_tty}' 2>/dev/null); [[ -w $tty ]] && printf '\a' > "$tty" }

state=$1 event=$(j .hook_event_name)
case $state in
  end) for o in state task dir model ctx ctx_fg cost where; do opt -u @claude_$o; done; exit 0 ;;
  notify) [[ $(j .notification_type) == idle_prompt ]] && exit 0; state=waiting ;;   # idle reminder: stay green
esac

dir=$(j .cwd); [[ -n $dir ]] && opt @claude_dir "${${dir:t}//\#/}"
if [[ $event == UserPromptSubmit ]]; then
  p=$(j .prompt | tr '\n\t' '  ')
  if [[ -n $p && $p != /* ]]; then                       # slash commands keep the previous task
    words=(${=p}); task="${${(j: :)words[1,3]}//\#/}"    # first 3 words, no # (tmux format char)
    (( ${#task} > 20 )) && task="${task[1,19]}…"
    opt @claude_task "$task"
  fi
fi
opt @claude_state $state
[[ $state == waiting || $event == Stop ]] && bell
exit 0
