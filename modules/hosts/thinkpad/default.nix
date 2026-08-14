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
      yubikey
      gpg
      ai
      # dev
      infra
      # security
    ];
  };
}
