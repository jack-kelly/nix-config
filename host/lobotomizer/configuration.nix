{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.system76
    ../bundles/global
    ../bundles/i3
    ../bundles/work
    ../bundles/yocto-flashing
    ./hardware-configuration.nix
  ];
  networking.hostName = "lobotomizer";

  boot.kernelParams = [
    # Force i915 for Intel GPU — xe claims this device ID but doesn't support it yet
    "i915.force_probe=a788"
    "xe.force_probe=!a788"
    # Prevent PCIe port power management from leaving the dGPU link in a degraded
    # state (Gen 1 / 2.5 GT/s) at boot, which causes intermittent nvidia init failures
    "pcie_port_pm=off"
    "pcie_aspm=off"
  ];

  # System76 Adder WS
  services.xserver.videoDrivers = [
    "nvidia"
    "displaylink"
  ];

  hardware = {
    graphics.enable = true;
    nvidia = {
      modesetting.enable = true;
      # The dGPU drives no display (the panels are on the Intel iGPU, the docked
      # monitors are DisplayLink), so it is a PRIME offload provider kept only for
      # CUDA and `nvidia-offload`. It has to stay in videoDrivers: hardware.nvidia
      # is gated on that.
      #
      # S3 resume is broken on this dGPU with every firmware/driver/PM combination
      # tried (Xid 79, nvKmsResume oops, hangs; open-gpu #1142, same AD107), so
      # suspend is masked further down. Use poweroff.
      powerManagement.enable = false; # no VRAM-preserve suspend services (we never suspend)
      powerManagement.finegrained = true; # RTD3: dGPU powers down when idle (battery)
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      prime = {
        offload.enable = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "nvidia-offload" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      exec "$@"
    '')
    # System76 Open Firmware flashing: scripts/flash.sh calls `sudo efibootmgr` to set
    # BootNext into the firmware updater. Installing it system-wide puts it on sudo's
    # secure_path so flash.sh works without absolute store paths.
    efibootmgr
  ];

  services.power-profiles-daemon.enable = false;

  # Suspend is broken here (see the nvidia block above), so make it impossible:
  # mask the sleep targets and have the lid and keys lock or power off instead.
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };
  services.logind.settings.Login = {
    HandleLidSwitch = "lock";
    HandleLidSwitchExternalPower = "lock";
    HandleLidSwitchDocked = "ignore"; # docked w/ externals: keep working on lid close
    HandleSuspendKey = "ignore";
    HandlePowerKey = "poweroff"; # clean shutdown, not suspend
  };

  system.stateVersion = "24.11";
}
