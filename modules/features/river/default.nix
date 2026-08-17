{
  inputs,
  moduleWithSystem,
  ...
}:
{
  flake.nixosModules.river = moduleWithSystem (
    { self', ... }:
    { pkgs, ... }:
    {
      programs.river-classic = {
        enable = true;
        package = self'.packages.river;
        extraPackages = with pkgs; [
          rivercarro
          swaybg
        ];
      };
      environment.sessionVariables.WLR_SCENE_DISABLE_DIRECT_SCANOUT = "1";
      systemd.user.targets.river-session = {
        description = "river compositor session";
        documentation = [ "man:systemd.special(7)" ];
        bindsTo = [ "graphical-session.target" ];
        wants = [ "graphical-session-pre.target" ];
        after = [ "graphical-session-pre.target" ];
      };
    }
  );
  perSystem =
    { pkgs, self', ... }:
    {
      packages.river =
        let
          screenshotScript = pkgs.writeShellScript "river-screenshot" (builtins.readFile ./screenshot.sh);
          initScript = pkgs.writeShellScript "river-init" (
            builtins.replaceStrings
              [ "WALLPAPER_PATH" "SCREENSHOT_SCRIPT" ]
              [
                "${./terra-nova-everforest.jpg}"
                "${screenshotScript}"
              ]
              (builtins.readFile ./init)
          );
        in
        inputs.wrappers.lib.wrapPackage [
          { inherit pkgs; }
          {
            package = pkgs.river-classic;
            flags."-c" = initScript;
            filesToPatch = [
              "share/applications/*.desktop"
              "share/wayland-sessions/*.desktop"
            ];
            runtimePkgs =
              (with pkgs; [
                dbus
                river-classic
                rivercarro
                swaybg
                wlsunset
                grim
                slurp
                satty
              ])
              ++ (with self'.packages; [
                kitty
                fuzzel
                swaylock
                kanshi
                waybar
                wob-daemon
                osd-volume
                osd-brightness
              ]);
          }
        ]
        // {
          providedSessions = pkgs.river-classic.providedSessions;
        };
    };
}
