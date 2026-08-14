{
  inputs,
  moduleWithSystem,
  ...
}:
{
  flake.nixosModules.starship = moduleWithSystem (
    { self', ... }:
    { ... }:
    {
      environment.systemPackages = [ self'.packages.starship ];
    }
  );
  perSystem =
    { pkgs, ... }:
    {
      packages.starship = inputs.wrappers.wrappers.starship.wrap {
        inherit pkgs;
        settings = {
          palette = "everforest";
          scan_timeout = 10;

          character = {
            success_symbol = "[❯](accent)";
            error_symbol = "[❯](red)";
            vimcmd_symbol = "[❯](green)";
          };
          directory.style = "bold accent";
          nix_shell = {
            disabled = false;
            format = "[$symbol](bold accent) ";
            symbol = "󱄅 ";
          };

          palettes.everforest = {
            base00 = "#2d353b";
            base01 = "#343f44";
            base02 = "#3d484d";
            base03 = "#475258";
            base04 = "#7a8478";
            base05 = "#859289";
            base06 = "#9da9a0";
            base07 = "#d3c6aa";
            red = "#e67e80";
            orange = "#e69875";
            yellow = "#dbbc7f";
            green = "#a7c080";
            aqua = "#83c092";
            blue = "#7fbbb3";
            purple = "#d699b6";
            accent = "#a7c080";
          };
        };
      };
    };
}
