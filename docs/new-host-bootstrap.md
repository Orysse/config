# New host bootstrap

Runbook for bringing up a brand new machine in this flake, from a blank disk to a fully
booted, secrets-decrypting, impermanence-correct NixOS system. This covers disk setup,
passwords, and secrets — for the Secure Boot / measured boot / TPM2 LUKS phase that comes
after the host is up and booting normally, see
[secure-boot-enrollment.md](./secure-boot-enrollment.md).

## 1. Partition and install

Boot a NixOS live ISO on the target machine.

```bash
sudo nix run github:nix-community/disko -- --mode disko --flake .#<host>
```

Uses the host's `_disko.nix` (copy `modules/hosts/thinkpad/_disko.nix` as a starting point —
same GPT/ESP/LUKS/btrfs layout, just change `disk.main.device`). This partitions, formats,
opens LUKS, and mounts everything under `/mnt`.

Generate hardware config for the new machine:

```bash
sudo nixos-generate-config --no-filesystems --root /mnt
```

Take the `hardware-configuration.nix` it writes to `/mnt/etc/nixos/`, trim it down to match
the style of `modules/hosts/thinkpad/_hardware.nix` (kernel modules, `hostPlatform`,
microcode toggle — disko already owns the filesystem definitions, so drop those), and save it
as `modules/hosts/<host>/_hardware.nix`.

Add a `modules/hosts/<host>/default.nix` matching `modules/hosts/thinkpad/default.nix`'s
shape (`flake.nixosConfigurations.<host> = inputs.nixpkgs.lib.nixosSystem { modules = ...; }`),
picking whichever flavors/features this host actually needs.

## 2. Password hashes — before first boot

`users.mutableUsers = false` and both `abel` and `root` use `hashedPasswordFile` pointing at
`/persistent/passwords/{abel,root}` (`modules/system/core/user.nix`) — nothing in the repo
ever contains a password or hash. Those files have to exist on `/persistent` *before* first
boot, or the accounts come up locked with no way to log in.

```bash
nix run nixpkgs#mkpasswd -- -m sha-512
```

Run it once for `abel`, once for `root`. While still in the live ISO with the target mounted
at `/mnt`:

```bash
sudo mkdir -p /mnt/persistent/passwords
sudo install -m 0600 /dev/stdin /mnt/persistent/passwords/abel <<< '<hash from mkpasswd>'
sudo install -m 0600 /dev/stdin /mnt/persistent/passwords/root <<< '<hash from mkpasswd>'
```

## 3. Register the new host as a secrets recipient

Secrets are decrypted two ways: the host's own SSH host key (automatic, at boot) and abel's
YubiKey (manual/emergency) — see `modules/flavors/secrets/default.nix` and the `.sops.yaml`
in the separate `nix-secrets` repo. A brand new host isn't a valid recipient for anything
yet, so any secrets it needs (`flavors.secrets.srs`/`.forge` etc.) will fail to decrypt until
it's added.

```bash
sudo nixos-install --root /mnt --flake .#<host> --no-root-passwd
```

installs without touching passwords (already handled in step 2) and generates the host's SSH
host keys under `/mnt/etc/ssh/`. Get the new host's age-converted public key:

```bash
nix run nixpkgs#ssh-to-age -- -i /mnt/etc/ssh/ssh_host_ed25519_key.pub
```

In the `nix-secrets` checkout, add it to `.sops.yaml`:

```yaml
keys:
  - &thinkpad age1wln3h7pv5qd799kek4dmnwv2at99p5raeqqlf6g0lquka86qyupspmd2hv
  - &<host> age1...                      # the key you just derived
```

and add `*<host>` to the `key_groups` of whichever `creation_rules` entries this host should
be able to decrypt (mirror how `*thinkpad` is used — narrowly for `user-age-key.yaml`,
broadly for everything else, depending on what the host needs). Then re-key every secret file
that rule now covers so the new recipient can actually decrypt it:

```bash
sops updatekeys secrets/<path>.yaml   # once per affected file
```

Commit and push `nix-secrets`, then from this repo:

```bash
nix flake lock --update-input nix-secrets
```

## 4. First boot

Reboot into the new system. Confirm secrets decrypted automatically via the host key (check
whatever `flavors.secrets` wired up — e.g. `ls /etc/wireguard/`, `~/.kube/configs/`). If you
need the YubiKey emergency path, that's `sops.age.keyFile`/`age-plugin-yubikey`, already wired
generically in `modules/flavors/secrets/default.nix` — no per-host setup needed there beyond
having the YubiKey itself.

At this point the host is a normal, working NixOS system on whatever bootloader `_disko.nix`
+ the host's boot module gave it (likely plain `boot.loader.systemd-boot` or `grub` until you
deliberately opt it into `bootloader` / lanzaboote). Continue with
[secure-boot-enrollment.md](./secure-boot-enrollment.md) whenever you're ready for that.
