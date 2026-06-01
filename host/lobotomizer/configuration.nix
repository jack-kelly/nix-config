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
      powerManagement.enable = true;
      powerManagement.finegrained = true;
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
  ];

  services.libinput.touchpad.disableWhileTyping = true;

  services.power-profiles-daemon.enable = false;

  programs.nix-ld.enable = true;

  services.tailscale.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false;

  system.stateVersion = "24.11";
}
