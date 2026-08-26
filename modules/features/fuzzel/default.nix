{
  inputs,
  moduleWithSystem,
  ...
}:
{
  flake.nixosModules.fuzzel = moduleWithSystem (
    { self', ... }:
    { ... }:
    {
      environment.systemPackages = [ self'.packages.fuzzel ];
    }
  );
  perSystem =
    { pkgs, ... }:
    {
      packages.fuzzel = inputs.wrappers.wrappers.fuzzel.wrap {
        inherit pkgs;
        settings = {
          colors = {
            background = "2d353bff";
            text = "d3c6aaff";
            match = "a7c080ff";
            selection = "3d484dff";
            selection-text = "d3c6aaff";
            selection-match = "a7c080ff";
            border = "a7c080ff";
          };
        };
      };
    };
}
