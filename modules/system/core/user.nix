{ self, ... }:
{
  flake.nixosModules.user =
    { config, lib, ... }:
    let
      modules = with self.nixosModules; [
        zsh
      ];
      name = config.user.name;
    in
    {
      imports = modules;

      # The machine's main user, for the modules that need it (config.user.name).
      options.user.name = lib.mkOption {
        type = lib.types.str;
        default = "abel";
        description = "Login of the machine's main user.";
      };

      config = {
        users.mutableUsers = false;
        users.users.${name} = {
          isNormalUser = true;
          description = name;
          extraGroups = [
            "wheel"
            "networkmanager"
            "plugdev"
          ];
          hashedPasswordFile = "/persistent/passwords/${name}";
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP1sdw0bh/AvoLRvvTgIWOSXQ5hTyiHWnSV9GOZVI2Tt abel@thinkpad"
          ];
        };
        users.users.root.hashedPasswordFile = "/persistent/passwords/root";
      };
    };
}
