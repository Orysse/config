{ ... }: {
  flake.nixosModules.fprint = { pkgs, ... }: {
    services.fprintd.enable = true;
    security.pam.services.sudo.fprintAuth = false;
    security.pam.services.swaylock.fprintAuth = false;

    # swaylock's patched-in fingerprint support (see
    # modules/features/swaylock/fingerprint.patch) runs its own PAM
    # conversation in a separate child process against this service,
    # entirely independent of the password-only "swaylock" service above.
    security.pam.services."swaylock-fingerprint".text = ''
      auth required ${pkgs.fprintd}/lib/security/pam_fprintd.so max-tries=-1 timeout=-1
      account include login
      session include login
    '';
  };
}
