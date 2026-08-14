sink="@DEFAULT_AUDIO_SINK@"
sock="$XDG_RUNTIME_DIR/wob.sock"

case "$1" in
  up) wpctl set-volume -l 1.0 "$sink" 5%+ ;;
  down) wpctl set-volume "$sink" 5%- ;;
  mute) wpctl set-mute "$sink" toggle ;;
esac

info=$(wpctl get-volume "$sink")
if echo "$info" | grep -q MUTED; then
  echo 0 > "$sock"
else
  echo "$info" | awk '{printf "%d\n", $2 * 100}' > "$sock"
fi
