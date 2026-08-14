{ ... }: {
  flake.nixosModules.bootloader = { ... }: {
    boot = {
      loader = {
        timeout = 2;
        efi.canTouchEfiVariables = true;
        grub = {
          enable = true;
          efiSupport = true;
          device = "nodev";
          font = null;
          splashImage = null;
          extraConfig = ''
            set color_normal=white/black
            set color_highlight=black/white
            set menu_color_normal=white/black
            set menu_color_highlight=black/white
          '';
        };
      };
      initrd.systemd.enable = true;
      tmp.useTmpfs = true;
    };
  };
}
