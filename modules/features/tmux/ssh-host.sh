pane_tty="$1"
ssh_args=$(ps -t "$pane_tty" -o args= | grep -m1 -E '(^|/)ssh ')

if [ -n "$ssh_args" ]; then
  target=$(echo "$ssh_args" | awk '{print $NF}')
  printf '󰣀 %s' "${target#*@}"
else
  hostname
fi
