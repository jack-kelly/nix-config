{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.system76
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    ../bundles/global
    ../bundles/i3
    ../bundles/work
    ../bundles/yocto-flashing
    ./hardware-configuration.nix
  ];
  networking.hostName = "ossifier";

  # System76 Darter Pro 10 (darp10-b) specific hardware configuration
  services.xserver.videoDrivers = [
    "displaylink"
  ];

  hardware.graphics.enable = true;

  # Hibernate: resume from the LUKS swap partition (see disko.nix). The systemd
  # initrd unlocks it before resume.
  boot.resumeDevice = "/dev/mapper/luks-3ef56867-64ff-4094-976e-2188ecbf4057";

  services.power-profiles-daemon.enable = false;

  system.stateVersion = "25.11";
}
