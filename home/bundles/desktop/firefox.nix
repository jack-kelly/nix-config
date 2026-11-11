{ ... }:
{
  # We don't theme Firefox via stylix, and the profile we actually use lives in
  # legacy ~/.mozilla (not the XDG path home-manager manages), so disable the
  # target — otherwise it themes a dead profile and warns about it.
  stylix.targets.firefox.enable = false;

  programs.firefox = {
    enable = true;

    # Everything goes through policies, which apply to every profile wherever
    # it lives. HM's per-profile config (user.js, extensions.packages) targets
    # the XDG path this firefox doesn't use (see the stylix note above).
    policies = {
      # Restore the previous session on startup. (browser.startup.page itself
      # can't be set through the Preferences policy.)
      Homepage.StartPage = "previous-session";

      # StartPage only covers clean startups. A reboot, or a switch that swaps
      # the running binary, kills Firefox uncleanly, and it then shows the
      # about:sessionrestore page instead of restoring. -1 disables that page
      # (and the "session is over 6h old" prompt), so it always restores
      # silently. Tradeoff: a tab that crashes Firefox on load would loop;
      # recover with Safe Mode.
      Preferences."browser.sessionstore.max_resumed_crashes" = {
        Value = -1;
        Status = "locked";
      };

      # Force-install uBlock Origin and 1Password from AMO (latest, not pinned
      # by Nix) and allow both in private windows.
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          private_browsing = true;
        };
        "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
          private_browsing = true;
        };
      };
    };
  };
}
