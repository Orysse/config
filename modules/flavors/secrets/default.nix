{inputs, ...}: {
  flake.nixosModules.secrets = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.flavors.secrets;
    secretsRoot = inputs.nix-secrets + "/secrets";

    discoverYaml = dir:
      if builtins.pathExists dir
      then
        lib.pipe (builtins.readDir dir) [
          builtins.attrNames
          (builtins.filter (lib.hasSuffix ".yaml"))
          (map (lib.removeSuffix ".yaml"))
        ]
      else [];

    wireguardTunnels = lib.optionals cfg.srs (discoverYaml (secretsRoot + "/srs/wireguard"));
    openstackCreds = lib.optionals cfg.srs (discoverYaml (secretsRoot + "/srs/openstack"));
    k8sConfigs = lib.optionals cfg.forge (discoverYaml (secretsRoot + "/forge/k8s"));
  in {
    imports = [inputs.sops-nix.nixosModules.sops];

    options.flavors.secrets = {
      srs = lib.mkEnableOption "SRS secrets (WireGuard tunnels + OpenStack credentials)";
      forge = lib.mkEnableOption "Forge secrets (k8s kubeconfigs)";
    };

    config = lib.mkMerge [
      {
        environment.systemPackages = [pkgs.sops];

        sops.age.plugins = [pkgs.age-plugin-yubikey];
        sops.age.keyFile = "/etc/age/yubikey-identity.txt";
        environment.etc."age/yubikey-identity.txt".source = secretsRoot + "/yubikey-identity.txt";
      }

      (lib.mkIf (wireguardTunnels != []) {
        environment.systemPackages = [pkgs.wireguard-tools];

        sops.secrets = lib.listToAttrs (map (
            name:
              lib.nameValuePair "wireguard/${name}" {
                sopsFile = secretsRoot + "/srs/wireguard/${name}.yaml";
                key = "config";
                path = "/etc/wireguard/${name}.conf";
                mode = "0400";
              }
          )
          wireguardTunnels);

        systemd.services = lib.listToAttrs (map (
            name:
              lib.nameValuePair "wg-quick-${name}" {
                description = "WireGuard tunnel ${name}";
                after = ["network-online.target" "nss-lookup.target"];
                wants = ["network-online.target"];
                wantedBy = [];
                path = with pkgs; [wireguard-tools iproute2 iptables procps];
                environment.WG_ENDPOINT_RESOLUTION_RETRIES = "infinity";
                serviceConfig = {
                  Type = "oneshot";
                  RemainAfterExit = true;
                  ExecStart = "${pkgs.wireguard-tools}/bin/wg-quick up /etc/wireguard/${name}.conf";
                  ExecStop = "${pkgs.wireguard-tools}/bin/wg-quick down /etc/wireguard/${name}.conf";
                };
              }
          )
          wireguardTunnels);
      })

      (lib.mkIf (openstackCreds != []) {
        sops.secrets = lib.listToAttrs (map (
            name:
              lib.nameValuePair "openstack/${name}" {
                sopsFile = secretsRoot + "/srs/openstack/${name}.yaml";
                key = "config";
                path = "/home/abel/.config/openstack/${name}.yaml";
                owner = "abel";
                mode = "0600";
              }
          )
          openstackCreds);
      })

      (lib.mkIf (k8sConfigs != []) {
        sops.secrets = lib.listToAttrs (map (
            name:
              lib.nameValuePair "k8s/${name}" {
                sopsFile = secretsRoot + "/forge/k8s/${name}.yaml";
                key = "config";
                path = "/home/abel/.kube/configs/${name}";
                owner = "abel";
                mode = "0600";
              }
          )
          k8sConfigs);
      })
    ];
  };
}
