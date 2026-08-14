{...}: {
  flake.nixosModules.locale = {...}: {
    time.timeZone = "Europe/Paris";
    i18n.defaultLocale = "en_US.UTF-8";
    services.xserver.xkb = {
      layout = "us";
      variant = "intl";
    };
    console.keyMap = "us";
  };
}
