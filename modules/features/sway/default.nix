{ ... }:
{
  flake.nixosModules.sway =
    { pkgs, ... }:
    {
      programs.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
        extraPackages = with pkgs; [
          brightnessctl
          grim
          slurp
          satty
          pulseaudio
          swayidle
          wlsunset
        ];
      };
      xdg.portal = {
        enable = true;
        wlr.enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
        config.common.default = "*";
      };
      services.gvfs.enable = true;
      environment.etc."sway/config".text =
        builtins.replaceStrings [ "WALLPAPER_PATH" ] [ "${./terra-nova-everforest.jpg}" ]
          (builtins.readFile ./config);
    };
}
