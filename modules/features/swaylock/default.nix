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
      settings = {
        color = "2d353b";
        indicator-idle-visible = false;
        indicator-radius = 100;
        indicator-thickness = 7;
        inside-color = "2d353b";
        text-color = "859289";
        ring-color = "3d484d";
        ring-ver-color = "a7c080";
        ring-wrong-color = "e67e80";
        key-hl-color = "a7c080";
      };
    };
  };
}
