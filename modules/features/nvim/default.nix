{
  inputs,
  moduleWithSystem,
  ...
}:
{
  flake.nixosModules.nvim = moduleWithSystem (
    { self', ... }:
    {
      config,
      lib,
      ...
    }:
    {
      options.programs.nvim.java.enable = lib.mkEnableOption "Java/jdtls support in nvim";
      config.environment.systemPackages = [
        (if config.programs.nvim.java.enable then self'.packages.nvim-java else self'.packages.nvim)
      ];
    }
  );

  perSystem =
    {
      pkgs,
      lib,
      ...
    }:
    let
      baseSpecs = {
        everforest.data = pkgs.vimPlugins.everforest;
        blink-cmp.data = pkgs.vimPlugins.blink-cmp;
        friendly-snippets.data = pkgs.vimPlugins.friendly-snippets;
        mini-nvim.data = pkgs.vimPlugins.mini-nvim;
        flash-nvim.data = pkgs.vimPlugins.flash-nvim;
        render-markdown-nvim.data = pkgs.vimPlugins.render-markdown-nvim;
        undotree.data = pkgs.vimPlugins.undotree;
        treesitter.data = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
        conform-nvim.data = pkgs.vimPlugins.conform-nvim;
        gitsigns-nvim.data = pkgs.vimPlugins.gitsigns-nvim;
        fidget-nvim.data = pkgs.vimPlugins.fidget-nvim;
        schemastore-nvim.data = pkgs.vimPlugins.SchemaStore-nvim;
        nvim-lspconfig.data = pkgs.vimPlugins.nvim-lspconfig;
        trouble-nvim.data = pkgs.vimPlugins.trouble-nvim;
        oil-nvim.data = pkgs.vimPlugins.oil-nvim;
        snacks-nvim.data = pkgs.vimPlugins.snacks-nvim;
        ansible-vim.data = pkgs.vimPlugins.ansible-vim;
      };

      javaSpecs = {
        nvim-jdtls.data = pkgs.vimPlugins.nvim-jdtls;
      };

      runtimeTools = with pkgs; [
        wl-clipboard
        ripgrep
        lua-language-server
        nixd
        typescript-language-server
        vscode-langservers-extracted
        pyright
        gopls
        clang-tools
        rust-analyzer
        haskell-language-server
        ocamlPackages.ocaml-lsp
        powershell-editor-services
        powershell
        cmake-language-server
        tofu-ls
        helm-ls
        yaml-language-server
        ansible-language-server
        bicep-lsp
        postgres-language-server
        black
        isort
        nixfmt
        ocamlformat
        prettierd
        eslint_d
        stylua
        shellcheck
        shfmt
        shellharden
        jq
        bicep
        rustfmt
      ];

      javaRuntimeTools = with pkgs; [
        jdt-language-server
        jdk
      ];

      mkNvim =
        {
          java ? false,
        }:
        inputs.wrappers.wrappers.neovim.wrap {
          inherit pkgs;
          specs = baseSpecs // (lib.optionalAttrs java javaSpecs);
          runtimePkgs = runtimeTools ++ (lib.optionals java javaRuntimeTools);
          settings = {
            block_normal_config = false;
            config_directory = ./.;
          };
          info = {
            inherit java;
            powershellBundlePath = "${pkgs.powershell-editor-services}/lib/powershell-editor-services";
          };
        };
    in
    {
      packages.nvim = mkNvim { };
      packages.nvim-java = mkNvim { java = true; };
    };
}
