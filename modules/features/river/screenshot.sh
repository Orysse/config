mkdir -p ~/Pictures/Screenshots
grim -g "$(slurp -b '#2d353b55' -c '#a7c080')" -t ppm - | satty --app-id com.gabm.satty -f - -o ~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png
