{
  imports = [
    ../bundles/global
    ../bundles/i3
    ./hardware-configuration.nix
  ];

  services.xserver.videoDrivers = [
    "displaylink"
  ];

  networking.hostName = "beguiler"; # Define your hostname.
  system.stateVersion = "24.05";
}
