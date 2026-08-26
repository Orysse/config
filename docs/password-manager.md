# Password manager: KeePassXC + YubiKey unlock

KeePassXC as the primary password manager (`modules/features/keepassxc`, in every desktop
host via `modules/system/desktop`), with the KeePassXC-Browser extension force-installed in
Firefox (`modules/features/firefox`) the same way uBlock/Vimium/the Everforest theme are.
Self-contained by design: no server, no daemon, just a local `.kdbx` file — see the tradeoff
discussion this was chosen over (local Vaultwarden, `pass`/gopass, Bitwarden hosted) in memory
if you want the reasoning again later.

Everything below is imperative — a `.kdbx` vault and a YubiKey's programmed slot are both
real-world state Nix can't own, so this is a one-time manual setup, not something a rebuild
does for you.

## 1. Create the vault

Launch `keepassxc`, create a new database. Store the `.kdbx` file under `~/Documents/` (or
anywhere under `~/`, `~/.config`, or another path already listed in
`modules/system/impermanence/default.nix`'s `preserveAt` — anything outside those paths is on
tmpfs and vanishes on reboot). Set a real master password even though the YubiKey will be the
day-to-day unlock (step 3) — KeePassXC's own security model expects the password to always
exist as a fallback if the key is lost, damaged, or not on hand.

## 2. Program a YubiKey slot for challenge-response

**Destructive to whatever's currently in that slot** — a stock YubiKey ships with slot 1 doing
Yubico OTP and slot 2 empty, so slot 2 is normally safe, but check first if you've customized
either slot before:

```bash
ykman otp info
```

If slot 2 is free:

```bash
ykman otp chalresp --generate --touch 2
```

`--generate` writes a random secret to the key itself (never leaves the device, nothing to
back up separately) and `--touch` requires a physical touch on each unlock — worth keeping,
since it's what stops a background process/malware from silently unlocking the vault without
you present.

This is unrelated to the `abel_yubikey` age identity already used for sops-nix secrets
(`modules/flavors/secrets`) — that's a separate applet (PIV/age) on the same physical key, not
reused here. One YubiKey, two independent credential types on it.

## 3. Add the YubiKey as a database unlock factor

In KeePassXC: **Database → Database Security → Add additional protection... → Add
Challenge-Response**. Select the YubiKey and slot 2, save. From then on, unlocking prompts for
the master password *and* a YubiKey touch — both factors required, matching how sops-nix's
YubiKey-gated secrets already work in this config.

## 4. Repeat step 3 per database

The Challenge-Response binding lives inside each `.kdbx` file's own security settings, not as
a system-wide setting — if you create more than one database (e.g. a separate one for
work-only secrets), each needs step 3 done individually.

## Losing the YubiKey

The master password alone still opens the database — Challenge-Response is an *additional*
factor, not a replacement, so losing or damaging the key doesn't lock you out, just drops back
to password-only until you program a replacement key and re-run step 3.
