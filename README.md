# thinkpad — dendritic NixOS config

This repository contains the NixOS configuration for my primary machine (`thinkpad`). The purpose of this document is to present the architectural choices and technologies involved: the dendritic pattern used to compose modules, the decision to forgo home-manager in favor of declarative wrappers, disk partitioning handled entirely through Nix, explicit persistence over a tmpfs root filesystem, and the handling of encrypted secrets.

## Screenshot

![tmux-nvim](./.github/screenshot.jpg)

## Dendritic pattern

The configuration follows the dendritic pattern: every `.nix` file under `modules/` is automatically loaded as a top-level flake-parts module via [import-tree](https://github.com/vic/import-tree). There is no centralized import list to maintain — a file becomes part of the flake by the mere fact of existing in the tree, and contributes to `flake.nixosModules.*` and/or `perSystem` depending on which systems or hosts actually make use of it. Files prefixed with `_` (`_hardware.nix`, `_disko.nix`) are the one exception: import-tree skips them, and they are imported explicitly by the single host that needs them.

```
modules/
├─ parts.nix     flake-parts systems (x86_64-linux)
├─ features/     one application per folder — a perSystem package plus the nixosModule installing it
├─ system/       infrastructure with no user-facing binary: boot, users, network, impermanence
├─ flavors/      optional profiles a host may choose to enable (dev tooling, security tooling, secrets, ...)
└─ hosts/        flake.nixosConfigurations.<name>, built by composing the elements above
```

## Every component runs independently

Since each feature is its own `perSystem` package, no full system rebuild is required to inspect or use it:

```bash
nix run .#kitty        # run the wrapped terminal standalone, independent of the rest of the NixOS config
nix build .#zsh         # build only the wrapped shell package and inspect its store output
nix build .#nixosConfigurations.thinkpad.config.system.build.toplevel  # the full system closure
```

`nix run .#<feature>` works for every wrapped application under `modules/features/` — kitty, zsh, tmux, nvim, waybar, fuzzel, git, starship, swaylock, among others. Each one is a real derivation with no hidden dependency on the rest of the system configuration, which is also what makes `nix flake check` meaningful: the command evaluates and type-checks every module and every package independently, not only the targeted host.

## Declarative configuration, no dotfiles

Each application's configuration is done by wrapping its binary via [nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules), rather than with home-manager. A wrapper module takes structured Nix options (or directly a configuration string) as input, renders the actual configuration file into the Nix store, and produces a wrapped binary pointing at that file — so `pkgs.kitty` in this repository is not the upstream kitty package, but kitty pre-configured to point at a store path containing exactly this repository's `kitty.conf`. Where no wrapper module exists for a given application (sway, kanshi, wob), the same principle is applied by hand: `pkgs.writeText`/`pkgs.writeShellScriptBin` bake a configuration file or launcher script directly into the store. No file is generated in `$HOME` at runtime, and no dotfile is expected to pre-exist.

`modules/features/nvim/` is the most developed example of this principle: nix-wrapper-modules' neovim module follows the nixCats convention — Nix handles only plugin packaging and dependency injection (`specs`), while `modules/features/nvim/lua/` is genuine hand-written Lua, loaded directly from the store via `block_normal_config = false`. Two build outputs (`nvim`, `nvim-java`) are produced from the same Lua configuration, with a different Nix-side plugin set depending on whether the `dev` flavor is enabled.

## disko: the partition table as declarative data

`hosts/thinkpad/_disko.nix` declares the entire partitioning scheme as data — [disko](https://github.com/nix-community/disko) translates that declaration into the actual partitioning, formatting, and mounting commands. The layout used on this machine: a GPT table, a 1G FAT32 ESP, then a LUKS container holding a single btrfs volume split into `nix` and `persistent` subvolumes (zstd compression, `noatime`), with `/` itself mounted directly as tmpfs with no underlying partition at all. No manual `parted`/`cryptsetup`/`mkfs` sequence is involved at any point: the actual state of the disk and the Nix configuration describing it can never drift apart, since they are the same file.

## Impermanence: tmpfs root, explicit persistence

`/` is a tmpfs sized to 25% of available RAM — every boot starts from nothing. Only two things survive: `/nix` (the store, naturally) and `/persistent` (the one real btrfs subvolume), both mounted from the LUKS-encrypted disk. Everything else — `/etc`, `/var`, `/home`, without exception — is rebuilt in full by NixOS activation on every boot, then disappears on the next one.

`modules/system/impermanence/default.nix`, via [preservation](https://github.com/nix-community/preservation), is the single exhaustive list of what is actually bind-mounted through from `/persistent`: machine-id, SSH host keys, NetworkManager connections, Bluetooth pairings, and a specific set of directories under `/home/abel` (`.config`, `.ssh`, `.gnupg`, shell history, nvim state, and a few application-specific caches) — each with permissions set explicitly where the default would be wrong (SSH refuses a world-readable host key, GPG refuses an overly permissive keyring directory). Anything not on that list is, by construction, volatile state: installing a package, tweaking a runtime setting, dropping a file outside a persisted directory — none of it survives a reboot unless it is expressed as actual Nix configuration or added to that list. This is a deliberate design choice, not an oversight.

Users are immutable (`users.mutableUsers = false`) for the same reason — password hashes are read from files under `/persistent/passwords/`, never written by `passwd`, so login credentials follow the same declarative path as the rest of the configuration.

## Secrets: dual decryption path, nothing versioned in the clear

Encrypted secrets (WireGuard tunnel configurations, kubeconfigs, cloud credentials) live in a separate private repository, `nix-secrets`, pulled in only as a flake input — never copied into this repository. [sops-nix](https://github.com/Mic92/sops-nix) decrypts them at system activation time, using whichever identity is available: a YubiKey via `age-plugin-yubikey` (manual decryption, confirmed by physical touch), or the host's own SSH host key converted to an age identity (automatic decryption, no touch required at boot). Both are independently valid recipients on every secret, so decryption does not depend on physical presence.

The `secrets` flavor (`modules/flavors/secrets/`) exposes this mechanism as coarse per-directory toggles rather than naming each file individually — enabling `flavors.secrets.srs` triggers automatic discovery of every secret present under that directory in `nix-secrets`, along with the corresponding systemd units and file placements. Adding a new secret to an already-enabled category requires no modification to this repository at all.

## Flavors: optional composition

Modules under `modules/flavors/` are profiles a host chooses to enable, layered on top of `modules/system/desktop` (which every desktop host receives unconditionally). `thinkpad` currently enables `ai` (claude-code), `infra` (kubectl/opentofu/ansible/podman/OpenStack client), `security` (gdb/radare2/pwntools/binwalk — reverse-engineering and pentesting tooling, mostly command-line), and `secrets`. A flavor is, technically, just another `flake.nixosModules.<name>` — what makes it a "flavor" rather than a "feature" is only the fact that a host must enable it explicitly instead of receiving it by default.
