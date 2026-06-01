{
  config,
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
    ../bundles/yocto-flashing
    ./hardware-configuration.nix
  ];
  networking.hostName = "ossifier";

  # System76 Darter Pro 10 (darp10-b) specific hardware configuration
  services.xserver.videoDrivers = [
    "displaylink"
  ];

  hardware = {
    keyboard.zsa.enable = true;
    graphics.enable = true;
    system76.enableAll = true;
  };

  environment.systemPackages = with pkgs; [
    wally-cli
    keymapp
  ];

  services.libinput.touchpad.disableWhileTyping = true;

  services.power-profiles-daemon.enable = false;

  programs.nix-ld.enable = true;

  services.tailscale.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false;

  system.stateVersion = "25.11";
}
