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
        extra-substituters = [ "https://nix-community.cachix.org" ];
        extra-trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs"
        ];
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
