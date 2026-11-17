{ config, pkgs, ... }:
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

  xdg.userDirs = {
    enable = true;
    createDirectories = false;
    download = "${config.home.homeDirectory}/Downloads";
  };

  home.packages = with pkgs; [
    discord
    evince
    obsidian
    signal-desktop
    spotify

    nerd-fonts.inconsolata
    nerd-fonts.fira-code
  ];
}
