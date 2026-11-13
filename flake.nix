{
  description = "Abel's dendritic nix config";

  inputs = {
    # System
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    preservation.url = "github:nix-community/preservation";
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-secrets = {
      url = "git+ssh://git@github.com/Orysse/nix-secrets";
      flake = false;
    };
    ohmyzsh = {
      url = "github:ohmyzsh/ohmyzsh";
      flake = false;
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Claude Code plugins, pinned by commit (see modules/flavors/ai)
    claude-plugins-official = {
      url = "github:anthropics/claude-plugins-official/fa4eb54397ee2faccb6940512a19c017cb1337f3";
      flake = false;
    };
    claude-code-ref = {
      url = "github:anthropics/claude-code/26382c08758260c9f5deb2019d8fe851f89fa9ae";
      flake = false;
    };
    egm = {
      url = "github:google/elephant-goldfish-model/113a3afc44e8f4f54722d7150d5701f65cc8ef7f";
      flake = false;
    };
    ponytail = {
      url = "github:DietrichGebert/ponytail/96608e078b2d5ea607c5c3b8b5a54d1c1fba6846";
      flake = false;
    };
    humanizer = {
      url = "github:blader/humanizer/0ef9fe5bc3572734fd3ae6c448fe00a30cd5dcf0";
      flake = false;
    };

    # Flake parts
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    wrappers.url = "github:BirdeeHub/nix-wrapper-modules";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
