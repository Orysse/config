{ inputs, ... }: {
  flake.nixosModules.thinkpadConfiguration = { config, ... }: {
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

    # VPN du homelab au quotidien : Tailscale, serveur Headscale (https://hs.abe.lc, login
    # Pocket-ID), nuc1 route 192.168.1.192/26. Première fois :
    #   tailscale up --login-server https://hs.abe.lc --accept-routes
    # Ensuite `tailscale up` / `tailscale down`, sans sudo (operator ci-dessous).
    # wg-homelab ci-dessous reste en secours (cluster ou Pocket-ID en panne) : pas les deux
    # en même temps, ils routent le même réseau.
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "client";   # --accept-routes (rp_filter souple)
      extraSetFlags = [ "--operator=${config.user.name}" ];   # pilotable sans sudo
    };

    # Tunnels WireGuard : `nmcli connection up <nom>`. Secrets : nix-secrets/secrets/wireguard/.
    # Réseaux routés à garder disjoints entre tunnels (sinon ils se masquent mutuellement).
    flavors.wireguard.tunnels = {
      # VPN d'administration du homelab (serveur : nuc1, voir homelab-nix/modules/topology).
      # Seulement le homelab (.192-.255) : pas tout 192.168.1.0/24, trop courant ailleurs.
      wg-homelab = {
        address = [ "10.250.0.2/24" ];
        secretsFile = "wireguard/wg-homelab.yaml";
        peers = [
          {
            publicKey = "TNugHNt2qsBT5T/3ac1HWzXFzrw24rWu1l0uCKZhWEM=";
            endpoint = "vpn.abe.lc:51820";
            allowedIPs = [
              "10.250.0.0/24"
              "192.168.1.192/26"
            ];
          }
        ];
      };

      # SRS – cyber range (EPITA).
      wg-cyberrange = {
        address = [ "10.9.0.65/32" ];
        dns = [
          "1.1.1.1"
          "8.8.8.8"
        ];
        secretsFile = "wireguard/wg-cyberrange.yaml";
        peers = [
          {
            publicKey = "RG1t8IPfIZsamJvW6N41wfkqsEQBNfF8aZMVOA5ArHs=";
            endpoint = "vpn.srs.epita.fr:51820";
            allowedIPs = [
              "10.32.0.0/20"
              "10.16.0.0/22"
              "10.100.0.0/24"
            ];
          }
        ];
      };

      # SRS – ARS. Imbriqué : son endpoint (10.32.3.65) n'est joignable que via wg-cyberrange.
      wg-ars = {
        address = [ "192.168.100.2/32" ];
        secretsFile = "wireguard/wg-ars.yaml";
        peers = [
          {
            publicKey = "LC8d9Ikp7R8GfEeuYJVTXDsShrhaWLJY+dUErGFcwys=";
            endpoint = "10.32.3.65:51820";
            allowedIPs = [
              "192.168.100.0/24"
              "192.168.2.0/24"
            ];
          }
        ];
      };

      # SRS – DC02 (avec clé pré-partagée).
      wg-srs-dc02 = {
        address = [ "10.8.0.3/24" ];
        secretsFile = "wireguard/wg-srs-dc02.yaml";
        peers = [
          {
            publicKey = "Wi/aWn9Bj+LWYA3gsqoOHLPObOpVMInX4pvS6km4PlY=";
            presharedKey = "preshared-key";
            endpoint = "78.201.20.167:51821";
            allowedIPs = [ "10.42.67.0/24" ];
          }
        ];
      };
    };
  };
}
