{
  self,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.thinkpad = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      desktop
      impermanence
      thinkpadConfiguration
      secrets
      wireguard
      yubikey
      gpg
      fprint
      ai
      # dev
      infra
      # security
      gaming
    ];
  };
}
