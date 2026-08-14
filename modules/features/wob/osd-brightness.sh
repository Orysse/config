sock="$XDG_RUNTIME_DIR/wob.sock"

case "$1" in
  up) brightnessctl set 5%+ > /dev/null ;;
  down) brightnessctl set 5%- > /dev/null ;;
esac

cur=$(brightnessctl get)
max=$(brightnessctl max)
echo "$((cur * 100 / max)) brightness" > "$sock"
