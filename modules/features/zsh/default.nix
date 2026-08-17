{
  inputs,
  moduleWithSystem,
  ...
}:
{
  flake.nixosModules.zsh = moduleWithSystem (
    { self', ... }:
    { pkgs, ... }:
    {
      nixpkgs.overlays = [
        (final: prev: {
          zsh = self'.packages.zsh;
        })
      ];
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        enableGlobalCompInit = false;
        enableLsColors = false;
        autosuggestions = {
          enable = true;
          strategy = [
            "history"
            "completion"
          ];
        };
        syntaxHighlighting.enable = true;
        histSize = 10000;
        promptInit = "";
      };
      users.defaultUserShell = pkgs.zsh;
    }
  );
  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    let
      vividTheme = pkgs.writeText "vivid-everforest.yml" ''
        colors:
          nord0:  '2d353b'
          nord1:  '343f44'
          nord2:  '3d484d'
          nord3:  '475258'
          nord4:  '859289'
          nord5:  '9da9a0'
          nord6:  'd3c6aa'
          nord7:  '83c092'
          nord8:  '83c092'
          nord9:  '7fbbb3'
          nord10: '7fbbb3'
          nord11: 'e67e80'
          nord12: 'e69875'
          nord13: 'dbbc7f'
          nord14: 'a7c080'
          nord15: 'd699b6'

          dim-foreground: '7a8478'

        core:
          normal_text:
            foreground: dim-foreground

          reset_to_normal:
            background: nord0
            foreground: nord4
            font-style: regular

          regular_file:
            foreground: nord4

          directory:
            foreground: nord10
            font-style: bold

          multi_hard_link:
            foreground: nord8
            font-style: underline

          symlink:
            foreground: nord8

          broken_symlink:
            foreground: nord11

          missing_symlink_target:
            background: nord11
            foreground: nord5
            font-style: bold

          fifo:
            foreground: nord7
            font-style:
              - bold
              - underline

          character_device:
            foreground: nord13

          block_device:
            foreground: nord13
            font-style: underline

          door:
            foreground: nord13
            font-style: italic

          socket:
            foreground: nord13
            font-style: bold

          executable_file:
            foreground: nord7
            font-style: bold

          file_with_capability:
            foreground: nord4
            font-style:
              - bold
              - underline

          setuid:
            foreground: nord4
            font-style:
              - bold
              - underline

          setgid:
            foreground: nord4
            font-style:
              - bold
              - underline

          sticky:
            background: nord10
            foreground: nord5
            font-style: underline

          other_writable:
            background: nord10
            foreground: nord5
            font-style: bold

          sticky_other_writable:
            background: nord10
            foreground: nord5
            font-style:
              - bold
              - underline

        archives:
          foreground: nord5
          font-style: bold

        executable:
          foreground: nord7
          font-style: bold

        markup:
          foreground: nord6
          web:
            foreground: nord4

        media:
          foreground: nord15
          fonts:
            foreground: nord4

        office:
          foreground: nord14

        programming:
          source:
            foreground: nord7
          tooling:
            foreground: nord4

        text:
          foreground: nord4

        unimportant:
          foreground: nord3
      '';

      lsColors = pkgs.runCommand "everforest-ls-colors" { } ''
        ${lib.getExe pkgs.vivid} generate ${vividTheme} > $out
      '';
      starshipInit = pkgs.runCommand "starship-init-zsh" { } ''
        ${lib.getExe pkgs.starship} init zsh > $out
      '';
      zoxideInit = pkgs.runCommand "zoxide-init-zsh" { } ''
        ${lib.getExe pkgs.zoxide} init zsh > $out
      '';
      kubectlCompletion = pkgs.runCommand "kubectl-completion-zsh" { } ''
        ${lib.getExe pkgs.kubectl} completion zsh > $out
      '';
    in
    {
      packages.zsh = inputs.wrappers.wrappers.zsh.wrap {
        inherit pkgs;
        hmSessionVariables = null;
        zshAliases = {
          vim = lib.getExe self'.packages.nvim;
          ls = "${lib.getExe pkgs.eza} --icons=auto";
          la = "${lib.getExe pkgs.eza} --icons=auto --all";
          lst = "${lib.getExe pkgs.eza} --icons=auto --tree";
          tree = "${lib.getExe pkgs.eza} --icons=auto --tree";
          c = "clear";

          d = "podman";
          tf = "tofu";
        };
        zshenv.content = ''
          fpath+=(${pkgs.zsh-completions}/share/zsh/site-functions)

          if [ -z "$SSH_AUTH_SOCK" ]; then
            export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
          fi
        '';
        zshrc.content = ''
          mkdir -p "$HOME/.local/share/zsh"

          zcompdump="$HOME/.local/share/zsh/zcompdump"
          autoload -Uz compinit
          if [[ -n $zcompdump(#qN.mh+24) ]]; then
            compinit -d "$zcompdump"
          else
            compinit -C -d "$zcompdump"
          fi

          HISTFILE="$HOME/.local/share/zsh/history"
          SAVEHIST=10000
          setopt SHARE_HISTORY HIST_IGNORE_DUPS

          export EDITOR=nvim
          export COLORTERM=truecolor
          export TERM=xterm-256color

          source ${pkgs.zsh-defer}/share/zsh-defer/zsh-defer.plugin.zsh
          source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
          source ${pkgs.nix-zsh-completions}/share/zsh/plugins/nix/nix.plugin.zsh

          export LS_COLORS="${builtins.readFile lsColors}"
          ${builtins.readFile starshipInit}
          ${builtins.readFile zoxideInit}

          function __git_prompt_git() {
            GIT_OPTIONAL_LOCKS=0 command git "$@"
          }
          function git_current_branch() {
            local ref
            ref=$(__git_prompt_git symbolic-ref --quiet HEAD 2> /dev/null)
            local ret=$?
            if [[ $ret != 0 ]]; then
              [[ $ret == 128 ]] && return
              ref=$(__git_prompt_git rev-parse --short HEAD 2> /dev/null) || return
            fi
            echo ''${ref#refs/heads/}
          }
          source ${inputs.ohmyzsh}/plugins/git/git.plugin.zsh
          if (( $+commands[kubectl] )); then
            source ${inputs.ohmyzsh}/plugins/kubectl/kubectl.plugin.zsh
          fi

          kubeconfigs=("$HOME"/.kube/configs/*(N))
          (( $#kubeconfigs )) && export KUBECONFIG="''${(j.:.)kubeconfigs}"

          compdef g=git
          if (( $+commands[kubectl] )); then
            ${builtins.readFile kubectlCompletion}
            compdef _kubectl k
          fi
        '';
      };
    };
}
