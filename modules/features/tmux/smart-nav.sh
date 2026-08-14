#!/bin/sh

dir="$1"
tmux_flag="$2"
sway_dir="$3"
at_edge="$4"
pane_id="$5"

pane_tty=$(tmux display-message -p -t "$pane_id" '#{pane_tty}')

if ps -o state= -o comm= -t "$pane_tty" \
    | grep -iqE '^[^TXZ ]+ +(\S+/)?g?\.?(view|l?n?vim?x?|fzf)(diff)?(-wrapped)?$'; then
  tmux send-keys -t "$pane_id" "C-$dir"
elif [ "$at_edge" = "1" ]; then
  swaymsg focus "$sway_dir"
else
  tmux select-pane -t "$pane_id" "-$tmux_flag"
fi
