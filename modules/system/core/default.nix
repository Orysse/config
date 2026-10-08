{ self, inputs, ... }:
{
  flake.nixosModules.core =
    { pkgs, ... }:
    let
      modules = with self.nixosModules; [
        user
        bootloader
        nix
        locale
        zram
      ];
    in
    {
      imports = modules ++ [ inputs.nix-index-database.nixosModules.nix-index ];
      services.openssh.enable = true;
      programs.nix-index-database.enable = true;
      programs.nix-index-database.comma.enable = true;
      programs.nix-index.enableZshIntegration = false;
      programs.nix-index.enableBashIntegration = false;
      environment.systemPackages = with pkgs; [
        eza
        fd
        git
        lsof
        ripgrep
        sbctl
        unzip
        usbutils
        wget
        zoxide
      ];
      system.stateVersion = "26.05";
    };
}
