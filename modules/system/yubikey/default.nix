{ ... }: {
  flake.nixosModules.yubikey = { pkgs, ... }: {
    services.pcscd.enable = true;
    services.udev.packages = [
      pkgs.yubikey-personalization
      pkgs.libu2f-host
    ];

    environment.systemPackages = with pkgs; [
      yubikey-manager
      yubikey-personalization
      yubioath-flutter
      age-plugin-yubikey
    ];
  };
}
