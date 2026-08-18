{
  imports = [
    ../bundles/global
    ../bundles/yocto-flashing
    ./hardware-configuration.nix
  ];

  networking.hostName = "vitrifier"; # Define your hostname.
  system.stateVersion = "24.05";
}
