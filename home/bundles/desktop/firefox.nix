{ ... }:
{
  # We don't theme Firefox via stylix, and the profile we actually use lives in
  # legacy ~/.mozilla (not the XDG path home-manager manages), so disable the
  # target — otherwise it themes a dead profile and warns about it.
  stylix.targets.firefox.enable = false;

  programs.firefox = {
    enable = true;

    # Everything is driven through policies, not per-profile settings: policies
    # are written to the firefox package's policies.json and apply to every
    # profile regardless of on-disk location, whereas HM's per-profile config
    # (user.js, extensions.packages) targets the XDG path this firefox doesn't
    # use. See the project memory on the profile-path mismatch.
    policies = {
      # Restore the previous session on startup. This is the policy equivalent
      # of `browser.startup.page = 3`, which is not settable via the Preferences
      # policy; StartPage is.
      Homepage.StartPage = "previous-session";

      # StartPage above only governs *clean* startups. `reboot` (and a Nix
      # update-switch that swaps the running firefox binary) terminates Firefox
      # uncleanly, so on next launch it takes the crash-recovery path instead
      # and shows the about:sessionrestore interstitial ("Sorry. We're having
      # trouble getting your pages back") that needs a manual "Restore Session"
      # click. -1 disables that interstitial entirely: Firefox always silently
      # auto-restores after a crash, and also skips the separate "session is
      # >6h old" prompt. (See SessionStore.sys.mjs `_needsRestorePage`: the
      # `max_resumed_crashes != -1` guard short-circuits both triggers.)
      # Tradeoff: a tab that reliably crashes Firefox on load would loop with
      # no UI escape hatch — recover via Safe Mode if that ever happens.
      # browser.* prefs are settable via the Preferences policy (only
      # app.update.{channel,lastUpdateTime,migrated} and one vpn pref are
      # blocked), unlike browser.startup.page.
      Preferences."browser.sessionstore.max_resumed_crashes" = {
        Value = -1;
        Status = "locked";
      };

      # Force-install uBlock Origin and 1Password from AMO and allow both in
      # Private Windows. `force_installed` auto-enables them; `private_browsing`
      # requires Firefox >= 136 / ESR >= 128.8. These track AMO's latest (i.e.
      # not version-pinned by Nix).
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
