# Secure boot / measured boot host enrollment

Runbook for taking a new host from `boot.loader.grub` (or any non-lanzaboote state) to
lanzaboote + Secure Boot + measured boot + TPM2 LUKS auto-unlock, matching what `thinkpad`
runs. The `flake.nixosModules.bootloader` module (`modules/system/core/boot.nix`) already
has the reusable parts wired up (lanzaboote, `pcrs = [0 4 7]`, `pcrlockPolicy` pointed at
the persisted `/var/lib/pcrlock.d` directory) — a new host just needs to import it and walk
through the imperative, per-machine steps below, which nothing in the flake can do for you.

## 0. Prerequisites in the host's own config

- ESP mounted at `/boot`, LUKS root, `boot.initrd.luks.devices.<name>.crypttabExtraOpts = [ "tpm2-device=auto" ];`
- `impermanence`'s `preserveAt` needs `/var/lib/sbctl` (directory, mode `0700`) and
  `/var/lib/pcrlock.d` (directory) persisted. Do **not** persist `/var/lib/systemd/pcrlock.json`
  as a single `files` entry — `systemd-pcrlock` replaces it via atomic rename, which fails
  with `EBUSY` against a bind-mounted single file. That's exactly why `pcrlockPolicy` is
  pointed inside the already-persisted `pcrlock.d` directory instead.
- Host module list includes `bootloader`.

## 1. First build, keys, first boot

```bash
sudo sbctl create-keys        # only if this host has never had sbctl keys
nixos-rebuild switch --flake .#<host>
```

This installs lanzaboote's signed UKIs/stub to the ESP and (first time only)
registers a `Linux Boot Manager` NVRAM entry via `canTouchEfiVariables`. **Lanzaboote does
not recreate this entry on later switches** — if you ever delete it, you have to recreate it
by hand:

```bash
sudo efibootmgr --create --disk /dev/<disk> --part <esp-part-num> \
  --label "Linux Boot Manager" --loader '\EFI\systemd\systemd-bootx64.efi'
```

Reboot and confirm you actually land on it (not an old bootloader still in NVRAM ahead of
it in `BootOrder`) — check `sudo bootctl status`, looking for `Measured UKI: yes`. Some
firmware (observed on this ThinkPad) doesn't reliably honor `efibootmgr -o` ordering for the
*default* automatic boot choice even when the NVRAM `BootOrder` variable is correct — if that
happens, reorder from the firmware's own Setup boot-priority screen (F1), not just from Linux.

## 2. Check for OptionROMs before touching Secure Boot

```bash
sudo dmesg | grep -i rom
sudo lspci -vvv | grep -B6 -i "expansion rom"
```

A discrete/integrated GPU commonly shows up here (`Fetched VBIOS from VFCT` in dmesg). This
matters for step 4 below — `sbctl enroll-keys` will refuse to proceed blindly if it detects
an OptionROM in the boot chain, and which flag is correct depends on what device it is.

## 3. Enter Setup Mode

BIOS Setup (F1, not the one-time F12 boot menu) → Security → Secure Boot → enable the
toggle, then use "Reset to Setup Mode" / "Clear All Secure Boot Keys". Save & exit. This
should still boot Linux fine afterward (Setup Mode bypasses enforcement regardless of the
toggle). Confirm with `sudo sbctl status` → `Setup Mode: Enabled`.

## 4. Enroll keys

```bash
sudo sbctl enroll-keys                  # no OptionROM detected, or you want pure custom keys
sudo sbctl enroll-keys --tpm-eventlog   # OptionROM present (e.g. GPU VBIOS) — trusts only
                                         # its exact current hash, no broad CA added
sudo sbctl enroll-keys -m               # need Microsoft's certs too (dual-boot Windows,
                                         # vendor recovery tools, MS-signed option ROMs)
```

Reboot, confirm `sudo sbctl status` → `Setup Mode: Disabled`, `Secure Boot: Enabled`, and
that the display/POST still works fine if you went the `--tpm-eventlog` route.

## 5. Regenerate the pcrlock policy against the real, enrolled state

The policy generated before enrollment was computed against the old (vendor/no) keys and is
stale — PCR7 changed the moment you enrolled.

```bash
nixos-rebuild switch --flake .#<host>
```

If this fails with `Esys_PolicyAuthorizeNV` / "Remote address changed": the pcrlock NV index's
own update-authorization was tied to the pre-enrollment PCR7 value and can no longer be
satisfied. Remove it and let the switch define a fresh one:

```bash
sudo /run/current-system/systemd/lib/systemd/systemd-pcrlock remove-policy \
  --policy=/var/lib/pcrlock.d/pcrlock.json
nixos-rebuild switch --flake .#<host>
```

## 6. Bind LUKS to the TPM

Use `--tpm2-pcrlock=`, **not** `--tpm2-pcrs=`. Sealing to raw PCR values breaks on any future
kernel/bootloader/config change and silently falls back to a password prompt until you
manually re-enroll; sealing to the pcrlock policy tracks lanzaboote's own predictive
regeneration (done automatically on every switch) instead.

```bash
sudo systemd-cryptenroll --tpm2-device=auto \
  --tpm2-pcrlock=/var/lib/pcrlock.d/pcrlock.json /dev/<luks-partition>
```

Reboot and confirm no passphrase prompt.

## 7. Recovery key, then retire the old password

```bash
sudo systemd-cryptenroll --recovery-key /dev/<luks-partition>
```

Save the printed key somewhere durable *immediately* — it's shown once. Once TPM2 auto-unlock
is confirmed working and the recovery key is safely stored:

```bash
sudo systemd-cryptenroll --wipe-slot=password /dev/<luks-partition>
sudo systemd-cryptenroll /dev/<luks-partition>   # confirm only tpm2 + recovery remain
```

To add a password back later at any point: `sudo systemd-cryptenroll --password /dev/<luks-partition>`.

## 8. Cleanup

Once the new boot path has proven reliable across several reboots, remove whatever old
bootloader entry/files it replaced:

```bash
sudo efibootmgr -b <old-entry-id> -B
sudo rm -rf /boot/EFI/<old-bootloader-dir>
```
