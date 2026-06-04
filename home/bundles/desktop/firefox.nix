{
  # Let stylix theme the profile we declare below.
  stylix.targets.firefox.profileNames = [ "default" ];

  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      settings = {
        # Restore the previous session (open windows/tabs) on startup.
        "browser.startup.page" = 3;
      };
    };
  };
}
