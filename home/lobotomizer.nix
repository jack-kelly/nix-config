{ pkgs, ... }:
{
  imports = [
    ./global
    ./bundles/desktop
    ./bundles/i3
    ./bundles/i3/autorandr.nix
    ./bundles/nvidia
    ./bundles/work
  ];

  local.autorandr.eDP1 = {
    fingerprint = "00ffffffffffff000dae5615000000001f200104a522137803ee95a3544c99260f505400000001010101010101010101010101010101ad3780a070383e403020a50058c110000018000000fd003c90a5a522010a202020202020000000fc004e313536484d412d4741310a20000000fe00434d4e0a20202020202020202001cc7020790200220014243805857f079f002f001f0037043d00090004002b000627003c8f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002e90";
    mode = "1920x1080";
    rate = "144.00";
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
