{
  imports = [
    ../bundles/global
    ../bundles/i3
    ./hardware-configuration.nix
  ];

  services.xserver.videoDrivers = [
    "displaylink"
  ];

  networking.hostName = "beguiler";
  system.stateVersion = "24.05";
}
