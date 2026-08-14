{
  inputs,
  moduleWithSystem,
  ...
}:
{
  flake.nixosModules.kitty = moduleWithSystem (
    { self', ... }:
    { pkgs, ... }:
    {
      environment.systemPackages = with self'.packages; [
        kitty
      ];
      fonts.packages = [ pkgs.nerd-fonts.iosevka-term pkgs.nerd-fonts.symbols-only ];
    }
  );
  perSystem =
    { pkgs, ... }:
    {
      packages.kitty = inputs.wrappers.wrappers.kitty.wrap {
        inherit pkgs;
        font = {
          name = "IosevkaTerm Nerd Font Mono";
          size = 16;
        };
        themeFile = "everforest_dark_medium";
        extraConfig = builtins.readFile ./kitty.conf;
      };
    };
}
