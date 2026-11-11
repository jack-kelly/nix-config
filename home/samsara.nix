{
  lib,
  pkgs-stable,
  ...
}:
let
  # DP-6 tops out at 74.97 for 2560x1440 on its current cable; the panel does 165
  portrait = "DP-6"; # Dell S2721D, rotated right
  landscape = "DP-4"; # OMEN 27q

  monitors = import ./bundles/i3/monitors.nix;
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

  # mkAfter keeps this last (after the work bundle's entries too), so focus
  # settles on the landscape monitor rather than ws1.
  local.i3.startupApps = lib.mkAfter [ "i3-msg 'workspace number 3'" ];

  programs.autorandr = {
    profiles.desktop = {
      fingerprint = {
        ${portrait} = monitors.dellS2721D;
        ${landscape} = monitors.omen27qDisplayPort;
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
