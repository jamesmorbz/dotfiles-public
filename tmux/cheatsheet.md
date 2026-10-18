# tmux cheatsheet          (q to close)

Press ⌘B (or Ctrl-b), let go, then the key.
A red strip at the bottom shows the common
keys while tmux is waiting.

## Windows (the pills along the bottom)
  Pills are named after the folder. With Claude running they show
  "folder: task" and a light: red busy, yellow waiting for you,
  green free. A bell icon means that window wants you.
  Right side: that window's Claude model, context %, cost, folder.
  c          new window (same folder)
  1-9        go to window 1-9
  n / p      next / previous window
  ,          rename window
  &          close window

## Panes (splits inside a window)
  |          split side by side
  -          split top / bottom
  ⌘⌥ arrows  move between panes (no ⌘B needed)
  h j k l    move left / down / up / right
  H J K L    resize (⌘B once, then tap repeatedly)
  z          zoom pane to full screen and back
  x          close pane
  space      cycle pane layouts

## Popups
  g          lazygit for this folder (q closes)
  f          jump to any session / window (Esc closes)
  t          scratch shell (Ctrl-d closes)
  ?          this cheatsheet (q closes)

## Sessions
  d          detach (main keeps running; `t` re-attaches it)
  s          session list
  $          rename session
  Sessions save every 15 min and come back after a restart.
  Save now: ⌘B Ctrl-s     Restore now: ⌘B Ctrl-r

## Copy
  Drag with the mouse: copies to the Mac clipboard (and Tinycast history)
  [          copy mode: scroll with arrows/PgUp, v start, y copy, q quit
  ]          paste last tmux copy

## Other
  r          reload tmux config
  :          tmux command prompt
