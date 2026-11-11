{
  imports = [
    ../bundles/global
    ../bundles/yocto-flashing
    ./hardware-configuration.nix
  ];

  networking.hostName = "vitrifier";
  system.stateVersion = "24.05";
}
