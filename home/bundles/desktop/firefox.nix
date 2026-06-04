{ pkgs, ... }:
let
  addons = pkgs.firefox-addons;
in
{
  # Let stylix theme the profile we declare below.
  stylix.targets.firefox.profileNames = [ "default" ];

  programs.firefox = {
    enable = true;

    # Allow uBlock Origin and 1Password to run in Private Windows. The XPIs
    # themselves are installed (pinned) via extensions.packages below; this
    # policy just attaches the private-browsing grant by extension ID.
    # `private_browsing` requires Firefox >= 136 / ESR >= 128.8.
    policies.ExtensionSettings = {
      "uBlock0@raymondhill.net".private_browsing = true;
      "{d634138d-c276-4fc8-924b-40a0ea21d284}".private_browsing = true;
    };

    profiles.default = {
      id = 0;
      settings = {
        # Restore the previous session (open windows/tabs) on startup.
        "browser.startup.page" = 3;
        # Enable installed extensions without a manual per-extension prompt.
        "extensions.autoDisableScopes" = 0;
      };
      extensions.packages = [
        addons.ublock-origin
        addons.onepassword-password-manager
      ];
    };
  };
}
