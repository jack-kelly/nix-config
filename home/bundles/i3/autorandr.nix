# Docking profiles for the laptops. autorandr itself (and its postswitch
# hooks) is enabled by the i3 bundle.
{ lib, config, ... }:
let
  eDP1 = config.local.autorandr.eDP1;
  monitors = import ./monitors.nix;

  # The two-monitor desk through the DisplayLink dock. The dock's outputs
  # show up under either of two name pairs, hence a profile for each.
  mkDocked = portrait: landscape: {
    fingerprint = {
      eDP-1 = eDP1.fingerprint;
      ${portrait} = monitors.dellS2721D;
      ${landscape} = monitors.omen27qDisplayLink;
    };
    config = {
      eDP-1 = {
        enable = true;
        primary = true;
        mode = eDP1.mode;
        rate = eDP1.rate;
        position = "1440x1480";
      };
      ${portrait} = {
        enable = true;
        mode = "2560x1440";
        rate = "59.95";
        position = "0x0";
        rotate = "right";
      };
      ${landscape} = {
        enable = true;
        mode = "2560x1440";
        rate = "59.95";
        position = "1440x40";
      };
    };
  };
in
{
  options.local.autorandr.eDP1 = {
    fingerprint = lib.mkOption {
      type = lib.types.str;
      description = "EDID fingerprint for the internal laptop display (eDP-1).";
    };
    mode = lib.mkOption {
      type = lib.types.str;
      description = "Native resolution for eDP-1 (e.g. \"1920x1080\").";
    };
    rate = lib.mkOption {
      type = lib.types.str;
      description = "Refresh rate for eDP-1 (e.g. \"144.00\").";
    };
  };

  config.programs.autorandr.profiles = {
    docked = mkDocked "DVI-I-3-2" "DVI-I-2-1";
    docked-alt = mkDocked "DVI-I-1-1" "DVI-I-2-2";

    docked-single = {
      fingerprint = {
        eDP-1 = eDP1.fingerprint;
        DP-1 = monitors.dellS3225QS;
      };
      config = {
        eDP-1 = {
          enable = true;
          primary = true;
          mode = eDP1.mode;
          rate = eDP1.rate;
          position = "0x1080";
        };
        DP-1 = {
          enable = true;
          mode = "3840x2160";
          rate = "59.98";
          position = "1920x0";
        };
      };
    };

    docked-single-alt = {
      fingerprint = {
        eDP-1 = eDP1.fingerprint;
        DP-1 = monitors.dellP3225DE;
      };
      config = {
        eDP-1 = {
          enable = true;
          mode = eDP1.mode;
          rate = eDP1.rate;
          position = "0x0";
        };
        DP-1 = {
          enable = true;
          primary = true;
          mode = "2560x1440";
          rate = "99.95";
          position = "1920x0";
        };
      };
    };

    mobile = {
      fingerprint = {
        eDP-1 = eDP1.fingerprint;
      };
      config = {
        eDP-1 = {
          enable = true;
          primary = true;
          mode = eDP1.mode;
          rate = eDP1.rate;
          position = "0x0";
        };
      };
    };
  };
}
