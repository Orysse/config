{ ... }: {
    flake.nixosModules.security = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      gdb
      gef
      radare2
      binwalk
      checksec
      strace
      ltrace
      (python3.withPackages (ps: [ ps.pwntools ]))

      john
      hashcat

      nmap
      wireshark-cli

      exiftool
      steghide

      sqlmap
      yara
    ];
  };
}
