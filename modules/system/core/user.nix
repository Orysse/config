{ self, ... }:
{
  flake.nixosModules.user =
    { ... }:
    let
      modules = with self.nixosModules; [
        zsh
      ];
    in
    {
      imports = modules;
      users.mutableUsers = false;
      users.users.abel = {
        isNormalUser = true;
        description = "abel";
        extraGroups = [
          "wheel"
          "networkmanager"
          "plugdev"
        ];
        hashedPasswordFile = "/persistent/passwords/abel";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP1sdw0bh/AvoLRvvTgIWOSXQ5hTyiHWnSV9GOZVI2Tt abel@thinkpad"
        ];
      };
      users.users.root.hashedPasswordFile = "/persistent/passwords/root";
    };
}
