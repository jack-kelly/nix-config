{ lib, pkgs, pkgs-stable, ... }: {
  imports = [
    ../modules/git.nix
    ../modules/eza.nix
    ../modules/fzf.nix
    ../modules/direnv.nix
    ../modules/zsh.nix
    ../modules/starship.nix
    # ../modules/alacritty.nix
    ../modules/zoxide.nix
  ];
  nixpkgs = {
    overlays = [];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  targets.genericLinux.enable = true;

  systemd.user.startServices = "sd-switch";

  fonts.fontconfig.enable = true;

  home = {
    username = "jack";
    homeDirectory = "/home/jack";
    stateVersion = "22.11";
    packages = with pkgs; [
      alacritty
      _1password-gui
      discord
      obsidian
      firefox
      spotify

      (nerdfonts.override { fonts = [ "Inconsolata" "FiraCode" ]; })

      _1password
      direnv
      difftastic
      eza
      fd
      fzf
      gitui
      helix
      htop
      jq
      killall
      lazygit
      p7zip
      ripgrep
      spotify-player
      tree
      unzip
      xclip
      xh
      xz
      yazi
      zellij    
    ];
  };

  xdg.enable = true;


  programs = {
    alacritty.enable = true;
    home-manager.enable = true;
    htop.enable = true;
    bat.enable = true;
    firefox.enable = true;
  };
}
