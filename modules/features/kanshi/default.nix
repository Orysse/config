{...}: {
  flake.nixosModules.kanshi = {pkgs, ...}: {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "kanshi" ''
        exec ${pkgs.kanshi}/bin/kanshi -c ${./config} "$@"
      '')
    ];
  };
}
