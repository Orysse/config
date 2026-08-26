{ inputs, ... }: {
  flake.nixosModules.thinkpadConfiguration = { ... }: {
    imports = [
      inputs.disko.nixosModules.default
      ./_hardware.nix
      ./_disko.nix
    ];

    networking.hostName = "thinkpad";

    hardware.graphics.enable = true;
    hardware.enableRedistributableFirmware = true;
    environment.sessionVariables.LIBVA_DRIVER_NAME = "radeonsi";

    flavors.secrets.srs = true;
    flavors.secrets.forge = true;
  };
}
