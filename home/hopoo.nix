{ pkgs, ... }:
{
  imports = [
    ./global
    ./bundles/desktop
    ./bundles/i3
  ];

  local.wallpaper = ../assets/hopoo.jpeg;

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
      command = "${pkgs.firefox}/bin/firefox";
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
