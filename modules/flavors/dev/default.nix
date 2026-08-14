{ ... }: {
  flake.nixosModules.dev = { pkgs, ... }: {
    programs.nvim.java.enable = true;

    environment.systemPackages = with pkgs; [
      jdk
      maven
      gradle

      gcc
      gnumake
      cmake

      ocaml
      dune_3
      opam

      python3
      uv

      nodejs
      typescript
      pnpm

      postgresql
    ];
  };
}
