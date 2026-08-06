{
  pkgs,
  pkgs-stable,
  config,
  ...
}:
let
  # DP-6 tops out at 74.97 for 2560x1440 on its current cable; the panel does 165
  portrait = "DP-6"; # Dell S2721D, rotated right
  landscape = "DP-4"; # OMEN 27q
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

  local.i3.trayOutput = landscape;

  local.i3.statusBar = {
    laptop = false;
    mouseBattery = "G700s";
  };

  # unstable's solaar 1.1.19 crashes on python 3.14
  home.packages = [ pkgs-stable.solaar ];

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
    # last, so focus settles on the landscape monitor rather than ws1
    {
      command = "i3-msg 'workspace number 3'";
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
          "00ffffffffffff00220e44390101010122210104b53c22783b5015af4f47a6250f5054a54b00d1c0a9c081c0d100b300950081008180565e00a0a0a029503020350055502100001a000000fd003ca5ffff48010a202020202020000000fc004f4d454e203237710a20202020000000ff00434e43333334315842590a2020026c020328b147103f40040302016d1a000002013ca5000000000000e305c301e6060501626255e200ea09ec00a0a0a067503020350055502100001a6fc200a0a0a055503020350055502100001ed97600a0a0a034503020350055502100001a0000000000000000000000000000000000000000000000000000000000000000002c701279030003011440100104ff090001080020009f053c00060008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e690";
      };
      config = {
        ${portrait} = {
          enable = true;
          mode = "2560x1440";
          rate = "74.97";
          position = "0x0";
          rotate = "right";
        };
        ${landscape} = {
          enable = true;
          primary = true;
          mode = "2560x1440";
          rate = "143.97";
          position = "1440x0";
        };
      };
    };
  };
}
