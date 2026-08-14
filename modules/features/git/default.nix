{
  inputs,
  moduleWithSystem,
  ...
}: {
  flake.nixosModules.git = moduleWithSystem (
    {self', ...}: {...}: {
      environment.systemPackages = [self'.packages.git];
    }
  );
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    forgeConfig = pkgs.writeText "forge.gitconfig" (
      lib.generators.toGitINI {
        user = {
          name = "Abel Chartier";
          email = "abel1.chartier@epita.fr";
          signingKey = "abel1.chartier@epita.fr";
        };
        commit.gpgSign = true;
        tag.gpgSign = true;
        pull.rebase = true;
        core.sshCommand = "${pkgs.writeShellScript "ssh-forge" ''
          tmp=$(mktemp)
          ${lib.getExe' pkgs.openssh "ssh-add"} -L > "$tmp"
          ${lib.getExe' pkgs.openssh "ssh"} -i "$tmp" -o IdentitiesOnly=yes "$@"
          rm -f "$tmp"
        ''}";
      }
    );
  in {
    packages.git = inputs.wrappers.wrappers.git.wrap {
      inherit pkgs;
      settings = {
        user = {
          name = "Abel Chartier";
          email = "abel.chartier@gmail.com";
        };
        core = {
          sshCommand = "ssh -i /home/abel/.ssh/id_ed25519 -o IdentitiesOnly=yes";
          editor = "nvim";
        };
        init.defaultBranch = "master";
        pull.rebase = true;
        push = {
          autoSetupRemote = true;
          default = "simple";
        };
        color = {
          ui = "auto";
          branch = "auto";
          diff = "auto";
          interactive = "auto";
          status = "auto";
        };
        commit.verbose = true;
        branch.autosetuprebase = "always";
        alias = {
          st = "status";
          co = "checkout";
          br = "branch";
          ci = "commit";
          df = "diff";
          lg = "log --oneline --graph --decorate";
          last = "log -1 HEAD";
          amend = "commit --amend";
          unstage = "reset HEAD --";
        };
        rebase = {
          autoSquash = true;
          autoStash = true;
        };
        includeIf."gitdir:~/Documents/Forge/".path = "${forgeConfig}";
      };
    };
  };
}
