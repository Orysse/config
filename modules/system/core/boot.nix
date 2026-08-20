{ inputs, ... }: {
  flake.nixosModules.bootloader = { lib, ... }: {
    imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

    boot.loader.grub.enable = false;
    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.timeout = 2;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      measuredBoot = {
        enable = true;
        pcrs = [
          0
          4
          7
        ];
        pcrlockPolicy = "/var/lib/pcrlock.d/pcrlock.json";
      };
      configurationLimit = 8; # required cap when measuredBoot is on: systemd-pcrlock hard-limits to 8 generations (enforced by an assertion, not just a doc suggestion)
    };

    boot.initrd.luks.devices.cryptroot.crypttabExtraOpts = [ "tpm2-device=auto" ];

    boot.initrd.systemd.enable = true;
    boot.tmp.useTmpfs = true;
  };
}
