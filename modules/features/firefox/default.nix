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
    in
    {
      programs.firefox = {
        enable = true;
        preferences = {
          "media.ffmpeg.vaapi.enabled" = false;
          "media.rdd-ffmpeg.enabled" = false;
        };
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
          };
        };
      };
    };
}
