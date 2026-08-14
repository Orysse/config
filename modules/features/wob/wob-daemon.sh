sock="$XDG_RUNTIME_DIR/wob.sock"
[ -p "$sock" ] || mkfifo -m 600 "$sock"
tail -f "$sock" | wob
