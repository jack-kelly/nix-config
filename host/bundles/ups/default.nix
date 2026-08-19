{
  config,
  lib,
  pkgs,
  ...
}:
let
  # upsd speaks its client protocol over TCP only (the Unix sockets under
  # /var/lib/nut are the driver<->upsd link, not this one), so there is no
  # peer-credential path and upsmon has to present a real password. It does not
  # have to be a *known* password though: upsd.users and upsmon.conf are both
  # rendered at service start from this one file, so whatever it contains ends
  # up on both sides. Generating it at runtime keeps it out of the world-
  # readable store without pulling in sops/agenix.
  passwordFile = "/var/lib/nut/upsmon-password";

  # How long mains can be out before we stop waiting for it to come back. Short
  # blips ride out on battery; anything longer shuts the machine down while
  # there is still plenty of runtime left.
  onBatterySeconds = 60;

  # upssched needs a directory it can create its FIFO and lockfile in, owned by
  # the (unprivileged) user upsmon runs as. The module's own /run/nut is
  # root-owned, so this gets its own.
  runtimeDir = "/run/nut-upssched";

  # Run by upssched, so this inherits upsmon's unprivileged user. `upsmon -c
  # fsd` works anyway: the pidfile holds the *child's* pid, which that user
  # owns, and the child relays the shutdown to its root parent over their pipe.
  # This is NUT's own escalation path — no sudo or polkit bridge required.
  upsschedCmd = pkgs.writeShellScript "upssched-cmd" ''
    case "$1" in
      onbatt-shutdown)
        ${pkgs.util-linux}/bin/logger -t upssched-cmd \
          "on battery for ${toString onBatterySeconds}s, forcing shutdown"
        exec ${config.power.ups.package}/sbin/upsmon -c fsd
        ;;
    esac
  '';
in
{
  power.ups = {
    enable = true;

    # standalone = driver + upsd + upsmon on one host, for a UPS on its own USB
    # port. netserver/netclient only matter when one host shuts down others.
    mode = "standalone";

    ups.cyberpower = {
      # CyberPower CP1500PFCLCDa is a plain USB HID power device — NUT's
      # generic usbhid-ups driver picks the `cps` subdriver from the vendor ID
      # automatically, no per-model driver needed. (Model per the device's own
      # `device.model`; lsusb reports 0764:0601 as "PR1500LCDRT2U" because
      # that is the one name usb.ids carries for a PID CyberPower reuses across
      # its whole line.)
      driver = "usbhid-ups";
      # `port` is a required key even for USB drivers, where it is meaningless;
      # "auto" tells the driver to scan the bus instead of pinning a device node.
      port = "auto";
      description = "CyberPower CP1500PFCLCDa";
    };

    users.upsmon = {
      inherit passwordFile;
      # Grants the upsd-side ACLs a primary upsmon needs: reading UPS vars plus
      # the SET/FSD commands it issues when it decides to shut the system down.
      upsmon = "primary";
    };

    upsmon.monitor.cyberpower = {
      user = "upsmon";
      # primary: this host owns the UPS, so it is the one that runs the killpower
      # step after the OS halts. (NUT 2.8 name for what used to be "master";
      # the module's default is still the legacy spelling.)
      type = "primary";
    };

    # NOTIFYCMD is already upssched, but upsmon only ever calls it for events
    # whose flags include EXEC, and the built-in defaults are SYSLOG+WALL only.
    # Without these two lines the timer below never gets armed or cancelled.
    upsmon.settings.NOTIFYFLAG = [
      [
        "ONBATT"
        "SYSLOG+WALL+EXEC"
      ]
      [
        "ONLINE"
        "SYSLOG+WALL+EXEC"
      ]
    ];

    # The timer lives only in upssched's memory — losing power mid-countdown
    # just means the machine dies with the UPS, which is the same outcome.
    # (the option is typed `str`, hence the interpolation rather than a bare
    # derivation)
    schedulerRules = "${pkgs.writeText "upssched.conf" ''
      CMDSCRIPT ${upsschedCmd}
      PIPEFN ${runtimeDir}/upssched.pipe
      LOCKFN ${runtimeDir}/upssched.lock

      AT ONBATT * START-TIMER onbatt-shutdown ${toString onBatterySeconds}
      AT ONLINE * CANCEL-TIMER onbatt-shutdown
    ''}";
  };

  systemd.tmpfiles.rules = [
    "d ${runtimeDir} 0700 ${config.power.ups.upsmon.user} ${config.power.ups.upsmon.group} -"
  ];

  # The module points every NUT unit at /var/lib/nut, which it creates 0700
  # root — so upssched, which inherits this unit's environment and runs
  # unprivileged, logs "writepid: fopen /var/lib/nut/upssched.pid: Permission
  # denied" on every ONBATT. It is only a warning (the timer still arms), but
  # it lands in the log exactly when you are reading it during an outage.
  #
  # upsmon has no use for the state path: it reaches upsd over TCP, and its own
  # pidfile goes to /var/run regardless of this variable — which is also why
  # `upsmon -c fsd` in the CMDSCRIPT keeps working. Repointing it here is
  # therefore confined to upssched's pidfile. Note this deliberately does not
  # touch upsdrv/upsd/ups-killpower, which do need the real state path to reach
  # the driver socket.
  systemd.services.upsmon.environment.NUT_STATEPATH = lib.mkForce runtimeDir;

  systemd.services.nut-upsmon-password = {
    description = "Generate the local upsd password for upsmon";
    # upsd and upsmon each declare LoadCredential= against the file, and PID1
    # resolves those before the units' own ExecStartPre runs — so this has to be
    # ordered before both, not merely wanted by them.
    before = [
      "upsd.service"
      "upsmon.service"
    ];
    requiredBy = [
      "upsd.service"
      "upsmon.service"
    ];
    # Skipped once the password exists. A condition that fails counts as a
    # successful start, so the ordering above still releases both services.
    unitConfig.ConditionPathExists = "!${passwordFile}";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      UMask = "0077";
    };
    # Hex rather than base64: the value is spliced into a quoted field in both
    # upsd.users and upsmon.conf, and hex has nothing either parser can choke on.
    script = ''
      install -d -m0700 "$(dirname ${passwordFile})"
      od -An -tx1 -N24 /dev/urandom | tr -d ' \n' > ${passwordFile}
    '';
  };
}
