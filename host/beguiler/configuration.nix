{
  imports = [
    ../bundles/global
    ../bundles/i3
    ./hardware-configuration.nix
  ];

  services.xserver.videoDrivers = [
    "displaylink"
  ];

  services.libinput.touchpad.disableWhileTyping = true;

  networking.hostName = "beguiler"; # Define your hostname.
  system.stateVersion = "24.05";
}
