{ ... }: {
  flake.nixosModules.greetd =
    {
      pkgs,
      lib,
      ...
    }:
    {
      services.greetd = {
        enable = true;
        settings.default_session = {
          command = ''${lib.getExe pkgs.tuigreet} --time --remember --cmd river --theme "border=white;text=white;prompt=white;time=white;action=white;button=white;container=black;input=white;title=white;greet=white"'';
          user = "greeter";
        };
      };
    };
}
