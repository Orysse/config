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

      xdg.portal = {
        enable = true;
        wlr = {
          enable = true;
          settings.screencast = {
            chooser_type = "dmenu";
            chooser_cmd = "${self'.packages.fuzzel}/bin/fuzzel --dmenu --prompt 'Share: '";
          };
        };
      };
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
          screenshotFullScript = pkgs.writeShellScript "river-screenshot-full" (
            builtins.readFile ./screenshot-full.sh
          );
          initScript = pkgs.writeShellScript "river-init" (
            builtins.replaceStrings
              [ "WALLPAPER_PATH" "SCREENSHOT_SCRIPT" "SCREENSHOT_FULL_SCRIPT" "POLKIT_AGENT" ]
              [
                "${./terra-nova-everforest.jpg}"
                "${screenshotScript}"
                "${screenshotFullScript}"
                "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
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
                wlopm
                swayidle
                grim
                slurp
                satty
                wl-clip-persist
                wl-clipboard
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
