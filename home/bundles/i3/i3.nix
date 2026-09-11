{
  pkgs,
  lib,
  config,
  ...
}:
let
  mod = "Mod4";
  terminal = "alacritty";
  launcher = "rofi -show drun";

  # Pause dunst while locked so notifications don't render over i3lock,
  # then resume on unlock. i3lock must run with --nofork so the resume
  # only fires after the lock screen exits.
  lock = pkgs.writeShellScript "lock" ''
    ${pkgs.dunst}/bin/dunstctl set-paused true
    ${pkgs.i3lock}/bin/i3lock --nofork -c 1e1e2e
    ${pkgs.dunst}/bin/dunstctl set-paused false
  '';

  left = "h";
  down = "j";
  up = "k";
  right = "l";

  ws1 = "1";
  ws2 = "2";
  ws3 = "3";
  ws4 = "4";
  ws5 = "5";
  ws6 = "6";
  ws7 = "7";
  ws8 = "8";
  ws9 = "9: chat";
  ws10 = "10: music";

  outputs = config.local.i3.outputs;

  # Single source of truth for window placement. These strings come from the
  # apps themselves and drift across updates (obsidian 1.13 renamed itself to
  # md.Obsidian, then to md.obsidian.Obsidian as of 1.13.7). All classes below
  # are case-insensitive regexes, matched anywhere in the class string (not
  # anchored), so a future re-capitalization or added/renamed segment doesn't
  # silently go stale the same way; .desktop StartupWMClass is not a usable
  # substitute, it disagrees with the real class for slack and spotify and
  # obsidian omits it. startupOnly windows are homed once at login instead of
  # via `assign`, so later windows and dialogs stay where they are opened.
  windowRules = [
    {
      class = "[Oo]bsidian";
      regex = true;
      workspace = ws1;
    }
    {
      class = "[Ff]irefox";
      regex = true;
      workspace = ws4;
      startupOnly = true;
    }
    {
      class = "[Ss]lack";
      regex = true;
      workspace = ws5;
    }
    {
      class = "[Dd]iscord";
      regex = true;
      workspace = ws9;
    }
    {
      class = "[Ss]ignal";
      regex = true;
      workspace = ws9;
    }
    {
      class = "[Ss]potify";
      regex = true;
      workspace = ws10;
    }
  ];

  # `class` is normally a literal class name, escaped and matched against the
  # whole string; set `regex = true` on a rule to use `class` as-is, an
  # extended regex matched anywhere in the string (as above), for an app
  # whose class gains segments or changes case across versions.
  classInner =
    r: if r.regex or false then r.class else builtins.replaceStrings [ "." ] [ "\\." ] r.class;
  classCriteria = r: if r.regex or false then classInner r else "^" + classInner r + "$";
  # `[^"]*` rather than `.*` so a substring match can't run past the closing
  # JSON quote when scanning get_tree's output below.
  classDetectPattern = r: "[^\"]*" + classInner r + "[^\"]*";

  # i3 silently ignores a criterion that stops matching and drops the window on
  # whatever workspace has focus, so say something when a class never shows up.
  placeStartupWindows = pkgs.writeShellScript "place-startup-windows" ''
    i3=${config.xsession.windowManager.i3.package}/bin/i3-msg

    check() { # detectPattern workspace place criteria
      local pattern=$1 ws=$2 place=$3 criteria=$4 i
      for ((i = 0; i < 60; i++)); do
        if $i3 -t get_tree | ${pkgs.gnugrep}/bin/grep -qE "\"class\":\"$pattern\""; then
          if [ "$place" = 1 ]; then
            $i3 "[class=\"$criteria\"] move container to workspace \"$ws\"" >/dev/null
          fi
          return 0
        fi
        ${pkgs.coreutils}/bin/sleep 1
      done
      ${pkgs.libnotify}/bin/notify-send -u critical "i3 window rules" \
        "No window matching class pattern '$pattern' appeared; its rule for workspace $ws is stale."
    }

    ${lib.concatMapStringsSep "\n" (
      r:
      "check ${lib.escapeShellArg (classDetectPattern r)} ${lib.escapeShellArg r.workspace} "
      + "${if r.startupOnly or false then "1" else "0"} ${lib.escapeShellArg (classCriteria r)} &"
    ) windowRules}
    wait
  '';
in
{
  options.local.i3.startupApps = lib.mkOption {
    type = lib.types.listOf lib.types.attrs;
    default = [ ];
    description = "Per-host i3 autostart applications, appended to infrastructure startup.";
  };

  options.local.i3.outputs = {
    portrait = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "DVI-I-3-2"
        "DVI-I-1-1"
      ];
      description = "Outputs, in priority order, for the portrait workspaces (1-2).";
    };
    landscape = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "DVI-I-2-1"
        "DVI-I-2-2"
      ];
      description = "Outputs, in priority order, for the landscape workspaces (3-5).";
    };
    chatMusic = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "eDP-1" ];
      description = "Outputs, in priority order, for the chat/music workspaces (9-10).";
    };
    fallback = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "DP-1"
        "eDP-1"
      ];
      description = "Shared fallback outputs appended to the portrait/landscape lists.";
    };
  };

  # Naming the output beats "primary": i3bar resolves the tray when it starts,
  # which is before `autorandr --change` has set the primary output.
  options.local.i3.trayOutput = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "DP-4";
    description = "Output for the i3bar tray. Null leaves i3's default (primary at bar startup).";
  };

  config.xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = mod;
      terminal = terminal;

      fonts = {
        names = [ "FiraCode Nerd Font" ];
        size = 10.0;
      };

      gaps = {
        inner = 8;
        outer = 4;
        smartGaps = true;
      };

      window = {
        titlebar = false;
        border = 2;
      };

      floating.titlebar = false;

      # Don't warp the cursor to the newly focused window/output on every
      # keyboard focus change.
      focus.mouseWarping = false;

      keybindings = lib.mkOptionDefault {
        # Launch
        "${mod}+Return" = "exec ${terminal}";
        "${mod}+d" = "exec ${launcher}";

        # Kill
        "${mod}+Shift+q" = "kill";

        # Focus
        "${mod}+${left}" = "focus left";
        "${mod}+${down}" = "focus down";
        "${mod}+${up}" = "focus up";
        "${mod}+${right}" = "focus right";

        # Move
        "${mod}+Shift+${left}" = "move left";
        "${mod}+Shift+${down}" = "move down";
        "${mod}+Shift+${up}" = "move up";
        "${mod}+Shift+${right}" = "move right";

        # Splits
        "${mod}+b" = "split h";
        "${mod}+v" = "split v";

        # Layout
        "${mod}+f" = "fullscreen toggle";
        "${mod}+s" = "layout stacking";
        "${mod}+w" = "layout tabbed";
        "${mod}+e" = "layout toggle split";
        "${mod}+Shift+space" = "floating toggle";
        "${mod}+space" = "focus mode_toggle";
        "${mod}+a" = "focus parent";

        # Scratchpad
        "${mod}+Shift+minus" = "move scratchpad";
        "${mod}+minus" = "scratchpad show";

        # Workspaces
        "${mod}+1" = "workspace number ${ws1}";
        "${mod}+2" = "workspace number ${ws2}";
        "${mod}+3" = "workspace number ${ws3}";
        "${mod}+4" = "workspace number ${ws4}";
        "${mod}+5" = "workspace number ${ws5}";
        "${mod}+6" = "workspace number ${ws6}";
        "${mod}+7" = "workspace number ${ws7}";
        "${mod}+8" = "workspace number ${ws8}";
        "${mod}+9" = "workspace number ${ws9}";
        "${mod}+0" = "workspace number ${ws10}";

        "${mod}+Shift+1" = "move container to workspace number ${ws1}";
        "${mod}+Shift+2" = "move container to workspace number ${ws2}";
        "${mod}+Shift+3" = "move container to workspace number ${ws3}";
        "${mod}+Shift+4" = "move container to workspace number ${ws4}";
        "${mod}+Shift+5" = "move container to workspace number ${ws5}";
        "${mod}+Shift+6" = "move container to workspace number ${ws6}";
        "${mod}+Shift+7" = "move container to workspace number ${ws7}";
        "${mod}+Shift+8" = "move container to workspace number ${ws8}";
        "${mod}+Shift+9" = "move container to workspace number ${ws9}";
        "${mod}+Shift+0" = "move container to workspace number ${ws10}";

        "${mod}+Shift+greater" = "move workspace to output right";
        "${mod}+Shift+less" = "move workspace to output left";

        # Reload / restart
        "${mod}+Shift+c" = "reload";
        "${mod}+Shift+r" = "restart";
        "${mod}+Shift+e" = ''exec "i3-nagbar -t warning -m 'Exit i3?' -B 'Yes' 'i3-msg exit'"'';

        # Resize
        "${mod}+r" = "mode resize";

        # Media keys
        "XF86AudioRaiseVolume" = "exec --no-startup-id wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" = "exec --no-startup-id wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute" = "exec --no-startup-id wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioMicMute" = "exec --no-startup-id wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        "XF86AudioPlay" = "exec --no-startup-id playerctl play-pause";
        "XF86AudioNext" = "exec --no-startup-id playerctl next";
        "XF86AudioPrev" = "exec --no-startup-id playerctl previous";

        # Brightness
        "XF86MonBrightnessUp" = "exec --no-startup-id brightnessctl set +5%";
        "XF86MonBrightnessDown" = "exec --no-startup-id brightnessctl set 5%-";

        # Screenshot
        "Print" = "exec --no-startup-id flameshot gui";

        # Lock
        "${mod}+Escape" = "exec --no-startup-id ${lock}";
      };

      modes = {
        resize = {
          "${left}" = "resize shrink width 10 px or 10 ppt";
          "${down}" = "resize grow height 10 px or 10 ppt";
          "${up}" = "resize shrink height 10 px or 10 ppt";
          "${right}" = "resize grow width 10 px or 10 ppt";
          "Escape" = "mode default";
          "Return" = "mode default";
        };
      };

      workspaceOutputAssign = [
        {
          workspace = ws1;
          output = outputs.portrait ++ outputs.fallback;
        }
        {
          workspace = ws2;
          output = outputs.portrait ++ outputs.fallback;
        }
        {
          workspace = ws3;
          output = outputs.landscape ++ outputs.fallback;
        }
        {
          workspace = ws4;
          output = outputs.landscape ++ outputs.fallback;
        }
        {
          workspace = ws5;
          output = outputs.landscape ++ outputs.fallback;
        }
        {
          workspace = ws9;
          output = outputs.chatMusic;
        }
        {
          workspace = ws10;
          output = outputs.chatMusic;
        }
      ];

      assigns = lib.mapAttrs (_: rules: map (r: { class = classCriteria r; }) rules) (
        lib.groupBy (r: r.workspace) (builtins.filter (r: !(r.startupOnly or false)) windowRules)
      );

      bars = [
        {
          position = "top";
          trayOutput = config.local.i3.trayOutput;
          statusCommand = "i3status-rs ~/.config/i3status-rust/config-default.toml";
          fonts = {
            names = [ "FiraCode Nerd Font" ];
            size = 10.0;
          };
        }
      ];

      startup = [
        # Tray applets
        {
          command = "nm-applet";
          notification = false;
        }
        {
          command = "blueman-applet";
          notification = false;
        }
        {
          command = "pasystray";
          notification = false;
        }

        # Screen locking
        {
          command = "xss-lock --transfer-sleep-lock -- ${lock}";
          notification = false;
        }
        # Lets apps that call the freedesktop Idle Inhibition Service (e.g.
        # browser tabs with an active webcam call) actually suspend the X
        # screensaver, so xss-lock doesn't lock mid-meeting despite no
        # keyboard/mouse input. Only helps apps that call Inhibit -- native
        # clients that don't bother (some Zoom builds, etc.) aren't covered.
        {
          command = "xssproxy";
          notification = false;
        }

        # Monitor hotplug
        {
          command = "autorandr --change";
          notification = false;
        }

        {
          command = "${placeStartupWindows}";
          notification = false;
        }

        # Polkit agent (needed for 1Password)
        {
          command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          notification = false;
        }

        # Wallpaper (feh will be configured by stylix, but as fallback)
        {
          command = "feh --bg-fill ~/.config/wallpaper";
          notification = false;
        }
      ]
      ++ config.local.i3.startupApps;
    };
  };
}
