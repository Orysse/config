{ ... }:
{
  flake.nixosModules.gaming =
    { pkgs, ... }:
    {
      hardware.graphics.enable32Bit = true;

      nixpkgs.config.allowUnfreePredicate =
        pkg:
        builtins.elem (pkgs.lib.getName pkg) [
          "steam"
          "steam-original"
          "steam-run"
          "steam-unwrapped"
        ];

      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        gamescopeSession.enable = true;
      };

      programs.gamemode.enable = true;
    };
}
