{ ... }: {
  flake.nixosModules.greetd =
    {
      pkgs,
      lib,
      ...
    }:
    {
      # Type=idle only waits 5 s; wait for the whole boot so logs stop before tuigreet draws.
      systemd.services.greetd.unitConfig.After = [ "multi-user.target" ];

      services.greetd = {
        enable = true;
        settings.default_session = {
          command = ''${lib.getExe pkgs.tuigreet} --time --remember --cmd river --theme "border=white;text=white;prompt=white;time=white;action=white;button=white;container=black;input=white;title=white;greet=white"'';
          user = "greeter";
        };
      };
    };
}
