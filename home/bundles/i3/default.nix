{ pkgs, pkgs-stable, ... }:
{
  imports = [
    ./i3.nix
    ./i3status-rust.nix
    ./rofi.nix
    ./stylix.nix
    ./picom.nix
  ];

  home.packages =
    (with pkgs; [
      # Tray applets
      networkmanagerapplet
      blueman
      pasystray
      pavucontrol

      # Utilities
      feh
      xss-lock
      # Bridges org.freedesktop.ScreenSaver Inhibit calls (browsers hold one
      # open during an active webcam call) to XScreenSaverSuspend, so xss-lock
      # doesn't fire while a call is inhibiting the screensaver. See i3.nix
      # for why this is needed and its coverage caveats.
      xssproxy
      arandr
      playerctl
      brightnessctl
    ])
    ++ [
      # unstable's flameshot 14 hangs on xdg-desktop-portal; stable is 12.x
      pkgs-stable.flameshot
    ];

  services.dunst.enable = true;
}
