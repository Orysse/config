{ ... }:
{
  flake.nixosModules.firefox =
    { pkgs, ... }:
    let
      ublockOrigin = pkgs.fetchurl {
        url = "https://addons.mozilla.org/firefox/downloads/file/4940584/ublock_origin-1.73.0.xpi";
        sha256 = "bccc51a773150af4af6e1fd62c7bfdeb7238b79ff2381b998fa9f2e38f64786a";
      };
      vimium = pkgs.fetchurl {
        url = "https://addons.mozilla.org/firefox/downloads/file/4717567/vimium_ff-2.4.2.xpi";
        sha256 = "131e2a67580e7ae9125ab19781159e61409fac47b441fc2782aab76396ead196";
      };
      everforestTheme = pkgs.fetchurl {
        url = "https://addons.mozilla.org/firefox/downloads/file/4849455/everforest_dark_medium_theme-2.6.xpi";
        sha256 = "d05a21225ea65c43dc22946e6a1c3b4bbfb4acbe3df9a05acf0531f8ab96dd1b";
      };
      keepassxcBrowser = pkgs.fetchurl {
        url = "https://addons.mozilla.org/firefox/downloads/file/4831838/keepassxc_browser-1.10.3.xpi";
        sha256 = "4df9c54e0a293aa2e37e9bcf97ec307a35a00e78cebaa9a68edba552c07c4568";
      };
    in
    {
      programs.firefox = {
        enable = true;
        nativeMessagingHosts.packages = [ pkgs.keepassxc ];
        policies = {
          ExtensionSettings = {
            "uBlock0@raymondhill.net" = {
              installation_mode = "force_installed";
              install_url = "file://${ublockOrigin}";
            };
            "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
              installation_mode = "force_installed";
              install_url = "file://${vimium}";
            };
            "{0e5c8ff0-b54b-4bd1-b33e-d5e016e066f0}" = {
              installation_mode = "force_installed";
              install_url = "file://${everforestTheme}";
            };
            "keepassxc-browser@keepassxc.org" = {
              installation_mode = "force_installed";
              install_url = "file://${keepassxcBrowser}";
            };
          };
        };
      };
    };
}
