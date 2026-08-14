{...}: {
  flake.nixosModules.ai = {pkgs, ...}: {
    environment.systemPackages = [pkgs.claude-code];
  };
}
