{ pkgs, ... }:
{
  imports = [
    ./alacritty.nix
    ./firefox.nix
    ./zellij.nix
  ];

  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    discord
    obsidian
    signal-desktop
    spotify

    nerd-fonts.inconsolata
    nerd-fonts.fira-code
  ];
}
