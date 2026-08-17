{
  inputs,
  moduleWithSystem,
  ...
}:
{
  flake.nixosModules.wob = moduleWithSystem (
    { self', ... }: { ... }: {
      environment.systemPackages = [
        self'.packages.wob
        self'.packages.wob-daemon
        self'.packages.osd-volume
        self'.packages.osd-brightness
      ];
    }
  );

  perSystem =
    {
      pkgs,
      self',
      ...
    }:
    let
      config = pkgs.writeText "wob.ini" ''
        timeout = 1000
        max = 100
        width = 400
        height = 40
        border_offset = 4
        border_size = 4
        bar_padding = 4
        anchor = bottom
        margin = 88
        border_color = 3d484dff
        background_color = 2d353bff
        bar_color = a7c080ff

        [style.brightness]
        bar_color = dbbc7fff
      '';
    in
    {
      packages.wob = inputs.wrappers.lib.wrapPackage [
        { inherit pkgs; }
        {
          package = pkgs.wob;
          flags."-c" = config;
        }
      ];

      packages.osd-volume = pkgs.writeShellApplication {
        name = "osd-volume";
        runtimeInputs = [
          pkgs.wireplumber
          pkgs.gawk
        ];
        text = builtins.readFile ./osd-volume.sh;
      };

      packages.osd-brightness = pkgs.writeShellApplication {
        name = "osd-brightness";
        runtimeInputs = [ pkgs.brightnessctl ];
        text = builtins.readFile ./osd-brightness.sh;
      };

      packages.wob-daemon = pkgs.writeShellApplication {
        name = "wob-daemon";
        runtimeInputs = [
          pkgs.coreutils
          self'.packages.wob
        ];
        text = builtins.readFile ./wob-daemon.sh;
      };
    };
}
