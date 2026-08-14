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
    console.colors = [
      "000000"
      "aa0000"
      "00aa00"
      "aa5500"
      "0000aa"
      "aa00aa"
      "00aaaa"
      "aaaaaa"
      "555555"
      "ff5555"
      "55ff55"
      "ffff55"
      "5555ff"
      "ff55ff"
      "55ffff"
      "ffffff"
    ];
  };
}
