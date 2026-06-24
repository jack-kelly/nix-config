{ config, pkgs, ... }:
{
  imports = [
    ../bundles/global
    ../bundles/i3
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

  # System 76 adder-ws specific hardware configuration
  # including nvidia and system76 firmware
  services.xserver.videoDrivers = [
    "nvidia"
    "displaylink"
  ];

  hardware = {
    keyboard.zsa.enable = true;
    graphics.enable = true;
    system76.enableAll = true;
    nvidia = {
      modesetting.enable = true;
      # Display + suspend (settled 2026-06-24): X runs iGPU-primary with nvidia as a PRIME
      # OFFLOAD provider (prime.offload below). The panels (eDP-1 + DP-1) are on the Intel
      # iGPU and the docked monitors are DisplayLink/USB, so the dGPU drives no display;
      # it stays loaded only for CUDA + `nvidia-offload`. S3 suspend is UNSUPPORTED here:
      # the dGPU's resume is broken in every firmware/driver/PM combo tried (Xid 79 /
      # nvKmsResume Oops / suspend hang), no driver version fixes it (open-gpu #1142, same
      # AD107), and clean compute-only isn't possible on NixOS (hardware.nvidia is gated on
      # `nvidia` ∈ videoDrivers, so dropping it kills CUDA). Suspend is therefore masked
      # below — use poweroff. Full writeup: host/lobotomizer/firmware-runbook.md.
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
    cudaPackages.cudatoolkit
    cudaPackages.cudnn
    wally-cli
    keymapp
    # System76 Open Firmware flashing: scripts/flash.sh calls `sudo efibootmgr` to set
    # BootNext into the firmware updater. Installing it system-wide puts it on sudo's
    # secure_path so flash.sh works without absolute store paths. See host/lobotomizer/firmware-runbook.md
    efibootmgr
  ];

  services.libinput.touchpad.disableWhileTyping = true;

  services.power-profiles-daemon.enable = false;

  # S3 suspend is unsupported on this machine — the nvidia dGPU's resume is broken at every
  # firmware/driver/PM combo and there's no clean fix (see the nvidia block above and
  # host/lobotomizer/firmware-runbook.md). Hard-guard against accidentally triggering the
  # broken suspend: mask the sleep targets, and make the lid/keys lock or poweroff — never suspend.
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

  programs.nix-ld.enable = true;

  services.tailscale.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false;

  system.stateVersion = "24.11";
}
