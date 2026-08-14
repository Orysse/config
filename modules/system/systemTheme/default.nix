{ ... }: {
  flake.nixosModules.systemTheme =
    {
      pkgs,
      lib,
      ...
    }:
    let
      cursorName = "everforest-cursors";
      cursorSize = 24;

      gtkThemeName = "Everforest-Dark";
    in
    {
      environment.systemPackages = [
        pkgs.adwaita-icon-theme
        pkgs.everforest-cursors
        pkgs.everforest-gtk-theme
      ];

      environment.sessionVariables = {
        GTK_THEME = gtkThemeName;
        XCURSOR_THEME = cursorName;
        XCURSOR_SIZE = toString cursorSize;
      };

      programs.dconf.enable = true;
      programs.dconf.profiles.user.databases = [
        {
          settings = with lib.gvariant; {
            "org/gnome/desktop/interface" = {
              gtk-theme = gtkThemeName;
              cursor-theme = cursorName;
              cursor-size = mkInt32 cursorSize;
            };
          };
        }
      ];
    };
}
