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

      # Moonlight's Vulkan renderer crashes river (wp_linux_drm_syncobj error 3); force VAAPI.
      environment.systemPackages = [
        (pkgs.symlinkJoin {
          name = "moonlight-qt";
          paths = [ pkgs.moonlight-qt ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = "wrapProgram $out/bin/moonlight --set FORCE_VAAPI 1";
        })
      ];
    };
}
