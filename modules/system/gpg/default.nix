{ ... }: {
  flake.nixosModules.gpg = { pkgs, ... }: {
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-curses;
      settings = {
        default-cache-ttl = 3600;
        max-cache-ttl = 86400;
      };
    };

    environment.etc."gnupg/gpg.conf".text = ''
      personal-cipher-preferences AES256 AES192 AES
      personal-digest-preferences SHA512 SHA384 SHA256
      personal-compress-preferences ZLIB BZIP2 ZIP Uncompressed
      default-preference-list SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed
      cert-digest-algo SHA512
      s2k-digest-algo SHA512
      s2k-cipher-algo AES256
      charset utf-8
      keyid-format 0xlong
      with-fingerprint
      list-options show-uid-validity
      verify-options show-uid-validity
      require-cross-certification
      require-secmem
      no-symkey-cache
      throw-keyids
      no-comments
      no-emit-version
      no-greeting
      armor
      use-agent
    '';
  };
}
