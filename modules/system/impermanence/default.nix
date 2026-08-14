{ inputs, ... }:
{
  flake.nixosModules.impermanence =
    { ... }:
    {
      imports = [
        inputs.preservation.nixosModules.default
      ];

      preservation = {
        enable = true;

        preserveAt."/persistent" = {
          directories = [
            "/var/lib/bluetooth"
            "/var/lib/systemd/backlight"
            "/etc/NetworkManager/system-connections"
            "/var/db/sudo/lectured"
            {
              directory = "/var/lib/nixos";
              inInitrd = true;
            }
            {
              directory = "/var/cache/tuigreet";
              user = "greeter";
              group = "greeter";
            }
          ];

          files = [
            {
              file = "/etc/machine-id";
              inInitrd = true;
            }
            {
              file = "/etc/ssh/ssh_host_ed25519_key";
              mode = "0600";
            }
            "/etc/ssh/ssh_host_ed25519_key.pub"
            {
              file = "/etc/ssh/ssh_host_rsa_key";
              mode = "0600";
            }
            "/etc/ssh/ssh_host_rsa_key.pub"
          ];

          users.abel = {
            directories = [
              "config"
              "Documents"
              "Downloads"
              "Pictures"
              "Videos"
              {
                directory = ".ssh";
                mode = "0700";
              }
              ".config"
              ".local/share/keyrings"
              ".local/share/zsh"
              ".local/share/zoxide"
              ".local/share/nvim"
              ".local/state/nvim"
              ".local/state/wireplumber"
              ".claude"
              ".tmux/resurrect"
              {
                directory = ".gnupg";
                mode = "0700";
              }
            ];
            files = [
              ".claude.json"
            ];
          };
        };
      };

      systemd.services.systemd-machine-id-commit.enable = false;
    };
}
