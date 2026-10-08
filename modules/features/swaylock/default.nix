{
  inputs,
  moduleWithSystem,
  ...
}:
{
  flake.nixosModules.swaylock = moduleWithSystem (
    { self', ... }: { ... }: {
      environment.systemPackages = [ self'.packages.swaylock ];
      security.pam.services.swaylock = { };
    }
  );
  perSystem = { pkgs, ... }: {
    packages.swaylock = inputs.wrappers.wrappers.swaylock.wrap {
      inherit pkgs;
      package = pkgs.swaylock.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./fingerprint.patch ];
      });
      flags."--fingerprint" = true;
      settings = {
        color = "2d353b";
        indicator-idle-visible = true;
        indicator-radius = 100;
        indicator-thickness = 7;
        font = "IosevkaTerm Nerd Font Mono";
        font-size = 28;

        inside-color = "2d353b";
        inside-ver-color = "2d353b";
        inside-wrong-color = "2d353b";
        inside-caps-lock-color = "2d353b";

        text-color = "859289";
        text-ver-color = "a7c080";
        text-wrong-color = "e67e80";
        text-caps-lock-color = "dbbc7f";

        ring-color = "3d484d";
        ring-ver-color = "a7c080";
        ring-wrong-color = "e67e80";
        ring-caps-lock-color = "dbbc7f";

        key-hl-color = "a7c080";
        bs-hl-color = "e67e80";

        separator-color = "3d484d";
        indicator-caps-lock = true;

        layout-bg-color = "2d353bcc";
        layout-border-color = "3d484d";
        layout-text-color = "859289";
      };
    };
  };
}
