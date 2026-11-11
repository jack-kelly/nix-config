{ pkgs, ... }:
{
  imports = [
    ../desktop
  ];

  services.displayManager.ly = {
    enable = true;
    settings = {
      animation = "doom";
    };
  };

  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [
      i3lock
      i3status-rust
    ];
  };

  programs.dconf.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.autorandr.enable = true;
}
