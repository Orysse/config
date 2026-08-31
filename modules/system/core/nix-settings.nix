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
        extra-substituters = [
          "https://nix-community.cachix.org"
          "https://s3.cri.epita.fr/cri-nix-cache.s3.cri.epita.fr"
        ];
        extra-trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs"
          "cache.nix.cri.epita.fr:qDIfJpZWGBWaGXKO3wZL1zmC+DikhMwFRO4RVE6VVeo="
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
