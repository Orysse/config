{ ... }: {
  flake.nixosModules.network = { ... }: {
    networking = {
      networkmanager = {
        enable = true;
        dns = "systemd-resolved";
      };
      firewall.enable = true;
      nameservers = [
        "1.1.1.1"
        "8.8.8.8"
      ];
    };

    services.resolved.enable = true;
  };
}
