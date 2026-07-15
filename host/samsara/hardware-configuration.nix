# TEMPLATE — replace with the output of `nixos-generate-config --no-filesystems`
# run on samsara during install. `--no-filesystems` because disko.nix owns
# fileSystems/swapDevices/LUKS. The modules below are a sane default for a
# Threadripper + NVMe box; the generated file may add/adjust them.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # fileSystems, swapDevices, and LUKS are managed by disko (see disko.nix)

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  # AMD microcode is enabled via nixos-hardware's common-cpu-amd module
  # (imported in configuration.nix).
}
