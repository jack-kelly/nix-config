{ lib, config, ... }:
let
  eDP1 = config.local.autorandr.eDP1;
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

  config.programs.autorandr = {
    enable = true;

    hooks.postswitch = {
      "restart-i3" = "i3-msg restart";
      "reset-wallpaper" = "feh --bg-fill ~/.config/wallpaper";
    };

    profiles = {
      docked = {
        fingerprint = {
          eDP-1 = eDP1.fingerprint;
          DVI-I-3-2 = "00ffffffffffff0010ac99a1494d3530211f0104a53b21783be4a5a6544c9e260d5054a54b00714f8180a9c0d1c00101010101010101565e00a0a0a029503020350055502100001a000000ff0031474a4b5034330a2020202020000000fc0044454c4c205332373231440a20000000fd00304b73733c010a202020202020011602031df150101f20051404131211030216150706012309070783010000bf1600a08038134030203a0055502100001a7e3900a080381f4030203a0055502100001a023a801871382d40582c450055502100001ed97600a0a0a034503020350055502100001a00000000000000000000000000000000000000000000000000008e";
          DVI-I-2-1 = "00ffffffffffff00220e45390101010122210103803c22782a5015af4f47a6250f5054a54b00d1c0a9c081c0d100b300950081008180565e00a0a0a029503020350055502100001a000000fd0037901efa3c000a202020202020000000fc004f4d454e203237710a20202020000000ff00434e43333334315842590a202001c0020339b148103f40040302015a67030c001000384467d85dc4017880006d1a000002013790ed0000000000e305c301e6060501626255e200eaf8e300a0a0a032500820980455502100001e6fc200a0a0a055503020350055502100001ed97600a0a0a034503020350055502100001a000000000000000000000000000000009e";
        };
        config = {
          eDP-1 = {
            enable = true;
            primary = true;
            mode = eDP1.mode;
            rate = eDP1.rate;
            position = "1440x1480";
          };
          DVI-I-3-2 = {
            enable = true;
            mode = "2560x1440";
            rate = "59.95";
            position = "0x0";
            rotate = "right";
          };
          DVI-I-2-1 = {
            enable = true;
            mode = "2560x1440";
            rate = "59.95";
            position = "1440x40";
          };
        };
      };

      docked-alt = {
        fingerprint = {
          eDP-1 = eDP1.fingerprint;
          DVI-I-1-1 = "00ffffffffffff0010ac99a1494d3530211f0104a53b21783be4a5a6544c9e260d5054a54b00714f8180a9c0d1c00101010101010101565e00a0a0a029503020350055502100001a000000ff0031474a4b5034330a2020202020000000fc0044454c4c205332373231440a20000000fd00304b73733c010a202020202020011602031df150101f20051404131211030216150706012309070783010000bf1600a08038134030203a0055502100001a7e3900a080381f4030203a0055502100001a023a801871382d40582c450055502100001ed97600a0a0a034503020350055502100001a00000000000000000000000000000000000000000000000000008e";
          DVI-I-2-2 = "00ffffffffffff00220e45390101010122210103803c22782a5015af4f47a6250f5054a54b00d1c0a9c081c0d100b300950081008180565e00a0a0a029503020350055502100001a000000fd0037901efa3c000a202020202020000000fc004f4d454e203237710a20202020000000ff00434e43333334315842590a202001c0020339b148103f40040302015a67030c001000384467d85dc4017880006d1a000002013790ed0000000000e305c301e6060501626255e200eaf8e300a0a0a032500820980455502100001e6fc200a0a0a055503020350055502100001ed97600a0a0a034503020350055502100001a000000000000000000000000000000009e";
        };
        config = {
          eDP-1 = {
            enable = true;
            primary = true;
            mode = eDP1.mode;
            rate = eDP1.rate;
            position = "1440x1480";
          };
          DVI-I-1-1 = {
            enable = true;
            mode = "2560x1440";
            rate = "59.95";
            position = "0x0";
            rotate = "right";
          };
          DVI-I-2-2 = {
            enable = true;
            mode = "2560x1440";
            rate = "59.95";
            position = "1440x40";
          };
        };
      };

      docked-single = {
        fingerprint = {
          eDP-1 = eDP1.fingerprint;
          DP-1 = "00ffffffffffff0010aca8d15659343206230104b5462878fb2cd5ae5044a2240e5054a54b00714f8140818081c081009500b300d1c04dd000a0f0703e8030203500b9882100001a000000ff00423454595234340a2020202020000000fc0044454c4c20533332323551530a000000fd0c30782d2d7d010a202020202020026f020346f15301030212111304141f05104c2021223f5d61762309070783010000e200d5e20e75e305c000e606050155552e741a00000301307800000000000078000000008900565e00a0a0a0295030203500b9882100001a0000000000000000000000000000000000000000000000000000000000000000000000000000003270127903000301280fd00104ff0e2f02af8057006f085900070009006ec20004ff099f002f801f009f055400020004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001790";
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
          DP-1 = "00ffffffffffff0010ac804342514b4103240104b54627783a62a5ad5046ab240e5054a54b00714f8180a940d1c081c0a9c001010101565e00a0a0a0295030203500ba892100001a000000ff00484258533838340a2020202020000000fc0044454c4c20503332323544450a000000fd0030641e9734010a2020202020200100020312b14a40101f04131211030201e200ea5aa000a0a0a0465030203500ba892100001a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
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
  };
}
