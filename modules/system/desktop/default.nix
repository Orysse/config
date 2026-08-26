{ self, ... }:
{
  flake.nixosModules.desktop =
    { ... }:
    let
      modules = with self.nixosModules; [
        core
        network
        audio
        systemTheme
        river
        greetd
        kitty
        firefox
        nvim
        tmux
        starship
        git
        fuzzel
        kanshi
        swaylock
        wob
        waybar
        keepassxc
      ];
    in
    {
      imports = modules;
      hardware.bluetooth.enable = true;
    };
}
