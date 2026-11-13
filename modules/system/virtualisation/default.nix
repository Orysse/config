{
  self,
  ...
}:
{
  flake.nixosModules.labHost =
    { config, pkgs, ... }:
    {
      virtualisation.libvirtd = {
        enable = true;
        qemu.swtpm.enable = true;
      };

      programs.virt-manager.enable = true;

      users.users.${config.user.name}.extraGroups = [ "libvirtd" ];

      environment.systemPackages = with pkgs; [
        qemu
        swtpm
      ];
    };
}
