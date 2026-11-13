{ inputs, ... }: {
  flake.nixosModules.secrets =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.flavors.secrets;
      secretsRoot = inputs.nix-secrets + "/secrets";

      discoverYaml =
        dir:
        if builtins.pathExists dir then
          lib.pipe (builtins.readDir dir) [
            builtins.attrNames
            (builtins.filter (lib.hasSuffix ".yaml"))
            (map (lib.removeSuffix ".yaml"))
          ]
        else
          [ ];

      openstackCreds = lib.optionals cfg.srs (discoverYaml (secretsRoot + "/srs/openstack"));
      k8sConfigs = lib.optionals cfg.forge (discoverYaml (secretsRoot + "/forge/k8s"));
    in
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];

      options.flavors.secrets = {
        srs = lib.mkEnableOption "SRS secrets (OpenStack credentials ; tunnels WireGuard : flavors.wireguard)";
        forge = lib.mkEnableOption "Forge secrets (k8s kubeconfigs)";
      };

      config = lib.mkMerge [
        {
          environment.systemPackages = [ pkgs.sops ];

          sops.age.plugins = [ pkgs.age-plugin-yubikey ];
          sops.age.keyFile = "/etc/age/yubikey-identity.txt";
          # Secrets are installed in the initrd, before impermanence restores
          # /etc/ssh: read the host key from the persistent volume directly.
          sops.age.sshKeyPaths = [ "/persistent/etc/ssh/ssh_host_ed25519_key" ];
          environment.etc."age/yubikey-identity.txt".source = secretsRoot + "/yubikey-identity.txt";
        }

        (lib.mkIf (openstackCreds != [ ]) {
          sops.secrets = lib.listToAttrs (
            map (
              name:
              lib.nameValuePair "openstack/${name}" {
                sopsFile = secretsRoot + "/srs/openstack/${name}.yaml";
                key = "config";
                path = "/home/abel/.config/openstack/${name}.yaml";
                owner = "abel";
                mode = "0600";
              }
            ) openstackCreds
          );
        })

        (lib.mkIf (k8sConfigs != [ ]) {
          sops.secrets = lib.listToAttrs (
            map (
              name:
              lib.nameValuePair "k8s/${name}" {
                sopsFile = secretsRoot + "/forge/k8s/${name}.yaml";
                key = "config";
                path = "/home/abel/.kube/configs/${name}";
                owner = "abel";
                mode = "0600";
              }
            ) k8sConfigs
          );
        })
      ];
    };
}
