{
  inputs,
  moduleWithSystem,
  ...
}:
{
  flake.nixosModules.kanshi = moduleWithSystem (
    { self', ... }:
    { ... }:
    {
      environment.systemPackages = [ self'.packages.kanshi ];
    }
  );
  perSystem =
    { pkgs, ... }:
    {
      packages.kanshi = inputs.wrappers.lib.wrapPackage [
        { inherit pkgs; }
        {
          package = pkgs.kanshi;
          flags."-c" = ./config;
        }
      ];
    };
}
