{ pkgs, config, ... }:
{
  imports = [
    ./global
    ./bundles/desktop
    ./bundles/i3
  ];

  local.wallpaper = ../assets/beguiler.jpeg;

  local.i3.startupApps = [
    {
      command = "${pkgs.obsidian}/bin/obsidian";
      notification = false;
    }
    {
      command = "${pkgs.spotify}/bin/spotify";
      notification = false;
    }
    {
      command = "i3-msg 'workspace 3; exec ${pkgs.alacritty}/bin/alacritty'";
      notification = false;
    }
    {
      # Use the policy-configured firefox from programs.firefox (session
      # restore etc.), NOT bare pkgs.firefox which has empty policies.
      command = "${config.programs.firefox.finalPackage}/bin/firefox";
      notification = false;
    }
    {
      command = "${pkgs.discord}/bin/discord";
      notification = false;
    }
    {
      command = "${pkgs.signal-desktop}/bin/signal-desktop";
      notification = false;
    }
  ];
}
