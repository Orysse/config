{ ... }: {
  flake.nixosModules.infra = { pkgs, ... }: {
    virtualisation.podman.enable = true;

    environment.systemPackages = with pkgs; [
      kubectl
      kubectx
      k9s
      kubernetes-helm
      fluxcd
      kubelogin-oidc     # kubectl oidc-login (homelab: login through Pocket-ID)

      opentofu
      ansible

      openstackclient

      nmap
      mtr
      bind

      lazydocker
    ];
  };
}
