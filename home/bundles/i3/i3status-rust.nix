{
  pkgs,
  pkgs-stable,
  lib,
  config,
  ...
}:
let
  cfg = config.local.i3.statusBar;

  # hid-logitech-hidpp exposes no power_supply for HID++ 1.0 mice, so read it
  # from solaar. unstable's solaar 1.1.19 crashes on python 3.14; stable works.
  mouseBattery = pkgs.writeShellScript "mouse-battery" ''
    out=$(${pkgs-stable.solaar}/bin/solaar show ${lib.escapeShellArg (toString cfg.mouseBattery)} 2>/dev/null)
    info=$(printf '%s' "$out" | ${pkgs.gnugrep}/bin/grep -iE '^[[:space:]]*Battery' | head -1)

    if [ -z "$info" ]; then
      echo '{"icon":"mouse","state":"Idle","text":"n/a"}'
      exit 0
    fi

    pct=$(printf '%s' "$info" | ${pkgs.gnugrep}/bin/grep -oE '[0-9]+%' | head -1 | tr -d '%')

    if [ -n "$pct" ]; then
      if [ "$pct" -lt 10 ]; then state=Critical
      elif [ "$pct" -lt 25 ]; then state=Warning
      else state=Good
      fi
      printf '{"icon":"mouse","state":"%s","text":"%s%%"}\n' "$state" "$pct"
      exit 0
    fi

    # Plugging in to charge takes the wireless link offline, and the G700s
    # reports no battery over USB, so there is no level to show here. Wired
    # entries carry `USB id`, wireless ones `WPID`.
    if printf '%s' "$out" | ${pkgs.gnugrep}/bin/grep -qE '^[[:space:]]*USB id'; then
      echo '{"icon":"bat_charging","state":"Good","text":"chg"}'
      exit 0
    fi

    # No percentage available — fall back to the discrete level.
    level=$(printf '%s' "$info" | tr 'A-Z' 'a-z')
    case "$level" in
      *critical*|*empty*) state=Critical; text=critical ;;
      *low*)              state=Warning;  text=low ;;
      *full*)             state=Good;     text=full ;;
      *good*)             state=Good;     text=good ;;
      *offline*)          state=Idle;     text=off ;;
      *)                  state=Idle;     text="?" ;;
    esac
    printf '{"icon":"mouse","state":"%s","text":"%s"}\n' "$state" "$text"
  '';
in
{
  options.local.i3.statusBar = {
    laptop = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include the laptop-only blocks (backlight, internal battery).";
    };

    mouseBattery = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "G700s";
      description = "solaar device name to show a battery block for, or null to omit it. Needs hardware.logitech.wireless.enable on the host.";
    };
  };

  config.programs.i3status-rust = {
    enable = true;
    bars = {
      default = {
        theme = "ctp-mocha";
        icons = "material-nf";
        blocks = [
          {
            block = "focused_window";
            format = " $title.str(max_w:50) |";
          }
          {
            block = "disk_space";
            path = "/";
            format = " $icon $available ";
            warning = 20.0;
            alert = 10.0;
          }
          {
            block = "memory";
            format = " $icon $mem_used_percents.eng(w:1) ";
          }
          {
            block = "cpu";
            interval = 2;
            format = " $icon $utilization ";
          }
          {
            block = "temperature";
            format = " $icon $max ";
            chip = "*-isa-*";
          }
          {
            block = "sound";
            format = " $icon $volume ";
          }
        ]
        ++ lib.optionals cfg.laptop [
          {
            block = "backlight";
            format = " $icon $brightness ";
          }
          {
            block = "battery";
            format = " $icon $percentage $time ";
          }
        ]
        ++ lib.optional (cfg.mouseBattery != null) {
          block = "custom";
          command = "${mouseBattery}";
          json = true;
          interval = 300;
          format = " $icon $text ";
        }
        ++ [
          {
            block = "time";
            interval = 60;
            # Formats to "UTC: 12:00" - adjust format string as needed
            format = " $icon UTC: $timestamp.datetime(f:'%H:%M') ";
            timezone = "UTC"; # This forces UTC
          }
          {
            block = "time";
            interval = 30;
            format = " $icon $timestamp.datetime(f:'%a %m/%d %I:%M %p') ";
          }
        ];
      };
    };
  };
}
