{
  inputs,
  moduleWithSystem,
  ...
}:
{
  perSystem =
    {
      pkgs,
      lib,
      system,
      self',
      ...
    }:
    let
      # claude-code is unfree; the perSystem pkgs does not allow it. Scoped predicate.
      unfreePkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg: lib.getName pkg == "claude-code";
      };

      # Hooks run outside the sandbox with the user's rights: keep them short,
      # offline, and pin their only dependencies (jq, grep, coreutils) here.
      mkHook =
        name: file:
        pkgs.writeShellScript name ''
          export PATH=${
            lib.makeBinPath [
              pkgs.jq
              pkgs.gnugrep
              pkgs.coreutils
            ]
          }
          ${builtins.readFile file}
        '';
      dangerGuard = mkHook "claude-danger-guard" ./_claude/danger-guard.sh;
      auditLog = mkHook "claude-audit-log" ./_claude/audit-log.sh;
      statusline = mkHook "claude-statusline" ./_claude/statusline.sh;

      # Local plugin written here (no third-party code): LSP servers from the store.
      localLsp = pkgs.runCommand "local-lsp-plugin" { } ''
        mkdir -p $out/.claude-plugin
        cp ${
          pkgs.writeText "plugin.json" (
            builtins.toJSON {
              name = "local-lsp";
              version = "1.0.0";
              description = "LSP servers (pyright, clangd, jdtls, nixd, bash) from the nix store";
              author.name = "abel";
              lspServers = {
                pyright = {
                  command = lib.getExe' pkgs.pyright "pyright-langserver";
                  args = [ "--stdio" ];
                  extensionToLanguage = {
                    ".py" = "python";
                    ".pyi" = "python";
                  };
                };
                clangd = {
                  command = lib.getExe' pkgs.clang-tools "clangd";
                  args = [ "--background-index" ];
                  extensionToLanguage = {
                    ".c" = "c";
                    ".h" = "c";
                    ".cpp" = "cpp";
                    ".cc" = "cpp";
                    ".cxx" = "cpp";
                    ".hpp" = "cpp";
                    ".hxx" = "cpp";
                  };
                };
                jdtls = {
                  command = lib.getExe pkgs.jdt-language-server;
                  extensionToLanguage.".java" = "java";
                  startupTimeout = 120000;
                };
                nixd = {
                  command = lib.getExe pkgs.nixd;
                  extensionToLanguage.".nix" = "nix";
                };
                bash = {
                  command = lib.getExe pkgs.bash-language-server;
                  args = [ "start" ];
                  extensionToLanguage = {
                    ".sh" = "shellscript";
                    ".bash" = "shellscript";
                  };
                };
              };
            }
          )
        } $out/.claude-plugin/plugin.json
      '';

      secureProjectTemplate = pkgs.runCommand "secure-project-template" { } ''
        mkdir -p $out
        cp -rT ${./_claude/template} $out
        chmod -R u+w $out
        cp -r ${inputs.claude-code-ref}/.devcontainer $out/.devcontainer
      '';
    in
    {
      packages.omo = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
        pname = "omo";
        version = "5.1.58";

        src = pkgs.fetchurl {
          url = "https://github.com/code-yeongyu/oh-my-openagent/releases/download/v${finalAttrs.version}/omo-linux-x64";
          hash = "sha256-V4L6PfHkB0k3VkHxUTBW3zYJyxy6yB6lsVPHOrcveFI=";
        };

        dontUnpack = true;
        dontStrip = true;
        dontPatchELF = true;

        installPhase = ''
          runHook preInstall
          install -Dm755 $src $out/bin/omo
          runHook postInstall
        '';

        meta = {
          description = "OmO, an AI agent harness";
          homepage = "https://github.com/code-yeongyu/oh-my-openagent";
          mainProgram = "omo";
          platforms = [ "x86_64-linux" ];
        };
      });

      packages.new-secure-project = pkgs.writeShellApplication {
        name = "new-secure-project";
        text = ''
          dest=''${1:?usage: new-secure-project <dir>}
          if [ -e "$dest" ] && [ -n "$(ls -A "$dest")" ]; then
            echo "new-secure-project: $dest exists and is not empty" >&2
            exit 1
          fi
          mkdir -p "$dest"
          cp -rT --no-preserve=mode,ownership ${secureProjectTemplate} "$dest"
        '';
      };

      # Claude Code, fully declared: settings, hooks, CLAUDE.md and plugins pinned
      # by flake.lock. Plugins are loaded with --plugin-dir, so nothing is
      # installed under ~/.claude/plugins and /plugin has no marketplace.
      packages.claude = inputs.wrappers.wrappers.claude-code.wrap {
        pkgs = unfreePkgs;

        pluginDirs = [
          inputs.ponytail
          inputs.egm
          inputs.humanizer
          "${inputs.claude-plugins-official}/plugins/claude-md-management"
          "${inputs.claude-plugins-official}/external_plugins/context7"
          localLsp
        ];

        # Remote MCP, nothing to pin or store: sign-in is OAuth 2.1 in the browser (/mcp in
        # Claude Code), and the consent screen on trip.abe.lc picks the scopes.
        mcpConfig.trek = {
          type = "http";
          url = "https://trip.abe.lc/mcp";
        };

        # Browser for JS-only sites (hotel availability). Pinned by nixpkgs in flake.lock,
        # bundled Chromium; --isolated = throwaway in-memory profile, no saved logins or cookies.
        mcpConfig.playwright = {
          type = "stdio";
          command = lib.getExe pkgs.playwright-mcp;
          args = [ "--isolated" ];
        };

        # xdg-open for the MCP OAuth flow: without it the browser never opens (suffix: used only when the system has none).
        runtimePkgs = [ pkgs.xdg-utils ];

        flags."--append-system-prompt-file" = "${./_claude/CLAUDE.md}";

        settings = {
          model = "sonnet";
          modelSettings."claude-sonnet-5-5".effortLevel = "high";
          tui = "fullscreen";
          statusLine = {
            type = "command";
            command = "${statusline}";
          };
          theme = "dark";

          permissions = {
            defaultMode = "default";
            deny = [
              "Read(./.env)"
              "Read(./.env.*)"
              "Read(./**/secrets/**)"
              "Read(./**/*.pem)"
              "Read(./**/*.key)"
              "Read(~/.ssh/**)"
              "Read(~/.aws/**)"
              "Read(~/.gnupg/**)"
              "Read(~/.kube/**)"
              "Read(~/.config/gcloud/**)"
              "Read(~/.docker/config.json)"
              "Read(~/.netrc)"
              # ~ is a tmpfs: backups live in the persisted ~/Documents.
              "Read(~/Documents/claude-backup-*)"
            ];
          };

          sandbox = {
            enabled = true;
            failIfUnavailable = true;
            # A failed command can be retried outside the sandbox, after a permission prompt.
            allowUnsandboxedCommands = true;
            # ~/.ssh is hidden from the sandbox, so git over ssh must run outside it.
            excludedCommands = [
              "git push"
              "git push *"
              "git pull"
              "git pull *"
              "git fetch"
              "git fetch *"
              "git clone *"
            ];
            filesystem.denyRead = [
              "~/.ssh"
              "~/.aws"
              "~/.gnupg"
              "~/.kube"
              "~/.config/gcloud"
              "~/.docker/config.json"
              "~/.netrc"
            ];
            # The sandbox blocks unix sockets by default, which breaks every nix command.
            network.allowUnixSockets = [ "/nix/var/nix/daemon-socket/socket" ];
            network.allowedDomains = [
              "github.com"
              "api.github.com"
              "codeload.github.com"
              "raw.githubusercontent.com"
              "objects.githubusercontent.com"
              "registry.npmjs.org"
              "pypi.org"
              "files.pythonhosted.org"
              "cache.nixos.org"
              "nix-community.cachix.org"
              "channels.nixos.org"
              "api.anthropic.com"
              "code.claude.com"
            ];
          };

          hooks = {
            PreToolUse = [
              {
                matcher = "*";
                hooks = [
                  {
                    type = "command";
                    command = "${auditLog}";
                  }
                ];
              }
              {
                matcher = "Bash";
                hooks = [
                  {
                    type = "command";
                    command = "${dangerGuard}";
                  }
                ];
              }
            ];
            SubagentStart = [
              {
                hooks = [
                  {
                    type = "command";
                    command = "${auditLog}";
                  }
                ];
              }
            ];
          };
        };
      };

      # Same config as `claude` (deny rules, hooks, plugins, MCP) but no bash sandbox and the
      # auto permission mode (classifier reviews each action). For trusted, supervised runs only.
      packages.claude-auto = self'.packages.claude.wrap {
        binName = "claude-auto";
        settings.sandbox.enabled = lib.mkForce false;
        settings.permissions.defaultMode = lib.mkForce "auto";
      };
    };

  flake.nixosModules.ai = moduleWithSystem (
    { self', ... }:
    { pkgs, ... }:
    {
      programs.nix-ld = {
        enable = true;
        libraries = [ pkgs.glibc ];
      };

      sops.secrets."api/openrouter" = {
        sopsFile = inputs.nix-secrets + "/secrets/api/openrouter.yaml";
        key = "token";
        owner = "abel";
        mode = "0400";
      };

      environment.systemPackages = [
        self'.packages.claude
        self'.packages.claude-auto
        self'.packages.new-secure-project
        pkgs.nodejs
        pkgs.bun
        self'.packages.omo
        pkgs.deepseek-harness
      ];
    }
  );
}
