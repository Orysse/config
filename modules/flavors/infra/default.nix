{...}: {
  flake.nixosModules.infra = {pkgs, ...}: {
    virtualisation.podman.enable = true;

    environment.systemPackages = with pkgs; [
      kubectl
      kubectx
      k9s
      kubernetes-helm

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
