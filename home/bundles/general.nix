{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: {
  nixpkgs = {
    config = {
      allowUnfree = true;
      experimental-features = "nix-command flakes";
    };
  };

  programs = {
    home-manager.enable = true;
    lazygit.enable = true;
    bat.enable = true;
  };

  myHomeManager = {
    zsh.enable = lib.mkDefault true;
    fish.enable = lib.mkDefault true;
    lf.enable = lib.mkDefault true;
    yazi.enable = lib.mkDefault true;
    nix-extra.enable = lib.mkDefault true;
    btop.enable = lib.mkDefault true;
    nix-direnv.enable = lib.mkDefault true;
    nix.enable = lib.mkDefault true;
    git.enable = lib.mkDefault true;
    stylix.enable = lib.mkDefault true;
  };

  services = {
    openssh.enable = true;
    flatpak.enable = true;
  };

  home.packages = with pkgs; [
    nil
    pistol
    file
    git
    p7zip
    unzip
    zip
    stow
    libqalculate
    imagemagick
    killall
    neovim

    fzf
    htop
    lf
    eza
    fd
    zoxide
    du-dust
    ripgrep
    neofetch

    ffmpeg
    wget

    yt-dlp
    tree-sitter

    nh
  ];

  home.sessionVariables = {
    FLAKE = "${config.home.homeDirectory}/nixconf";
  };
}
