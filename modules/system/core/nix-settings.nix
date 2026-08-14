{ ... }:
{
  flake.nixosModules.nix =
    { ... }:
    {
      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        warn-dirty = false;
      };
      nixpkgs.config.allowUnfree = true;
      programs.nh = {
        enable = true;
        flake = "/home/abel/config";
        clean = {
          enable = true;
          dates = "05:00";
          extraArgs = "--keep 5 --keep-since 8d";
        };
      };
    };
}
