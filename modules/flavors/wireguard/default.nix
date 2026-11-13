# tunnels     : profils NetworkManager (nmcli connection up <nom>, sans sudo) ; seuls les
#               secrets (private-key, PSK) viennent de nix-secrets.
# wgQuickFiles : .conf wg-quick complets chiffrés, pour un tunnel pas encore migré.
# Nom = nom d'interface : 15 caractères max, préfixe wg- (repéré par waybar).
{ inputs, ... }:
{
  flake.nixosModules.wireguard =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib) mkOption types;
      cfg = config.flavors.wireguard;
      secretsRoot = inputs.nix-secrets + "/secrets";

      secretKeys = t: [ "private-key" ] ++ lib.filter (k: k != null) (map (p: p.presharedKey) t.peers);
      secretName = name: key: "wireguard-${name}-${key}";
      envName = name: key: lib.toUpper (lib.replaceStrings [ "-" ] [ "_" ] "${name}_${key}");

      isV6 = lib.hasInfix ":";
      # Format keyfile NetworkManager : address1, address2…
      numbered = prefix: xs: lib.listToAttrs (lib.imap1 (i: x: lib.nameValuePair "${prefix}${toString i}" x) xs);
      nmList = xs: lib.concatStringsSep ";" xs + ";";

      peerType = types.submodule {
        options = {
          publicKey = mkOption { type = types.str; };
          endpoint = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "vpn.example.com:51820";
          };
          allowedIPs = mkOption {
            type = types.listOf types.str;
            description = "Réseaux routés dans le tunnel. Éviter 192.168.0.0/16 entier : conflits avec les LAN locaux.";
          };
          persistentKeepalive = mkOption {
            type = types.nullOr types.ints.unsigned;
            default = 25;
          };
          presharedKey = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Nom de la clé PSK dans le fichier de secrets du tunnel (null = pas de PSK).";
            example = "preshared-key";
          };
        };
      };

      tunnelType = types.submodule {
        options = {
          address = mkOption {
            type = types.listOf types.str;
            example = [ "10.100.0.2/24" ];
          };
          dns = mkOption {
            type = types.listOf types.str;
            default = [ ];
          };
          secretsFile = mkOption {
            type = types.str;
            description = "Fichier dans nix-secrets/secrets/ : `private-key` (+ PSK nommées par les pairs).";
            example = "wireguard/wg-homelab.yaml";
          };
          peers = mkOption { type = types.listOf peerType; };
        };
      };

      mkProfile =
        name: t:
        let
          v4 = lib.filter (a: !isV6 a) t.address;
          v6 = lib.filter isV6 t.address;
        in
        {
          connection = {
            id = name;
            type = "wireguard";
            interface-name = name;
            autoconnect = false;
          };
          wireguard.private-key = "$" + envName name "private-key";
          ipv4 = (if v4 == [ ] then { method = "disabled"; } else { method = "manual"; } // numbered "address" v4)
            // lib.optionalAttrs (t.dns != [ ]) { dns = nmList t.dns; };
          ipv6 = if v6 == [ ] then { method = "disabled"; } else { method = "manual"; } // numbered "address" v6;
        }
        // lib.listToAttrs (
          map (
            p:
            lib.nameValuePair "wireguard-peer.${p.publicKey}" (
              { allowed-ips = nmList p.allowedIPs; }
              // lib.optionalAttrs (p.endpoint != null) { inherit (p) endpoint; }
              // lib.optionalAttrs (p.persistentKeepalive != null) { persistent-keepalive = p.persistentKeepalive; }
              // lib.optionalAttrs (p.presharedKey != null) {
                preshared-key = "$" + envName name p.presharedKey;
                preshared-key-flags = 0; # stockée dans le profil, pas d'agent de secrets
              }
            )
          ) t.peers
        );
    in
    {
      options.flavors.wireguard = {
        tunnels = mkOption {
          type = types.attrsOf tunnelType;
          default = { };
        };
        wgQuickFiles = mkOption {
          type = types.attrsOf types.str;
          default = { };
          description = "Tunnels hérités : <nom> = fichier dans nix-secrets/secrets/ contenant `config` (.conf wg-quick).";
          example = {
            wg-ars = "srs/wireguard/wg-ars.yaml";
          };
        };
      };

      config = lib.mkMerge [
        {
          assertions = map (name: {
            assertion = lib.stringLength name <= 15;
            message = "flavors.wireguard : « ${name} » dépasse 15 caractères (nom d'interface Linux).";
          }) (lib.attrNames cfg.tunnels ++ lib.attrNames cfg.wgQuickFiles);
        }

        (lib.mkIf (cfg.tunnels != { } || cfg.wgQuickFiles != { }) {
          environment.systemPackages = [ pkgs.wireguard-tools ];
        })

        (lib.mkIf (cfg.tunnels != { }) {
          sops.secrets = lib.listToAttrs (
            lib.concatLists (
              lib.mapAttrsToList (
                name: t:
                map (
                  key:
                  lib.nameValuePair (secretName name key) {
                    sopsFile = secretsRoot + "/${t.secretsFile}";
                    inherit key;
                  }
                ) (secretKeys t)
              ) cfg.tunnels
            )
          );

          # ensureProfiles substitue $NOM dans les profils depuis ce fichier.
          sops.templates."wireguard-networkmanager.env".content = lib.concatStringsSep "\n" (
            lib.concatLists (
              lib.mapAttrsToList (
                name: t:
                map (key: "${envName name key}=${config.sops.placeholder.${secretName name key}}") (secretKeys t)
              ) cfg.tunnels
            )
          );

          networking.networkmanager.ensureProfiles = {
            environmentFiles = [ config.sops.templates."wireguard-networkmanager.env".path ];
            profiles = lib.mapAttrs mkProfile cfg.tunnels;
          };
        })

        (lib.mkIf (cfg.wgQuickFiles != { }) {
          sops.secrets = lib.mapAttrs' (
            name: file:
            lib.nameValuePair "wireguard/${name}.conf" {
              sopsFile = secretsRoot + "/${file}";
              key = "config";
              mode = "0400";
            }
          ) cfg.wgQuickFiles;

          networking.wg-quick.interfaces = lib.mapAttrs (name: _: {
            configFile = config.sops.secrets."wireguard/${name}.conf".path;
            autostart = false;
          }) cfg.wgQuickFiles;

          # L'endpoint peut ne pas être résolvable tant que le réseau n'est pas prêt.
          systemd.services = lib.mapAttrs' (
            name: _: lib.nameValuePair "wg-quick-${name}" { environment.WG_ENDPOINT_RESOLUTION_RETRIES = "infinity"; }
          ) cfg.wgQuickFiles;
        })
      ];
    };
}
