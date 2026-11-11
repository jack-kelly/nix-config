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
      xssproxy # keeps xss-lock from firing mid-call; see i3.nix
      arandr
      playerctl
      brightnessctl
    ])
    ++ [
      # unstable's flameshot 14 hangs on xdg-desktop-portal; stable is 12.x
      pkgs-stable.flameshot
    ];

  services.dunst.enable = true;

  # i3 runs `autorandr --change` at startup (see i3.nix). Profiles are
  # per-host: laptops import ./autorandr.nix, desktops define their own.
  programs.autorandr = {
    enable = true;
    hooks.postswitch = {
      "restart-i3" = "i3-msg restart";
      "reset-wallpaper" = "feh --bg-fill ~/.config/wallpaper";
    };
  };
}
