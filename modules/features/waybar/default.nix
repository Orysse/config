{
  inputs,
  moduleWithSystem,
  ...
}:
{
  flake.nixosModules.waybar = moduleWithSystem (
    { self', ... }: { ... }: {
      environment.systemPackages = [ self'.packages.waybar ];
    }
  );
  perSystem = { pkgs, ... }: {
    packages.waybar = inputs.wrappers.wrappers.waybar.wrap {
      inherit pkgs;
      settings = {
        layer = "bottom";
        output = "eDP-1";
        position = "bottom";
        height = 36;
        spacing = 0;

        modules-left = [
          "river/tags"
        ];
        modules-right = [
          "network#speed"
          "network"
          "custom/wireguard"
          "cpu"
          "memory"
          "battery"
          "clock"
        ];

        "river/tags" = {
          num-tags = 9;
          hide-vacant = true;
        };

        network = {
          format-wifi = "  {essid}";
          format-ethernet = "󰈀  {ipaddr}";
          format-disconnected = "offline";
          tooltip = false;
        };

        "network#speed" = {
          interval = 2;
          format = " {bandwidthDownBytes}  {bandwidthUpBytes}";
          format-disconnected = "";
          tooltip = false;
        };

        "custom/wireguard" = {
          exec = "ip -o link show type wireguard 2>/dev/null | awk -F': ' '{print $2}' | paste -sd' '";
          interval = 5;
          format = "  {}";
          exec-if = "ip -o link show type wireguard 2>/dev/null | grep -q wg";
          tooltip = false;
        };

        cpu = {
          format = "  {usage}%";
          tooltip = false;
        };
        memory = {
          format = "  {used:0.1f}G";
          tooltip = false;
        };

        battery = {
          format = "  {capacity}%";
          format-charging = " {capacity}%";
          states = {
            warning = 30;
            critical = 15;
          };
          tooltip = false;
        };

        clock = {
          format = "{:%H:%M   %a %d %b}";
          tooltip = false;
        };
      };
      "style.css".path = pkgs.writeText "waybar-style.css" (builtins.readFile ./style.css);
    };
  };
}
