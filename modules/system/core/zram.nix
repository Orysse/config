{ ... }: {
  flake.nixosModules.zram = { ... }: {
    # Compressed swap in RAM only — nothing ever touches the LUKS-encrypted
    # disk, so there's no at-rest exposure to consider (unlike a swapfile,
    # which would otherwise need to live on the encrypted volume).
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
    };

    # Default (60) is tuned for slow disk swap. zram is cheap to use
    # compared to real disk, so prefer it over reclaiming file cache.
    boot.kernel.sysctl."vm.swappiness" = 180;
  };
}
