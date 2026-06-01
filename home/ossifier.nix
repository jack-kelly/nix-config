{ pkgs, ... }:
{
  imports = [
    ./global
    ./bundles/desktop
    ./bundles/i3
    ./bundles/i3/autorandr.nix
    ./bundles/work
  ];

  local.autorandr.eDP1 = {
    fingerprint = "00ffffffffffff000dae8a140000000008220104a51e13780328659759548e271e505400000001010101010101010101010101010101423c80a070b024403020a6002dbc10000018423c80a070b08e423020a6002dbc1000001a000000fd00283c4a4a10010a202020202020000000fe004e3134304a43412d454c4c0a20016102031700721a00000301283c0000000000003c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b4";
    mode = "1920x1200";
    rate = "60.00";
  };

  local.i3.startupApps = [
    {
      command = "${pkgs.obsidian}/bin/obsidian";
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
      command = "${pkgs.slack}/bin/slack";
      notification = false;
    }
  ];
}
