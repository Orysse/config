{
  inputs,
  moduleWithSystem,
  ...
}:
{
  flake.nixosModules.tmux = moduleWithSystem (
    { self', ... }:
    { ... }:
    {
      environment.systemPackages = [ self'.packages.tmux ];
    }
  );
  perSystem =
    { pkgs, ... }:
    {
      packages.tmux = let
        navScript = pkgs.writeShellScript "tmux-smart-nav" (builtins.readFile ./smart-nav.sh);
        sshHostScript = pkgs.writeShellScript "tmux-ssh-host" (builtins.readFile ./ssh-host.sh);
      in inputs.wrappers.wrappers.tmux.wrap {
        inherit pkgs;
        sourceSensible = true;
        shell = "${pkgs.zsh}/bin/zsh";
        terminal = "tmux-256color";
        terminalOverrides = ",$TERM:RGB";
        historyLimit = 100000;
        prefix = "C-s";
        mouse = true;
        modeKeys = "vi";
        vimVisualKeys = true;
        baseIndex = 1;
        escapeTime = 0;

        configAfter = ''
          bind-key -n C-h run-shell '${navScript} h L left  #{pane_at_left}   #{pane_id}'
          bind-key -n C-j run-shell '${navScript} j D down  #{pane_at_bottom} #{pane_id}'
          bind-key -n C-k run-shell '${navScript} k U up    #{pane_at_top}    #{pane_id}'
          bind-key -n C-l run-shell '${navScript} l R right #{pane_at_right}  #{pane_id}'

          bind -r H resize-pane -L 5
          bind -r J resize-pane -D 5
          bind -r K resize-pane -U 5
          bind -r L resize-pane -R 5
          bind -r C-h resize-pane -L 1
          bind -r C-j resize-pane -D 1
          bind -r C-k resize-pane -U 1
          bind -r C-l resize-pane -R 1

          set -g pane-border-style "fg=#475258"
          set -g pane-active-border-style "fg=#a7c080"
          set -g message-style "bg=default,fg=#e67e80"
          set -g message-command-style "bg=default,fg=#7fbbb3"
          set -g mode-style "bg=#a7c080,fg=#2d353b"
          set -g popup-border-style "fg=#a7c080"
          set -g popup-border-lines rounded
          set -g clock-mode-colour "#a7c080"
        '';

        plugins = with pkgs.tmuxPlugins; [
          yank
          open
          {
            plugin = extrakto;
            configBefore = ''
              set -g @extrakto_key 'tab'
              set -g @extrakto_grab_area 'window recent'
              set -g @extrakto_split_direction 'p'
              set -g @extrakto_split_size '15'
              set -g @extrakto_fzf_tool 'fzf'
            '';
          }
          {
            plugin = fzf-tmux-url;
            configBefore = ''
              set -g @fzf-url-bind 'u'
              set -g @fzf-url-fzf-options '-w 50% -h 50% --multi -0 --no-preview --no-border'
            '';
          }
          {
            plugin = dotbar;
            configBefore = ''
              set -g @tmux-dotbar-bg "default"
              set -g @tmux-dotbar-bg-prefix "default"
              set -g @tmux-dotbar-fg "#7a8478"
              set -g @tmux-dotbar-fg-current "#d3c6aa"
              set -g @tmux-dotbar-fg-session "#a7c080"
              set -g @tmux-dotbar-fg-prefix "#7fbbb3"
              set -g @tmux-dotbar-position "bottom"
              set -g @tmux-dotbar-justify "absolute-centre"
              set -g @tmux-dotbar-left "true"
              set -g @tmux-dotbar-status-left "  #S"
              set -g @tmux-dotbar-right "true"
              set -g @tmux-dotbar-status-right "#(${sshHostScript} #{pane_tty})"
              set -g @tmux-dotbar-window-status-format " #W "
              set -g @tmux-dotbar-window-status-separator " • "
              set -g @tmux-dotbar-maximized-icon "󰊓"
              set -g @tmux-dotbar-show-maximized-icon-for-all-tabs false
            '';
          }
          {
            plugin = resurrect;
            configBefore = "set -g @resurrect-strategy-nvim 'session'";
          }
          {
            plugin = continuum;
            configBefore = ''
              set -g @continuum-restore 'off'
              set -g @continuum-save-interval '15'
            '';
          }
        ];
      };
    };
}
