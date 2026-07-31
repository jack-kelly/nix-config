{ pkgs, config, ... }:
let
  # A400 Mini-DP output names — confirm on the machine (`xrandr --query`) and
  # regenerate the profile below with `autorandr --save`.
  portrait = "DP-0";
  landscape = "DP-1";
in
{
  imports = [
    ./global
    ./bundles/desktop
    ./bundles/i3
    ./bundles/nvidia
    ./bundles/work
  ];

  local.i3.outputs = {
    portrait = [ portrait ];
    landscape = [ landscape ];
    chatMusic = [ landscape ];
    fallback = [ ];
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
      command = "${config.programs.firefox.finalPackage}/bin/firefox";
      notification = false;
    }
    {
      command = "${pkgs.slack}/bin/slack";
      notification = false;
    }
  ];

  programs.autorandr = {
    enable = true;
    hooks.postswitch = {
      "restart-i3" = "i3-msg restart";
      "reset-wallpaper" = "feh --bg-fill ~/.config/wallpaper";
    };
    profiles.desktop = {
      fingerprint = {
        ${portrait} =
          "00ffffffffffff0010ac99a1494d3530211f0104a53b21783be4a5a6544c9e260d5054a54b00714f8180a9c0d1c00101010101010101565e00a0a0a029503020350055502100001a000000ff0031474a4b5034330a2020202020000000fc0044454c4c205332373231440a20000000fd00304b73733c010a202020202020011602031df150101f20051404131211030216150706012309070783010000bf1600a08038134030203a0055502100001a7e3900a080381f4030203a0055502100001a023a801871382d40582c450055502100001ed97600a0a0a034503020350055502100001a00000000000000000000000000000000000000000000000000008e";
        ${landscape} =
          "00ffffffffffff00220e45390101010122210103803c22782a5015af4f47a6250f5054a54b00d1c0a9c081c0d100b300950081008180565e00a0a0a029503020350055502100001a000000fd0037901efa3c000a202020202020000000fc004f4d454e203237710a20202020000000ff00434e43333334315842590a202001c0020339b148103f40040302015a67030c001000384467d85dc4017880006d1a000002013790ed0000000000e305c301e6060501626255e200eaf8e300a0a0a032500820980455502100001e6fc200a0a0a055503020350055502100001ed97600a0a0a034503020350055502100001a000000000000000000000000000000009e";
      };
      config = {
        ${portrait} = {
          enable = true;
          mode = "2560x1440";
          rate = "144.00";
          position = "0x0";
          rotate = "right";
        };
        ${landscape} = {
          enable = true;
          primary = true;
          mode = "2560x1440";
          rate = "144.00";
          position = "1440x40";
        };
      };
    };
  };
}
